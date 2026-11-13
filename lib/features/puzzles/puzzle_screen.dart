import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/progress_actions.dart';
import '../../app/providers/app_providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../data/content/content_strings.dart';
import '../../domain/models/content/content_models.dart';
import '../../domain/rules/prerequisite_evaluator.dart';

/// Puzzle screen. Phase 5 ships the data-driven keypad family; Phase 7
/// generalizes this into the reusable puzzle engine.
class PuzzleScreen extends ConsumerWidget {
  const PuzzleScreen({super.key, required this.puzzleId});

  final String puzzleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final puzzle = catalog.puzzlesById[puzzleId];

    if (puzzle == null) {
      return AppScaffold(
        title: l10n.errorGeneric,
        showBackButton: true,
        body: Center(child: Text(l10n.errorGeneric)),
      );
    }

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
      PuzzleType.keypad => _KeypadPuzzle(
        puzzle: puzzle,
        strings: strings,
        locale: locale,
        s: s,
      ),
      _ => AppScaffold(
        title: s(puzzle.titleKey),
        showBackButton: true,
        body: Center(child: Text(l10n.errorGeneric)),
      ),
    };
  }
}

/// Numeric keypad puzzle driven entirely by the puzzle definition:
/// `initialState.digits` sets the code length, `solutionConfig.code`
/// is the expected digit string, `validationConfig.allowLeadingZero`
/// controls whether leading zeros are preserved in comparisons.
class _KeypadPuzzle extends ConsumerStatefulWidget {
  const _KeypadPuzzle({
    required this.puzzle,
    required this.strings,
    required this.locale,
    required this.s,
  });

  final PuzzleDefinition puzzle;
  final ContentStrings strings;
  final String locale;
  final String Function(String) s;

  @override
  ConsumerState<_KeypadPuzzle> createState() => _KeypadPuzzleState();
}

class _KeypadPuzzleState extends ConsumerState<_KeypadPuzzle> {
  late final int _length;
  late final String _code;
  final List<String> _entered = [];
  bool _wrong = false;
  bool _solving = false;

  @override
  void initState() {
    super.initState();
    final digits = widget.puzzle.initialState['digits'];
    _length = digits is int && digits > 0 ? digits : 4;
    final rawCode = widget.puzzle.solutionConfig['code'];
    _code = rawCode is String ? rawCode.trim() : '';
  }

  bool get _complete => _entered.length == _length;

  void _press(String digit) {
    if (_solving || _complete) return;
    setState(() {
      _wrong = false;
      _entered.add(digit);
    });
    if (_complete) _check();
  }

  void _delete() {
    if (_solving || _entered.isEmpty) return;
    setState(() {
      _wrong = false;
      _entered.removeLast();
    });
  }

  void _clear() {
    if (_solving) return;
    setState(() {
      _wrong = false;
      _entered.clear();
    });
  }

  Future<void> _check() async {
    final guess = _entered.join();
    final allowLeadingZero =
        widget.puzzle.validationConfig['allowLeadingZero'] != false;
    final expected = allowLeadingZero
        ? _code
        : _code.replaceFirst(RegExp('^0+'), '');
    final actual = allowLeadingZero
        ? guess
        : guess.replaceFirst(RegExp('^0+'), '');

    if (actual == expected && expected.isNotEmpty) {
      setState(() => _solving = true);
      await ref
          .read(progressActionsProvider)
          .solvePuzzle(widget.puzzle.id, widget.puzzle.successActions);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.puzzleSolvedMessage)));
      Navigator.of(context).pop();
    } else {
      setState(() {
        _wrong = true;
        _entered.clear();
      });
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
              Text(
                widget.s(widget.puzzle.instructionsKey),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Digit display.
              Semantics(
                label: _entered.join(' '),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _length; i++)
                      Container(
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
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _wrong ? 1 : 0,
                child: Text(
                  l10n.puzzleIncorrectMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.clockRed,
                  ),
                ),
              ),
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
