# Up Escape Mind

A narrative-driven 2D escape-room / brain-teaser game. Single-player,
**fully offline**, Flutter for Android and iOS (portrait-first).

The full product and technical plan lives in [`PLAN.md`](PLAN.md).
Pre-production game design documents live in [`design/`](design/README.md).

## Tech stack

- Flutter **3.47.8** stable / Dart **3.13.7** (pinned at project creation; CI tracks `stable`)
- State management / DI: `flutter_riverpod`
- Navigation: `go_router` (named routes)
- Persistence: Drift + SQLite (Phase 3); `shared_preferences` for settings
- Content: versioned JSON assets under `assets/content/` (Phase 2)
- Localization: `gen-l10n`, Vietnamese (default) + English

## Repository layout

Feature-first MVVM. See `AGENTS.md` for the full rules and `PLAN.md` §12
for the target structure — Phase 1 establishes `app/`, `core/`, `data/`,
`domain/`, and `features/` foundations.

## Commands

```bash
flutter pub get
flutter gen-l10n            # regenerate localizations after editing .arb files
flutter analyze
dart format lib test
flutter test
flutter run
```

Quality gate: `dart format --set-exit-if-changed .`, clean `flutter analyze`,
and passing `flutter test`.
