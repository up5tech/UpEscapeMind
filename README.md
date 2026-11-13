# Up Escape Mind

A narrative-driven 2D escape-room / brain-teaser game. Single-player,
**fully offline**, Flutter for Android and iOS (portrait-first).

The full product and technical plan lives in [`PLAN.md`](PLAN.md).
Pre-production game design documents live in [`design/`](design/README.md).

## Tech stack

- Flutter **3.47.8** stable / Dart **3.13.7** (pinned at project creation; CI tracks `stable`)
- State management / DI: `flutter_riverpod`
- Navigation: `go_router` (named routes)
- Persistence: Drift + SQLite (`lib/data/database/`) for progress; `shared_preferences` for settings
- Content: versioned JSON assets under `assets/content/` (Phase 2)
- Localization: `gen-l10n`, Vietnamese (default) + English

## Repository layout

Feature-first MVVM. See `AGENTS.md` for the full rules and `PLAN.md` §12
for the target structure — Phase 1 establishes `app/`, `core/`, `data/`,
`domain/`, and `features/` foundations.

## Content pipeline (Phase 2)

Game content lives in `assets/content/` as versioned JSON (`schemaVersion`)
with a `type` discriminator per file. `assets/content/manifest.json` lists
every file. Types: `chapter`, `room`, `puzzle`, `item`,
`item_combination`, `clue`.

`ContentLoader` (`lib/data/content/`) loads the manifest via `rootBundle`,
parses strictly typed models (`lib/domain/models/content/`), then runs
`ContentValidator` — duplicate IDs, cross-references, normalized hotspot
bounds, asset existence, per-puzzle-type `solutionConfig` keys, hint counts,
localization keys (when supplied), and circular unlock dependencies are all
checked before the catalog is used.

`test/content_validation/` runs the full validator against the bundled
content plus negative cases. `chapter_sample`/`room_sample*` is a dev
fixture exercising every content type; real Chapter 1 content lands in
Phase 9.

## Save system (Phase 3)

`AppDatabase` (`lib/data/database/`) is a Drift/SQLite database with one
row-set per save slot: unlocked rooms, solved puzzles, in-progress puzzle
states, collected/consumed items, discovered clues, completed chapters,
revealed hint levels. `DriftProgressRepository` rewrites a slot inside a
single transaction on every save — durable actions are atomic and
idempotent. `save_slots.schemaVersion` guards against unsupported saves.
Settings (audio, haptics, language) stay in `shared_preferences`.

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
