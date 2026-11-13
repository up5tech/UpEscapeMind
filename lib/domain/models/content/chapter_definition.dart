import '../../../core/errors/app_exceptions.dart';
import 'parse_utils.dart';
import 'prerequisites.dart';

/// `assets/content/chapters/*.json` — `type: "chapter"`.
class ChapterDefinition {
  const ChapterDefinition({
    required this.id,
    required this.titleKey,
    required this.order,
    required this.roomIds,
    required this.unlockConditions,
    this.descriptionKey,
    this.endingSceneId,
  });

  final String id;
  final String titleKey;
  final String? descriptionKey;
  final int order;
  final List<String> roomIds;
  final List<Prerequisite> unlockConditions;
  final String? endingSceneId;

  factory ChapterDefinition.fromJson(
    Map<String, dynamic> json,
    String filePath,
  ) {
    if (json['type'] != 'chapter') {
      throw ContentValidationException('$filePath: expected "type": "chapter"');
    }
    reqSchemaVersion(json, filePath);
    return ChapterDefinition(
      id: reqString(json, 'id', filePath),
      titleKey: reqString(json, 'titleKey', filePath),
      descriptionKey: optString(json, 'descriptionKey', filePath),
      order: reqInt(json, 'order', filePath),
      roomIds: reqStringList(json, 'roomIds', filePath),
      unlockConditions: _parseConditions(json, filePath),
      endingSceneId: optString(json, 'endingSceneId', filePath),
    );
  }

  static List<Prerequisite> _parseConditions(
    Map<String, dynamic> json,
    String filePath,
  ) {
    final raw = json['unlockConditions'];
    if (raw == null) return const [];
    return [
      for (final entry in reqMapList(json, 'unlockConditions', filePath))
        Prerequisite.fromJson(entry, filePath),
    ];
  }
}
