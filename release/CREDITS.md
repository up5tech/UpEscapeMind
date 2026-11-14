# Credits — Up Escape Mind

## Game

Up Escape Mind — a single-player, offline escape-room adventure.
Chapter 1 "The Clockmaker's Archive".

## Art

All shipped artwork is original, project-owned IP generated in-repo by
`tool/gen_chapter1_art.py` (rooms, items, puzzle backdrops). See the full
per-asset ledger in `assets/licenses/README.md`.

- Rooms: `assets/art/rooms/` (Entrance Hall, Study, Workshop, Gallery,
  Observatory)
- Items: `assets/art/items/`
- Puzzle backdrops: `assets/art/puzzles/`

## Audio

No audio assets ship in 1.0.0 (see `assets/audio/` — intentionally
empty; music/SFX planned for a later update).

## Fonts

System default fonts (Flutter/Roboto) pending a licensed font decision.
When a licensed font is adopted, its license text will be stored in
`assets/fonts/` and recorded in `assets/licenses/README.md`.

## Third-party software

Built with Flutter (BSD-3-Clause) and the Dart ecosystem. Notable
dependencies: flutter_riverpod, go_router, drift, sqlite3_flutter_libs,
shared_preferences. Full license texts are available via each package's
pub.dev page and in the app's Licenses screen (Flutter `LicenseRegistry`).
