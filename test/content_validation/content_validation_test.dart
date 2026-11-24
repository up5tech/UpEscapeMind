import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/data/content/content_validator.dart';
import 'package:up_escape_mind/domain/models/content/content_models.dart';

/// Loads every content JSON referenced by a manifest from disk (not
/// rootBundle) so validation tests exercise the real parser + validator
/// end to end.
ContentCatalog _loadCatalogFromDisk({String manifest = 'manifest.json'}) {
  final chapters = <ChapterDefinition>[];
  final rooms = <RoomDefinition>[];
  final puzzles = <PuzzleDefinition>[];
  final items = <ItemDefinition>[];
  final combinations = <ItemCombinationDefinition>[];
  final clues = <ClueDefinition>[];

  final manifestFile = File('assets/content/$manifest');
  expect(
    manifestFile.existsSync(),
    isTrue,
    reason: 'assets/content/$manifest must exist',
  );
  final decoded =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;

  for (final entry in decoded['files'] as List) {
    final rel = entry as String;
    final filePath = 'assets/content/$rel';
    final json =
        jsonDecode(File(filePath).readAsStringSync()) as Map<String, dynamic>;
    switch (json['type']) {
      case 'chapter':
        chapters.add(ChapterDefinition.fromJson(json, rel));
      case 'room':
        rooms.add(RoomDefinition.fromJson(json, rel));
      case 'puzzle':
        puzzles.add(PuzzleDefinition.fromJson(json, rel));
      case 'item':
        items.add(ItemDefinition.fromJson(json, rel));
      case 'item_combination':
        combinations.add(ItemCombinationDefinition.fromJson(json, rel));
      case 'clue':
        clues.add(ClueDefinition.fromJson(json, rel));
      default:
        fail('unknown content type in $rel');
    }
  }

  return ContentCatalog(
    chapters: chapters,
    rooms: rooms,
    puzzles: puzzles,
    items: items,
    combinations: combinations,
    clues: clues,
  );
}

/// Union of keys defined in the bundled content string tables
/// (`assets/content/localization/strings_*.json`).
Set<String> _localizationKeys() {
  final keys = <String>{};
  for (final locale in ['en', 'vi']) {
    final table = jsonDecode(
      File('assets/content/localization/strings_$locale.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    keys.addAll(table.keys);
  }
  return keys;
}

bool _assetExists(String path) => File(path).existsSync();

void main() {
  late ContentCatalog catalog;

  setUpAll(() {
    catalog = _loadCatalogFromDisk();
  });

  test('Chapter 1 production content passes full validation', () async {
    await ContentValidator.validate(
      catalog,
      assetExists: (p) async => _assetExists(p),
      localizationKeys: _localizationKeys(),
    );
  });

  test('sample dev-fixture content also passes validation', () async {
    final sample = _loadCatalogFromDisk(manifest: 'manifest.sample.json');
    await ContentValidator.validate(
      sample,
      assetExists: (p) async => _assetExists(p),
      localizationKeys: _localizationKeys(),
    );
  });

  test('catalog contains the full Chapter 1 entity set', () {
    final ch1 = catalog.chaptersById['chapter_01']!;
    expect(ch1.roomIds, [
      'room_entrance',
      'room_study',
      'room_workshop',
      'room_gallery',
      'room_observatory',
    ]);
    expect(catalog.rooms.where((r) => r.chapterId == 'chapter_01').length, 5);
    expect(
      catalog.puzzles.where((p) => p.roomId.startsWith('room_')).length,
      greaterThanOrEqualTo(19),
    );
    expect(
      catalog.items.map((i) => i.id),
      containsAll([
        'item_clock_key',
        'item_lens',
        'item_brass_frame',
        'item_crank',
        'item_focus_lens',
      ]),
    );
    expect(catalog.combinationsById.keys, contains('comb_focus_lens'));
    expect(
      catalog.clues
          .where(
            (c) =>
                c.sourceRoomId.startsWith('room_entrance') ||
                c.sourceRoomId.startsWith('room_study') ||
                c.sourceRoomId.startsWith('room_workshop') ||
                c.sourceRoomId.startsWith('room_gallery') ||
                c.sourceRoomId.startsWith('room_observatory'),
          )
          .length,
      25,
    );
    // Sample entities must NOT ship in the production manifest.
    expect(
      catalog.puzzles.map((p) => p.id),
      isNot(contains('puz_sample_lock')),
    );
  });

  test('catalog contains the Chapter 2 entity set', () {
    final ch2 = catalog.chaptersById['chapter_02']!;
    expect(ch2.order, greaterThan(catalog.chaptersById['chapter_01']!.order));
    expect(ch2.roomIds, [
      'room_conservatory',
      'room_pump_room',
      'room_orangery',
    ]);
    // Chapter 2 opens only after Chapter 1 is completed.
    expect(ch2.unlockConditions.single.targetId, 'chapter_01');
    expect(catalog.rooms.where((r) => r.chapterId == 'chapter_02').length, 3);
    expect(
      catalog.puzzles
          .where(
            (p) =>
                p.roomId == 'room_conservatory' ||
                p.roomId == 'room_pump_room' ||
                p.roomId == 'room_orangery',
          )
          .length,
      10,
    );
    expect(
      catalog.items.map((i) => i.id),
      containsAll([
        'item_copper_ring',
        'item_glass_vial',
        'item_prismatic_lens',
        'item_steel_shim',
      ]),
    );
    expect(catalog.combinationsById.keys, contains('comb_prismatic_lens'));
    expect(
      catalog.clues
          .where(
            (c) =>
                c.sourceRoomId == 'room_conservatory' ||
                c.sourceRoomId == 'room_pump_room' ||
                c.sourceRoomId == 'room_orangery',
          )
          .length,
      15,
    );
  });

  test('missing asset is reported', () async {
    final bad = RoomDefinition.fromJson({
      'type': 'room',
      'schemaVersion': 1,
      'id': 'room_bad_asset',
      'chapterId': 'chapter_01',
      'titleKey': 'roomEntranceTitle',
      'backgroundAsset': 'assets/art/rooms/does_not_exist.png',
      'hotspots': <dynamic>[],
    }, 'rooms/room_bad_asset.json');
    final badCatalog = ContentCatalog(
      chapters: catalog.chapters,
      rooms: [bad],
      puzzles: const [],
      items: const [],
      combinations: const [],
      clues: const [],
    );
    await expectLater(
      ContentValidator.validate(
        badCatalog,
        assetExists: (p) async => _assetExists(p),
      ),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          contains('does_not_exist.png'),
        ),
      ),
    );
  });

  test('r2 room layers are parsed and validated', () async {
    final room = RoomDefinition.fromJson({
      'type': 'room',
      'schemaVersion': 1,
      'id': 'room_layers',
      'chapterId': 'chapter_01',
      'titleKey': 'roomEntranceTitle',
      'backgroundAsset': 'assets/art/rooms/room_sample.png',
      'midgroundAsset': 'assets/art/rooms/room_study.png',
      'lightingAsset': 'assets/art/effects/missing_light.webp',
      'foregroundAsset': 'assets/art/rooms/room_gallery.png',
      'solvedAsset': 'assets/art/rooms/room_sample_exit.png',
      'ambientParticle': 'dust',
      'hotspots': <dynamic>[],
    }, 'rooms/room_layers.json');
    expect(room.sceneLayers, [
      'assets/art/rooms/room_study.png',
      'assets/art/effects/missing_light.webp',
      'assets/art/rooms/room_gallery.png',
    ]);
    expect(room.artAssets, contains('assets/art/effects/missing_light.webp'));
    // The procedural particle token is not an asset path.
    expect(room.artAssets, isNot(contains('dust')));

    final layeredCatalog = ContentCatalog(
      chapters: catalog.chapters,
      rooms: [room],
      puzzles: const [],
      items: const [],
      combinations: const [],
      clues: const [],
    );
    await expectLater(
      ContentValidator.validate(
        layeredCatalog,
        assetExists: (p) async => _assetExists(p),
      ),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          contains('missing_light.webp'),
        ),
      ),
    );
  });

  test('unknown ids and broken references are reported', () async {
    expect(
      () => PuzzleDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'puzzle',
        'id': 'puz_bad',
        'roomId': 'room_ghost',
        'hotspotId': 'hs_ghost',
        'puzzleType': 'keypad',
        'titleKey': 'puz.puz_eh_door_lock.title',
        'instructionsKey': 'puz.puz_eh_door_lock.instr',
        'initialState': {'digits': 4},
        'solutionConfig': {'code': '1234'},
        'validationConfig': <String, dynamic>{},
        'hints': [
          {'level': 1, 'textKey': 'hint.puz_eh_door_lock.l1'},
        ],
        'resetPolicy': 'keep',
      }, 'puzzles/puz_bad.json'),
      isNot(throwsA(anything)),
    );
    // Cross-file references are checked by the validator, not the parser:
    final orphan = PuzzleDefinition.fromJson({
      'schemaVersion': 1,
      'type': 'puzzle',
      'id': 'puz_orphan',
      'roomId': 'room_entrance',
      'hotspotId': 'hs_nonexistent',
      'puzzleType': 'keypad',
      'titleKey': 'puz.puz_eh_door_lock.title',
      'instructionsKey': 'puz.puz_eh_door_lock.instr',
      'initialState': {'digits': 4},
      'solutionConfig': {'code': '1234'},
      'validationConfig': <String, dynamic>{},
      'hints': [
        {'level': 1, 'textKey': 'hint.puz_eh_door_lock.l1'},
      ],
      'resetPolicy': 'keep',
    }, 'puzzles/puz_orphan.json');
    final c = ContentCatalog(
      chapters: catalog.chapters,
      rooms: catalog.rooms,
      puzzles: [orphan],
      items: const [],
      combinations: const [],
      clues: const [],
    );
    await expectLater(
      ContentValidator.validate(c),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          contains('hs_nonexistent'),
        ),
      ),
    );
  });
}
