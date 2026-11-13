import 'dart:convert';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/logging/app_log.dart';
import '../../domain/models/content/content_models.dart';
import 'content_validator.dart';

/// Loads all bundled content JSON from `assets/content/` via [rootBundle].
///
/// File list comes from `assets/content/manifest.json`. Every file declares
/// `schemaVersion` and a `type` discriminator; mismatches fail loudly.
/// Fully offline — no network access.
class ContentLoader {
  const ContentLoader({this.manifestName = 'manifest.json'});

  /// Which manifest under `assets/content/` to load. Tests use
  /// `manifest.sample.json` for the dev fixture entities; the app ships
  /// with the production `manifest.json` (Chapter 1).
  final String manifestName;

  static const _contentRoot = 'assets/content';

  /// Loads and cross-validates the full content catalog.
  ///
  /// [assetExists] verifies referenced art/audio assets. In the app this is
  /// backed by `rootBundle`; tests may pass a filesystem check instead.
  /// [localizationKeys] optionally enables player-facing key validation
  /// (tests supply the union of en/vi arb keys).
  Future<ContentCatalog> load({
    Future<bool> Function(String assetPath)? assetExists,
    Set<String>? localizationKeys,
  }) async {
    final manifestRaw = await _loadText('$_contentRoot/$manifestName');
    final manifest = _decodeObject(manifestRaw, manifestName);

    final schemaVersion = manifest['schemaVersion'];
    if (schemaVersion != AppConstants.contentSchemaVersion) {
      throw ContentValidationException(
        '$manifestName: unsupported schemaVersion $schemaVersion '
        '(expected ${AppConstants.contentSchemaVersion})',
      );
    }

    final files = manifest['files'];
    if (files is! List || files.isEmpty) {
      throw ContentValidationException(
        '$manifestName: "files" must be a non-empty list',
      );
    }

    final chapters = <ChapterDefinition>[];
    final rooms = <RoomDefinition>[];
    final puzzles = <PuzzleDefinition>[];
    final items = <ItemDefinition>[];
    final combinations = <ItemCombinationDefinition>[];
    final clues = <ClueDefinition>[];

    for (final entry in files) {
      if (entry is! String || entry.isEmpty) {
        throw ContentValidationException(
          '$manifestName: "files[]" entries must be non-empty strings',
        );
      }
      final path = '$_contentRoot/$entry';
      final raw = await _loadText(path);
      final json = _decodeObject(raw, entry);
      final type = json['type'];

      switch (type) {
        case 'chapter':
          chapters.add(ChapterDefinition.fromJson(json, entry));
        case 'room':
          rooms.add(RoomDefinition.fromJson(json, entry));
        case 'puzzle':
          puzzles.add(PuzzleDefinition.fromJson(json, entry));
        case 'item':
          items.add(ItemDefinition.fromJson(json, entry));
        case 'item_combination':
          combinations.add(ItemCombinationDefinition.fromJson(json, entry));
        case 'clue':
          clues.add(ClueDefinition.fromJson(json, entry));
        default:
          throw ContentValidationException(
            '$entry: unknown content "type" "$type"',
          );
      }
    }

    final catalog = ContentCatalog(
      chapters: chapters,
      rooms: rooms,
      puzzles: puzzles,
      items: items,
      combinations: combinations,
      clues: clues,
    );

    await ContentValidator.validate(
      catalog,
      assetExists: assetExists,
      localizationKeys: localizationKeys,
    );

    AppLog.debug(
      'Content loaded: ${chapters.length} chapters, ${rooms.length} rooms, '
      '${puzzles.length} puzzles, ${items.length} items, '
      '${combinations.length} combinations, ${clues.length} clues',
    );
    return catalog;
  }

  Future<String> _loadText(String path) async {
    try {
      return await rootBundle.loadString(path);
    } on FlutterError catch (e) {
      throw ContentValidationException('failed to load "$path": $e');
    }
  }

  Map<String, dynamic> _decodeObject(String raw, String path) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('top-level value is not an object');
      }
      return decoded;
    } on FormatException catch (e) {
      throw ContentValidationException('$path: invalid JSON — $e');
    }
  }
}
