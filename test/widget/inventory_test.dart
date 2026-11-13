import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    required GameProgress progress,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftProgressRepository(db).saveProgress(progress);

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

  Future<void> flush(WidgetTester tester, [int times = 2]) async {
    for (var i = 0; i < times; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  GameProgress progressWith(List<String> items) => GameProgress(
    saveSlotId: AppConstants.defaultSaveSlotId,
    currentRoomId: 'room_sample',
    unlockedRoomIds: const ['room_sample'],
    collectedItemIds: items,
  );

  Future<void> openRoom(WidgetTester tester) async {
    await tester.tap(find.text('Chương'));
    await flush(tester);
    await tester.tap(find.text('Phòng Mẫu'));
    await flush(tester, 3);
  }

  /// Opens the item detail sheet from the inventory bar.
  Future<void> openItemSheet(WidgetTester tester, String itemName) async {
    await tester.tap(find.text(itemName));
    await tester.pumpAndSettle();
  }

  testWidgets('using accepted item consumes it and grants success actions', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      progress: progressWith(const ['item_sample_hook']),
    );
    await openRoom(tester);

    await openItemSheet(tester, 'Móc & Chìa');
    await tester.tap(find.text('Sử dụng'));
    await tester.pumpAndSettle();

    // Item is now "in hand"; tap the carved panel hotspot.
    await tester.tap(
      find.byKey(const ValueKey('hotspot_hs_sample_hook_panel')),
    );
    await flush(tester);

    expect(find.textContaining('Bạn sử dụng Móc & Chìa'), findsOneWidget);

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.collectedItemIds, isNot(contains('item_sample_hook')));
    expect(saved.consumedItemIds, contains('item_sample_hook'));
    expect(saved.discoveredClueIds, contains('clue_sample_note'));
  });

  testWidgets('invalid item use gives feedback and consumes nothing', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      progress: progressWith(const ['item_sample_key']),
    );
    await openRoom(tester);

    await openItemSheet(tester, 'Chìa Khóa Nhỏ');
    await tester.tap(find.text('Sử dụng'));
    await tester.pumpAndSettle();

    // The panel only accepts the hook — the key does nothing there.
    await tester.tap(
      find.byKey(const ValueKey('hotspot_hs_sample_hook_panel')),
    );
    await flush(tester);
    expect(find.text('Món này không có tác dụng ở đây.'), findsOneWidget);

    // Selection is kept; tapping a non-use_item hotspot is also invalid.
    await tester.tap(find.byKey(const ValueKey('hotspot_hs_sample_note')));
    await flush(tester);
    expect(find.text('Món này không có tác dụng ở đây.'), findsWidgets);

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(saved!.collectedItemIds, contains('item_sample_key'));
    expect(saved.consumedItemIds, isEmpty);
  });

  testWidgets('defined combination produces result item', (tester) async {
    final db = await pumpApp(
      tester,
      progress: progressWith(const ['item_sample_key', 'item_sample_gear']),
    );
    await openRoom(tester);

    await openItemSheet(tester, 'Bánh Răng Đồng');
    await tester.tap(find.text('Kết hợp'));
    await tester.pumpAndSettle();

    // Combine mode: gear preselected, tap the key chip to add it.
    await tester.tap(find.text('Chìa Khóa Nhỏ'));
    await tester.pump();
    await tester.tap(find.text('Kết hợp').last);
    await flush(tester);

    expect(
      find.textContaining('Bạn gắn bánh răng vào chìa khóa'),
      findsOneWidget,
    );

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    // consumeInputItems=false: inputs are retained, result is added.
    expect(
      saved!.collectedItemIds,
      containsAll(<String>[
        'item_sample_key',
        'item_sample_gear',
        'item_sample_hook',
      ]),
    );
    expect(
      saved.collectedItemIds.where((id) => id == 'item_sample_hook').length,
      1,
    );
  });

  testWidgets('undefined combination keeps all items', (tester) async {
    final db = await pumpApp(
      tester,
      progress: progressWith(const ['item_sample_gear', 'item_sample_hook']),
    );
    await openRoom(tester);

    await openItemSheet(tester, 'Bánh Răng Đồng');
    await tester.tap(find.text('Kết hợp'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Móc & Chìa'));
    await tester.pump();
    await tester.tap(find.text('Kết hợp').last);
    await flush(tester);

    expect(find.text('Các vật phẩm này không thể kết hợp.'), findsOneWidget);

    final saved = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    expect(
      saved!.collectedItemIds,
      containsAll(<String>['item_sample_gear', 'item_sample_hook']),
    );
  });
}
