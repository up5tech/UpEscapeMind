import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../../../domain/validators/symbol_order_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `symbol_matching` family UI: one slot per dial/ring, each picking a
/// symbol from the authored palette. The puzzle auto-checks when every
/// slot is filled; input persists within the session per resetPolicy.
class SymbolMatchingPuzzle extends ConsumerStatefulWidget {
  const SymbolMatchingPuzzle({
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
  ConsumerState<SymbolMatchingPuzzle> createState() =>
      _SymbolMatchingPuzzleState();
}

class _SymbolMatchingPuzzleState extends ConsumerState<SymbolMatchingPuzzle> {
  late final SymbolOrderValidator _validator;
  late final List<String?> _picks;
  bool _wrong = false;
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    _validator = SymbolOrderValidator.parse(
      solutionConfig: widget.puzzle.solutionConfig,
      validationConfig: widget.puzzle.validationConfig,
      where: 'puzzle "${widget.puzzle.id}"',
    );
    _picks = List<String?>.filled(_validator.slotCount, null);
    final stored = ref.read(puzzleSessionsProvider.notifier).inputFor(
      widget.puzzle.id,
    );
    if (stored is List<String?> && stored.length == _validator.slotCount) {
      for (var i = 0; i < _picks.length; i++) {
        final pick = stored[i];
        if (pick != null && _validator.choices.contains(pick)) {
          _picks[i] = pick;
        }
      }
    }
  }

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, List<String?>.unmodifiable(_picks));
  }

  Future<void> _pick(int slot) async {
    if (_solved) return;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.charcoal,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final choice in _validator.choices)
              ListTile(
                key: ValueKey('symbol_option_$choice'),
                title: Text(
                  idLabel(widget.puzzle.initialState, choice, widget.s),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.parchmentText),
                ),
                onTap: () => Navigator.of(sheetContext).pop(choice),
              ),
            ListTile(
              title: Text(
                AppLocalizations.of(sheetContext).commonClose,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _wrong = false;
      _picks[slot] = chosen;
      if (!_validator.allowDuplicates) {
        // A symbol used elsewhere moves here instead of duplicating.
        for (var i = 0; i < _picks.length; i++) {
          if (i != slot && _picks[i] == chosen) _picks[i] = null;
        }
      }
    });
    _syncSession();
  }

  Future<void> _submit() async {
    final result = await submitPuzzleAttempt(
      context,
      ref,
      widget.puzzle,
      List<String?>.unmodifiable(_picks),
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
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _picks.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        key: ValueKey('symbol_slot_$i'),
                        onTap: _solved ? null : () => _pick(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 76,
                          height: 76,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.charcoal,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _picks[i] == null
                                  ? AppColors.secondaryText
                                  : AppColors.brass,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            key: ValueKey('symbol_slot_text_$i'),
                            _picks[i] == null
                                ? '·'
                                : idLabel(
                                    widget.puzzle.initialState,
                                    _picks[i]!,
                                    widget.s,
                                  ),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: _picks[i] == null
                                  ? AppColors.disabledText
                                  : AppColors.parchmentText,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              PuzzleFeedback(visible: _wrong),
              const SizedBox(height: 16),
              PuzzleActionRow(
                onCheck: _submit,
                onReset: () {
                  setState(() {
                    _wrong = false;
                    for (var i = 0; i < _picks.length; i++) {
                      _picks[i] = null;
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
