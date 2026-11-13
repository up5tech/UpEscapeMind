import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/lever_pattern_validator.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';

LeverPatternValidator build({
  required List<bool> targetState,
  List<bool>? states,
}) {
  return LeverPatternValidator.parse(
    initialState: {
      'states': ?states,
    },
    solutionConfig: {'targetState': targetState},
    where: 'test',
  );
}

void main() {
  group('LeverPatternValidator (puz_eh_sconce: up, down, up)', () {
    final v = build(targetState: [true, false, true]);

    test('accepts the exact pattern', () {
      expect(v.check([true, false, true]), PuzzleVerdict.correct);
    });

    test('rejects the inverse', () {
      expect(v.check([false, true, false]), PuzzleVerdict.incorrect);
    });

    test('rejects rotations of the pattern', () {
      expect(v.check([false, true, true]), PuzzleVerdict.incorrect);
      expect(v.check([true, true, false]), PuzzleVerdict.incorrect);
    });

    test('rejects wrong-length input', () {
      expect(v.check([true, false]), PuzzleVerdict.incorrect);
      expect(v.check([true, false, true, false]), PuzzleVerdict.incorrect);
    });

    test('levers flip freely; start state defaults to all down', () {
      expect(v.leverCount, 3);
      expect(v.startState, [false, false, false]);
      final withStart = build(
        targetState: [true, false],
        states: [true, true],
      );
      expect(withStart.startState, [true, true]);
    });

    test('malformed config is rejected', () {
      expect(
        () => build(targetState: []),
        throwsA(isA<ContentValidationException>()),
      );
      expect(
        () => build(targetState: [true, false], states: [true]),
        throwsA(isA<ContentValidationException>()),
      );
    });
  });
}
