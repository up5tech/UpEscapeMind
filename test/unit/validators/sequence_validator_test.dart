import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';
import 'package:up_escape_mind/domain/validators/sequence_validator.dart';

SequenceValidator build(List<String> order) => SequenceValidator.parse(
  solutionConfig: {'order': order},
  where: 'test',
);

void main() {
  group('SequenceValidator (puz_st_books: 1861, 1874, 1892)', () {
    final v = build(['book_early', 'book_mid', 'book_late']);

    test('accepts the chronological order', () {
      expect(
        v.check(['book_early', 'book_mid', 'book_late']),
        PuzzleVerdict.correct,
      );
    });

    test('rejects the reverse order', () {
      expect(
        v.check(['book_late', 'book_mid', 'book_early']),
        PuzzleVerdict.incorrect,
      );
    });

    test('rejects duplicates', () {
      expect(
        v.check(['book_mid', 'book_mid', 'book_late']),
        PuzzleVerdict.incorrect,
      );
    });

    test('rejects unknown candidates', () {
      expect(
        v.check(['book_early', 'book_ghost', 'book_late']),
        PuzzleVerdict.incorrect,
      );
    });

    test('partial progress stays incomplete and durable-free', () {
      expect(v.check(['book_early']), PuzzleVerdict.incomplete);
      expect(v.check(['book_early', 'book_mid']), PuzzleVerdict.incomplete);
      expect(v.check([]), PuzzleVerdict.incomplete);
    });

    test('candidate set is exactly the solution set', () {
      expect(v.candidates, ['book_early', 'book_mid', 'book_late']);
    });

    test('malformed order config is rejected', () {
      expect(() => build(['a', 'a']), throwsA(isA<ContentValidationException>()));
      expect(() => build([]), throwsA(isA<ContentValidationException>()));
    });
  });
}
