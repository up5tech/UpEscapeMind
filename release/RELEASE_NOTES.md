# Release Notes — Up Escape Mind 1.1.0

**Version:** 1.1.0 (build 1)
**Date:** 2026-11-24
**Platforms:** iOS (this update); Android build can follow the same version bump.
**Bundle ID:** `com.up5.upescapemind`

## Highlights

- **Chapter 2 "The Sunken Conservatory" ("Nhà Kính Chìm")** — unlocks after
  Chapter 1. Three new areas (Conservatory, Pump Room, Orangery), 10 new
  puzzles, new items, clues, journal entries, and a continuation of Vale's
  story. Vietnamese and English text are both complete.
- **Full visual rebuild (r2)** — all five Chapter 1 rooms and the three new
  Chapter 2 rooms now use layered, high-resolution WebP art with lighting,
  foreground, solved-state overlays, and atmosphere. Clue details are painted
  directly into the scenes and enlarged inspection views.
- **New typography and UI chrome** — bundled OFL fonts Lora + Inter with full
  Vietnamese diacritic coverage, plus brass/glass panels, dividers, and buttons
  across menus and rooms.
- **Better navigation and clue discovery** — item-in-hand no longer blocks
  exit/back hotspots; Entrance/Study hot spots were re-aligned to the new art;
  a painted back door was restored in the Study; clue sheets show the enlarged
  inspection artwork.

## Fixes since 1.0.0

- Navigate/back hotspots work even when an item is selected.
- Corrected Entrance Hall clock hands/dial to read exactly 10:24; all clue
  times, dates, lever counts, marks, and symbol orders were re-verified against
  puzzle solutions.
- Fixed overlapping and misplaced hotspots introduced by the new artwork.
- Resolved a Flutter ink/assertion issue in `SectionCard`.

## Known issues

- Game ships silent — music/SFX are still not bundled.
- Store screenshots for 6.7"/6.5" iPhone still need to be captured from the
  release candidate and uploaded in App Store Connect.
- Signing: local machine has an Apple Development identity, not an Apple
  Distribution certificate; archive/upload may need Xcode automatic signing
  with the team `CZJGGG5A9W` or a distribution certificate in the keychain.
