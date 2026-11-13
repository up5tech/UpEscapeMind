import '../../core/errors/app_exceptions.dart';
import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// `symbol_matching` family — one symbol chosen per slot, order-sensitive
/// (covers the carved-marks dials, frames, and astrolabe ring orders).
///
/// Config:
/// - `solutionConfig.symbols` ordered list of slot solution symbol ids.
/// - `solutionConfig.choices` optional palette of selectable symbol ids
///   (defaults to the solution symbols).
/// - `validationConfig.allowDuplicates` bool (default false) — when false,
///   any repeated symbol makes the answer incorrect.
///
/// Input: `List<String?>` with exactly one entry per slot; `null` = unset.
class SymbolOrderValidator extends PuzzleValidator {
  SymbolOrderValidator._({
    required this.symbols,
    required this.choices,
    required this.allowDuplicates,
  });

  factory SymbolOrderValidator.parse({
    required Map<String, dynamic> solutionConfig,
    required Map<String, dynamic> validationConfig,
    required String where,
  }) {
    // The solution may repeat a symbol (e.g. A-A-B); the palette may not.
    final symbols = reqStringListCfg(
      solutionConfig,
      'symbols',
      where,
      allowDuplicates: true,
    );
    final choicesRaw = solutionConfig['choices'];
    final choices = choicesRaw == null
        ? List<String>.unmodifiable(symbols)
        : reqStringListCfg(solutionConfig, 'choices', where);
    for (final s in symbols) {
      if (!choices.contains(s)) {
        throw ContentValidationException(
          '$where: "symbols" entry "$s" is not a selectable choice',
        );
      }
    }
    return SymbolOrderValidator._(
      symbols: symbols,
      choices: choices,
      allowDuplicates: reqBoolCfg(
        validationConfig,
        'allowDuplicates',
        where,
      ),
    );
  }

  /// Solution symbol id per slot.
  final List<String> symbols;

  /// Selectable palette of symbol ids.
  final List<String> choices;
  final bool allowDuplicates;

  int get slotCount => symbols.length;

  PuzzleVerdict check(List<String?> picks) {
    if (picks.length != symbols.length) return PuzzleVerdict.incorrect;
    for (final pick in picks) {
      if (pick == null) return PuzzleVerdict.incomplete;
      if (!choices.contains(pick)) return PuzzleVerdict.incorrect;
    }
    if (!allowDuplicates && picks.toSet().length != picks.length) {
      return PuzzleVerdict.incorrect;
    }
    for (var i = 0; i < picks.length; i++) {
      if (picks[i] != symbols[i]) return PuzzleVerdict.incorrect;
    }
    return PuzzleVerdict.correct;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) =>
      input is List<String?> ? check(input) : PuzzleVerdict.incomplete;
}
