import 'package:drift/drift.dart';

/// Durable progress tables (PLAN.md §11.1). Content definitions themselves
/// are never duplicated here — only stable IDs and state.

/// One row per save slot. MVP ships a single slot (`slot_main`).
class SaveSlots extends Table {
  TextColumn get id => text()();

  /// Save schema version — bump with migrations in `AppDatabase.onUpgrade`.
  IntColumn get schemaVersion => integer()();

  TextColumn get currentRoomId => text().nullable()();
  IntColumn get playTimeMs => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class UnlockedRooms extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get roomId => text()();

  @override
  Set<Column> get primaryKey => {saveSlotId, roomId};
}

class SolvedPuzzles extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get puzzleId => text()();
  IntColumn get solvedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {saveSlotId, puzzleId};
}

/// Serialized in-progress puzzle input, per the puzzle's `resetPolicy`.
class PuzzleStates extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get puzzleId => text()();
  TextColumn get stateJson => text()();

  @override
  Set<Column> get primaryKey => {saveSlotId, puzzleId};
}

class CollectedItems extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get itemId => text()();

  @override
  Set<Column> get primaryKey => {saveSlotId, itemId};
}

class ConsumedItems extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get itemId => text()();

  @override
  Set<Column> get primaryKey => {saveSlotId, itemId};
}

class DiscoveredClues extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get clueId => text()();

  @override
  Set<Column> get primaryKey => {saveSlotId, clueId};
}

class CompletedChapters extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get chapterId => text()();
  IntColumn get completedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {saveSlotId, chapterId};
}

/// puzzleId -> highest revealed hint level (1-3).
class RevealedHints extends Table {
  TextColumn get saveSlotId => text()();
  TextColumn get puzzleId => text()();
  IntColumn get maxLevel => integer()();

  @override
  Set<Column> get primaryKey => {saveSlotId, puzzleId};
}
