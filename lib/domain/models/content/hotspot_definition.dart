import '../../../core/errors/app_exceptions.dart';
import 'parse_utils.dart';
import 'prerequisites.dart';

/// How a hotspot behaves when tapped.
enum HotspotInteraction {
  inspect('inspect'),
  puzzle('puzzle'),
  collectItem('collect_item'),
  discoverClue('discover_clue'),
  navigate('navigate'),
  useItem('use_item');

  const HotspotInteraction(this.jsonValue);

  final String jsonValue;

  static HotspotInteraction parse(String value, String filePath, String field) {
    for (final type in values) {
      if (type.jsonValue == value) return type;
    }
    throw ContentValidationException(
      '$filePath: "$field" has unknown interactionType "$value"',
    );
  }
}

/// Normalized hotspot bounds relative to the scene image (0.0–1.0).
class HotspotBounds {
  const HotspotBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  factory HotspotBounds.fromJson(
    Map<String, dynamic> json,
    String filePath,
    String fieldPrefix,
  ) {
    double read(String key) {
      final value = json[key];
      if (value is! num) {
        throw ContentValidationException(
          '$filePath: "$fieldPrefix.$key" must be a number',
        );
      }
      return value.toDouble();
    }

    return HotspotBounds(
      x: read('x'),
      y: read('y'),
      width: read('width'),
      height: read('height'),
    );
  }
}

/// `hotspots[]` entry inside a room definition.
class HotspotDefinition {
  const HotspotDefinition({
    required this.id,
    required this.bounds,
    required this.labelKey,
    required this.interactionType,
    this.targetId,
    this.descriptionKey,
    this.inspectionAsset,
    this.visibilityConditions = const [],
  });

  final String id;
  final HotspotBounds bounds;
  final String labelKey;
  final HotspotInteraction interactionType;

  /// Referenced entity: puzzle id, item id, clue id, or room id,
  /// depending on [interactionType].
  final String? targetId;
  final String? descriptionKey;
  final String? inspectionAsset;
  final List<Prerequisite> visibilityConditions;

  factory HotspotDefinition.fromJson(
    Map<String, dynamic> json,
    String filePath, {
    String fieldPrefix = 'hotspots[]',
  }) {
    final boundsJson = json['bounds'];
    if (boundsJson is! Map<String, dynamic>) {
      throw ContentValidationException(
        '$filePath: "$fieldPrefix.bounds" must be an object',
      );
    }

    final interactionRaw = json['interactionType'];
    if (interactionRaw is! String) {
      throw ContentValidationException(
        '$filePath: "$fieldPrefix.interactionType" must be a string',
      );
    }

    final visibilityRaw = json['visibilityConditions'];
    final visibility = visibilityRaw == null
        ? const <Prerequisite>[]
        : <Prerequisite>[
            for (final entry in reqMapList(
              json,
              'visibilityConditions',
              filePath,
              fieldPrefix: fieldPrefix,
            ))
              Prerequisite.fromJson(entry, filePath),
          ];

    return HotspotDefinition(
      id: reqString(json, 'id', filePath, fieldPrefix: fieldPrefix),
      bounds: HotspotBounds.fromJson(
        boundsJson,
        filePath,
        '$fieldPrefix.bounds',
      ),
      labelKey: reqString(json, 'labelKey', filePath, fieldPrefix: fieldPrefix),
      interactionType: HotspotInteraction.parse(
        interactionRaw,
        filePath,
        '$fieldPrefix.interactionType',
      ),
      targetId: optString(json, 'targetId', filePath, fieldPrefix: fieldPrefix),
      descriptionKey: optString(
        json,
        'descriptionKey',
        filePath,
        fieldPrefix: fieldPrefix,
      ),
      inspectionAsset: optString(
        json,
        'inspectionAsset',
        filePath,
        fieldPrefix: fieldPrefix,
      ),
      visibilityConditions: visibility,
    );
  }
}
