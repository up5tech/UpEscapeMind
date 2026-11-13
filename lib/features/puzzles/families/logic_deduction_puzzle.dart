import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/logic_deduction_validator.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `logic_deduction` family UI: several typed entry fields compared
/// together (the orrery's three time rings + year ring).
class LogicDeductionPuzzle extends ConsumerStatefulWidget {
  const LogicDeductionPuzzle({
    super.key,
    required this.puzzle,
    required this.s,
    this.hintAction,
  });

  final PuzzleDefinition puzzle;
  final String Function(String) s;

  /// AppBar lightbulb action opened by [PuzzleScreen] (Phase 8).
  final Widget? hintAction;

  @override
  ConsumerState<LogicDeductionPuzzle> createState() =>
      _LogicDeductionPuzzleState();
}

class _LogicDeductionPuzzleState extends ConsumerState<LogicDeductionPuzzle> {
  late final LogicDeductionValidator _validator;
  late final Map<String, TextEditingController> _controllers;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _validator = LogicDeductionValidator.parse(
      initialState: widget.puzzle.initialState,
      solutionConfig: widget.puzzle.solutionConfig,
      where: 'puzzle "${widget.puzzle.id}"',
    );
    final stored = ref.read(puzzleSessionsProvider.notifier).inputFor(
      widget.puzzle.id,
    );
    final values = stored is Map<String, String>
        ? stored
        : const <String, String>{};
    _controllers = {
      for (final field in _validator.fields)
        field.id: TextEditingController(text: values[field.id] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _currentInput() => {
    for (final e in _controllers.entries) e.key: e.value.text,
  };

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, Map<String, String>.of(_currentInput()));
  }

  Future<void> _submit() async {
    final result = await submitPuzzleAttempt(
      context,
      ref,
      widget.puzzle,
      Map<String, String>.of(_currentInput()),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PuzzleInstructions(
                text: widget.s(widget.puzzle.instructionsKey),
              ),
              const SizedBox(height: 24),
              for (final field in _validator.fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    key: ValueKey('deduction_field_${field.id}'),
                    controller: _controllers[field.id],
                    enabled: !_solved,
                    keyboardType: field.kind == 'digits'
                        ? TextInputType.number
                        : TextInputType.text,
                    maxLength: field.maxLength > 0 ? field.maxLength : null,
                    inputFormatters: [
                      if (field.kind == 'digits')
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9 ]'),
                        )
                      else
                        LengthLimitingTextInputFormatter(
                          field.maxLength > 0 ? field.maxLength : 64,
                        ),
                    ],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.parchmentText,
                    ),
                    onChanged: (_) {
                      setState(() => _wrong = false);
                      _syncSession();
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: widget.s(field.labelKey),
                      labelStyle: const TextStyle(
                        color: AppColors.secondaryText,
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.brass.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              PuzzleFeedback(visible: _wrong),
              const SizedBox(height: 16),
              PuzzleActionRow(
                onCheck: _submit,
                onReset: () {
                  setState(() {
                    _wrong = false;
                    for (final c in _controllers.values) {
                      c.clear();
                    }
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
