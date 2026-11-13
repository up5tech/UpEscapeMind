import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/domain/models/content/prerequisites.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/domain/rules/prerequisite_evaluator.dart';

Prerequisite pre(PrerequisiteType type, String targetId) =>
    Prerequisite(type: type, targetId: targetId);

void main() {
  group('prerequisitesMet', () {
    test('empty conditions are always met', () {
      expect(
        prerequisitesMet(const [], GameProgress(saveSlotId: 's1')),
        isTrue,
      );
    });

    test('roomUnlocked checks unlockedRoomIds', () {
      const progress = GameProgress(
        saveSlotId: 's1',
        unlockedRoomIds: ['room_a'],
      );
      expect(
        prerequisitesMet([
          pre(PrerequisiteType.roomUnlocked, 'room_a'),
        ], progress),
        isTrue,
      );
      expect(
        prerequisitesMet([
          pre(PrerequisiteType.roomUnlocked, 'room_b'),
        ], progress),
        isFalse,
      );
    });

    test('puzzleSolved / itemCollected / itemConsumed / clueDiscovered / '
        'chapterCompleted', () {
      const progress = GameProgress(
        saveSlotId: 's1',
        solvedPuzzleIds: ['puz_1'],
        collectedItemIds: ['item_1'],
        consumedItemIds: ['item_0'],
        discoveredClueIds: ['clue_1'],
        completedChapterIds: ['ch_1'],
      );
      expect(
        prerequisitesMet([
          pre(PrerequisiteType.puzzleSolved, 'puz_1'),
          pre(PrerequisiteType.itemCollected, 'item_1'),
          pre(PrerequisiteType.itemConsumed, 'item_0'),
          pre(PrerequisiteType.clueDiscovered, 'clue_1'),
          pre(PrerequisiteType.chapterCompleted, 'ch_1'),
        ], progress),
        isTrue,
      );
      expect(
        prerequisitesMet([
          pre(PrerequisiteType.itemCollected, 'item_0'),
        ], progress),
        isFalse,
        reason: 'consumed items are no longer collected',
      );
    });

    test('all conditions must hold (AND semantics)', () {
      const progress = GameProgress(
        saveSlotId: 's1',
        unlockedRoomIds: ['room_a'],
      );
      expect(
        prerequisitesMet([
          pre(PrerequisiteType.roomUnlocked, 'room_a'),
          pre(PrerequisiteType.puzzleSolved, 'puz_missing'),
        ], progress),
        isFalse,
      );
    });
  });
}
