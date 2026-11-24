# Asset license ledger

Per `design/05-visual-style.md` §5, every shipped asset is recorded here.

| Asset group | Source | License | Notes |
| ----------- | ------ | ------- | ----- |
| `art/rooms/room_entrance.png`, `room_study.png`, `room_workshop.png`, `room_gallery.png`, `room_observatory.png` | Generated in-repo by `tool/gen_chapter1_art.py` (original programmatic art, palette per style guide) | Project-owned original IP | Replace with commissioned/approved art when available; regenerate or swap paths here. |
| `art/items/item_clock_key.png`, `item_lens.png`, `item_brass_frame.png`, `item_crank.png`, `item_focus_lens.png` | Same script | Project-owned original IP | — |
| `art/puzzles/floorboards.png`, `star_chart.png` | Same script | Project-owned original IP | Puzzle tap-scene backdrops; region coordinates in puzzle JSON match the drawn positions. |
| `art/rooms/room_sample*.png`, `art/items/item_sample_*.png`, `art/objects/sample_note.png` | Phase 1 dev fixtures | Project-owned placeholder | Dev/test only — referenced exclusively by `manifest.sample.json`; NOT reachable from the production content manifest. |
| Audio (`audio/music`, `audio/sfx`) | None shipped yet | — | Game ships silent; audio is optional (Phase 10 scope). |
| Fonts `assets/fonts/Lora/Lora.ttf`, `assets/fonts/Inter/Inter.ttf` | Google Fonts (`ofl/lora`, `ofl/inter`), downloaded 2026-11-23; OFL.txt stored beside each file | SIL Open Font License 1.1 | Vietnamese + English glyph coverage verified with fontTools for all precomposed VI characters used by the game. |
| `art/rooms/room_entrance_r2_background.webp`, `room_entrance_r2_foreground.webp`, `room_entrance_r2_solved.webp`, `art/effects/room_entrance_r2_lighting.webp` | Generated with WorkBuddy ImageGen on 2026-11-23; prompts and raw masters in `.trail/art_r2/entrance/` | AI-generated output used under provider terms; project is free and open source, owner approved AI art on 2026-11-23 | Hero-room r2 vertical slice. Overlays were alpha-processed and optimized in-repo with PIL. No third-party source art. |
| `art/rooms/room_{study,workshop,gallery,observatory}_r2_*.webp`, `art/effects/room_{study,workshop,gallery,observatory}_r2_lighting.webp` | Generated with WorkBuddy ImageGen on 2026-11-23; masters/prompts in `.trail/art_r2/{study,workshop,gallery,observatory}/` | Same owner-approved AI-art license as above | Four remaining Chapter 1 rooms. Lighting/foreground/solved overlays derived in-repo with PIL; clock hands painted to authored clue times. |
| `art/objects/inspect_{regulator,workshop_clock,portrait,star_chart}.webp` | Generated with WorkBuddy ImageGen on 2026-11-23; masters in `.trail/art_r2/inspection/` | Same owner-approved AI-art license as above | Inspection close-ups; clock hands painted programmatically to 03:47 and 06:58. |
| `art/objects/inspect_{eh_clock,eh_marks,eh_doormat,st_certificate,st_books,st_globe,st_desk,wk_blueprint,wk_crane,ga_medallions,ga_letter,ga_chronometer}.webp` and clue details repainted on all five `room_*_r2_background.webp` | Derived in-repo from the approved AI room art with `tool/paint_clues.py`; four-lever patch generated with WorkBuddy ImageGen on 2026-11-23 (`workshop/Repaint_ONLY_the_wooden_lever__*.png`) | Project-owned derivative of approved AI art; patch uses same owner-approved AI-art license | Engraved symbol order, years, blueprint codes, globe meridian, chalk X, medallion plaques, star-chart badges, etc. are drawn with Lora/Inter (OFL). Checkpoint masters in `.trail/art_r2/clean/`. |
| `art/items/item_{clock_key,lens,brass_frame,crank,focus_lens}_r2.png` | Generated with WorkBuddy ImageGen on 2026-11-23; masters in `.trail/art_r2/items/` | Same owner-approved AI-art license as above | 512×512 inventory icons; navy background converted to alpha in-repo. |
| `art/ui/menu_key_art.webp`, `design/styleframes/*.jpg`, `assets/art/branding/app_icon.png` | Derived in-repo from the AI-generated Entrance Hall master / optimized existing icon | Project-owned derivative of approved AI art | Menu key art and five approved styleframes; app icon optimized to 512 px. |

Rules for future additions:
- Commissioned or original work: note the author and date.
- Third-party: paste the license text in this folder as
  `<asset-name>.license.txt` and add the attribution to the Credits
  screen if required.
- Scraped assets must NOT be added. AI-generated assets are permitted for this
  free, open-source project with owner approval recorded above; keep the raw
  prompt/master and generation date in `.trail/art_r2/` for provenance.
