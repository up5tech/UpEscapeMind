import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:up_escape_mind/main.dart' as app;

/// Phase 11 release-candidate journey on a real device/emulator.
///
/// Boots the production app (real assets, real on-device database) and
/// verifies the critical path: New Game → skippable prologue → Entrance
/// Hall → tutorial keypad (wrong code inert, authored code 1024 solves)
/// → room unlock → simulated restart resumes the saved room.
///
/// Run with:
///   flutter test integration_test/app_journey_test.dart -d DEVICE_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, [int ms = 400]) async {
    await tester.runAsync(
      () => Future<void>.delayed(Duration(milliseconds: ms)),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
  }

  Future<void> newGame(WidgetTester tester) async {
    await tester.tap(find.text('Chơi mới'));
    await settle(tester);
    // A previous save on this device triggers a confirm dialog.
    final confirm = find.text('Xác nhận');
    if (confirm.evaluate().isNotEmpty) {
      await tester.tap(confirm.last);
      await settle(tester);
    }
  }

  /// Pumps until [finder] matches or [seconds] elapse, then asserts.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    int seconds = 15,
  }) async {
    final deadline = DateTime.now().add(Duration(seconds: seconds));
    while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsWidgets);
  }

  Future<void> skipPrologue(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('prologue_skip')));
    await settle(tester);
  }

  /// First playthrough on a device shows the one-time how-to-play guide
  /// after the prologue; pass through it when present.
  Future<void> passHowToPlay(WidgetTester tester) async {
    final start = find.byKey(const ValueKey('how_to_play_start'));
    await settle(tester);
    if (start.evaluate().isNotEmpty) {
      await tester.tap(start);
      await settle(tester);
    }
  }

  testWidgets('chapter 1 critical path: new game to unlocked study', (
    tester,
  ) async {
    unawaited(app.main());
    await settle(tester, 800);

    // Main menu → New Game → prologue → Entrance Hall.
    await newGame(tester);
    expect(find.byKey(const ValueKey('prologue_skip')), findsOneWidget);
    await skipPrologue(tester);
    await passHowToPlay(tester);

    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_grandfather_clock')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_study_door')),
      findsOneWidget,
    );
    // Locked exit stays hidden until the door puzzle is solved.
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_study_exit')),
      findsNothing,
    );

    // Open the tutorial keypad and submit a wrong code first.
    await tester.tap(find.byKey(const ValueKey('hotspot_hot_eh_study_door')));
    await settle(tester);
    for (final d in ['9', '9', '9', '9']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await settle(tester);
    expect(find.text('Chưa chính xác. Hãy thử lại.'), findsOneWidget);

    // Authored code 1-0-2-4 unlocks the study.
    for (final d in ['1', '0', '2', '4']) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await settle(tester, 600);
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_study_exit')),
      findsOneWidget,
    );

    // Enter the study so the saved room becomes room_study.
    await tester.tap(find.byKey(const ValueKey('hotspot_hot_eh_study_exit')));
    await settle(tester, 800);
    expect(
      find.byKey(const ValueKey('hotspot_hot_st_bookshelf')),
      findsOneWidget,
    );
  });

  // Runs after the journey test: the widget tree is torn down between
  // testWidgets, so booting the app again is a real restart over the same
  // on-device save.
  testWidgets('save resumes in the study after an app restart', (tester) async {
    unawaited(app.main());
    await waitFor(tester, find.text('Tiếp tục'));
    await tester.tap(find.text('Tiếp tục'));
    await waitFor(
      tester,
      find.byKey(const ValueKey('hotspot_hot_st_bookshelf')),
    );

    // Resume lands directly in the study, not the entrance hall.
    expect(
      find.byKey(const ValueKey('hotspot_hot_eh_grandfather_clock')),
      findsNothing,
    );
  });
}
