import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/progress_actions.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/models/content/content_models.dart';
import '../../domain/validators/puzzle_validator.dart';
import '../../domain/validators/puzzle_validator_factory.dart';

/// Shared building blocks for the Phase 7 puzzle-family UIs.

/// Outcome of one submission: the verdict plus any chapters that became
/// completed by this exact solve (drives the one-time chapter summary).
class PuzzleAttemptResult {
  const PuzzleAttemptResult({
    required this.verdict,
    required this.newlyCompletedChapterIds,
  });

  final PuzzleVerdict verdict;
  final List<String> newlyCompletedChapterIds;
}

/// Submits [input] for [puzzle]. On [PuzzleVerdict.correct] the durable
/// mutation goes through [ProgressActions.solvePuzzle], which is idempotent
/// — reopening a solved puzzle can never grant rewards twice, and a
/// chapter completion is granted exactly once.
Future<PuzzleAttemptResult> submitPuzzleAttempt(
  BuildContext context,
  WidgetRef ref,
  PuzzleDefinition puzzle,
  Object? input,
) async {
  final verdict = buildPuzzleValidator(puzzle).evaluateInput(input);
  if (verdict != PuzzleVerdict.correct) {
    if (verdict == PuzzleVerdict.incorrect) {
      await _playHaptic(ref, HapticFeedback.lightImpact);
    }
    return PuzzleAttemptResult(
      verdict: verdict,
      newlyCompletedChapterIds: const [],
    );
  }
  await _playHaptic(ref, HapticFeedback.mediumImpact);
  final completed = await ref
      .read(progressActionsProvider)
      .solvePuzzle(puzzle.id, puzzle.successActions);
  return PuzzleAttemptResult(
    verdict: verdict,
    newlyCompletedChapterIds: completed,
  );
}

Future<void> _playHaptic(
  WidgetRef ref,
  Future<void> Function() feedback,
) async {
  try {
    if (await ref.read(settingsRepositoryProvider).isHapticsEnabled()) {
      await feedback();
    }
  } on Object {
    // Haptics are optional; unsupported devices must not interrupt gameplay.
  }
}

/// Shows the solved snackbar, leaves the puzzle screen — and when this
/// solve completed a chapter, REPLACES the puzzle route with that
/// chapter's summary (opened exactly once, on the same navigation frame
/// so the pop+push cannot race).
Future<void> finishPuzzleSolved(
  BuildContext context, {
  List<String> newlyCompletedChapterIds = const [],
}) async {
  final l10n = AppLocalizations.of(context);
  final go = GoRouter.of(context);
  final navigator = Navigator.of(context);
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(l10n.puzzleSolvedMessage)));
  if (newlyCompletedChapterIds.isNotEmpty) {
    unawaited(
      go.replaceNamed(
        'chapterSummary',
        pathParameters: {'chapterId': newlyCompletedChapterIds.first},
      ),
    );
  } else if (navigator.mounted) {
    navigator.pop();
  }
}

/// Transient "not quite right" line. Removed from the tree when hidden so
/// tests (and screen readers) never see a stale message.
class PuzzleFeedback extends StatelessWidget {
  const PuzzleFeedback({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        l10n.puzzleIncorrectMessage,
        key: const ValueKey('puzzle_feedback'),
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.clockRed),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Check / Reset action row used by the confirm-style families
/// (rotation, logic deduction, mechanical state).
class PuzzleActionRow extends StatelessWidget {
  const PuzzleActionRow({
    super.key,
    required this.onCheck,
    required this.onReset,
  });

  final VoidCallback onCheck;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            key: const ValueKey('puzzle_check'),
            label: l10n.puzzleCheck,
            onPressed: onCheck,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            key: const ValueKey('puzzle_reset'),
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.parchmentText,
              side: BorderSide(color: AppColors.brass.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.puzzleReset),
          ),
        ),
      ],
    );
  }
}

/// Puzzle instructions header shared by every family screen.
class PuzzleInstructions extends StatelessWidget {
  const PuzzleInstructions({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }
}

/// Scrollable column body with consistent padding for puzzle screens.
class PuzzleBody extends StatelessWidget {
  const PuzzleBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Resolves a display label for a content id (symbol, candidate, region)
/// from the puzzle's `initialState.labelKeys` map, localized through the
/// content strings table [s]. Falls back to the raw id in debug.
String idLabel(
  Map<String, dynamic> initialState,
  String id,
  String Function(String) s,
) {
  final raw = initialState['labelKeys'];
  if (raw is Map<String, dynamic>) {
    final key = raw[id];
    if (key is String && key.isNotEmpty) return s(key);
  }
  return id;
}
