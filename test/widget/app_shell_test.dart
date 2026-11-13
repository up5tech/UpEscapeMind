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
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Content assets are loaded once in real async (outside the FakeAsync
  // zone used by testWidgets) and injected as provider overrides. The
  // loading pipeline itself is covered by test/data/content_loader_test.
  late final ContentCatalog catalog;
  late final ContentStrings strings;

  setUpAll(() async {
    catalog = await AssetContentRepository().loadCatalog();
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

  /// Real async (drift isolate) needs `runAsync` to settle; a couple of
  /// bounded pumps then render the resolved state.
  Future<void> flush(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('chapter map shows catalog chapter and room lock states', (
    tester,
  ) async {
    await pumpApp(
      tester,
      progress: GameProgress(
        saveSlotId: AppConstants.defaultSaveSlotId,
        currentRoomId: 'room_sample',
        unlockedRoomIds: const ['room_sample'],
      ),
    );

    await tester.tap(find.text('Chương'));
    await flush(tester);
    await flush(tester);

    // Chapter card title resolves through the content string table (vi).
    expect(find.text('Chương Mẫu (dữ liệu thử)'), findsOneWidget);
    expect(find.text('Phòng Mẫu'), findsOneWidget);
    expect(find.text('Phòng Mẫu — Lối Ra'), findsOneWidget);

    // The exit room is locked: its tile shows the locked label.
    expect(find.text('Đã khóa'), findsOneWidget);
  });

  testWidgets('journal shows only discovered clues', (tester) async {
    await pumpApp(
      tester,
      progress: GameProgress(
        saveSlotId: AppConstants.defaultSaveSlotId,
        currentRoomId: 'room_sample',
        unlockedRoomIds: const ['room_sample'],
        discoveredClueIds: const ['clue_sample_note'],
      ),
    );

    await tester.tap(find.text('Chương'));
    await flush(tester);
    await flush(tester);
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await flush(tester);
    await flush(tester);

    // Discovered clue appears with its localized title and body.
    expect(find.text('Ghi Chú Lề'), findsOneWidget);
    expect(find.textContaining('Thời gian là ổ khóa'), findsOneWidget);

    // Undiscovered clue does not appear.
    expect(find.text('Ổ Khóa Mở Ra'), findsNothing);
  });

  testWidgets('journal empty state when nothing discovered', (tester) async {
    await pumpApp(
      tester,
      progress: GameProgress(
        saveSlotId: AppConstants.defaultSaveSlotId,
        currentRoomId: 'room_sample',
        unlockedRoomIds: const ['room_sample'],
      ),
    );

    await tester.tap(find.text('Chương'));
    await flush(tester);
    await flush(tester);
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await flush(tester);
    await flush(tester);

    expect(find.textContaining('Chưa có khám phá nào'), findsOneWidget);
  });
}
