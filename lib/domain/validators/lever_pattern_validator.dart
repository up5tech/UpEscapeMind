import '../../core/errors/app_exceptions.dart';
import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// `mechanical_state` family — connected switches/levers must reach an
/// exact boolean pattern (`LeverPatternValidator`).
///
/// Config:
/// - `solutionConfig.targetState` non-empty list of bools (`true` = up/on),
///   fixed length, order-sensitive.
/// - `initialState.states` optional start pattern (default all false).
///   Individual flips are free; only the full pattern completes.
///
/// Input: `List<bool>` current states.
class LeverPatternValidator extends PuzzleValidator {
  LeverPatternValidator._({required this.targetState, required this.startState});

  factory LeverPatternValidator.parse({
    required Map<String, dynamic> initialState,
    required Map<String, dynamic> solutionConfig,
    required String where,
  }) {
    final target = reqBoolListCfg(solutionConfig, 'targetState', where);
    final startsRaw = initialState['states'];
    List<bool> start;
    if (startsRaw == null) {
      start = [for (final _ in target) false];
    } else if (startsRaw is! List || startsRaw.length != target.length) {
      throw ContentValidationException(
        '$where: "states" must be a list with one bool per "targetState" '
        'entry',
      );
    } else {
      start = [
        for (var i = 0; i < startsRaw.length; i++)
          if (startsRaw[i] is bool)
            startsRaw[i] as bool
          else
            throw ContentValidationException(
              '$where: "states[$i]" must be a bool',
            ),
      ];
    }
    return LeverPatternValidator._(targetState: target, startState: start);
  }

  final List<bool> targetState;
  final List<bool> startState;

  int get leverCount => targetState.length;

  PuzzleVerdict check(List<bool> states) {
    if (states.length != targetState.length) return PuzzleVerdict.incorrect;
    for (var i = 0; i < states.length; i++) {
      if (states[i] != targetState[i]) return PuzzleVerdict.incorrect;
    }
    return PuzzleVerdict.correct;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) =>
      input is List<bool> ? check(input) : PuzzleVerdict.incomplete;
}
