# Puzzle Specification Pack — Template & Index

> Phase 0 deliverable. One brief per puzzle; every brief follows PLAN §5.2.
> Player-facing text is bilingual (EN | VI). Rules/IDs are language-neutral.

## Files

| File | Room | Puzzles |
| ---- | ---- | ------- |
| `entrance-hall.md` | `room_entrance` | `puz_eh_door_lock`, `puz_eh_marks`, `puz_eh_sconce` |
| `study.md` | `room_study` | `puz_st_books`, `puz_st_safe`, `puz_st_astrolabe`, `puz_st_globe` |
| `workshop.md` | `room_workshop` | `puz_wk_gears`, `puz_wk_levers`, `puz_wk_code`, `puz_wk_floorboard`, `puz_wk_crane` |
| `gallery.md` | `room_gallery` | `puz_ga_portraits`, `puz_ga_frames`, `puz_ga_moon_dial`, `puz_ga_case_lock` |
| `observatory.md` | `room_observatory` | `puz_ob_starchart`, `puz_ob_orrery`, `puz_ob_telescope` |

## Spec template (used by every brief)

```markdown
### `puz_<id>` — <Title EN> / <Title VI>

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_*` / `hot_*` |
| Family | observation / keypad / symbol matching / sequence / rotation / logic / item use / mechanical state / hidden-object |
| Difficulty | tutorial / easy / medium / hard |
| Optional? | yes/no — optional puzzles never gate required progression |

**Objective** — what the player is asked to do (EN + VI).

**Prerequisites** — items, solved puzzles, or clues required (IDs).

**Clues** — every clue needed, its source hotspot/key, and where it lives.

**Solution & validation** — exact correct input, normalization, leading-zero
rules, validator type (pure Dart), edge cases.

**Success effects** — state changes, rewards (items/clues), unlocks. Must be
idempotent.

**Wrong-answer feedback** — what the player sees; state must not change.

**Reset policy** — what Reset does; leaving the puzzle keeps input per PLAN §4.5.

**Hints** — L1 nudge / L2 clue / L3 walkthrough (EN | VI). L3 reveals the
answer only after confirmation.

**Localization keys** — `puz.<id>.title|instr`, `hint.<id>.l1|l2|l3`, `msg.*`.

**Validator tests** — unit-test cases the pure-Dart validator must cover.
```

## Global validation conventions

- Keypad codes: numeric, exactly 4 digits for Chapter 1; leading zeros ARE
  significant (e.g., `1024`); input is trimmed, non-digits rejected.
- Symbol/sequence puzzles: order is 0-based internally; comparison is
  order-sensitive; partial progress within a session is kept, but durable
  state only changes on success.
- Rotation puzzles: target angles are absolute, snapped to defined detents;
  tolerance ±5°; validator receives normalized 0–359 angles.
- Mechanical-state puzzles: boolean lever states; pattern length fixed per
  puzzle; wrong flip gives feedback but does not reset other levers.
- Hidden-object puzzles: tap targets are normalized regions; wrong taps give
  gentle feedback; found targets stay found within the session and persist.
- All validators are pure Dart in `domain/validators/` — no Flutter imports.
