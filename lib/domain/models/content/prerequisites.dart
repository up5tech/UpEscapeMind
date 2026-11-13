import '../../../core/errors/app_exceptions.dart';

/// Conditions that gate content. Evaluated by the unlock engine (Phase 8);
/// validated here for reference integrity.
enum PrerequisiteType {
  roomUnlocked('room_unlocked'),
  puzzleSolved('puzzle_solved'),
  itemCollected('item_collected'),
  itemConsumed('item_consumed'),
  clueDiscovered('clue_discovered'),
  chapterCompleted('chapter_completed');

  const PrerequisiteType(this.jsonValue);

  final String jsonValue;

  static PrerequisiteType parse(String value, String filePath, String field) {
    for (final type in values) {
      if (type.jsonValue == value) return type;
    }
    throw ContentValidationException('$filePath: unknown $field "$value"');
  }
}

/// A single prerequisite condition, e.g. `{ "type": "puzzle_solved",
/// "targetId": "puz_eh_door_lock" }`.
class Prerequisite {
  const Prerequisite({required this.type, required this.targetId});

  final PrerequisiteType type;
  final String targetId;

  factory Prerequisite.fromJson(Map<String, dynamic> json, String filePath) {
    final field = 'prerequisites[]';
    final typeRaw = json['type'];
    final targetId = json['targetId'];
    if (typeRaw is! String) {
      throw ContentValidationException(
        '$filePath: $field.type must be a string',
      );
    }
    if (targetId is! String || targetId.isEmpty) {
      throw ContentValidationException(
        '$filePath: $field.targetId must be a non-empty string',
      );
    }
    return Prerequisite(
      type: PrerequisiteType.parse(typeRaw, filePath, '$field.type'),
      targetId: targetId,
    );
  }

  /// Entity ids this prerequisite depends on, for cycle detection.
  /// Only returns targets that participate in the unlock graph.
  String? get unlockGraphTarget => switch (type) {
    PrerequisiteType.roomUnlocked => targetId,
    PrerequisiteType.puzzleSolved => targetId,
    PrerequisiteType.chapterCompleted => targetId,
    _ => null,
  };
}

/// Side effects granted when a puzzle is solved.
enum SuccessActionType {
  unlockRoom('unlock_room'),
  collectItem('collect_item'),
  consumeItem('consume_item'),
  discoverClue('discover_clue'),
  completeChapter('complete_chapter');

  const SuccessActionType(this.jsonValue);

  final String jsonValue;

  static SuccessActionType parse(String value, String filePath) {
    for (final type in values) {
      if (type.jsonValue == value) return type;
    }
    throw ContentValidationException(
      '$filePath: unknown successActions[].type "$value"',
    );
  }
}

class SuccessAction {
  const SuccessAction({required this.type, required this.targetId});

  final SuccessActionType type;
  final String targetId;

  factory SuccessAction.fromJson(Map<String, dynamic> json, String filePath) {
    final typeRaw = json['type'];
    final targetId = json['targetId'];
    if (typeRaw is! String) {
      throw ContentValidationException(
        '$filePath: successActions[].type must be a string',
      );
    }
    if (targetId is! String || targetId.isEmpty) {
      throw ContentValidationException(
        '$filePath: successActions[].targetId must be a non-empty string',
      );
    }
    return SuccessAction(
      type: SuccessActionType.parse(typeRaw, filePath),
      targetId: targetId,
    );
  }
}
