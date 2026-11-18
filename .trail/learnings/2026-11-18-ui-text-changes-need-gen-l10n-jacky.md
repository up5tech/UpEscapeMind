---
title: UI text changes need gen-l10n rerun; dart format rewrites unrelated files
author: Jacky
date: 2026-11-18
branch: main
id: l-2d974e5c
scope: repo
status: active
src: agent
touches:
  - integration_test/app_journey_test.dart
  - lib/app/localization/app_en.arb
  - lib/app/localization/app_localizations.dart
  - lib/app/localization/app_localizations_en.dart
  - lib/app/localization/app_localizations_vi.dart
  - lib/app/localization/app_vi.arb
  - lib/app/router.dart
  - lib/data/repositories/settings_repository.dart
  - lib/data/repositories/shared_preferences_settings_repository.dart
  - lib/features/chapters/chapters_screen.dart
---

## Decided
- Player-facing strings live in `lib/app/localization/app_{vi,en}.arb`; after editing an .arb, run `flutter gen-l10n` — the generated `app_localizations*.dart` files are committed, so the diff must include them.
- Keep .arb files as single-line JSON to match repo style (json.dump default separators).

## Watch out
- `dart format lib/...` on this repo reformats files you didn't touch (newer formatter style vs committed code). Revert unrelated churn with `git checkout --` to keep diffs reviewable.
- Room/puzzle widget tests use real SharedPreferences with empty mocks, so any "show once" guidance flag defaults to unseen — prefer non-modal in-layout cards over modal sheets for first-visit UI, or every room test breaks on the modal barrier.
