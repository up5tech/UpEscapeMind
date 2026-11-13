import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/core/constants/app_constants.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/data/database/app_database.dart';
import 'package:up_escape_mind/data/repositories/drift_progress_repository.dart';
import 'package:up_escape_mind/domain/models/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftProgressRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftProgressRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  GameProgress sampleProgress() => GameProgress(
    saveSlotId: AppConstants.defaultSaveSlotId,
    currentRoomId: 'room_study',
    unlockedRoomIds: const ['room_entrance', 'room_study'],
    solvedPuzzleIds: const ['puz_eh_door_lock'],
    collectedItemIds: const ['item_brass_key'],
    consumedItemIds: const ['item_old_gear'],
    discoveredClueIds: const ['clue_note_1'],
    completedChapterIds: const [],
    revealedHintLevels: const {'puz_eh_door_lock': 2},
    puzzleStates: const {'puz_st_books': '{"step":1}'},
    playTimeMs: 42000,
  );

  test('returns null when no save exists', () async {
    expect(await repo.loadProgress('slot_main'), isNull);
  });

  test('save then load round-trips every field', () async {
    final progress = sampleProgress();
    await repo.saveProgress(progress);

    final loaded = await repo.loadProgress('slot_main');
    expect(loaded, isNotNull);
    expect(loaded!.currentRoomId, 'room_study');
    expect(loaded.unlockedRoomIds, containsAll(progress.unlockedRoomIds));
    expect(loaded.solvedPuzzleIds, progress.solvedPuzzleIds);
    expect(loaded.collectedItemIds, progress.collectedItemIds);
    expect(loaded.consumedItemIds, progress.consumedItemIds);
    expect(loaded.discoveredClueIds, progress.discoveredClueIds);
    expect(loaded.completedChapterIds, progress.completedChapterIds);
    expect(loaded.revealedHintLevels, progress.revealedHintLevels);
    expect(loaded.puzzleStates, progress.puzzleStates);
    expect(loaded.playTimeMs, 42000);
    expect(loaded.hasSave, isTrue);
  });

  test('re-saving identical progress is idempotent', () async {
    await repo.saveProgress(sampleProgress());
    await repo.saveProgress(sampleProgress());

    final counts = await Future.wait([
      db.select(db.unlockedRooms).get(),
      db.select(db.solvedPuzzles).get(),
      db.select(db.revealedHints).get(),
    ]);
    expect(counts[0], hasLength(2));
    expect(counts[1], hasLength(1));
    expect(counts[2], hasLength(1));
  });

  test('progress survives close and reopen (restart)', () async {
    final dir = await Directory.systemTemp.createTemp('uem_db_test');
    final file = File('${dir.path}/test.sqlite');
    addTearDown(() => dir.delete(recursive: true));

    final db1 = AppDatabase.forTesting(NativeDatabase(file));
    await DriftProgressRepository(db1).saveProgress(sampleProgress());
    await db1.close();

    // Simulate process restart: brand-new database instance on same file.
    final db2 = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db2.close);
    final loaded = await DriftProgressRepository(db2)
        .loadProgress(AppConstants.defaultSaveSlotId);

    expect(loaded?.solvedPuzzleIds, ['puz_eh_door_lock']);
    expect(loaded?.puzzleStates, {'puz_st_books': '{"step":1}'});
    expect(loaded?.currentRoomId, 'room_study');
  });

  test('unsupported save schema version throws SaveDataException', () async {
    await db
        .into(db.saveSlots)
        .insert(
          SaveSlotsCompanion.insert(
            id: 'slot_main',
            schemaVersion: AppConstants.saveSchemaVersion + 1,
            updatedAtMs: 0,
          ),
        );

    expect(
      () => repo.loadProgress('slot_main'),
      throwsA(isA<SaveDataException>()),
    );
  });

  test('reset removes the slot and all child rows', () async {
    await repo.saveProgress(sampleProgress());
    await repo.resetProgress('slot_main');

    expect(await repo.loadProgress('slot_main'), isNull);
    expect(await db.select(db.unlockedRooms).get(), isEmpty);
    expect(await db.select(db.solvedPuzzles).get(), isEmpty);
    expect(await db.select(db.revealedHints).get(), isEmpty);
  });

  test('saveSlots row tracks schema version and timestamp', () async {
    await repo.saveProgress(sampleProgress());
    final slot = await (db.select(
      db.saveSlots,
    )..where((s) => s.id.equals('slot_main'))).getSingle();
    expect(slot.schemaVersion, AppConstants.saveSchemaVersion);
    expect(slot.updatedAtMs, greaterThan(0));
  });
}
