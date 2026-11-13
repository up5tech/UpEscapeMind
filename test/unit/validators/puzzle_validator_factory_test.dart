import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/domain/models/content/puzzle_definition.dart';
import 'package:up_escape_mind/domain/validators/keypad_validator.dart';
import 'package:up_escape_mind/domain/validators/lever_pattern_validator.dart';
import 'package:up_escape_mind/domain/validators/logic_deduction_validator.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator.dart';
import 'package:up_escape_mind/domain/validators/puzzle_validator_factory.dart';
import 'package:up_escape_mind/domain/validators/rotation_validator.dart';
import 'package:up_escape_mind/domain/validators/sequence_validator.dart';
import 'package:up_escape_mind/domain/validators/symbol_order_validator.dart';
import 'package:up_escape_mind/domain/validators/tap_region_validator.dart';

PuzzleDefinition puzzleOf(String puzzleType, Map<String, dynamic> cfg) {
  final json = <String, dynamic>{
    'schemaVersion': 1,
    'type': 'puzzle',
    'id': 'puz_factory_$puzzleType',
    'roomId': 'room_test',
    'hotspotId': 'hs_test',
    'puzzleType': puzzleType,
    'titleKey': 'title',
    'instructionsKey': 'instr',
    'initialState': cfg['initialState'] ?? <String, dynamic>{},
    'solutionConfig': cfg['solutionConfig'] ?? <String, dynamic>{},
    'validationConfig': cfg['validationConfig'] ?? <String, dynamic>{},
    'hints': [
      {'level': 1, 'textKey': 'h1'},
    ],
    'resetPolicy': 'keep',
  };
  return PuzzleDefinition.fromJson(json, 'factory_test:$puzzleType');
}

void main() {
  test('factory maps every screen family to its typed validator', () {
    expect(
      buildPuzzleValidator(
        puzzleOf('keypad', {
          'initialState': {'digits': 4},
          'solutionConfig': {'code': '1234'},
        }),
      ),
      isA<KeypadValidator>(),
    );
    expect(
      buildPuzzleValidator(puzzleOf('symbol_matching', {
        'solutionConfig': {
          'symbols': ['a', 'b'],
        },
      })),
      isA<SymbolOrderValidator>(),
    );
    expect(
      buildPuzzleValidator(puzzleOf('sequence', {
        'solutionConfig': {
          'order': ['a', 'b'],
        },
      })),
      isA<SequenceValidator>(),
    );
    expect(
      buildPuzzleValidator(puzzleOf('rotation', {
        'solutionConfig': {
          'steps': [90],
        },
      })),
      isA<RotationValidator>(),
    );
    expect(
      buildPuzzleValidator(puzzleOf('logic_deduction', {
        'initialState': {
          'fields': [
            {'id': 'a', 'kind': 'digits', 'labelKey': 'l'},
          ],
        },
        'solutionConfig': {
          'answer': {'a': '01'},
        },
      })),
      isA<LogicDeductionValidator>(),
    );
    expect(
      buildPuzzleValidator(puzzleOf('mechanical_state', {
        'solutionConfig': {
          'targetState': [true, false],
        },
      })),
      isA<LeverPatternValidator>(),
    );
    final hidden = buildPuzzleValidator(puzzleOf('hidden_object', {
      'solutionConfig': {
        'regions': [
          {'id': 'r', 'x': 0.1, 'y': 0.1, 'width': 0.2, 'height': 0.2},
        ],
        'targetId': 'r',
      },
    }));
    expect(hidden, isA<TapRegionValidator>());
    expect((hidden as TapRegionValidator).isOrdered, isFalse);

    final obs = buildPuzzleValidator(puzzleOf('observation', {
      'solutionConfig': {
        'regions': [
          {'id': 'r', 'x': 0.1, 'y': 0.1, 'width': 0.2, 'height': 0.2},
        ],
        'targets': ['r'],
      },
    }));
    expect(obs, isA<TapRegionValidator>());
    expect((obs as TapRegionValidator).isOrdered, isTrue);
  });

  test('item families are room interactions, not screen puzzles', () {
    expect(isScreenPuzzleType(PuzzleType.itemUse), isFalse);
    expect(isScreenPuzzleType(PuzzleType.itemCombination), isFalse);
    expect(isScreenPuzzleType(PuzzleType.keypad), isTrue);
    expect(
      () => buildPuzzleValidator(puzzleOf('item_use', {
        'solutionConfig': {'requiredItemId': 'x'},
      })),
      throwsA(isA<ContentValidationException>()),
    );
  });

  test('malformed family config surfaces puzzle id and field', () {
    expect(
      () => buildPuzzleValidator(puzzleOf('keypad', {
        'solutionConfig': {'code': 'nope'},
      })),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          allOf(contains('puz_factory_keypad'), contains('code')),
        ),
      ),
    );
  });
}
