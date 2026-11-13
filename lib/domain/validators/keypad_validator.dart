import '../../core/errors/app_exceptions.dart';
import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// `keypad` family — numeric/alphanumeric code lock.
///
/// Config:
/// - `initialState.digits` int > 0 (default 4) — code length.
/// - `solutionConfig.code` digit string of exactly [digits] characters.
/// - `validationConfig.allowLeadingZero` bool (default true). When false,
///   leading zeroes are stripped from both the guess and the code before
///   comparison; when true the comparison is exact.
///
/// Input: the entered digit string. Anything that is not exactly [digits]
/// ASCII digits is [PuzzleVerdict.incomplete] until the length is reached,
/// then [PuzzleVerdict.incorrect] (non-digits cannot be produced by the
/// keypad UI, but the validator rejects them defensively).
class KeypadValidator extends PuzzleValidator {
  KeypadValidator._({
    required this.digits,
    required this.code,
    required this.allowLeadingZero,
  });

  factory KeypadValidator.parse({
    required Map<String, dynamic> initialState,
    required Map<String, dynamic> solutionConfig,
    required Map<String, dynamic> validationConfig,
    required String where,
  }) {
    final digits = reqIntCfg(initialState, 'digits', where, dflt: 4);
    if (digits <= 0 || digits > 12) {
      throw ContentValidationException(
        '$where: "digits" must be between 1 and 12',
      );
    }
    final code = reqStringCfg(solutionConfig, 'code', where);
    if (code.length != digits || !isDigitString(code)) {
      throw ContentValidationException(
        '$where: "code" must be exactly $digits digit(s)',
      );
    }
    final allowLeadingZero = reqBoolCfg(
      validationConfig,
      'allowLeadingZero',
      where,
      dflt: true,
    );
    return KeypadValidator._(
      digits: digits,
      code: code,
      allowLeadingZero: allowLeadingZero,
    );
  }

  final int digits;
  final String code;
  final bool allowLeadingZero;

  /// Keypad press handler: only digits are accepted.
  bool acceptsKey(String key) =>
      key.length == 1 && key.codeUnitAt(0) >= 0x30 && key.codeUnitAt(0) <= 0x39;

  PuzzleVerdict check(String entered) {
    if (entered.length != digits || !isDigitString(entered)) {
      return PuzzleVerdict.incomplete;
    }
    if (allowLeadingZero) {
      return entered == code
          ? PuzzleVerdict.correct
          : PuzzleVerdict.incorrect;
    }
    return stripLeadingZeroes(entered) == stripLeadingZeroes(code)
        ? PuzzleVerdict.correct
        : PuzzleVerdict.incorrect;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) => input is String
      ? check(input)
      : PuzzleVerdict.incomplete;
}
