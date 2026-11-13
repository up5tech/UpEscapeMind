import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';
import 'package:up_escape_mind/domain/validators/tap_region_validator.dart';

TapRegionValidator single({double? hitPadding}) {
  return TapRegionValidator.parse(
    solutionConfig: {
      'regions': [
        {'id': 'crate', 'x': 0.0, 'y': 0.6, 'width': 0.3, 'height': 0.3},
        {'id': 'floorboard', 'x': 0.4, 'y': 0.4, 'width': 0.2, 'height': 0.2},
        {'id': 'lamp', 'x': 0.7, 'y': 0.0, 'width': 0.25, 'height': 0.25},
      ],
      'targetId': 'floorboard',
    },
    validationConfig: {
      'hitPadding': ?hitPadding,
    },
    where: 'test',
  );
}

TapRegionValidator ordered() {
  return TapRegionValidator.parse(
    solutionConfig: {
      'regions': [
        {'id': 'gallery', 'x': 0.0, 'y': 0.0, 'width': 0.2, 'height': 0.2},
        {'id': 'study', 'x': 0.4, 'y': 0.4, 'width': 0.2, 'height': 0.2},
        {'id': 'workshop', 'x': 0.8, 'y': 0.8, 'width': 0.2, 'height': 0.2},
      ],
      'targets': ['gallery', 'study', 'workshop'],
    },
    validationConfig: {},
    where: 'test',
    ordered: true,
  );
}

void main() {
  group('HotspotHit semantics — hidden_object (puz_wk_floorboard)', () {
    final v = single();

    test('accepts a tap inside the target region', () {
      expect(v.checkTap(const TapPoint(0.5, 0.5)), PuzzleVerdict.correct);
      expect(v.evaluateInput(const TapPoint(0.41, 0.41)),
          PuzzleVerdict.correct);
    });

    test('rejects taps in sibling regions and empty space', () {
      expect(v.checkTap(const TapPoint(0.1, 0.7)), PuzzleVerdict.incorrect);
      expect(v.hitRegionId(const TapPoint(0.1, 0.7)), 'crate');
      expect(v.hitRegionId(const TapPoint(0.35, 0.35)), isNull);
      expect(v.checkTap(const TapPoint(0.35, 0.35)), PuzzleVerdict.incorrect);
    });

    test('hit padding enlarges the target beyond its bounds', () {
      final v = single(hitPadding: 0.08);
      // Just outside the raw rect, inside the padded hit area.
      expect(v.checkTap(const TapPoint(0.39, 0.5)), PuzzleVerdict.correct);
      expect(v.hitRegionId(const TapPoint(0.5, 0.2)), isNull);
    });

    test('later regions win overlap (drawn on top)', () {
      final v = TapRegionValidator.parse(
        solutionConfig: {
          'regions': [
            {'id': 'big', 'x': 0, 'y': 0, 'width': 1, 'height': 1},
            {'id': 'small', 'x': 0.4, 'y': 0.4, 'width': 0.2, 'height': 0.2},
          ],
          'targetId': 'small',
        },
        validationConfig: {},
        where: 'test',
      );
      expect(v.hitRegionId(const TapPoint(0.5, 0.5)), 'small');
      expect(v.hitRegionId(const TapPoint(0.1, 0.1)), 'big');
    });

    test('malformed config is rejected', () {
      expect(
        () => TapRegionValidator.parse(
          solutionConfig: {
            'regions': [
              {'id': 'a', 'x': 0.9, 'y': 0.0, 'width': 0.3, 'height': 0.1},
            ],
            'targetId': 'a',
          },
          validationConfig: {},
          where: 'test',
        ),
        throwsA(isA<ContentValidationException>()),
      );
      expect(
        () => TapRegionValidator.parse(
          solutionConfig: {
            'regions': [
              {'id': 'a', 'x': 0, 'y': 0, 'width': 0.1, 'height': 0.1},
            ],
            'targetId': 'ghost',
          },
          validationConfig: {},
          where: 'test',
        ),
        throwsA(isA<ContentValidationException>()),
      );
    });
  });

  group('ConstellationOrder semantics — observation '
      '(puz_ob_starchart)', () {
    final v = ordered();

    test('accepts gallery, study, workshop in order', () {
      expect(v.checkSequence(['gallery', 'study', 'workshop']),
          PuzzleVerdict.correct);
    });

    test('partial prefixes stay incomplete', () {
      expect(v.checkSequence([]), PuzzleVerdict.incomplete);
      expect(v.checkSequence(['gallery']), PuzzleVerdict.incomplete);
      expect(v.checkSequence(['gallery', 'study']), PuzzleVerdict.incomplete);
    });

    test('a wrong tap at any position breaks the chain', () {
      expect(v.checkSequence(['study']), PuzzleVerdict.incorrect);
      expect(v.checkSequence(['gallery', 'workshop']), PuzzleVerdict.incorrect);
      expect(
        v.checkSequence(['gallery', 'study', 'gallery']),
        PuzzleVerdict.incorrect,
      );
    });

    test('unknown input shape is incomplete', () {
      expect(v.evaluateInput(const TapPoint(0.5, 0.5)),
          PuzzleVerdict.incomplete);
    });

    test('targets must reference authored regions', () {
      expect(
        () => TapRegionValidator.parse(
          solutionConfig: {
            'regions': [
              {'id': 'a', 'x': 0, 'y': 0, 'width': 0.1, 'height': 0.1},
            ],
            'targets': ['ghost'],
          },
          validationConfig: {},
          where: 'test',
          ordered: true,
        ),
        throwsA(isA<ContentValidationException>()),
      );
    });
  });
}
