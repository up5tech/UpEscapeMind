import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/lever_pattern_validator.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `mechanical_state` family UI: levers/switches that flip freely; only
/// the exact full pattern completes. Wrong confirmation never moves any
/// lever.
class LeverPuzzle extends ConsumerStatefulWidget {
  const LeverPuzzle({super.key, required this.puzzle, required this.s});

  final PuzzleDefinition puzzle;
  final String Function(String) s;

  @override
  ConsumerState<LeverPuzzle> createState() => _LeverPuzzleState();
}

class _LeverPuzzleState extends ConsumerState<LeverPuzzle> {
  late final LeverPatternValidator _validator;
  late final List<bool> _states;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _validator = LeverPatternValidator.parse(
      initialState: widget.puzzle.initialState,
      solutionConfig: widget.puzzle.solutionConfig,
      where: 'puzzle "${widget.puzzle.id}"',
    );
    _states = List<bool>.from(_validator.startState);
    final stored = ref.read(puzzleSessionsProvider.notifier).inputFor(
      widget.puzzle.id,
    );
    if (stored is List<bool> && stored.length == _states.length) {
      for (var i = 0; i < stored.length; i++) {
        _states[i] = stored[i];
      }
    }
  }

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, List<bool>.unmodifiable(_states));
  }

  void _flip(int index) {
    if (_solved) return;
    setState(() {
      _wrong = false;
      _states[index] = !_states[index];
    });
    _syncSession();
  }

  Future<void> _submit() async {
    final verdict = await submitPuzzleAttempt(
      context,
      ref,
      widget.puzzle,
      List<bool>.unmodifiable(_states),
    );
    if (!mounted) return;
    if (verdict == PuzzleVerdict.correct) {
      setState(() => _solved = true);
      await finishPuzzleSolved(context);
    } else if (verdict == PuzzleVerdict.incorrect) {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: widget.s(widget.puzzle.titleKey),
      showBackButton: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              PuzzleInstructions(
                text: widget.s(widget.puzzle.instructionsKey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _states.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Semantics(
                        label:
                            '${idLabel(widget.puzzle.initialState, 'lever_$i', widget.s)} '
                            '${_states[i] ? l10n.leverUp : l10n.leverDown}',
                        button: true,
                        child: InkWell(
                          key: ValueKey('lever_$i'),
                          onTap: () => _flip(i),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 64,
                            height: 128,
                            decoration: BoxDecoration(
                              color: AppColors.charcoal,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _states[i]
                                    ? AppColors.brass
                                    : AppColors.secondaryText,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _states[i]
                                  ? Icons.arrow_circle_up
                                  : Icons.arrow_circle_down,
                              size: 40,
                              color: _states[i]
                                  ? AppColors.brass
                                  : AppColors.disabledText,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              PuzzleFeedback(visible: _wrong),
              const SizedBox(height: 8),
              PuzzleActionRow(
                onCheck: _submit,
                onReset: () {
                  setState(() {
                    _wrong = false;
                    _states
                      ..clear()
                      ..addAll(_validator.startState);
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
