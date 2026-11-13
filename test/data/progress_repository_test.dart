import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:up_escape_mind/core/errors/app_exceptions.dart';
import 'package:up_escape_mind/data/repositories/shared_preferences_progress_repository.dart';
import 'package:up_escape_mind/domain/models/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPreferencesProgressRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = SharedPreferencesProgressRepository(prefs);
  });

  test('returns null when no save exists', () async {
    expect(await repo.loadProgress('slot_main'), isNull);
  });

  test('save then load round-trips progress', () async {
    final progress = GameProgress.newGame('slot_main', 'room_entrance');
    await repo.saveProgress(progress);

    final loaded = await repo.loadProgress('slot_main');
    expect(loaded?.unlockedRoomIds, ['room_entrance']);
    expect(loaded?.currentRoomId, 'room_entrance');
  });

  test('reset removes the save', () async {
    await repo.saveProgress(GameProgress.newGame('slot_main', 'room_entrance'));
    await repo.resetProgress('slot_main');
    expect(await repo.loadProgress('slot_main'), isNull);
  });

  test('corrupt payload throws SaveDataException', () async {
    await prefs.setString('progress.slot_main', 'not-json{{{');
    expect(
      () => repo.loadProgress('slot_main'),
      throwsA(isA<SaveDataException>()),
    );
  });

  test('wrong-typed payload throws SaveDataException', () async {
    await prefs.setString('progress.slot_main', jsonEncode({'saveSlotId': 42}));
    expect(
      () => repo.loadProgress('slot_main'),
      throwsA(isA<SaveDataException>()),
    );
  });
}
