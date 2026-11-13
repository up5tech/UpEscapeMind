import 'config_parsing.dart';
import 'puzzle_validator.dart';

/// `sequence` family — order candidates into the correct sequence
/// (books by year, portraits chronologically, constellation taps).
///
/// Config:
/// - `solutionConfig.order` ordered list of element ids. The candidate set
///   is exactly this list: every element must be used exactly once, so the
///   answer is a permutation.
///
/// Input: `List<String>` picks in the order the player placed them.
class SequenceValidator extends PuzzleValidator {
  SequenceValidator._({required this.order});

  factory SequenceValidator.parse({
    required Map<String, dynamic> solutionConfig,
    required String where,
  }) => SequenceValidator._(
    order: reqStringListCfg(solutionConfig, 'order', where),
  );

  final List<String> order;

  List<String> get candidates => order;

  PuzzleVerdict check(List<String> picks) {
    for (final pick in picks) {
      if (!order.contains(pick)) return PuzzleVerdict.incorrect;
    }
    if (picks.toSet().length != picks.length) {
      return PuzzleVerdict.incorrect;
    }
    if (picks.length < order.length) return PuzzleVerdict.incomplete;
    if (picks.length > order.length) return PuzzleVerdict.incorrect;
    for (var i = 0; i < order.length; i++) {
      if (picks[i] != order[i]) return PuzzleVerdict.incorrect;
    }
    return PuzzleVerdict.correct;
  }

  @override
  PuzzleVerdict evaluateInput(Object? input) =>
      input is List<String> ? check(input) : PuzzleVerdict.incomplete;
}
