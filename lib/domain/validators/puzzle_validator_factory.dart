import '../../core/errors/app_exceptions.dart';
import '../models/content/puzzle_definition.dart';
import 'keypad_validator.dart';
import 'lever_pattern_validator.dart';
import 'logic_deduction_validator.dart';
import 'puzzle_validator.dart';
import 'rotation_validator.dart';
import 'sequence_validator.dart';
import 'symbol_order_validator.dart';
import 'tap_region_validator.dart';

/// Builds the typed validator for a screen puzzle family from its
/// [PuzzleDefinition]. Throws [ContentValidationException] when the
/// family-specific configuration is malformed — the content validation
/// suite uses this to catch bad puzzle JSON before runtime.
PuzzleValidator buildPuzzleValidator(PuzzleDefinition puzzle) {
  final where = 'puzzle "${puzzle.id}"';
  return switch (puzzle.type) {
    PuzzleType.keypad => KeypadValidator.parse(
      initialState: puzzle.initialState,
      solutionConfig: puzzle.solutionConfig,
      validationConfig: puzzle.validationConfig,
      where: where,
    ),
    PuzzleType.symbolMatching => SymbolOrderValidator.parse(
      solutionConfig: puzzle.solutionConfig,
      validationConfig: puzzle.validationConfig,
      where: where,
    ),
    PuzzleType.sequence => SequenceValidator.parse(
      solutionConfig: puzzle.solutionConfig,
      where: where,
    ),
    PuzzleType.rotation => RotationValidator.parse(
      initialState: puzzle.initialState,
      solutionConfig: puzzle.solutionConfig,
      validationConfig: puzzle.validationConfig,
      where: where,
    ),
    PuzzleType.logicDeduction => LogicDeductionValidator.parse(
      initialState: puzzle.initialState,
      solutionConfig: puzzle.solutionConfig,
      where: where,
    ),
    PuzzleType.mechanicalState => LeverPatternValidator.parse(
      initialState: puzzle.initialState,
      solutionConfig: puzzle.solutionConfig,
      where: where,
    ),
    PuzzleType.hiddenObject => TapRegionValidator.parse(
      solutionConfig: puzzle.solutionConfig,
      validationConfig: puzzle.validationConfig,
      where: where,
    ),
    PuzzleType.observation => TapRegionValidator.parse(
      solutionConfig: puzzle.solutionConfig,
      validationConfig: puzzle.validationConfig,
      where: where,
      ordered: true,
    ),
    PuzzleType.itemUse || PuzzleType.itemCombination =>
      throw ContentValidationException(
        '$where: type "${puzzle.type.jsonValue}" is handled by room and '
        'inventory interactions, not the puzzle screen',
      ),
  };
}
