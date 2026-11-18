import 'dart:async';

import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:up_escape_mind/core/constants/app_constants.dart';
import 'package:up_escape_mind/data/content/content_loader.dart';
import 'package:up_escape_mind/data/content/content_strings.dart';
import 'package:up_escape_mind/data/database/app_database.dart';
import 'package:up_escape_mind/data/repositories/asset_content_repository.dart';
import 'package:up_escape_mind/data/repositories/drift_progress_repository.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final ContentCatalog catalog;
  late final ContentStrings strings;

  setUpAll(() async {
    catalog = await AssetContentRepository(
      loader: ContentLoader(manifestName: 'manifest.sample.json'),
    ).loadCatalog();
    strings = await ContentStrings.load();
  });

  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    GameProgress? progress,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    if (progress != null) {
      await DriftProgressRepository(db).saveProgress(progress);
    }

    await tester.pumpWidget(
      UpEscapeMindApp(
        prefs: prefs,
        database: db,
        catalog: catalog,
        strings: strings,
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  /// Lets real async (drift isolate, asset decode) complete, then renders.
  Future<void> flush(WidgetTester tester, [int times = 2]) async {
    for (var i = 0; i < times; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  GameProgress progressWith({
    List<String> unlocked = const ['room_sample'],
    List<String> solved = const [],
    List<String> items = const [],
    List<String> clues = const [],
    String? currentRoomId = 'room_sample',
  }) {
    return GameProgress(
      saveSlotId: AppConstants.defaultSaveSlotId,
      currentRoomId: currentRoomId,
      unlockedRoomIds: unlocked,
      solvedPuzzleIds: solved,
      collectedItemIds: items,
      discoveredClueIds: clues,
    );
  }

  /// Menu -> Chapters -> taps the unlocked room tile.
  Future<void> openSampleRoom(WidgetTester tester) async {
    await tester.tap(find.text('Chương'));
    await flush(tester);
    await tester.tap(find.text('Phòng Mẫu'));
    await flush(tester, 3);
  }

  testWidgets('room scene renders catalog hotspots', (tester) async {
    await pumpApp(tester, progress: progressWith());
    await openSampleRoom(tester);

    expect(find.text('Phòng Mẫu'), findsWidgets);
    expect(
      find.byKey(const ValueKey('hotspot_hs_sample_note')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hotspot_hs_sample_door_lock')),
      findsOneWidget,
    );
    // Exit door hotspot is hidden until the lock puzzle is solved.
    expect(
      find.byKey(const ValueKey('hotspot_hs_sample_exit_door')),
      findsNothing,
    );
  });

  testWidgets('room scene hotspot is exposed as an accessible button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, progress: progressWith());
    await openSampleRoom(tester);

    expect(find.bySemanticsLabel('Một mẩu ghi chú'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('locked room route redirects to chapter map', (tester) async {
    await pumpApp(tester, progress: progressWith());

    // Navigate directly to a locked room — must not render room content.
    final ctx = tester.element(find.byType(Scaffold).first);
    unawaited(
      GoRouter.of(ctx)
          .pushNamed('room', pathParameters: {'roomId': 'room_sample_exit'}),
    );
    await flush(tester, 3);

    expect(find.text('Chương Mẫu (dữ liệu thử)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('hotspot_hs_sample_exit_back')),
      findsNothing,
    );
  });

  testWidgets('inspect hotspot opens description sheet', (tester) async {
    await pumpApp(tester, progress: progressWith());
    await openSampleRoom(tester);

    await tester.tap(find.byKey(const ValueKey('hotspot_hs_sample_note')));
    await flush(tester);

    expect(find.text('Một mẩu giấy gấp nằm trên bàn.'), findsOneWidget);
    expect(find.text('Đóng'), findsOneWidget);
  });

  testWidgets('discover clue and collect item persist immediately', (
    tester,
  ) async {
    final db = await pumpApp(tester, progress: progressWith());
    await openSampleRoom(tester);

    // Discover the plaque clue.
    await tester.tap(find.byKey(const ValueKey('hotspot_hs_sample_plaque')));
    await flush(tester);
    expect(find.textContaining('Manh mối mới trong Nhật ký'), findsOneWidget);

    // Collect the key, then tap again — idempotent, no duplicate.
    await tester.tap(
      find.byKey(const ValueKey('hotspot_hs_sample_key_drawer')),
    );
    await flush(tester);
    expect(find.textContaining('Đã nhặt được Chìa Khóa Nhỏ'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('hotspot_hs_sample_key_drawer')),
    );
    await flush(tester);
    expect(find.textContaining('Bạn đã có Chìa Khóa Nhỏ rồi'), findsOneWidget);

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.discoveredClueIds, contains('clue_sample_note'));
    expect(saved.collectedItemIds, contains('item_sample_key'));
    expect(
      saved.collectedItemIds.where((id) => id == 'item_sample_key').length,
      1,
    );
  });

  testWidgets('puzzle gate, keypad solve, and room transition', (tester) async {
    final db = await pumpApp(
      tester,
      progress: progressWith(items: const ['item_sample_key']),
    );
    await openSampleRoom(tester);

    // Wrong code first.
    await tester.tap(find.byKey(const ValueKey('hotspot_hs_sample_door_lock')));
    await flush(tester);
    expect(find.text('Nhập mã số gồm bốn chữ số.'), findsOneWidget);
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await flush(tester);
    expect(find.text('Chưa chính xác. Hãy thử lại.'), findsOneWidget);

    // Correct code 4-2-7-1.
    for (final d in ['4', '2', '7', '1']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await flush(tester, 3);

    // Back in the room: exit door hotspot now visible; puzzle state saved.
    expect(
      find.byKey(const ValueKey('hotspot_hs_sample_exit_door')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('hotspot_hs_sample_exit_door')));
    await flush(tester, 3);
    expect(find.text('Phòng Mẫu — Lối Ra'), findsWidgets);

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.solvedPuzzleIds, contains('puz_sample_lock'));
    expect(saved.unlockedRoomIds, contains('room_sample_exit'));
    expect(saved.discoveredClueIds, contains('clue_sample_lock_opened'));
    expect(saved.currentRoomId, 'room_sample_exit');
  });

  testWidgets('puzzle hotspot locked without required item', (tester) async {
    await pumpApp(tester, progress: progressWith());
    await openSampleRoom(tester);

    await tester.tap(find.byKey(const ValueKey('hotspot_hs_sample_door_lock')));
    await flush(tester);

    expect(find.text('Câu đố này chưa thể mở ra lúc này.'), findsOneWidget);
    expect(find.text('Nhập mã số gồm bốn chữ số.'), findsNothing);
  });

  testWidgets('menu Continue enters the current room', (tester) async {
    await pumpApp(tester, progress: progressWith());

    await tester.tap(find.text('Tiếp tục'));
    await flush(tester, 3);

    expect(
      find.byKey(const ValueKey('hotspot_hs_sample_note')),
      findsOneWidget,
    );
  });

  testWidgets('first visit shows the room intro; dismiss keeps the tip bar', (
    tester,
  ) async {
    await pumpApp(tester, progress: progressWith());
    await openSampleRoom(tester);

    // First visit: intro card with the room description and tip.
    expect(
      find.byKey(const ValueKey('room_intro_room_sample')),
      findsOneWidget,
    );
    expect(
      find.text('Một căn phòng tối giản dùng để kiểm tra hệ thống nội dung.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Đã hiểu'));
    await flush(tester);

    // Afterwards only the compact guidance strip remains.
    expect(find.byKey(const ValueKey('room_intro_room_sample')), findsNothing);
    expect(
      find.byKey(const ValueKey('room_guidance_room_sample')),
      findsOneWidget,
    );
  });
}
