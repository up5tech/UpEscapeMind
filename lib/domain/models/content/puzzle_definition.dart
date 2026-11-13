import '../../../core/errors/app_exceptions.dart';
import 'parse_utils.dart';
import 'prerequisites.dart';

/// Puzzle families from PLAN.md §5.1. At least five are required for MVP;
/// each maps to a reusable puzzle UI + pure-Dart validator (Phase 7).
enum PuzzleType {
  observation('observation'),
  keypad('keypad'),
  symbolMatching('symbol_matching'),
  sequence('sequence'),
  rotation('rotation'),
  logicDeduction('logic_deduction'),
  itemUse('item_use'),
  itemCombination('item_combination'),
  hiddenObject('hidden_object'),
  mechanicalState('mechanical_state');

  const PuzzleType(this.jsonValue);

  final String jsonValue;

  static PuzzleType parse(String value, String filePath) {
    for (final type in values) {
      if (type.jsonValue == value) return type;
    }
    throw ContentValidationException(
      '$filePath: unknown puzzle "type" "$value"',
    );
  }
}

/// How unfinished puzzle input is treated when the player leaves.
enum ResetPolicy {
  /// Input is preserved and restored on re-entry.
  keep('keep'),

  /// Input resets whenever the puzzle screen is closed.
  resetOnExit('reset_on_exit');

  const ResetPolicy(this.jsonValue);

  final String jsonValue;

  static ResetPolicy parse(String value, String filePath) {
    for (final policy in values) {
      if (policy.jsonValue == value) return policy;
    }
    throw ContentValidationException(
      '$filePath: unknown "resetPolicy" "$value"',
    );
  }
}

/// A single authored hint. Levels are 1 (nudge), 2 (clue), 3 (walkthrough).
class HintDefinition {
  const HintDefinition({required this.level, required this.textKey});

  final int level;
  final String textKey;

  factory HintDefinition.fromJson(
    Map<String, dynamic> json,
    String filePath, {
    String fieldPrefix = 'hints[]',
  }) {
    final level = json['level'];
    if (level is! int || level < 1 || level > 3) {
      throw ContentValidationException(
        '$filePath: "$fieldPrefix.level" must be an int between 1 and 3',
      );
    }
    return HintDefinition(
      level: level,
      textKey: reqString(json, 'textKey', filePath, fieldPrefix: fieldPrefix),
    );
  }
}

/// `assets/content/puzzles/*.json` — `type: "puzzle"`.
class PuzzleDefinition {
  const PuzzleDefinition({
    required this.id,
    required this.roomId,
    required this.hotspotId,
    required this.type,
    required this.titleKey,
    required this.instructionsKey,
    required this.initialState,
    required this.solutionConfig,
    required this.validationConfig,
    required this.prerequisites,
    required this.successActions,
    required this.hints,
    required this.resetPolicy,
  });

  final String id;
  final String roomId;
  final String hotspotId;
  final PuzzleType type;
  final String titleKey;
  final String instructionsKey;

  /// Declarative puzzle state — opaque to the engine, interpreted by the
  /// puzzle-family UI/validator. Never executable code.
  final Map<String, dynamic> initialState;
  final Map<String, dynamic> solutionConfig;
  final Map<String, dynamic> validationConfig;
  final List<Prerequisite> prerequisites;
  final List<SuccessAction> successActions;
  final List<HintDefinition> hints;
  final ResetPolicy resetPolicy;

  factory PuzzleDefinition.fromJson(
    Map<String, dynamic> json,
    String filePath,
  ) {
    if (json['type'] != 'puzzle') {
      throw ContentValidationException('$filePath: expected "type": "puzzle"');
    }
    reqSchemaVersion(json, filePath);

    final typeRaw = json['type'] == 'puzzle' ? json['puzzleType'] : null;
    if (typeRaw is! String) {
      throw ContentValidationException(
        '$filePath: "puzzleType" must be a string',
      );
    }

    final resetRaw = json['resetPolicy'];
    if (resetRaw is! String) {
      throw ContentValidationException(
        '$filePath: "resetPolicy" must be a string',
      );
    }

    final hintsRaw = reqMapList(json, 'hints', filePath);
    final hints = <HintDefinition>[
      for (var i = 0; i < hintsRaw.length; i++)
        HintDefinition.fromJson(
          hintsRaw[i],
          filePath,
          fieldPrefix: 'hints[$i]',
        ),
    ];
    final levels = hints.map((h) => h.level).toList()..sort();
    if (levels.toSet().length != levels.length) {
      throw ContentValidationException('$filePath: duplicate hint levels');
    }

    return PuzzleDefinition(
      id: reqString(json, 'id', filePath),
      roomId: reqString(json, 'roomId', filePath),
      hotspotId: reqString(json, 'hotspotId', filePath),
      type: PuzzleType.parse(typeRaw, filePath),
      titleKey: reqString(json, 'titleKey', filePath),
      instructionsKey: reqString(json, 'instructionsKey', filePath),
      initialState: reqMap(json, 'initialState', filePath),
      solutionConfig: reqMap(json, 'solutionConfig', filePath),
      validationConfig: reqMap(json, 'validationConfig', filePath),
      prerequisites: _parseList(
        json,
        'prerequisites',
        filePath,
        Prerequisite.fromJson,
      ),
      successActions: _parseList(
        json,
        'successActions',
        filePath,
        SuccessAction.fromJson,
      ),
      hints: hints,
      resetPolicy: ResetPolicy.parse(resetRaw, filePath),
    );
  }

  static List<T> _parseList<T>(
    Map<String, dynamic> json,
    String key,
    String filePath,
    T Function(Map<String, dynamic>, String) parse,
  ) {
    final raw = json[key];
    if (raw == null) return const [];
    return [
      for (final entry in reqMapList(json, key, filePath))
        parse(entry, filePath),
    ];
  }
}
