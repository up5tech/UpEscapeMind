import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../../../domain/validators/sequence_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `sequence` family UI: tap candidates in the intended order. Tapping a
/// placed slot removes it again. Checked explicitly via the Check action.
class SequencePuzzle extends ConsumerStatefulWidget {
  const SequencePuzzle({
    super.key,
    required this.puzzle,
    required this.s,
    this.hintAction,
    this.guide,
  });

  final PuzzleDefinition puzzle;
  final String Function(String) s;

  /// AppBar lightbulb action opened by [PuzzleScreen] (Phase 8).
  final Widget? hintAction;

  /// One-line controls hint under the instructions.
  final String? guide;

  @override
  ConsumerState<SequencePuzzle> createState() => _SequencePuzzleState();
}

class _SequencePuzzleState extends ConsumerState<SequencePuzzle> {
  late final SequenceValidator _validator;
  late final List<String> _picks;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _validator = SequenceValidator.parse(
      solutionConfig: widget.puzzle.solutionConfig,
      where: 'puzzle "${widget.puzzle.id}"',
    );
    _picks = <String>[];
    final stored = ref
        .read(puzzleSessionsProvider.notifier)
        .inputFor(widget.puzzle.id);
    if (stored is List<String>) {
      for (final pick in stored) {
        if (_validator.candidates.contains(pick) && !_picks.contains(pick)) {
          _picks.add(pick);
        }
      }
    }
  }

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, List<String>.unmodifiable(_picks));
  }

  void _add(String candidate) {
    if (_solved || _picks.contains(candidate)) return;
    setState(() {
      _wrong = false;
      _picks.add(candidate);
    });
    _syncSession();
  }

  void _removeAt(int index) {
    if (_solved) return;
    setState(() {
      _wrong = false;
      _picks.removeAt(index);
    });
    _syncSession();
  }

  Future<void> _submit() async {
    final result = await submitPuzzleAttempt(
      context,
      ref,
      widget.puzzle,
      List<String>.unmodifiable(_picks),
    );
    if (!mounted) return;
    if (result.verdict == PuzzleVerdict.correct) {
      setState(() => _solved = true);
      await finishPuzzleSolved(
        context,
        newlyCompletedChapterIds: result.newlyCompletedChapterIds,
      );
    } else if (result.verdict == PuzzleVerdict.incorrect) {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: widget.s(widget.puzzle.titleKey),
      showBackButton: true,
      actions: [if (widget.hintAction != null) widget.hintAction!],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              PuzzleInstructions(
                text: widget.s(widget.puzzle.instructionsKey),
                guide: widget.guide,
              ),
              const SizedBox(height: 24),
              // Ordered slots.
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _validator.order.length; i++)
                    _SequenceChip(
                      key: ValueKey('sequence_slot_$i'),
                      label: i < _picks.length
                          ? idLabel(
                              widget.puzzle.initialState,
                              _picks[i],
                              widget.s,
                            )
                          : '·',
                      filled: i < _picks.length,
                      onTap: i < _picks.length ? () => _removeAt(i) : null,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_picks.length}/${_validator.order.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              PuzzleFeedback(visible: _wrong),
              const SizedBox(height: 8),
              // Candidates.
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final candidate in _validator.candidates)
                    _SequenceChip(
                      key: ValueKey('sequence_candidate_$candidate'),
                      label: idLabel(
                        widget.puzzle.initialState,
                        candidate,
                        widget.s,
                      ),
                      filled: false,
                      dimmed: _picks.contains(candidate),
                      onTap: _picks.contains(candidate)
                          ? null
                          : () => _add(candidate),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              PuzzleActionRow(
                onCheck: _submit,
                onReset: () {
                  setState(() {
                    _wrong = false;
                    _picks.clear();
                  });
                  ref
                      .read(puzzleSessionsProvider.notifier)
                      .clearInput(widget.puzzle.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SequenceChip extends StatelessWidget {
  const _SequenceChip({
    super.key,
    required this.label,
    required this.filled,
    this.dimmed = false,
    this.onTap,
  });

  final String label;
  final bool filled;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: dimmed ? 0.35 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: filled ? AppColors.brass : AppColors.secondaryText,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.parchmentText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
