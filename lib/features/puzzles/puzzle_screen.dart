import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/models/content/content_models.dart';
import '../../domain/rules/prerequisite_evaluator.dart';
import '../hints/hint_sheet.dart';
import 'families/keypad_puzzle.dart';
import 'families/lever_puzzle.dart';
import 'families/logic_deduction_puzzle.dart';
import 'families/rotation_puzzle.dart';
import 'families/sequence_puzzle.dart';
import 'families/symbol_matching_puzzle.dart';
import 'families/tap_region_puzzle.dart';
import 'puzzle_sessions.dart';

/// Entry point of the reusable puzzle engine (Phase 7) and the hint
/// access point (Phase 8).
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

    /// Hints are always available for unsolved puzzles — including locked
    /// ones, so a stuck player can always get a nudge (PLAN §6.2: never
    /// block, never punish).
    Widget? hintAction;
    if (!progress.isPuzzleSolved(puzzle.id)) {
      hintAction = IconButton(
        key: const ValueKey('puzzle_hint_action'),
        icon: const Icon(Icons.lightbulb_outline, color: AppColors.brass),
        tooltip: l10n.hintsAction,
        onPressed: () => showHintSheet(context, puzzle),
      );
    }

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

    final unmet = unmetPrerequisites(puzzle.prerequisites, progress);
    if (unmet.isNotEmpty) {
      return AppScaffold(
        title: s(puzzle.titleKey),
        showBackButton: true,
        actions: [hintAction!],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.puzzleLockedMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Explain WHAT KIND of discovery is still needed, without
                // exposing the solution (PLAN §6.3).
                for (final condition in unmet)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      _prerequisiteHint(l10n, condition),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return switch (puzzle.type) {
      PuzzleType.keypad => KeypadPuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.symbolMatching =>
        SymbolMatchingPuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.sequence =>
        SequencePuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.rotation =>
        RotationPuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.logicDeduction =>
        LogicDeductionPuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.mechanicalState =>
        LeverPuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.hiddenObject ||
      PuzzleType.observation =>
        TapRegionPuzzle(puzzle: puzzle, s: s, hintAction: hintAction),
      PuzzleType.itemUse ||
      PuzzleType.itemCombination =>
        AppScaffold(
          title: s(puzzle.titleKey),
          showBackButton: true,
          actions: [hintAction!],
          body: Center(child: Text(l10n.errorGeneric)),
        ),
    };
  }

  static String _prerequisiteHint(
    AppLocalizations l10n,
    Prerequisite condition,
  ) {
    return switch (condition.type) {
      PrerequisiteType.puzzleSolved => l10n.prereqMissingPuzzle,
      PrerequisiteType.itemCollected => l10n.prereqMissingItem,
      PrerequisiteType.itemConsumed => l10n.prereqMissingItemUse,
      PrerequisiteType.clueDiscovered => l10n.prereqMissingClue,
      PrerequisiteType.roomUnlocked => l10n.prereqMissingArea,
      PrerequisiteType.chapterCompleted => l10n.prereqMissingChapter,
    };
  }
}
