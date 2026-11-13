import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';
import 'package:up_escape_mind/domain/validators/rotation_validator.dart';

RotationValidator build({
  required List<Object> steps,
  double? tolerance,
  int? detents,
  List<num>? startAngles,
}) {
  return RotationValidator.parse(
    initialState: {
      'startAngles': ?startAngles,
    },
    solutionConfig: {'steps': steps},
    validationConfig: {
      'toleranceDegrees': ?tolerance,
      'detents': ?detents,
    },
    where: 'test',
  );
}

void main() {
  group('normalizeAngle / angleError', () {
    test('normalize wraps into [0, 360)', () {
      expect(normalizeAngle(-150), 210);
      expect(normalizeAngle(360), 0);
      expect(normalizeAngle(721), 1);
    });

    test('angleError uses the shortest arc', () {
      expect(angleError(358, 2), closeTo(4, 1e-9));
      expect(angleError(0, 180), 180);
      expect(angleError(200, 210), 10);
    });
  });

  group('RotationValidator (puz_st_globe: 210°, ±5°)', () {
    final v = build(steps: [210]);

    test('accepts the target and its tolerance band', () {
      for (final a in [205.0, 210.0, 214.9]) {
        expect(v.check([a]), PuzzleVerdict.correct, reason: '$a');
      }
    });

    test('rejects 0° and 180°±10', () {
      expect(v.check([0]), PuzzleVerdict.incorrect);
      expect(v.check([170]), PuzzleVerdict.incorrect);
      expect(v.check([190]), PuzzleVerdict.incorrect);
    });

    test('accepts equivalent wrapped angles', () {
      expect(v.check([-152]), PuzzleVerdict.correct);
      expect(v.check([570]), PuzzleVerdict.correct); // 570 - 360 = 210
    });

    test('start angle defaults to 0 and reset restores it', () {
      expect(v.startAngles, [0.0]);
      final withStart = build(steps: [210], startAngles: [90]);
      expect(withStart.startAngles, [90.0]);
    });
  });

  group('MultiRotationValidator semantics (puz_wk_gears: 3 dials)', () {
    final v = build(steps: [30, 120, 200], tolerance: 5);

    test('accepts the triple within tolerance', () {
      expect(v.check([31, 124, 196]), PuzzleVerdict.correct);
    });

    test('rejects two-of-three alignment', () {
      expect(v.check([30, 120, 0]), PuzzleVerdict.incorrect);
    });

    test('rejects wrong dial count', () {
      expect(v.check([30, 120]), PuzzleVerdict.incorrect);
    });
  });

  group('detent snapping (astrolabe-style discrete positions)', () {
    test('snap rounds to the nearest detent', () {
      final v = build(steps: [45, 90], detents: 8);
      expect(v.snap(47), closeTo(45, 1e-9));
      expect(v.snap(51), closeTo(45, 1e-9));
      expect(v.snap(350), closeTo(0, 1e-9));
      expect(v.snap(-10), closeTo(0, 1e-9));
    });

    test('continuous dial normalizes without snapping', () {
      final v = build(steps: [10]);
      expect(v.snap(12.34), closeTo(12.34, 1e-9));
      expect(v.snap(-12.34), closeTo(347.66, 0.01));
    });
  });

  test('malformed config is rejected', () {
    expect(() => build(steps: []), throwsA(isA<ContentValidationException>()));
    expect(
      () => build(steps: ['x']),
      throwsA(isA<ContentValidationException>()),
    );
    expect(
      () => build(steps: [10], startAngles: [1, 2]),
      throwsA(isA<ContentValidationException>()),
    );
    expect(
      () => build(steps: [10], detents: 1),
      throwsA(isA<ContentValidationException>()),
    );
  });
}
