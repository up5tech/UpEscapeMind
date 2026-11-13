import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';
import 'package:up_escape_mind/domain/validators/symbol_order_validator.dart';

SymbolOrderValidator build({
  required List<String> symbols,
  List<String>? choices,
  bool? allowDuplicates,
}) {
  return SymbolOrderValidator.parse(
    solutionConfig: {
      'symbols': symbols,
      'choices': ?choices,
    },
    validationConfig: {
      'allowDuplicates': ?allowDuplicates,
    },
    where: 'test',
  );
}

void main() {
  group('SymbolOrderValidator (puz_eh_marks: moon, star, sun)', () {
    final v = build(
      symbols: ['moon', 'star', 'sun'],
      choices: ['moon', 'star', 'sun', 'key'],
    );

    test('accepts the correct ordered solution', () {
      expect(
        v.check(['moon', 'star', 'sun']),
        PuzzleVerdict.correct,
      );
    });

    test('rejects wrong order', () {
      expect(v.check(['star', 'moon', 'sun']), PuzzleVerdict.incorrect);
    });

    test('rejects duplicate symbols when not allowed', () {
      expect(v.check(['moon', 'moon', 'sun']), PuzzleVerdict.incorrect);
    });

    test('partial picks are incomplete', () {
      expect(v.check(['moon', null, null]), PuzzleVerdict.incomplete);
    });

    test('wrong slot count is rejected', () {
      expect(v.check(['moon', 'star']), PuzzleVerdict.incorrect);
    });

    test('only authored choices are selectable', () {
      expect(
        v.check(['moon', 'star', 'ghost']),
        PuzzleVerdict.incorrect,
      );
    });

    test('allowDuplicates enables repeated-symbol solutions', () {
      final v = build(
        symbols: ['sun', 'sun', 'moon'],
        allowDuplicates: true,
      );
      expect(v.check(['sun', 'sun', 'moon']), PuzzleVerdict.correct);
    });

    test('choices default to the solution symbols', () {
      final v = build(symbols: ['a', 'b']);
      expect(v.choices, ['a', 'b']);
      expect(v.slotCount, 2);
    });

    test('malformed config is rejected', () {
      expect(
        () => build(symbols: ['moon'], choices: ['star']),
        throwsA(isA<ContentValidationException>()),
      );
      expect(
        () => build(symbols: []),
        throwsA(isA<ContentValidationException>()),
      );
    });
  });
}
