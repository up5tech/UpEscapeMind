import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:up_escape_mind/core/constants/app_constants.dart';
import 'package:up_escape_mind/data/content/content_strings.dart';
import 'package:up_escape_mind/data/database/app_database.dart';
import 'package:up_escape_mind/data/repositories/asset_content_repository.dart';
import 'package:up_escape_mind/data/repositories/drift_progress_repository.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/main.dart';

/// Phase 9 UI smoke on PRODUCTION content: New Game → prologue (three
/// skippable cards) → Entrance Hall renders real hotspots; the tutorial
/// door keypad accepts the authored code 1024 and unlocks the study.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final ContentCatalog catalog;
  late final ContentStrings strings;

  setUpAll(() async {
    catalog = await AssetContentRepository().loadCatalog();
    strings = await ContentStrings.load();
  });

  late AppDatabase db;

  Future<void> pumpFreshApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      UpEscapeMindApp(
        prefs: prefs,
        database: db,
        catalog: catalog,
        strings: strings,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> flush(WidgetTester tester, [int times = 2]) async {
    for (var i = 0; i < times; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> newGame(WidgetTester tester) async {
    await tester.tap(find.text('Chơi mới'));
    await flush(tester);
  }

  /// First playthrough shows the how-to-play guide once after the
  /// prologue; pass through it to reach the room.
  Future<void> passHowToPlay(WidgetTester tester) async {
    final start = find.byKey(const ValueKey('how_to_play_start'));
    if (start.evaluate().isNotEmpty) {
      await tester.tap(start);
      await flush(tester, 3);
    }
  }

  testWidgets('New Game shows the localized prologue and enters the hall', (
    tester,
  ) async {
    await pumpFreshApp(tester);
    await newGame(tester);

    // Prologue screen visible (cards come from arb l10n, not content
    // strings — assert the chrome instead of the copy).
    expect(find.byKey(const ValueKey('prologue_skip')), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    // Advance through the three cards and enter the house.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('prologue_next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    await flush(tester, 3);

    // The one-time how-to-play guide sits between prologue and hall.
    expect(find.byKey(const ValueKey('how_to_play_start')), findsOneWidget);
    await passHowToPlay(tester);

    // Entrance Hall hotspots from production content.
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_grandfather_clock')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_study_door')),
      findsOneWidget,
    );
    // The locked study exit is not exposed.
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_study_exit')),
      findsNothing,
    );

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.currentRoomId, 'room_entrance');
    expect(saved.unlockedRoomIds, ['room_entrance']);

    // The note under the doormat is readable where it is found, not only
    // after hunting through the Journal.
    await tester.tap(find.byKey(const ValueKey('hotspot_hot_eh_doormat')));
    await flush(tester);
    expect(
      find.text('Đốt sáp nơi trăng ẩn — lên, xuống, lên.'),
      findsOneWidget,
    );
    expect(find.text('Đã lưu vào Nhật ký.'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await flush(tester);

    final afterClue = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(afterClue!.discoveredClueIds, contains('clue_doormat'));
  });

  testWidgets('prologue is skippable at any card', (tester) async {
    await pumpFreshApp(tester);
    await newGame(tester);
    await tester.tap(find.byKey(const ValueKey('prologue_skip')));
    await flush(tester, 3);
    await passHowToPlay(tester);

    expect(find.byKey(const ValueKey('hotspot_hot_eh_window')), findsOneWidget);
  });

  testWidgets('tutorial door keypad: wrong code inert, 1024 opens the '
      'study (production content e2e)', (tester) async {
    await pumpFreshApp(tester);
    await newGame(tester);
    await tester.tap(find.byKey(const ValueKey('prologue_skip')));
    await flush(tester, 3);
    await passHowToPlay(tester);

    await tester.tap(find.byKey(const ValueKey('hotspot_hot_eh_study_door')));
    await flush(tester);
    expect(
      find.text(strings.forLocale('vi', 'puz.puz_eh_door_lock.instr')),
      findsOneWidget,
    );

    // Wrong code 9999 -> feedback, no durable change.
    for (final d in ['9', '9', '9', '9']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await flush(tester);
    expect(find.text('Chưa chính xác. Hãy thử lại.'), findsOneWidget);
    var saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.solvedPuzzleIds, isEmpty);

    // Authored code 1-0-2-4.
    for (final d in ['1', '0', '2', '4']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await flush(tester, 3);

    saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.solvedPuzzleIds, contains('puz_eh_door_lock'));
    expect(saved.unlockedRoomIds, contains('room_study'));

    // Back in the hall: the study exit now appears.
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_study_exit')),
      findsOneWidget,
    );
  });

  testWidgets('continue resumes the saved room after the prologue flow', (
    tester,
  ) async {
    await pumpFreshApp(tester);
    await newGame(tester);
    await tester.tap(find.byKey(const ValueKey('prologue_skip')));
    await flush(tester, 3);
    await passHowToPlay(tester);
    expect(find.byKey(const ValueKey('hotspot_hot_eh_marks')), findsOneWidget);

    // Leave to the menu and press Continue.
    final ctx = tester.element(find.byType(Scaffold).first);
    Navigator.of(ctx).pop();
    await flush(tester, 3);
    await tester.tap(find.text('Tiếp tục'));
    await flush(tester, 3);
    expect(find.byKey(const ValueKey('hotspot_hot_eh_marks')), findsOneWidget);
  });
}
