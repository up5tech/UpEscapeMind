import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/models/content/content_models.dart';
import '../../../domain/validators/keypad_validator.dart';
import '../../../domain/validators/puzzle_validator.dart';
import '../puzzle_sessions.dart';
import '../puzzle_widgets.dart';

/// `keypad` family UI. Entirely driven by the puzzle definition through
/// [KeypadValidator]: `initialState.digits`, `solutionConfig.code`,
/// `validationConfig.allowLeadingZero`. Input is mirrored into the
/// transient puzzle session so `resetPolicy: "keep"` restores it.
class KeypadPuzzle extends ConsumerStatefulWidget {
  const KeypadPuzzle({super.key, required this.puzzle, required this.s});

  final PuzzleDefinition puzzle;
  final String Function(String) s;

  @override
  ConsumerState<KeypadPuzzle> createState() => _KeypadPuzzleState();
}

class _KeypadPuzzleState extends ConsumerState<KeypadPuzzle> {
  late final KeypadValidator _validator;
  late final List<String> _entered;
  bool _wrong = false;
  bool _solving = false;

  @override
  void initState() {
    super.initState();
    _validator = KeypadValidator.parse(
      initialState: widget.puzzle.initialState,
      solutionConfig: widget.puzzle.solutionConfig,
      validationConfig: widget.puzzle.validationConfig,
      where: 'puzzle "${widget.puzzle.id}"',
    );
    final stored = ref.read(puzzleSessionsProvider.notifier).inputFor(
      widget.puzzle.id,
    );
    _entered = stored is String && stored.isNotEmpty && isDigitString(stored)
        ? stored.split('')
        : <String>[];
  }

  bool get _complete => _entered.length == _validator.digits;

  void _press(String digit) {
    if (_solving || _complete) return;
    setState(() {
      _wrong = false;
      _entered.add(digit);
    });
    _syncSession();
    if (_complete) _check();
  }

  void _delete() {
    if (_solving || _entered.isEmpty) return;
    setState(() {
      _wrong = false;
      _entered.removeLast();
    });
    _syncSession();
  }

  void _clear() {
    if (_solving) return;
    setState(() {
      _wrong = false;
      _entered.clear();
    });
    _syncSession();
  }

  void _syncSession() {
    ref
        .read(puzzleSessionsProvider.notifier)
        .setInput(widget.puzzle.id, _entered.join());
  }

  Future<void> _check() async {
    final verdict = await submitPuzzleAttempt(
      context,
      ref,
      widget.puzzle,
      _entered.join(),
    );
    if (!mounted) return;
    if (verdict == PuzzleVerdict.correct) {
      setState(() => _solving = true);
      await finishPuzzleSolved(context);
    } else {
      setState(() {
        _wrong = true;
        _entered.clear();
      });
      _syncSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppScaffold(
      title: widget.s(widget.puzzle.titleKey),
      showBackButton: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              PuzzleInstructions(text: widget.s(widget.puzzle.instructionsKey)),
              const SizedBox(height: 24),
              // Digit display.
              Semantics(
                label: _entered.join(' '),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _validator.digits; i++)
                      Container(
                        key: ValueKey('keypad_cell_$i'),
                        width: 44,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: i < _entered.length
                                ? AppColors.brass
                                : AppColors.secondaryText,
                          ),
                        ),
                        child: Text(
                          key: ValueKey('keypad_cell_text_$i'),
                          i < _entered.length ? _entered[i] : '·',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: i < _entered.length
                                ? AppColors.parchmentText
                                : AppColors.disabledText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PuzzleFeedback(visible: _wrong),
              const SizedBox(height: 24),
              // Numpad.
              for (var row = 0; row < 4; row++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var col = 0; col < 3; col++)
                        _KeypadKey(
                          label: _keyLabel(row, col, l10n),
                          onTap: _keyAction(row, col),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _keyLabel(int row, int col, AppLocalizations l10n) {
    final digit = row * 3 + col + 1;
    if (digit <= 9) return '$digit';
    return switch ((row, col)) {
      (3, 0) => l10n.keypadClear,
      (3, 1) => '0',
      _ => l10n.keypadDelete,
    };
  }

  VoidCallback? _keyAction(int row, int col) {
    final digit = row * 3 + col + 1;
    if (digit <= 9) return () => _press('$digit');
    return switch ((row, col)) {
      (3, 0) => _clear,
      (3, 1) => () => _press('0'),
      _ => _delete,
    };
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 72,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brass.withValues(alpha: 0.4)),
            ),
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.parchmentText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
