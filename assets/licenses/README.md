# Asset license ledger

Per `design/05-visual-style.md` §5, every shipped asset is recorded here.

| Asset group | Source | License | Notes |
| ----------- | ------ | ------- | ----- |
| `art/rooms/room_entrance.png`, `room_study.png`, `room_workshop.png`, `room_gallery.png`, `room_observatory.png` | Generated in-repo by `tool/gen_chapter1_art.py` (original programmatic art, palette per style guide) | Project-owned original IP | Replace with commissioned/approved art when available; regenerate or swap paths here. |
| `art/items/item_clock_key.png`, `item_lens.png`, `item_brass_frame.png`, `item_crank.png`, `item_focus_lens.png` | Same script | Project-owned original IP | — |
| `art/puzzles/floorboards.png`, `star_chart.png` | Same script | Project-owned original IP | Puzzle tap-scene backdrops; region coordinates in puzzle JSON match the drawn positions. |
| `art/rooms/room_sample*.png`, `art/items/item_sample_*.png`, `art/objects/sample_note.png` | Phase 1 dev fixtures | Project-owned placeholder | Dev/test only — referenced exclusively by `manifest.sample.json`; NOT reachable from the production content manifest. |
| Audio (`audio/music`, `audio/sfx`) | None shipped yet | — | Game ships silent; audio is optional (Phase 10 scope). |
| Fonts (`assets/fonts`) | System default Flutter text (Roboto) pending licensed serif/sans with VI glyph verification | Google Fonts OFL (pending) | Before release store the licensed font files + their OFL/license text in this directory and update this row. |

Rules for future additions:
- Commissioned or original work: note the author and date.
- Third-party: paste the license text in this folder as
  `<asset-name>.license.txt` and add the attribution to the Credits
  screen if required.
- AI-generated or scraped assets must NOT be added without a verified
  commercial-use license (design/05 §5).
