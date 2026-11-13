# AGENTS.md — Up Escape Mind

> Guidance for agents working on this repo. The full product and technical plan lives in `PLAN.md` — read it before designing large features.

## Project overview

- **Game:** Up Escape Mind — a 2D narrative escape-room / brain-teaser game, single-player, **fully offline**.
- **Tech:** Flutter + Dart, Android & iOS, portrait-first.
- **MVP content:** Prologue + Chapter 1 "The Clockmaker's Archive" with 5 areas (Entrance Hall, Clockmaker's Study, Workshop, Portrait Gallery, Sealed Observatory), ~15–20 puzzles.
- **Explicitly out of scope:** backend, accounts, ads, IAP, multiplayer, online leaderboards.

## Directory structure (feature-first MVVM + repositories)

```text
lib/
├── app/            # app.dart, go_router router, theme/, localization/
├── core/           # constants, errors, extensions, logging, utils, widgets
├── data/           # content loader (JSON), database (Drift), repositories, migrations
├── domain/         # models, rules, validators, use_cases (pure Dart, no Flutter deps)
└── features/       # home, chapters, room, inspection, inventory, puzzles/*, hints,
                    # journal, progress, settings
assets/{art,audio,content,fonts}   # versioned content JSON, bundled offline
test/ {unit,widget,data,content_validation,fixtures}
integration_test/
```

## Hard rules

- **Offline-first:** everything (content, art, audio, saves) must be local. Do not add network permissions/dependencies to the critical path.
- **Independent domain:** `domain/` is pure Dart — no Flutter UI or database imports. Puzzle validators must be testable without widgets.
- **Data-driven content:** rooms/puzzles/items/hints are defined in JSON under `assets/content/` with a `schemaVersion`. Never hard-code puzzle rules into widgets. Never execute code loaded from JSON.
- **State:** `flutter_riverpod`; immutable state; separate transient UI state (selected item, open dialog) from durable game state (collected item, solved puzzle). Persist via Drift + SQLite; small settings via `shared_preferences`.
- **Navigation:** `go_router` with named routes; locked content must not be reachable via direct route navigation.
- **Hotspots:** normalized coordinates 0.0–1.0 relative to the scene image; hit areas must be larger than the object — no pixel-perfect tapping.
- **Strings:** all player-facing text goes through localization keys (vi + en; Vietnamese is the default). No hard-coded text in widgets.
- **IDs:** use stable IDs for every entity; never use display text as an identifier.

## Gameplay rules that matter

- Puzzle completion must be **idempotent**: reopening a solved puzzle must not grant duplicate items or repeat one-time actions.
- Wrong answers must never corrupt state; normalize input (trim, case) and explicitly define leading-zero behavior.
- Inventory: combinations only via predefined recipes; invalid item use never consumes items.
- Hints: 3 levels (nudge → clue → walkthrough), authored per puzzle, revealed levels are persisted, and hints never block progression.
- Every durable action (item collected, puzzle solved, hint revealed, unlock, chapter completion) must **save immediately**, using a transaction when it touches multiple records.
- No soft locks: no room may become unwinnable through normal player actions.
- No IQ/psychological claims — only puzzle categories and difficulty.

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter test integration_test/   # end-to-end player journey
flutter run                       # dev
```

Quality gate before marking a phase done: clean `flutter analyze`, passing tests, Android + iOS builds, and an airplane-mode/offline verification.

## Definition of Done (summary from PLAN §17)

- No placeholders or fake logic in release paths.
- UI / game rules / persistence responsibilities correctly separated.
- Unit tests for validators and state transitions; widget tests for primary flows; integration coverage for the main player journey.
- Complete localization keys; content passes content validation.
- Save/resume verified whenever durable state changes.
- Fully playable with no internet connection.

## Stop and ask first

- Changing save/content schema versions or major package upgrades.
- Adding new dependencies (especially anything touching network/permissions).
- Adding new puzzle families or mechanics beyond PLAN.md.
- Destructive player-data operations or breaking save migrations.
