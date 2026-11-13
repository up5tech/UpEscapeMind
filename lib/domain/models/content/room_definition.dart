import '../../../core/errors/app_exceptions.dart';
import 'hotspot_definition.dart';
import 'parse_utils.dart';
import 'prerequisites.dart';

/// A navigation exit from a room to an adjacent unlocked room.
class RoomExit {
  const RoomExit({required this.targetRoomId, this.labelKey});

  final String targetRoomId;
  final String? labelKey;

  factory RoomExit.fromJson(Map<String, dynamic> json, String filePath) {
    return RoomExit(
      targetRoomId: reqString(
        json,
        'targetRoomId',
        filePath,
        fieldPrefix: 'exitConnections[]',
      ),
      labelKey: optString(
        json,
        'labelKey',
        filePath,
        fieldPrefix: 'exitConnections[]',
      ),
    );
  }
}

/// `assets/content/rooms/*.json` — `type: "room"`.
class RoomDefinition {
  const RoomDefinition({
    required this.id,
    required this.chapterId,
    required this.titleKey,
    required this.backgroundAsset,
    required this.hotspots,
    required this.entryConditions,
    required this.exitConnections,
    this.descriptionKey,
    this.foregroundAssets = const [],
    this.ambientAudioAsset,
  });

  final String id;
  final String chapterId;
  final String titleKey;
  final String? descriptionKey;
  final String backgroundAsset;
  final List<String> foregroundAssets;
  final List<HotspotDefinition> hotspots;
  final List<Prerequisite> entryConditions;
  final List<RoomExit> exitConnections;
  final String? ambientAudioAsset;

  factory RoomDefinition.fromJson(Map<String, dynamic> json, String filePath) {
    if (json['type'] != 'room') {
      throw ContentValidationException('$filePath: expected "type": "room"');
    }
    reqSchemaVersion(json, filePath);

    final hotspotMaps = reqMapList(json, 'hotspots', filePath);
    final hotspots = <HotspotDefinition>[
      for (var i = 0; i < hotspotMaps.length; i++)
        HotspotDefinition.fromJson(
          hotspotMaps[i],
          filePath,
          fieldPrefix: 'hotspots[$i]',
        ),
    ];

    return RoomDefinition(
      id: reqString(json, 'id', filePath),
      chapterId: reqString(json, 'chapterId', filePath),
      titleKey: reqString(json, 'titleKey', filePath),
      descriptionKey: optString(json, 'descriptionKey', filePath),
      backgroundAsset: reqString(json, 'backgroundAsset', filePath),
      foregroundAssets: json['foregroundAssets'] == null
          ? const []
          : reqStringList(json, 'foregroundAssets', filePath),
      hotspots: hotspots,
      entryConditions: _parseConditions(json, 'entryConditions', filePath),
      exitConnections: _parseExits(json, filePath),
      ambientAudioAsset: optString(json, 'ambientAudioAsset', filePath),
    );
  }

  static List<Prerequisite> _parseConditions(
    Map<String, dynamic> json,
    String key,
    String filePath,
  ) {
    final raw = json[key];
    if (raw == null) return const [];
    return [
      for (final entry in reqMapList(json, key, filePath))
        Prerequisite.fromJson(entry, filePath),
    ];
  }

  static List<RoomExit> _parseExits(
    Map<String, dynamic> json,
    String filePath,
  ) {
    final raw = json['exitConnections'];
    if (raw == null) return const [];
    return [
      for (final entry in reqMapList(json, 'exitConnections', filePath))
        RoomExit.fromJson(entry, filePath),
    ];
  }
}
