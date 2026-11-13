import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/data/content/content_validator.dart';
import 'package:up_escape_mind/domain/models/content/content_models.dart';

/// Loads every `assets/content/**/*.json` file from disk (not rootBundle)
/// so validation tests exercise the real parser + validator end to end.
ContentCatalog _loadCatalogFromDisk() {
  final chapters = <ChapterDefinition>[];
  final rooms = <RoomDefinition>[];
  final puzzles = <PuzzleDefinition>[];
  final items = <ItemDefinition>[];
  final combinations = <ItemCombinationDefinition>[];
  final clues = <ClueDefinition>[];

  final manifestFile = File('assets/content/manifest.json');
  expect(
    manifestFile.existsSync(),
    isTrue,
    reason: 'assets/content/manifest.json must exist',
  );
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;

  for (final entry in manifest['files'] as List) {
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

  test('bundled sample content passes full validation', () async {
    await ContentValidator.validate(
      catalog,
      assetExists: (p) async => _assetExists(p),
      localizationKeys: _localizationKeys(),
    );
  });

  test('catalog contains the expected sample entities', () {
    expect(catalog.chapters.single.id, 'chapter_sample');
    expect(
      catalog.rooms.map((r) => r.id),
      containsAll(['room_sample', 'room_sample_exit']),
    );
    expect(catalog.puzzles.single.id, 'puz_sample_lock');
    expect(
      catalog.items.map((i) => i.id),
      containsAll(['item_sample_key', 'item_sample_gear', 'item_sample_hook']),
    );
    expect(catalog.combinations.single.id, 'comb_sample_hook');
    expect(
      catalog.clues.map((c) => c.id),
      containsAll(['clue_sample_note', 'clue_sample_lock_opened']),
    );
  });

  test('missing asset is reported', () async {
    final bad = RoomDefinition.fromJson({
      'type': 'room',
      'schemaVersion': 1,
      'id': 'room_bad_asset',
      'chapterId': 'chapter_sample',
      'titleKey': 'roomSampleTitle',
      'backgroundAsset': 'assets/art/rooms/does_not_exist.png',
      'hotspots': <dynamic>[],
    }, 'rooms/room_bad_asset.json');
    final badCatalog = ContentCatalog(
      chapters: catalog.chapters,
      rooms: [...catalog.rooms, bad],
      puzzles: catalog.puzzles,
      items: catalog.items,
      combinations: catalog.combinations,
      clues: catalog.clues,
    );
    // room_bad_asset is not in any chapter.roomIds — that's fine; validation
    // only requires chapter->room direction.
    await expectLater(
      ContentValidator.validate(
        badCatalog,
        assetExists: (p) async => _assetExists(p),
      ),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          contains('missing asset file'),
        ),
      ),
    );
  });

  test('out-of-bounds hotspot is reported with room and hotspot id', () async {
    final badRoomJson = {
      'type': 'room',
      'schemaVersion': 1,
      'id': 'room_bad_bounds',
      'chapterId': 'chapter_sample',
      'titleKey': 'roomSampleTitle',
      'backgroundAsset': 'assets/art/rooms/room_sample.png',
      'hotspots': [
        {
          'id': 'hs_bad',
          'bounds': {'x': 0.9, 'y': 0.1, 'width': 0.5, 'height': 0.2},
          'labelKey': 'hotspotSampleNote',
          'interactionType': 'inspect',
        },
      ],
    };
    final badRoom = RoomDefinition.fromJson(badRoomJson, 'rooms/x.json');
    final badCatalog = ContentCatalog(
      chapters: catalog.chapters,
      rooms: [...catalog.rooms, badRoom],
      puzzles: catalog.puzzles,
      items: catalog.items,
      combinations: catalog.combinations,
      clues: catalog.clues,
    );
    await expectLater(
      ContentValidator.validate(badCatalog),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('room_bad_bounds'),
            contains('hs_bad'),
            contains('extends past scene edge'),
          ),
        ),
      ),
    );
  });

  test('unknown puzzle prerequisite target is reported', () async {
    final badPuzzleJson = {
      'type': 'puzzle',
      'schemaVersion': 1,
      'id': 'puz_bad_ref',
      'roomId': 'room_sample',
      'hotspotId': 'hs_sample_door_lock',
      'puzzleType': 'keypad',
      'titleKey': 'puzzleSampleLockTitle',
      'instructionsKey': 'puzzleSampleLockInstructions',
      'initialState': <String, dynamic>{},
      'solutionConfig': {'code': '0000'},
      'validationConfig': <String, dynamic>{},
      'prerequisites': [
        {'type': 'puzzle_solved', 'targetId': 'puz_does_not_exist'},
      ],
      'successActions': <dynamic>[],
      'hints': [
        {'level': 1, 'textKey': 'puzzleSampleLockHint1'},
      ],
      'resetPolicy': 'keep',
    };
    final badPuzzle = PuzzleDefinition.fromJson(
      badPuzzleJson,
      'puzzles/puz_bad_ref.json',
    );
    final badCatalog = ContentCatalog(
      chapters: catalog.chapters,
      rooms: catalog.rooms,
      puzzles: [...catalog.puzzles, badPuzzle],
      items: catalog.items,
      combinations: catalog.combinations,
      clues: catalog.clues,
    );
    await expectLater(
      ContentValidator.validate(badCatalog),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          allOf(contains('puz_bad_ref'), contains('puz_does_not_exist')),
        ),
      ),
    );
  });

  test('circular unlock dependency is detected', () async {
    // room_a entry requires puzzle_x solved; puzzle_x (in room_b) requires
    // room_a unlocked -> cycle.
    RoomDefinition room(String id, List<Prerequisite> entry) => RoomDefinition(
      id: id,
      chapterId: 'chapter_sample',
      titleKey: 'roomSampleTitle',
      backgroundAsset: 'assets/art/rooms/room_sample.png',
      hotspots: const [],
      entryConditions: entry,
      exitConnections: const [],
    );

    final roomA = room('room_a', const [
      Prerequisite(type: PrerequisiteType.puzzleSolved, targetId: 'puz_x'),
    ]);
    final roomB = room('room_b', const []);
    final puzX = PuzzleDefinition(
      id: 'puz_x',
      roomId: 'room_b',
      hotspotId: 'hs_none',
      type: PuzzleType.keypad,
      titleKey: 'puzzleSampleLockTitle',
      instructionsKey: 'puzzleSampleLockInstructions',
      initialState: const {},
      solutionConfig: const {'code': '1'},
      validationConfig: const {},
      prerequisites: const [
        Prerequisite(type: PrerequisiteType.roomUnlocked, targetId: 'room_a'),
      ],
      successActions: const [],
      hints: const [],
      resetPolicy: ResetPolicy.keep,
    );

    final badCatalog = ContentCatalog(
      chapters: catalog.chapters,
      rooms: [roomA, roomB],
      puzzles: [puzX],
      items: catalog.items,
      combinations: catalog.combinations,
      clues: catalog.clues,
    );

    // room_b has no hotspot hs_none -> that error is expected too; we only
    // assert the cycle is reported.
    await expectLater(
      ContentValidator.validate(badCatalog),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          contains('circular unlock dependency'),
        ),
      ),
    );
  });

  test('missing schemaVersion fails parsing', () {
    expect(
      () => ChapterDefinition.fromJson({
        'type': 'chapter',
        'id': 'chapter_x',
        'titleKey': 'chapterSampleTitle',
        'order': 1,
        'roomIds': ['room_sample'],
      }, 'chapters/chapter_x.json'),
      throwsA(isA<ContentValidationException>()),
    );
  });

  test('missing required field reports file and field', () {
    expect(
      () => ItemDefinition.fromJson({
        'type': 'item',
        'id': 'item_x',
        // nameKey missing
        'descriptionKey': 'itemSampleKeyDesc',
        'iconAsset': 'assets/art/items/item_sample_key.png',
      }, 'items/item_x.json'),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          allOf(contains('items/item_x.json'), contains('nameKey')),
        ),
      ),
    );
  });
}
