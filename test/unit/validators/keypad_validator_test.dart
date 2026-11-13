import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/keypad_validator.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';

KeypadValidator build({
  int digits = 4,
  required String code,
  bool? allowLeadingZero,
}) {
  return KeypadValidator.parse(
    initialState: {'digits': digits},
    solutionConfig: {'code': code},
    validationConfig: {
      'allowLeadingZero': ?allowLeadingZero,
    },
    where: 'test',
  );
}

void main() {
  group('KeypadValidator (puz_eh_door_lock: code 1024)', () {
    final v = build(code: '1024');

    test('accepts the correct code', () {
      expect(v.check('1024'), PuzzleVerdict.correct);
    });

    test('rejects wrong length and non-digits', () {
      expect(v.check('102'), PuzzleVerdict.incomplete);
      expect(v.check('10245'), isNot(PuzzleVerdict.correct));
      expect(v.check('10a4'), isNot(PuzzleVerdict.correct));
      expect(v.check(''), PuzzleVerdict.incomplete);
    });

    test('rejects a different same-length code', () {
      expect(v.check('4271'), PuzzleVerdict.incorrect);
    });

    test('leading zeroes are significant by default (0012 vs 12)', () {
      final zero = build(code: '0012');
      expect(zero.check('0012'), PuzzleVerdict.correct);
      expect(zero.check('1201'), PuzzleVerdict.incorrect);
    });

    test('allowLeadingZero=false strips leading zeroes on both sides', () {
      final v = build(code: '0123', allowLeadingZero: false);
      expect(v.check('0123'), PuzzleVerdict.correct);
      expect(v.check('0012'), isNot(PuzzleVerdict.correct));
      expect(v.check('1203'), PuzzleVerdict.incorrect);
    });

    test('malformed config is reported with field names', () {
      expect(
        () => build(code: '12'),
        throwsA(
          isA<ContentValidationException>().having(
            (e) => e.message,
            'message',
            contains('code'),
          ),
        ),
      );
      expect(
        () => build(code: 'abcd'),
        throwsA(isA<ContentValidationException>()),
      );
      expect(
        () => build(digits: 0, code: '1'),
        throwsA(isA<ContentValidationException>()),
      );
    });

    test('unknown input types are incomplete', () {
      expect(v.evaluateInput(42), PuzzleVerdict.incomplete);
    });
  });
}
