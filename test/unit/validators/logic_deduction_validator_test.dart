import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/logic_deduction_validator.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';

LogicDeductionValidator orrery() => LogicDeductionValidator.parse(
  initialState: {
    'fields': [
      {'id': 't1', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'ring1'},
      {'id': 't2', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'ring2'},
      {'id': 't3', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'ring3'},
      {'id': 'year', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'year'},
    ],
  },
  solutionConfig: {
    'answer': {'t1': '0815', 't2': '0347', 't3': '0658', 'year': '1892'},
  },
  where: 'test',
);

void main() {
  group('LogicDeductionValidator (puz_ob_orrery)', () {
    final v = orrery();

    test('accepts the chart-order solution', () {
      expect(
        v.check({'t1': '0815', 't2': '0347', 't3': '0658', 'year': '1892'}),
        PuzzleVerdict.correct,
      );
    });

    test('rejects chronological order (the trap)', () {
      expect(
        v.check({'t1': '0347', 't2': '0658', 't3': '0815', 'year': '1892'}),
        PuzzleVerdict.incorrect,
      );
    });

    test('missing leading zeroes are rejected, not normalized away', () {
      expect(
        v.check({'t1': '815', 't2': '0347', 't3': '0658', 'year': '1892'}),
        PuzzleVerdict.incorrect,
      );
    });

    test('wrong year rejected', () {
      expect(
        v.check({'t1': '0815', 't2': '0347', 't3': '0658', 'year': '1893'}),
        PuzzleVerdict.incorrect,
      );
    });

    test('empty fields keep the answer incomplete', () {
      expect(
        v.check({'t1': '0815', 't2': '', 't3': '0658', 'year': '1892'}),
        PuzzleVerdict.incomplete,
      );
      expect(
        v.check({'t1': '', 't2': '', 't3': '', 'year': ''}),
        PuzzleVerdict.incomplete,
      );
    });

    test('field-level normalization trims digits', () {
      expect(
        v.check({'t1': ' 0815 ', 't2': '0347', 't3': '0658', 'year': '1892'}),
        PuzzleVerdict.correct,
      );
    });

    test('text fields are case-insensitive and whitespace-collapsed', () {
      final v = LogicDeductionValidator.parse(
        initialState: {
          'fields': [
            {'id': 'name', 'kind': 'text', 'labelKey': 'nameLabel'},
          ],
        },
        solutionConfig: {
          'answer': {'name': 'Edmund Vale'},
        },
        where: 'test',
      );
      expect(v.check({'name': '  EDMUND   vale '}), PuzzleVerdict.correct);
      expect(v.check({'name': 'Vale Edmund'}), PuzzleVerdict.incorrect);
    });

    test('malformed config is rejected with field context', () {
      expect(
        () => LogicDeductionValidator.parse(
          initialState: {
            'fields': [
              {'id': 'a', 'kind': 'digits', 'labelKey': 'l'},
            ],
          },
          solutionConfig: {
            'answer': {'a': '12x4'},
          },
          where: 'test',
        ),
        throwsA(isA<ContentValidationException>()),
      );
      expect(
        () => LogicDeductionValidator.parse(
          initialState: {
            'fields': [
              {'id': 'a', 'kind': 'text', 'labelKey': 'l'},
            ],
          },
          solutionConfig: {
            'answer': {'b': 'x'},
          },
          where: 'test',
        ),
        throwsA(isA<ContentValidationException>()),
      );
      expect(
        () => LogicDeductionValidator.parse(
          initialState: {
            'fields': [
              {'id': 'a', 'kind': 'riddle', 'labelKey': 'l'},
            ],
          },
          solutionConfig: {
            'answer': {'a': 'x'},
          },
          where: 'test',
        ),
        throwsA(isA<ContentValidationException>()),
      );
    });
  });
}
