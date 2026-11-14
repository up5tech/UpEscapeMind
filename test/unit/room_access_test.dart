import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/data/content/content_loader.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/content/room_definition.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/domain/rules/room_access.dart';

/// Phase 12: chapter-gated room access. Later chapters must stay locked
/// until the previous chapter is completed — for fresh saves AND for
/// saves written before Chapter 2 shipped (no migration needed).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentCatalog catalog;

  setUpAll(() async {
    catalog = await const ContentLoader().load(
      assetExists: (path) async {
        try {
          await rootBundle.load(path);
          return true;
        } catch (_) {
          return false;
        }
      },
    );
  });

  RoomDefinition get(String id) => catalog.roomsById[id]!;

  test('fresh save can only reach Chapter 1 rooms', () {
    final p = GameProgress.newGame('slot', 'room_entrance');
    expect(isRoomAccessible(catalog, p, get('room_entrance')), isTrue);
    for (final id in [
      'room_study',
      'room_workshop',
      'room_gallery',
      'room_observatory',
      'room_conservatory',
      'room_pump_room',
      'room_orangery',
    ]) {
      expect(isRoomAccessible(catalog, p, get(id)), isFalse, reason: id);
    }
  });

  test('Chapter 2 stays locked while Chapter 1 is incomplete', () {
    final p = GameProgress.newGame(
      'slot',
      'room_entrance',
    ).copyWith(unlockedRoomIds: ['room_entrance', 'room_study']);
    for (final id in ['room_conservatory', 'room_pump_room', 'room_orangery']) {
      expect(isRoomAccessible(catalog, p, get(id)), isFalse, reason: id);
    }
  });

  test('Chapter 1 completion opens the Chapter 2 entry room only', () {
    final p = GameProgress.newGame(
      'slot',
      'room_entrance',
    ).copyWith(completedChapterIds: const ['chapter_01']);
    expect(isRoomAccessible(catalog, p, get('room_conservatory')), isTrue);
    // Non-entry rooms still require their own unlocks.
    expect(isRoomAccessible(catalog, p, get('room_pump_room')), isFalse);
    expect(isRoomAccessible(catalog, p, get('room_orangery')), isFalse);
  });

  test('explicit unlocks still work inside an unlocked chapter', () {
    final p = GameProgress.newGame('slot', 'room_entrance').copyWith(
      completedChapterIds: const ['chapter_01'],
      unlockedRoomIds: const [
        'room_entrance',
        'room_conservatory',
        'room_pump_room',
      ],
    );
    expect(isRoomAccessible(catalog, p, get('room_pump_room')), isTrue);
    expect(isRoomAccessible(catalog, p, get('room_orangery')), isFalse);
  });
}
