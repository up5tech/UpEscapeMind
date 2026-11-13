import '../models/content/puzzle_definition.dart';

/// Result of validating a player's puzzle input against a definition.
///
/// - [incomplete]: the player has not entered a full answer yet.
/// - [incorrect]: the full answer is wrong. Durable state must not change.
/// - [correct]: the answer matches the solution config.
enum PuzzleVerdict { incomplete, incorrect, correct }

/// A normalized point on a scene image (0.0–1.0 in both axes).
class TapPoint {
  const TapPoint(this.x, this.y);

  final double x;
  final double y;
}

/// Common interface for the Phase 7 typed puzzle validators.
///
/// Concrete validators are pure Dart (no Flutter imports), constructed from
/// a validated [PuzzleDefinition]. Input types are family-specific:
///
/// | family            | input type                  |
/// | ----------------- | --------------------------- |
/// | keypad            | `String` of digits          |
/// | symbol_matching   | `List<String?>` slot picks  |
/// | sequence          | `List<String>` ordered picks |
/// | rotation          | `List<double>` angles       |
/// | logic_deduction   | `Map<String, String>` fields |
/// | mechanical_state  | `List<bool>` lever states   |
/// | hidden_object     | `TapPoint`                  |
/// | observation       | `List<String>` region ids   |
abstract class PuzzleValidator {
  const PuzzleValidator();

  /// Family-specific verdict. Unknown input types are [PuzzleVerdict.incomplete].
  PuzzleVerdict evaluateInput(Object? input);
}

/// Normalizes an arbitrary angle into `[0, 360)`.
double normalizeAngle(double degrees) {
  final a = degrees % 360;
  return a < 0 ? a + 360 : a;
}

/// Smallest absolute difference between two angles, in degrees (0–180).
double angleError(double a, double b) {
  final d = (normalizeAngle(a) - normalizeAngle(b)).abs();
  return d > 180 ? 360 - d : d;
}

/// True when [candidate] is a non-empty ASCII digit string.
bool isDigitString(String value) =>
    value.isNotEmpty &&
    value.codeUnits.every((c) => c >= 0x30 && c <= 0x39);

/// Strips leading zeroes; returns `'0'` for an all-zero string.
String stripLeadingZeroes(String digits) {
  var i = 0;
  while (i < digits.length - 1 && digits.codeUnitAt(i) == 0x30) {
    i++;
  }
  return digits.substring(i);
}

/// Puzzle types rendered by the reusable puzzle screen.
///
/// `item_use` and `item_combination` are room/inventory interactions
/// (Phase 6), not puzzle-screen families.
bool isScreenPuzzleType(PuzzleType type) => switch (type) {
  PuzzleType.keypad ||
  PuzzleType.symbolMatching ||
  PuzzleType.sequence ||
  PuzzleType.rotation ||
  PuzzleType.logicDeduction ||
  PuzzleType.mechanicalState ||
  PuzzleType.hiddenObject ||
  PuzzleType.observation =>
    true,
  PuzzleType.itemUse || PuzzleType.itemCombination => false,
};
