# Up Escape Mind — Design Documents (Phase 0)

> Pre-production game design pack for **Chapter 1: The Clockmaker's Archive**.
> These documents are the source of truth for content authoring in Phase 2+.
> Implementation must not begin from chat memory — use these files.

## Documents

| File | Nội dung / Content |
| ---- | ------------------ |
| `01-gdd.md` | Game design document: pillars, UX conventions, interaction rules, accessibility & touch targets |
| `02-chapter-1-story.md` | Chapter 1 narrative outline, room beats, ending, journal notes |
| `03-room-progression.md` | Room progression graph, unlock conditions, room-by-room hotspot inventory |
| `04-puzzles/` | Puzzle specification pack — one file per room, 19 puzzle briefs |
| `05-visual-style.md` | Visual style guide, asset naming conventions, asset checklist, licensing |

Each document is bilingual: **English first, Tiếng Việt second**.

## Shared ID registry

All content IDs are stable and language-neutral. Display text is never an ID.

### Rooms

| ID | Name (EN / VI) |
| -- | -------------- |
| `room_entrance` | Entrance Hall / Sảnh Chính |
| `room_study` | Clockmaker's Study / Phòng Nghiên Cứu của Thợ Làm Đồng Hồ |
| `room_workshop` | Workshop / Xưởng |
| `room_gallery` | Portrait Gallery / Phòng Chân Dung |
| `room_observatory` | Sealed Observatory / Đài Thiên Văn Phong Ấn |

### Puzzles (19 total)

| Room | Puzzle ID | Family | Short title |
| ---- | --------- | ------ | ----------- |
| Entrance | `puz_eh_door_lock` | Keypad | The Sealed Study Door |
| Entrance | `puz_eh_marks` | Symbol matching | Marks Beside the Door |
| Entrance | `puz_eh_sconce` | Mechanical state | The Dark Sconces *(optional)* |
| Study | `puz_st_books` | Sequence | The Stopped Hours |
| Study | `puz_st_safe` | Keypad | Vale's Strongbox |
| Study | `puz_st_astrolabe` | Symbol matching | The Astrolabe |
| Study | `puz_st_globe` | Rotation / logic | The Meridian Globe |
| Workshop | `puz_wk_gears` | Rotation | The Frozen Gear Train |
| Workshop | `puz_wk_levers` | Mechanical state | The Lever Board |
| Workshop | `puz_wk_code` | Keypad | The Parts Cabinet |
| Workshop | `puz_wk_floorboard` | Hidden-object | The Loose Floorboard |
| Workshop | `puz_wk_crane` | Rotation | The Hoist Crane |
| Gallery | `puz_ga_portraits` | Sequence | The Gallery Order |
| Gallery | `puz_ga_frames` | Symbol matching | Empty Frames |
| Gallery | `puz_ga_moon_dial` | Rotation | The Moon Dial |
| Gallery | `puz_ga_case_lock` | Keypad | The Reliquary |
| Observatory | `puz_ob_starchart` | Observation | The Star Chart |
| Observatory | `puz_ob_orrery` | Logic deduction | The Orrery |
| Observatory | `puz_ob_telescope` | Item use + rotation | The Last Lens |

### Items

| ID | Name (EN / VI) | Source |
| -- | -------------- | ------ |
| `item_clock_key` | Winding Key / Chìa Vặn Lò Xo | `puz_eh_marks` reward |
| `item_lens` | Magnifying Lens / Kính Lúp | `puz_st_books` reward |
| `item_brass_frame` | Empty Brass Frame / Khung Đồng Trống | `puz_wk_floorboard` reward |
| `item_focus_lens` | Focusing Lens / Ống Kính Hội Tụ | Combine `item_lens` + `item_brass_frame` |
| `item_crank` | Winch Handle / Tay Quay | `puz_wk_code` reward (retained after crane use) |

### Inventory combination

| Recipe ID | Inputs | Result | Consume inputs? |
| --------- | ------ | ------ | --------------- |
| `recipe_focus_lens` | `item_lens` + `item_brass_frame` | `item_focus_lens` | Yes |

### Journal clues

`clue_marks_order`, `clue_clock_1024`, `clue_vale_note_1`, `clue_doormat`,
`clue_eh_secret`, `clue_regulator_time`, `clue_book_dates`, `clue_astrolabe`,
`clue_vale_note_2`, `clue_apprentice_year`, `clue_seal_year`, `clue_moon_phases`,
`clue_vale_letter`, `clue_workshop_clock`, `clue_blueprint`, `clue_vale_note_3`,
`clue_portrait_dates`, `clue_elias_birth`, `clue_gallery_letter`,
`clue_vale_note_4`, `clue_gallery_clock`, `clue_seal_phrase`, `clue_dial_order`,
`clue_orrery_solution`, `clue_epilogue`

### Optional objectives (chapter rating)

`obj_eh_sconces` (solve `puz_eh_sconce`), `obj_ga_moon` (solve
`puz_ga_moon_dial`). Optional objectives never gate progression.

### Localization key convention

`room.<room_id>.title`, `room.<room_id>.desc`, `hot.<hotspot_id>.label`,
`puz.<puzzle_id>.title`, `puz.<puzzle_id>.instr`, `hint.<puzzle_id>.l1|l2|l3`,
`item.<item_id>.name`, `item.<item_id>.desc`, `clue.<clue_id>.title`,
`clue.<clue_id>.body`, `ui.*`, `msg.*`. Files: `assets/content/localization/vi.json`, `en.json`.
