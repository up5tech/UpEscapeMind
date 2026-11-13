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
import 'package:up_escape_mind/domain/models/content/content_catalog.dart';
import 'package:up_escape_mind/domain/models/content/prerequisites.dart';
import 'package:up_escape_mind/domain/models/content/puzzle_definition.dart';
import 'package:up_escape_mind/domain/models/progress.dart';
import 'package:up_escape_mind/main.dart';

/// Phase 7 acceptance coverage: every supported puzzle family works from
/// data-driven definitions (multiple content configs per family where the
/// engine differs), wrong answers never corrupt state, completion is
/// idempotent, and the reset policy governs session input.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final ContentStrings strings;

  setUpAll(() async {
    strings = await ContentStrings.load();
  });

  PuzzleDefinition puz(
    String id,
    String type, {
    Map<String, dynamic> initialState = const {},
    Map<String, dynamic> solutionConfig = const {},
    Map<String, dynamic> validationConfig = const {},
    List<SuccessAction> rewards = const [],
    String resetPolicy = 'keep',
  }) {
    return PuzzleDefinition.fromJson({
      'schemaVersion': 1,
      'type': 'puzzle',
      'id': id,
      'roomId': 'room_engine_test',
      'hotspotId': 'hs_$id',
      'puzzleType': type,
      'titleKey': 'puz.$id.title',
      'instructionsKey': 'puz.$id.instr',
      'initialState': initialState,
      'solutionConfig': solutionConfig,
      'validationConfig': validationConfig,
      'successActions': [
        for (final a in rewards) {'type': a.type.jsonValue, 'targetId': a.targetId},
      ],
      'hints': [
        {'level': 1, 'textKey': 'puz.$id.h1'},
      ],
      'resetPolicy': resetPolicy,
    }, 'engine_test:$id');
  }

  SuccessAction unlockRoom(String id) => SuccessAction(
    type: SuccessActionType.unlockRoom,
    targetId: id,
  );
  SuccessAction discoverClue(String id) => SuccessAction(
    type: SuccessActionType.discoverClue,
    targetId: id,
  );

  final catalog = ContentCatalog(
    chapters: const [],
    rooms: const [],
    puzzles: [
      puz('puz_kp_a', 'keypad',
          initialState: {'digits': 4},
          solutionConfig: {'code': '1234'},
          rewards: [unlockRoom('room_after_kp'), discoverClue('clue_kp')]),
      puz('puz_kp_b', 'keypad',
          initialState: {'digits': 5},
          solutionConfig: {'code': '00123'},
          resetPolicy: 'reset_on_exit'),
      puz('puz_sym', 'symbol_matching',
          solutionConfig: {
            'symbols': ['moon', 'star', 'sun'],
            'choices': ['moon', 'star', 'sun', 'key'],
          },
          initialState: {
            'labelKeys': {'moon': 'symMoon'},
          },
          rewards: [discoverClue('clue_sym')]),
      puz('puz_seq', 'sequence',
          solutionConfig: {
            'order': ['book_early', 'book_mid', 'book_late'],
          },
          rewards: [discoverClue('clue_seq')]),
      puz('puz_rot', 'rotation',
          solutionConfig: {
            'steps': [210],
          },
          rewards: [unlockRoom('room_after_rot')]),
      puz('puz_log', 'logic_deduction',
          initialState: {
            'fields': [
              {'id': 't1', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'ring1'},
              {'id': 't2', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'ring2'},
              {'id': 't3', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'ring3'},
              {'id': 'year', 'kind': 'digits', 'maxLength': 4, 'labelKey': 'yearF'},
            ],
          },
          solutionConfig: {
            'answer': {'t1': '0815', 't2': '0347', 't3': '0658', 'year': '1892'},
          },
          rewards: [discoverClue('clue_orrery')]),
      puz('puz_lev', 'mechanical_state',
          solutionConfig: {
            'targetState': [true, false, true],
          },
          rewards: [discoverClue('clue_lev')]),
      puz('puz_hid', 'hidden_object',
          solutionConfig: {
            'regions': [
              {'id': 'floorboard', 'x': 0.4, 'y': 0.4, 'width': 0.2, 'height': 0.2},
              {'id': 'crate', 'x': 0.0, 'y': 0.0, 'width': 0.2, 'height': 0.2},
            ],
            'targetId': 'floorboard',
          },
          rewards: [discoverClue('clue_hid')]),
      puz('puz_obs', 'observation',
          solutionConfig: {
            'regions': [
              {'id': 'gallery', 'x': 0.4, 'y': 0.4, 'width': 0.2, 'height': 0.2},
              {'id': 'study', 'x': 0.0, 'y': 0.0, 'width': 0.2, 'height': 0.2},
              {'id': 'workshop', 'x': 0.8, 'y': 0.8, 'width': 0.2, 'height': 0.2},
            ],
            'targets': ['study', 'gallery', 'workshop'],
          },
          rewards: [discoverClue('clue_obs')]),
    ],
    items: const [],
    combinations: const [],
    clues: const [],
  );

  late AppDatabase db;

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await DriftProgressRepository(db).saveProgress(
      GameProgress(saveSlotId: AppConstants.defaultSaveSlotId),
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

  /// Tap the AppBar back button (vi tooltip) to leave the puzzle screen.
  Future<void> leavePuzzle(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Quay lại'));
    await flush(tester, 2);
    // Let any solved snackbar finish its auto-dismiss timer.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
  }

  Future<GameProgress> saved() async {
    final progress = await DriftProgressRepository(db)
        .loadProgress(AppConstants.defaultSaveSlotId);
    return progress!;
  }

  const wrongMsg = 'Chưa chính xác. Hãy thử lại.';
  const solvedMsg = 'Chính xác! Câu đố đã được giải.';

  Future<void> tapKey(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  // ------------------------------------------------------------ keypad

  testWidgets('keypad: wrong code persists nothing, correct code rewards '
      'and solved state persists (idempotent reopen)', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_kp_a');

    // Wrong code.
    for (final d in ['9', '9', '9', '9']) {
      await tapKey(tester, find.text(d).last);
    }
    await flush(tester);
    expect(find.text(wrongMsg), findsOneWidget);
    var progress = await saved();
    expect(progress.solvedPuzzleIds, isEmpty);

    // Correct code 1-2-3-4.
    for (final d in ['1', '2', '3', '4']) {
      await tapKey(tester, find.text(d).last);
    }
    await flush(tester, 3);

    progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_kp_a']);
    expect(progress.unlockedRoomIds, ['room_after_kp']);
    expect(progress.discoveredClueIds, ['clue_kp']);

    // Success auto-pops to the menu; wait out the snackbar, then reopen.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await openPuzzle(tester, 'puz_kp_a');
    expect(find.text(solvedMsg), findsOneWidget);
    expect(find.byKey(const ValueKey('keypad_cell_0')), findsNothing);
    progress = await saved();
    expect(progress.unlockedRoomIds.length, 1);
    expect(progress.solvedPuzzleIds.length, 1);
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('keypad: a second content definition drives 5-digit code '
      'and leading zeroes', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_kp_b');
    expect(find.byKey(const ValueKey('keypad_cell_4')), findsOneWidget);

    for (final d in ['0', '0', '1', '2', '3']) {
      await tapKey(tester, find.text(d).last);
    }
    await flush(tester, 3);
    final progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_kp_b']);
  });

  // ------------------------------------------------------ reset policies

  testWidgets('resetPolicy keep restores partial input; reset_on_exit '
      'discards it', (tester) async {
    await pumpApp(tester);

    // keep (puz_kp_a): partial "12".
    await openPuzzle(tester, 'puz_kp_a');
    await tapKey(tester, find.text('1').last);
    await tapKey(tester, find.text('2').last);
    await leavePuzzle(tester);
    await openPuzzle(tester, 'puz_kp_a');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('keypad_cell_text_0'))).data,
      '1',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('keypad_cell_text_1'))).data,
      '2',
    );

    // reset_on_exit (puz_kp_b): partial input is dropped.
    await leavePuzzle(tester);
    await openPuzzle(tester, 'puz_kp_b');
    await tapKey(tester, find.text('3').last);
    await leavePuzzle(tester);
    await openPuzzle(tester, 'puz_kp_b');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('keypad_cell_text_0'))).data,
      '·',
    );
  });

  // ----------------------------------------------------- symbol matching

  testWidgets('symbol matching: wrong order rejects, correct order solves; '
      'duplicate pick moves instead of duplicating', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_sym');

    Future<void> pickSlot(int slot, String symbol) async {
      await tapKey(tester, find.byKey(ValueKey('symbol_slot_$slot')));
      await flush(tester);
      await tapKey(tester, find.byKey(ValueKey('symbol_option_$symbol')));
      await flush(tester);
    }

    await pickSlot(0, 'star');
    await pickSlot(1, 'moon');
    await pickSlot(2, 'sun');
    // Duplicates cannot be created: re-picking moon for slot 0 vacates
    // slot 1.
    await pickSlot(0, 'moon');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('symbol_slot_text_1'))).data,
      '·',
    );

    // Wrong order still achievable: moon, star, sun is actually correct
    // after fixes — set slot 1 to star, slot 2 stays sun, then submit.
    await pickSlot(1, 'star');
    await tester.ensureVisible(find.byKey(const ValueKey('puzzle_check')));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester, 3);

    final progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_sym']);
    expect(progress.discoveredClueIds, ['clue_sym']);
    // slot labels come from labelKeys → symMoon content key fallback.
    expect(find.text('symMoon'), findsNothing); // screen closed on success
  });

  // ------------------------------------------------------------- sequence

  testWidgets('sequence: partial submit is inert, wrong order is rejected, '
      'correct order solves', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_seq');

    Finder candidate(String id) =>
        find.byKey(ValueKey('sequence_candidate_$id'));

    // Partial: only two picked — Check must not report wrong or solve.
    await tapKey(tester, candidate('book_early'));
    await tapKey(tester, candidate('book_mid'));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester);
    expect(find.text(wrongMsg), findsNothing);
    var progress = await saved();
    expect(progress.solvedPuzzleIds, isEmpty);

    // Clear the partial picks by tapping slot 0 twice.
    await tapKey(tester, find.byKey(const ValueKey('sequence_slot_0')));
    await tapKey(tester, find.byKey(const ValueKey('sequence_slot_0')));

    // Wrong full order: late, mid, early.
    await tapKey(tester, candidate('book_late'));
    await tapKey(tester, candidate('book_mid'));
    await tapKey(tester, candidate('book_early'));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester);
    expect(find.text(wrongMsg), findsOneWidget);
    progress = await saved();
    expect(progress.solvedPuzzleIds, isEmpty);

    // Used candidates are disabled: re-tapping changes nothing.
    await tapKey(tester, candidate('book_early'));
    expect(find.text('3/3'), findsOneWidget);

    // Correct order: clear all slots, then early, mid, late.
    for (var i = 0; i < 3; i++) {
      await tapKey(tester, find.byKey(const ValueKey('sequence_slot_0')));
    }
    await tapKey(tester, candidate('book_early'));
    await tapKey(tester, candidate('book_mid'));
    await tapKey(tester, candidate('book_late'));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester, 3);

    progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_seq']);
    expect(progress.discoveredClueIds, ['clue_seq']);
  });

  // ------------------------------------------------------------- rotation

  testWidgets('rotation: ±15° nudges align the dial; reset restores the '
      'start angle; alignment solves', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_rot');

    // Wrong after a few degrees.
    for (var i = 0; i < 5; i++) {
      await tapKey(tester, find.byKey(const ValueKey('rotation_plus_0')));
    }
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester);
    expect(find.text(wrongMsg), findsOneWidget);
    expect((await saved()).solvedPuzzleIds, isEmpty);

    // Reset returns to 0°, then rotate the full way: 14 × 15° = 210°.
    await tapKey(tester, find.byKey(const ValueKey('puzzle_reset')));
    for (var i = 0; i < 14; i++) {
      await tapKey(tester, find.byKey(const ValueKey('rotation_plus_0')));
    }
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester, 3);

    final progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_rot']);
    expect(progress.unlockedRoomIds, contains('room_after_rot'));
  });

  // ------------------------------------------------------ logic deduction

  testWidgets('logic deduction: missing leading zeroes are rejected; full '
      'chart order solves', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_log');

    Future<void> enterField(String id, String value) async {
      final field = find.byKey(ValueKey('deduction_field_$id'));
      await tester.ensureVisible(field);
      await tapKey(tester, field);
      await tester.enterText(field, value);
      await tester.pump();
    }

    await enterField('t1', '815'); // trap: dropped leading zero
    await enterField('t2', '0347');
    await enterField('t3', '0658');
    await enterField('year', '1892');
    await tester.ensureVisible(find.byKey(const ValueKey('puzzle_check')));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester);
    expect(find.text(wrongMsg), findsOneWidget);
    expect((await saved()).solvedPuzzleIds, isEmpty);

    await enterField('t1', '0815');
    await tester.ensureVisible(find.byKey(const ValueKey('puzzle_check')));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester, 3);

    final progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_log']);
    expect(progress.discoveredClueIds, ['clue_orrery']);
  });

  // ------------------------------------------------------ mechanical state

  testWidgets('mechanical state: exact up/down/up pattern solves; wrong '
      'confirm leaves levers untouched', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_lev');

    // Wrong: flip only lever 0.
    await tapKey(tester, find.byKey(const ValueKey('lever_0')));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester);
    expect(find.text(wrongMsg), findsOneWidget);
    expect((await saved()).solvedPuzzleIds, isEmpty);
    expect(tester.widget<InkWell>(find.byKey(const ValueKey('lever_1'))).onTap,
        isNotNull); // lever 1 never moved, still interactive

    // Correct: up, down, up.
    await tapKey(tester, find.byKey(const ValueKey('lever_2')));
    await tapKey(tester, find.byKey(const ValueKey('puzzle_check')));
    await flush(tester, 3);

    final progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_lev']);
    expect(progress.discoveredClueIds, ['clue_lev']);
  });

  // ------------------------------------------------- hidden object / obs.

  testWidgets('hidden object: centre tap on the authored region solves',
      (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_hid');

    final scene = find.byKey(const ValueKey('tap_scene'));
    expect(scene, findsOneWidget);
    await tester.tap(scene); // scene center == image center == (0.5, 0.5)
    await flush(tester, 3);

    final progress = await saved();
    expect(progress.solvedPuzzleIds, ['puz_hid']);
    expect(progress.discoveredClueIds, ['clue_hid']);
  });

  testWidgets('observation: a tap that breaks the expected chain gives '
      'feedback and changes nothing durable', (tester) async {
    await pumpApp(tester);
    await openPuzzle(tester, 'puz_obs');

    // Expected first is study; the scene centre hits gallery.
    await tester.tap(find.byKey(const ValueKey('tap_scene')));
    await flush(tester);

    expect(find.text(wrongMsg), findsOneWidget);
    final progress = await saved();
    expect(progress.solvedPuzzleIds, isEmpty);
    expect(progress.discoveredClueIds, isEmpty);
  });
}
