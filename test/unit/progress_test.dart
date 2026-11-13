import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/domain/models/progress.dart';

void main() {
  group('GameProgress', () {
    test('newGame unlocks only the entry room', () {
      final progress = GameProgress.newGame('slot_main', 'room_entrance');

      expect(progress.currentRoomId, 'room_entrance');
      expect(progress.unlockedRoomIds, ['room_entrance']);
      expect(progress.hasSave, isTrue);
      expect(progress.isRoomUnlocked('room_study'), isFalse);
    });

    test('json round-trip preserves all fields', () {
      final progress = GameProgress(
        saveSlotId: 'slot_main',
        currentRoomId: 'room_study',
        unlockedRoomIds: const ['room_entrance', 'room_study'],
        solvedPuzzleIds: const ['puz_eh_door_lock'],
        collectedItemIds: const ['item_brass_key'],
        discoveredClueIds: const ['clue_note_1'],
        revealedHintLevels: const {'puz_eh_door_lock': 2},
        playTimeMs: 12345,
      );

      final restored = GameProgress.fromJson(progress.toJson());

      expect(restored.saveSlotId, progress.saveSlotId);
      expect(restored.currentRoomId, progress.currentRoomId);
      expect(restored.unlockedRoomIds, progress.unlockedRoomIds);
      expect(restored.solvedPuzzleIds, progress.solvedPuzzleIds);
      expect(restored.collectedItemIds, progress.collectedItemIds);
      expect(restored.discoveredClueIds, progress.discoveredClueIds);
      expect(restored.revealedHintLevels, progress.revealedHintLevels);
      expect(restored.playTimeMs, progress.playTimeMs);
      expect(restored.hintLevelFor('puz_eh_door_lock'), 2);
      expect(restored.hintLevelFor('unknown'), 0);
    });

    test('fromJson tolerates missing optional fields', () {
      final progress = GameProgress.fromJson({'saveSlotId': 'slot_main'});

      expect(progress.currentRoomId, isNull);
      expect(progress.unlockedRoomIds, isEmpty);
      expect(progress.playTimeMs, 0);
    });
  });
}
