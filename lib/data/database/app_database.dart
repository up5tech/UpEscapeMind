import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database for durable game progress.
///
/// Schema version lives in [AppConstants.saveSchemaVersion] and per-slot
/// `save_slots.schemaVersion`. Bump both together and add an `onUpgrade`
/// migration — never edit released table shapes in place.
@DriftDatabase(
  tables: [
    SaveSlots,
    UnlockedRooms,
    SolvedPuzzles,
    PuzzleStates,
    CollectedItems,
    ConsumedItems,
    DiscoveredClues,
    CompletedChapters,
    RevealedHints,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'up_escape_mind'));

  /// Test constructor — inject any [QueryExecutor] (e.g. `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => AppConstants.saveSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Future schema versions add ordered migrations here.
      // Example:
      // if (from < 2) { await m.addColumn(...); }
    },
  );
}
