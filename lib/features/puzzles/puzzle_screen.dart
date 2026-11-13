import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/providers/app_providers.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/models/content/content_models.dart';
import '../../domain/rules/prerequisite_evaluator.dart';
import 'families/keypad_puzzle.dart';
import 'families/lever_puzzle.dart';
import 'families/logic_deduction_puzzle.dart';
import 'families/rotation_puzzle.dart';
import 'families/sequence_puzzle.dart';
import 'families/symbol_matching_puzzle.dart';
import 'families/tap_region_puzzle.dart';
import 'puzzle_sessions.dart';

/// Entry point of the reusable puzzle engine (Phase 7).
///
/// Resolves the puzzle from the validated content catalog, gates it by
/// prerequisites and solved state, then dispatches to the family UI.
/// Puzzle rules live in pure-Dart validators under `domain/validators/`,
/// never in this widget or in room widgets.
class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, required this.puzzleId});

  final String puzzleId;

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  bool _resetOnExit = false;
  bool _resetPolicySeen = false;
  late final PuzzleSessions _sessions;

  @override
  void initState() {
    super.initState();
    // Capture now: `ref` must not be used from dispose (Riverpod rule).
    _sessions = ref.read(puzzleSessionsProvider.notifier);
  }

  @override
  void dispose() {
    // PLAN §4.5 / puzzle resetPolicy: `reset_on_exit` puzzles must not
    // leak partial input into the next visit. Provider writes are not
    // allowed from widget lifecycle callbacks, so the clear is posted to
    // the end of the frame that removes the screen.
    if (_resetPolicySeen && _resetOnExit) {
      final puzzleId = widget.puzzleId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _sessions.clearInput(puzzleId);
        } on Object {
          // The provider container is already gone (app/test teardown) —
          // the session dies with it anyway.
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(contentCatalogProvider);
    final stringsAsync = ref.watch(contentStringsProvider);
    final progressAsync = ref.watch(gameProgressProvider);
    final locale = ref.watch(appLocaleProvider)?.languageCode ?? 'vi';

    final catalog = catalogAsync.value;
    final strings = stringsAsync.value;
    if (catalog == null ||
        strings == null ||
        progressAsync.isLoading ||
        progressAsync.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = progressAsync.value!;
    final puzzle = catalog.puzzlesById[widget.puzzleId];

    if (puzzle == null) {
      return AppScaffold(
        title: l10n.errorGeneric,
        showBackButton: true,
        body: Center(child: Text(l10n.errorGeneric)),
      );
    }

    _resetPolicySeen = true;
    _resetOnExit = puzzle.resetPolicy == ResetPolicy.resetOnExit;

    String s(String key) => strings.forLocale(locale, key);

    if (progress.isPuzzleSolved(puzzle.id)) {
      return AppScaffold(
        title: s(puzzle.titleKey),
        showBackButton: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.puzzleSolvedMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!prerequisitesMet(puzzle.prerequisites, progress)) {
      return AppScaffold(
        title: s(puzzle.titleKey),
        showBackButton: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.puzzleLockedMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return switch (puzzle.type) {
      PuzzleType.keypad => KeypadPuzzle(puzzle: puzzle, s: s),
      PuzzleType.symbolMatching =>
        SymbolMatchingPuzzle(puzzle: puzzle, s: s),
      PuzzleType.sequence => SequencePuzzle(puzzle: puzzle, s: s),
      PuzzleType.rotation => RotationPuzzle(puzzle: puzzle, s: s),
      PuzzleType.logicDeduction =>
        LogicDeductionPuzzle(puzzle: puzzle, s: s),
      PuzzleType.mechanicalState => LeverPuzzle(puzzle: puzzle, s: s),
      PuzzleType.hiddenObject ||
      PuzzleType.observation => TapRegionPuzzle(puzzle: puzzle, s: s),
      PuzzleType.itemUse ||
      PuzzleType.itemCombination =>
        AppScaffold(
          title: s(puzzle.titleKey),
          showBackButton: true,
          body: Center(child: Text(l10n.errorGeneric)),
        ),
    };
  }
}
