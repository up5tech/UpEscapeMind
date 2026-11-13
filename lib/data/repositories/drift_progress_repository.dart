import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../domain/models/progress.dart';
import '../database/app_database.dart';
import 'progress_repository.dart';

/// Drift/SQLite implementation of [ProgressRepository].
///
/// Every [saveProgress] rewrites the slot's rows inside a single transaction,
/// so a durable action never lands partially. Primary keys keep re-saves
/// idempotent — no duplicate rows, ever.
class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._db);

  final AppDatabase _db;

  @override
  Future<GameProgress?> loadProgress(String saveSlotId) async {
    final slot = await (_db.select(
      _db.saveSlots,
    )..where((s) => s.id.equals(saveSlotId))).getSingleOrNull();
    if (slot == null) return null;

    if (slot.schemaVersion > AppConstants.saveSchemaVersion) {
      throw SaveDataException(
        'Save slot "$saveSlotId" uses schema v${slot.schemaVersion}, '
        'but this build supports v${AppConstants.saveSchemaVersion}',
      );
    }

    final unlocked = await (_db.select(
      _db.unlockedRooms,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final solved = await (_db.select(
      _db.solvedPuzzles,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final collected = await (_db.select(
      _db.collectedItems,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final consumed = await (_db.select(
      _db.consumedItems,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final clues = await (_db.select(
      _db.discoveredClues,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final chapters = await (_db.select(
      _db.completedChapters,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final hints = await (_db.select(
      _db.revealedHints,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();
    final states = await (_db.select(
      _db.puzzleStates,
    )..where((r) => r.saveSlotId.equals(saveSlotId))).get();

    return GameProgress(
      saveSlotId: saveSlotId,
      currentRoomId: slot.currentRoomId,
      unlockedRoomIds: [for (final r in unlocked) r.roomId],
      solvedPuzzleIds: [for (final r in solved) r.puzzleId],
      collectedItemIds: [for (final r in collected) r.itemId],
      consumedItemIds: [for (final r in consumed) r.itemId],
      discoveredClueIds: [for (final r in clues) r.clueId],
      completedChapterIds: [for (final r in chapters) r.chapterId],
      revealedHintLevels: {for (final r in hints) r.puzzleId: r.maxLevel},
      puzzleStates: {for (final r in states) r.puzzleId: r.stateJson},
      playTimeMs: slot.playTimeMs,
    );
  }

  @override
  Future<void> saveProgress(GameProgress progress) {
    return _db.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final slotId = progress.saveSlotId;

      await _db
          .into(_db.saveSlots)
          .insertOnConflictUpdate(
            SaveSlotsCompanion(
              id: Value(slotId),
              schemaVersion: Value(AppConstants.saveSchemaVersion),
              currentRoomId: Value(progress.currentRoomId),
              playTimeMs: Value(progress.playTimeMs),
              updatedAtMs: Value(now),
            ),
          );

      // Delete-then-insert per collection inside the transaction keeps the
      // write atomic and idempotent.
      await (_db.delete(
        _db.unlockedRooms,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.solvedPuzzles,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.puzzleStates,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.collectedItems,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.consumedItems,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.discoveredClues,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.completedChapters,
      )..where((t) => t.saveSlotId.equals(slotId))).go();
      await (_db.delete(
        _db.revealedHints,
      )..where((t) => t.saveSlotId.equals(slotId))).go();

      await _db.batch((b) {
        b.insertAll(_db.unlockedRooms, [
          for (final id in progress.unlockedRoomIds)
            UnlockedRoomsCompanion.insert(saveSlotId: slotId, roomId: id),
        ]);
        b.insertAll(_db.solvedPuzzles, [
          for (final id in progress.solvedPuzzleIds)
            SolvedPuzzlesCompanion.insert(
              saveSlotId: slotId,
              puzzleId: id,
              solvedAtMs: now,
            ),
        ]);
        b.insertAll(_db.puzzleStates, [
          for (final e in progress.puzzleStates.entries)
            PuzzleStatesCompanion.insert(
              saveSlotId: slotId,
              puzzleId: e.key,
              stateJson: e.value,
            ),
        ]);
        b.insertAll(_db.collectedItems, [
          for (final id in progress.collectedItemIds)
            CollectedItemsCompanion.insert(saveSlotId: slotId, itemId: id),
        ]);
        b.insertAll(_db.consumedItems, [
          for (final id in progress.consumedItemIds)
            ConsumedItemsCompanion.insert(saveSlotId: slotId, itemId: id),
        ]);
        b.insertAll(_db.discoveredClues, [
          for (final id in progress.discoveredClueIds)
            DiscoveredCluesCompanion.insert(saveSlotId: slotId, clueId: id),
        ]);
        b.insertAll(_db.completedChapters, [
          for (final id in progress.completedChapterIds)
            CompletedChaptersCompanion.insert(
              saveSlotId: slotId,
              chapterId: id,
              completedAtMs: now,
            ),
        ]);
        b.insertAll(_db.revealedHints, [
          for (final e in progress.revealedHintLevels.entries)
            RevealedHintsCompanion.insert(
              saveSlotId: slotId,
              puzzleId: e.key,
              maxLevel: e.value,
            ),
        ]);
      });
    });
  }

  @override
  Future<void> resetProgress(String saveSlotId) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.saveSlots,
      )..where((t) => t.id.equals(saveSlotId))).go();
      await (_db.delete(
        _db.unlockedRooms,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.solvedPuzzles,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.puzzleStates,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.collectedItems,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.consumedItems,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.discoveredClues,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.completedChapters,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
      await (_db.delete(
        _db.revealedHints,
      )..where((t) => t.saveSlotId.equals(saveSlotId))).go();
    });
  }
}
