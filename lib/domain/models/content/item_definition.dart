import '../../../core/errors/app_exceptions.dart';
import 'parse_utils.dart';

/// `assets/content/items/*.json` — `type: "item"`.
class ItemDefinition {
  const ItemDefinition({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconAsset,
    this.inspectionAsset,
    this.tags = const [],
    this.canBeCombined = false,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconAsset;
  final String? inspectionAsset;
  final List<String> tags;
  final bool canBeCombined;

  factory ItemDefinition.fromJson(Map<String, dynamic> json, String filePath) {
    if (json['type'] != 'item') {
      throw ContentValidationException('$filePath: expected "type": "item"');
    }
    return ItemDefinition(
      id: reqString(json, 'id', filePath),
      nameKey: reqString(json, 'nameKey', filePath),
      descriptionKey: reqString(json, 'descriptionKey', filePath),
      iconAsset: reqString(json, 'iconAsset', filePath),
      inspectionAsset: optString(json, 'inspectionAsset', filePath),
      tags: json['tags'] == null
          ? const []
          : reqStringList(json, 'tags', filePath),
      canBeCombined: reqBool(json, 'canBeCombined', filePath, mandatory: false),
    );
  }
}
