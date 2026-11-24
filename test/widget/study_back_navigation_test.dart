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

  late final ContentCatalog catalog;
  late final ContentStrings strings;

  setUpAll(() async {
    catalog = await AssetContentRepository().loadCatalog();
    strings = await ContentStrings.load();
  });

  Future<void> flush(WidgetTester tester, [int times = 3]) async {
    for (var i = 0; i < times; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> seedAndResume(WidgetTester tester, {List<String> items = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftProgressRepository(db).saveProgress(
      GameProgress(
        saveSlotId: AppConstants.defaultSaveSlotId,
        currentRoomId: 'room_study',
        unlockedRoomIds: const ['room_entrance', 'room_study'],
        collectedItemIds: items,
      ),
    );
    await tester.pumpWidget(
      UpEscapeMindApp(
        prefs: prefs,
        database: db,
        catalog: catalog,
        strings: strings,
      ),
    );
    await flush(tester);
    await tester.tap(find.text('Tiếp tục'));
    await flush(tester);
  }

  testWidgets('Study back door still works with an item selected', (tester) async {
    await seedAndResume(tester, items: const ['item_clock_key']);
    await tester.tap(find.text('Chìa Vặn'));
    await flush(tester, 2);
    await tester.tap(find.text('Sử dụng'));
    await flush(tester, 2);

    await tester.tap(find.byKey(const ValueKey('hotspot_hot_st_back_entrance')));
    await flush(tester);

    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_doormat')),
      findsOneWidget,
      reason: 'Navigation must not be blocked by an item in hand',
    );
  });

  testWidgets('Study back door navigates to Entrance Hall', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftProgressRepository(db).saveProgress(
      GameProgress(
        saveSlotId: AppConstants.defaultSaveSlotId,
        currentRoomId: 'room_study',
        unlockedRoomIds: const ['room_entrance', 'room_study'],
      ),
    );

    await tester.pumpWidget(
      UpEscapeMindApp(
        prefs: prefs,
        database: db,
        catalog: catalog,
        strings: strings,
      ),
    );
    await flush(tester);

    await tester.tap(find.text('Tiếp tục'));
    await flush(tester);

    final back = find.byKey(const ValueKey('hotspot_hot_st_back_entrance'));
    expect(back, findsOneWidget, reason: 'Study back-door hotspot must render');

    await tester.tap(back);
    await flush(tester);

    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_doormat')),
      findsOneWidget,
      reason: 'Tapping the back door must land in Entrance Hall',
    );
    expect(back, findsNothing);
  });
}
