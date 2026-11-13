import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:up_escape_mind/core/constants/app_constants.dart';
import 'package:up_escape_mind/data/content/content_strings.dart';
import 'package:up_escape_mind/data/database/app_database.dart';
import 'package:up_escape_mind/data/repositories/drift_progress_repository.dart';
import 'package:up_escape_mind/domain/models/content/chapter_definition.dart';
import 'package:up_escape_mind/domain/models/content/clue_definition.dart';
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/content/puzzle_definition.dart';
import 'package:up_escape_mind/domain/models/content/room_definition.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/main.dart';

/// Phase 8 acceptance coverage: three-level hints with persisted reveal
/// and walkthrough confirmation, prerequisite explanations, chapter
/// completion granted exactly once, and the summary screen (stars,
/// badge, stats) with its route guard.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final ContentStrings strings;

  setUpAll(() async {
    strings = await ContentStrings.load();
  });

  Map<String, dynamic> puzzleJson(
    String id, {
    Map<String, dynamic> extra = const <String, dynamic>{},
  }) {
    return <String, dynamic>{
      'schemaVersion': 1,
      'type': 'puzzle',
      'id': id,
      'roomId': 'r1',
      'hotspotId': 'hs_$id',
      'puzzleType': 'keypad',
      'titleKey': 'puz.$id.title',
      'instructionsKey': 'puz.$id.instr',
      'initialState': <String, dynamic>{'digits': 4},
      'solutionConfig': <String, dynamic>{'code': '1111'},
      'validationConfig': <String, dynamic>{},
      'hints': <Map<String, dynamic>>[
        {'level': 1, 'textKey': 'hint.$id.l1'},
        {'level': 2, 'textKey': 'hint.$id.l2'},
        {'level': 3, 'textKey': 'hint.$id.l3'},
      ],
      'resetPolicy': 'keep',
      ...extra,
    };
  }

  final catalog = ContentCatalog(
    chapters: [
      ChapterDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'chapter',
        'id': 'ch1',
        'titleKey': 'chapterOneTitle',
        'order': 0,
        'roomIds': ['r1'],
      }, 'ch'),
    ],
    rooms: [
      RoomDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'room',
        'id': 'r1',
        'chapterId': 'ch1',
        'titleKey': 'roomOneTitle',
        'backgroundAsset': 'assets/art/rooms/room_sample.png',
        'hotspots': const <Map<String, dynamic>>[],
      }, 'r1'),
    ],
    puzzles: [
      PuzzleDefinition.fromJson(puzzleJson('p_hint'), 'p_hint'),
      // Chapter-final puzzle: solving it completes the chapter exactly
      // once and journals the final note.
      PuzzleDefinition.fromJson(
        puzzleJson('p_final', extra: {
          'successActions': [
            {'type': 'complete_chapter', 'targetId': 'ch1'},
            {'type': 'discover_clue', 'targetId': 'c_final'},
          ],
        }),
        'p_final',
      ),
      // Locked: needs an item that the save does not have.
      PuzzleDefinition.fromJson(
        puzzleJson('p_locked', extra: {
          'prerequisites': [
            {'type': 'item_collected', 'targetId': 'item_missing'},
          ],
        }),
        'p_locked',
      ),
    ],
    items: const [],
    combinations: const [],
    clues: [
      ClueDefinition.fromJson({
        'schemaVersion': 1,
        'type': 'clue',
        'id': 'c_final',
        'titleKey': 'clueFinalTitle',
        'bodyKey': 'clueFinalBody',
        'sourceRoomId': 'r1',
      }, 'c_final'),
    ],
  );

  late AppDatabase db;

  Future<void> pumpApp(
    WidgetTester tester, {
    GameProgress? progress,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftProgressRepository(db).saveProgress(
      progress ??
          GameProgress(
            saveSlotId: AppConstants.defaultSaveSlotId,
            unlockedRoomIds: const ['r1'],
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
    await tester.pumpAndSettle();
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

  Future<void> openPuzzle(WidgetTester tester, String puzzleId) async {
    final ctx = tester.element(find.byType(Scaffold).first);
    unawaited(
      GoRouter.of(ctx)
          .pushNamed('puzzle', pathParameters: {'puzzleId': puzzleId}),
    );
    await flush(tester, 3);
  }

  Future<GameProgress> saved() async {
    final progress = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    return progress!;
  }

  /// Types the 4-digit answer 1-1-1-1 and lets the solve complete.
  Future<void> solveKeypad(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('1').last);
      await tester.pump();
    }
    await flush(tester, 3);
  }

  Future<void> openHintSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('puzzle_hint_action')));
    await flush(tester);
  }

  const nextHintButton = 'Xem gợi ý tiếp theo';
  const confirmWalkthrough = 'Xem bài giải từng bước?';

  // ------------------------------------------------------------- hints

  testWidgets('hints: reveal level by level, persist across close/reopen, '
      'walkthrough needs confirmation', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'p_hint');

    await openHintSheet(tester);
    // Nothing revealed yet — only the reveal button, no hint text.
    expect(find.text(nextHintButton), findsOneWidget);
    expect(find.text('hint.p_hint.l1'), findsNothing);

    // Reveal level 1.
    await tester.tap(find.byKey(const ValueKey('hint_reveal_next')));
    await flush(tester);
    expect(find.text('hint.p_hint.l1'), findsOneWidget);
    expect(find.text('Gợi ý 1'), findsOneWidget);

    // Close and reopen: revealed text is not lost (PLAN §6.2).
    await tester.tapAt(const Offset(10, 10)); // barrier tap closes sheet
    await flush(tester);
    await openHintSheet(tester);
    expect(find.text('hint.p_hint.l1'), findsOneWidget);

    // Reveal level 2.
    await tester.tap(find.byKey(const ValueKey('hint_reveal_next')));
    await flush(tester);
    expect(find.text('hint.p_hint.l2'), findsOneWidget);

    // Level 3 requires explicit confirmation — cancel keeps it hidden.
    await tester.tap(find.byKey(const ValueKey('hint_reveal_next')));
    await flush(tester);
    expect(find.text(confirmWalkthrough), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await flush(tester);
    expect(find.text('hint.p_hint.l3'), findsNothing);

    // Confirm reveals the walkthrough.
    await tester.tap(find.byKey(const ValueKey('hint_reveal_next')));
    await flush(tester);
    await tester.tap(find.byKey(const ValueKey('hint_walkthrough_confirm')));
    await flush(tester);
    expect(find.text('hint.p_hint.l3'), findsOneWidget);
    // All levels revealed — no more reveal button.
    expect(find.text(nextHintButton), findsNothing);

    final progress = await saved();
    expect(progress.revealedHintLevels, {'p_hint': 3});
  });

  testWidgets('locked puzzle: explains the missing discovery kind and '
      'still offers hints', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'p_locked');

    expect(find.text('Câu đố này chưa thể mở ra lúc này.'), findsOneWidget);
    expect(
      find.text('Bạn vẫn cần tìm thêm một vật phẩm.'),
      findsOneWidget,
    );
    // No answer leak: the code UI must not render.
    expect(find.byKey(const ValueKey('keypad_cell_text_0')), findsNothing);

    // Hints remain available while locked (PLAN §6.2: never block).
    await openHintSheet(tester);
    expect(find.text(nextHintButton), findsOneWidget);
  });

  // -------------------------------------------------- chapter summary

  testWidgets('solving the chapter-final puzzle opens the summary exactly '
      'once; completion is idempotent', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'p_final');
    await solveKeypad(tester);

    // The solved puzzle route is replaced by the chapter summary.
    expect(find.text('Hoàn thành chương!'), findsOneWidget);
    // 1★ only: p_hint and p... not solved, clue... walkthrough badge
    // earned (no hint used).
    expect(
      tester.widget<Icon>(find.byKey(const ValueKey('summary_star_1'))).icon,
      Icons.star,
    );
    expect(
      tester.widget<Icon>(find.byKey(const ValueKey('summary_star_2'))).icon,
      Icons.star_border,
    );
    expect(find.text('Không dùng bài giải từng bước'), findsOneWidget);
    // Chapter stats scoped to the catalog: 1 of 3 puzzles.
    expect(find.text('Câu đố đã giải: 1/3'), findsOneWidget);

    var progress = await saved();
    expect(progress.completedChapterIds, ['ch1']);
    expect(progress.discoveredClueIds, ['c_final']);

    // Leave the summary: reopening the solved puzzle must NOT re-grant
    // completion or re-open the summary.
    await tester.tap(find.byKey(const ValueKey('summary_continue')));
    await flush(tester, 3);
    // Let the solved snackbar expire so only the screen text can match.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await openPuzzle(tester, 'p_final');
    expect(find.text('Chính xác! Câu đố đã được giải.'), findsOneWidget);
    expect(find.text('Hoàn thành chương!'), findsNothing);
    progress = await saved();
    expect(progress.completedChapterIds.length, 1);
    expect(progress.discoveredClueIds.length, 1);
  });

  testWidgets('chapters screen: completed chapter shows summary entry and '
      'room checkmark once everything is solved', (tester) async {
    await pumpApp(
      tester,
      progress: GameProgress(
        saveSlotId: AppConstants.defaultSaveSlotId,
        unlockedRoomIds: const ['r1'],
        completedChapterIds: const ['ch1'],
        solvedPuzzleIds: const ['p_hint', 'p_final', 'p_locked'],
        discoveredClueIds: const ['c_final'],
      ),
    );

    // Menu -> Chapters
    await tester.tap(find.text('Chương'));
    await flush(tester);

    expect(
      find.byKey(const ValueKey('room_complete_r1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('chapter_view_summary_ch1')));
    await flush(tester, 3);

    expect(find.text('Hoàn thành chương!'), findsOneWidget);
    // All puzzles solved + all chapter clues -> 3★.
    expect(
      tester.widget<Icon>(find.byKey(const ValueKey('summary_star_3'))).icon,
      Icons.star,
    );
    expect(find.text('Manh mối tùy chọn đã tìm: 0/0'), findsOneWidget);
  });

  testWidgets('route guard: summary of an unfinished chapter redirects '
      'to the chapter map', (tester) async {
    await pumpApp(tester);
    await flush(tester, 2);

    final ctx = tester.element(find.byType(Scaffold).first);
    GoRouter.of(ctx).goNamed(
      'chapterSummary',
      pathParameters: {'chapterId': 'ch1'},
    );
    await flush(tester, 3);

    expect(find.text('Hoàn thành chương!'), findsNothing);
    // We land on the chapters screen instead.
    expect(find.text('Các chương'), findsOneWidget);
  });
}
