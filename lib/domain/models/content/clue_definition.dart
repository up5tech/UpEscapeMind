import '../../../core/errors/app_exceptions.dart';
import 'parse_utils.dart';

/// `assets/content/clues/*.json` — `type: "clue"`.
/// Journal notes and story fragments discovered during play.
class ClueDefinition {
  const ClueDefinition({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.sourceRoomId,
    this.optional = false,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final String sourceRoomId;
  final bool optional;

  factory ClueDefinition.fromJson(Map<String, dynamic> json, String filePath) {
    if (json['type'] != 'clue') {
      throw ContentValidationException('$filePath: expected "type": "clue"');
    }
    return ClueDefinition(
      id: reqString(json, 'id', filePath),
      titleKey: reqString(json, 'titleKey', filePath),
      bodyKey: reqString(json, 'bodyKey', filePath),
      sourceRoomId: reqString(json, 'sourceRoomId', filePath),
      optional: reqBool(json, 'optional', filePath, mandatory: false),
    );
  }
}
