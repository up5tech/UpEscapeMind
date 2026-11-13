import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/constants/app_constants.dart';
import 'package:up_escape_mind/data/content/content_loader.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/content/hotspot_definition.dart';
import 'package:up_escape_mind/domain/models/content/item_combination_definition.dart';
import 'package:up_escape_mind/domain/models/content/prerequisites.dart';
import 'package:up_escape_mind/domain/models/content/puzzle_definition.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/domain/rules/chapter_rating.dart';
import 'package:up_escape_mind/domain/rules/prerequisite_evaluator.dart';
import 'package:up_escape_mind/domain/use_cases/progress_reducer.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator_factory.dart';

/// Phase 9 acceptance: the shipped Chapter 1 content is fully solvable
/// with no soft locks. A "player who does everything discoverable"
/// simulation runs against the REAL production content (manifest.json)
/// and the REAL engine validators — every puzzle is only marked solved
/// when its authored solution passes `buildPuzzleValidator`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentCatalog catalog;

  setUpAll(() async {
    catalog = await const ContentLoader().load(
      assetExists: (path) async {
        try {
          await rootBundle.load(path);
          return true;
        } catch (_) {
          return false;
        }
      },
    );
  });

  /// The authored winning input for a puzzle, rebuilt from its own
  /// solutionConfig — proves the spec solution validates in the engine.
  Object? authoredSolutionInput(PuzzleDefinition p) {
    switch (p.type) {
      case PuzzleType.keypad:
        return p.solutionConfig['code'] as String;
      case PuzzleType.symbolMatching:
        return (p.solutionConfig['symbols'] as List)
            .cast<String?>();
      case PuzzleType.sequence:
        return (p.solutionConfig['order'] as List).cast<String>();
      case PuzzleType.rotation:
        return (p.solutionConfig['steps'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      case PuzzleType.logicDeduction:
        return Map<String, String>.from(p.solutionConfig['answer'] as Map);
      case PuzzleType.mechanicalState:
        return (p.solutionConfig['targetState'] as List).cast<bool>();
      case PuzzleType.hiddenObject:
        final regions = (p.solutionConfig['regions'] as List)
            .cast<Map<String, dynamic>>();
        final targetId = p.solutionConfig['targetId'] as String;
        final r = regions.firstWhere((e) => e['id'] == targetId);
        return TapPoint(
          (r['x'] as num).toDouble() + (r['width'] as num).toDouble() / 2,
          (r['y'] as num).toDouble() + (r['height'] as num).toDouble() / 2,
        );
      case PuzzleType.observation:
        return (p.solutionConfig['targets'] as List).cast<String>();
      case PuzzleType.itemUse:
      case PuzzleType.itemCombination:
        return null;
    }
  }

  GameProgress settle(GameProgress start) {
    var p = start;
    bool changed;
    final guard = <String>{}; // solved set snapshot for loop detection

    String snapshot(GameProgress g) => jsonEncode(g.toJson());

    do {
      changed = false;

      // 1. Every discoverable clue in an unlocked room, once its
      //    visibility conditions hold (a thorough player inspects all).
      for (final room in catalog.rooms.where(
            (r) => p.isRoomUnlocked(r.id) || r.id == 'room_entrance',
          )) {
        for (final h in room.hotspots) {
          if (h.interactionType == HotspotInteraction.discoverClue &&
              prerequisitesMet(h.visibilityConditions, p) &&
              h.targetId != null &&
              !p.discoveredClueIds.contains(h.targetId)) {
            p = p.copyWith(
              discoveredClueIds: [...p.discoveredClueIds, h.targetId!],
            );
            changed = true;
          }
          if (h.interactionType == HotspotInteraction.useItem &&
              prerequisitesMet(h.visibilityConditions, p) &&
              h.acceptedItemIds.every(p.hasItem)) {
            final before = snapshot(p);
            var next = p;
            for (final a in h.successActions) {
              next = applySuccessAction(next, a);
            }
            if (h.consumeItemOnUse) {
              for (final id in h.acceptedItemIds) {
                next = applySuccessAction(
                  next,
                  SuccessAction(
                    type: SuccessActionType.consumeItem,
                    targetId: id,
                  ),
                );
              }
            }
            if (snapshot(next) != before) {
              p = next;
              changed = true;
            }
          }
        }
      }

      // 2. All defined combinations whose inputs are held.
      for (final recipe in catalog.combinations) {
        final before = snapshot(p);
        final next = applyCombination(
          p: p,
          inputItemIds: recipe.inputItemIds,
          resultItemId: recipe.resultItemId,
          consumeInputItems: recipe.consumeInputItems,
        );
        if (snapshot(next) != before) {
          p = next;
          changed = true;
        }
      }

      // 3. Every puzzle whose room is reachable and prerequisites hold.
      for (final puzzle in catalog.puzzles) {
        final roomReachable =
            p.isRoomUnlocked(puzzle.roomId) || puzzle.roomId == 'room_entrance';
        if (!roomReachable ||
            p.isPuzzleSolved(puzzle.id) ||
            !prerequisitesMet(puzzle.prerequisites, p)) {
          continue;
        }
        // The engine must accept the authored solution.
        final verdict = buildPuzzleValidator(puzzle)
            .evaluateInput(authoredSolutionInput(puzzle));
        expect(verdict, PuzzleVerdict.correct,
            reason: '${puzzle.id} authored solution must validate');
        p = applyPuzzleSolve(p, puzzle.id, puzzle.successActions);
        changed = true;
      }

      guard.add(snapshot(p));
    } while (changed);

    return p;
  }

  test('Chapter 1 is fully solvable from a fresh save (no soft locks)', () {
    final fresh = GameProgress.newGame(
      AppConstants.defaultSaveSlotId,
      'room_entrance',
    );
    final done = settle(fresh);

    // All 19 puzzles solved, all 25 clues journaled, chapter completed.
    expect(done.solvedPuzzleIds.toSet(),
        catalog.puzzles.map((p) => p.id).toSet());
    expect(done.discoveredClueIds.toSet(),
        catalog.clues.map((c) => c.id).toSet());
    expect(done.completedChapterIds, ['chapter_01']);
    // The combine consumed lens + frame; the telescope finale consumed
    // the assembled focusing lens (the one intentional in-game use).
    expect(
      done.consumedItemIds.toSet(),
      containsAll(['item_lens', 'item_brass_frame', 'item_focus_lens']),
    );
    expect(done.hasItem('item_lens'), isFalse);
    expect(done.hasItem('item_focus_lens'), isFalse);
    expect(done.hasItem('item_clock_key'), isTrue); // retained winding key
    expect(done.hasItem('item_crank'), isTrue); // retained winch handle
  });

  test('replaying every action is idempotent', () {
    final fresh = GameProgress.newGame(
      AppConstants.defaultSaveSlotId,
      'room_entrance',
    );
    final done = settle(fresh);
    final replayed = settle(done);
    expect(jsonEncode(replayed.toJson()), jsonEncode(done.toJson()));
    expect(replayed.completedChapterIds.length, 1);
    expect(replayed.solvedPuzzleIds.length, catalog.puzzles.length);
  });

  test('full completion earns 3 stars and the no-walkthrough badge', () {
    final fresh = GameProgress.newGame(
      AppConstants.defaultSaveSlotId,
      'room_entrance',
    );
    final done = settle(fresh);
    final rating = rateChapter(
      chapter: catalog.chapters.single,
      catalog: catalog,
      progress: done,
    );
    expect(rating.stars, 3);
    expect(rating.noWalkthroughBadge, isTrue);
    expect(rating.rooms.every((r) => r.isComplete), isTrue);
  });

  test('hints exist at all three levels for every puzzle', () {
    for (final puzzle in catalog.puzzles) {
      expect(puzzle.hints.length, 3, reason: puzzle.id);
      expect(puzzle.hints.map((h) => h.level).toList(), [1, 2, 3]);
    }
  });

  test('every combination and required item chain is obtainable', () {
    // item_focus_lens ← comb of lens (books) + frame (floorboard);
    // both feed puzzles exist and their prerequisites are satisfiable.
    final lensSource = catalog.puzzles
        .where((p) => p.successActions.any(
              (a) =>
                  a.type == SuccessActionType.collectItem &&
                  a.targetId == 'item_lens',
            ));
    expect(lensSource, isNotEmpty);
    final frameSource = catalog.puzzles
        .where((p) => p.successActions.any(
              (a) =>
                  a.type == SuccessActionType.collectItem &&
                  a.targetId == 'item_brass_frame',
            ));
    expect(frameSource, isNotEmpty);
  });

  test('prerequisite targets all reference existing content', () {
    for (final puzzle in catalog.puzzles) {
      for (final pre in puzzle.prerequisites) {
        switch (pre.type) {
          case PrerequisiteType.puzzleSolved:
            expect(catalog.puzzlesById.containsKey(pre.targetId), isTrue,
                reason: pre.targetId);
          case PrerequisiteType.itemCollected:
          case PrerequisiteType.itemConsumed:
            expect(catalog.itemsById.containsKey(pre.targetId), isTrue,
                reason: pre.targetId);
          case PrerequisiteType.clueDiscovered:
            expect(catalog.cluesById.containsKey(pre.targetId), isTrue,
                reason: pre.targetId);
          case PrerequisiteType.roomUnlocked:
            expect(catalog.roomsById.containsKey(pre.targetId), isTrue,
                reason: pre.targetId);
          case PrerequisiteType.chapterCompleted:
            expect(catalog.chaptersById.containsKey(pre.targetId), isTrue,
                reason: pre.targetId);
        }
      }
    }
  });

  test('item_combination definitions parse with engine expectations', () {
    final ItemCombinationDefinition? recipe =
        catalog.combinationsById['comb_focus_lens'];
    expect(recipe, isNotNull);
    expect(recipe!.inputItemIds, ['item_lens', 'item_brass_frame']);
    expect(recipe.consumeInputItems, isTrue);
  });
}
