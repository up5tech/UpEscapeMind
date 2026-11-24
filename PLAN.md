# Up Escape Mind — Detailed Flutter Game Development Plan

> **Document type:** Product, game design, and technical implementation plan  
> **Project name:** Up Escape Mind  
> **Target:** Android and iOS mobile game  
> **Technology:** Flutter + Dart  
> **Game mode:** Single-player, fully offline  
> **Backend:** None  
> **Initial release target:** One polished story chapter with 5 connected areas and approximately 15–20 puzzles
> **Graphics rebuild (r2):** The §8 art direction and the related §9/§10/§12/§13/§15/§16/§17/§18 updates in this revision replace the original flat-vector art plan. The programmatic placeholder art (`tool/gen_*.py`, single-layer ~20 KB room PNGs) is superseded as release art and retained only as a fallback/placeholder generator. See §8.1–§8.8 and the new Phase 9A.

---

## 1. Product Vision

### 1.1 Overview

**Escape Mind** is a narrative-driven 2D escape-room and brain-teaser game. Players explore mysterious locations, inspect objects, collect and combine items, discover clues, solve mechanisms, and gradually unlock new areas. Each room is a self-contained environment, but its puzzles and story clues contribute to a larger mystery.

The game should feel like an atmospheric escape-room adventure rather than a collection of unrelated quiz questions. Players should be encouraged to observe carefully, form hypotheses, test solutions, and connect information found in different places.

### 1.2 Product goals

1. Deliver a satisfying escape-room experience on a phone with intuitive touch controls.
2. Make the game playable without an account, network connection, or server.
3. Support several puzzle families through reusable, data-driven components.
4. Save progress locally and restore a game after the app is closed or the device is restarted.
5. Introduce difficulty gradually without relying on arbitrary difficulty spikes.
6. Make hints available without making players feel punished for using them.
7. Make it practical to add new rooms and chapters without rewriting the game engine.

### 1.3 Design principles

- **Observation before guessing:** Important answers should be discoverable from clues in the environment or story.
- **Fair solutions:** Every puzzle must provide enough information to solve it. Avoid hidden assumptions and arbitrary trial-and-error.
- **Readable on mobile:** Clues, symbols, hotspots, and puzzle controls must remain usable on small screens.
- **Player-friendly failure:** Wrong answers should provide clear feedback without deleting progress or imposing a long penalty.
- **Progressive assistance:** Offer hints in stages, from a subtle nudge to a full explanation.
- **Offline by design:** All required content, art, audio, rules, and save data are local.
- **No false psychological claims:** The game may describe puzzle categories or difficulty, but must not present its results as a standardized IQ or psychological assessment.

### 1.4 Target audience

- Primary: Teenagers and adults who enjoy mysteries, logic games, and escape rooms.
- Secondary: Casual puzzle players who prefer short sessions and gradual progression.
- Difficulty: Easy onboarding, moderate core puzzles, and optional challenging puzzles.
- Localization: Vietnamese and English. Vietnamese should be the default language for the first release unless the product owner chooses otherwise.

---

## 2. Scope and Release Strategy

### 2.1 MVP scope

The first public-quality release should contain:

- A short prologue introducing the mystery.
- One complete chapter: **The Clockmaker's Archive**.
- Five connected areas:
  1. The Entrance Hall
  2. The Clockmaker's Study
  3. The Workshop
  4. The Portrait Gallery
  5. The Sealed Observatory
- Approximately 15–20 fully tested puzzles across multiple puzzle families.
- A local inventory with item inspection and supported item combinations.
- A three-level hint system.
- Local save/resume and chapter progress tracking.
- Settings for sound, music, haptics, language, and text presentation.
- A chapter ending that resolves the first mystery and teases the next chapter.

### 2.2 Explicitly out of scope for MVP

Do not implement these features in the initial release:

- Multiplayer, co-op, PvP, leaderboards, or online rooms.
- User accounts, cloud saves, backend APIs, or remote content delivery.
- Ads, in-app purchases, subscriptions, or an energy system.
- Procedurally generated story-critical puzzles.
- Open-ended natural-language answer interpretation.
- A physics-based 2D game engine or a platformer-style movement system.
- User-generated rooms or a public level editor.

These features may be evaluated later, but they must not delay the offline single-player core.

### 2.3 Release milestones

| Milestone        | Deliverable                                              | Exit condition                                                |
| ---------------- | -------------------------------------------------------- | ------------------------------------------------------------- |
| Prototype        | One room, three puzzle types                             | Core interaction is understandable and fun                    |
| Vertical Slice   | One complete room with inventory, hints, and save/resume | A player can complete the room without developer intervention |
| MVP              | Five connected areas and 15–20 puzzles                   | All chapter acceptance criteria pass                          |
| Content Update 1 | Additional chapter using existing systems                | New content requires minimal engine changes                   |
| Full Game        | Multiple story chapters and optional challenge rooms     | Content quality and performance remain consistent             |

---

## 3. Game Concept and Narrative

### 3.1 Premise

The player wakes inside an unfamiliar old house known as **The Meridian House**. The doors are locked, the clocks have stopped at different times, and the rooms appear to have been arranged by someone who expected the player to investigate them.

A missing clockmaker, Elias Vale, has left notes, mechanical devices, portraits, and carefully hidden clues. As the player explores the house, they discover that the rooms form a connected chain of tests. Escaping the building requires understanding why the clockmaker created them and what happened on the final night before he disappeared.

The narrative should be mysterious but easy to follow. Story information is delivered through short notes, environmental details, object descriptions, and brief scene transitions. Do not interrupt puzzle flow with long dialogue scenes.

### 3.2 Chapter 1: The Clockmaker's Archive

| Area               | Narrative purpose                           | Main mechanic                            | Unlock condition                   |
| ------------------ | ------------------------------------------- | ---------------------------------------- | ---------------------------------- |
| Entrance Hall      | Establish the setting and teach inspection  | Find and interpret visible clues         | Complete the introductory lock     |
| Clockmaker's Study | Introduce connected clues and inventory     | Collect, inspect, and combine items      | Obtain the study key               |
| Workshop           | Teach mechanical puzzle interaction         | Rotating gears and sequence controls     | Repair the small mechanism         |
| Portrait Gallery   | Connect story clues across multiple objects | Symbol matching and observation          | Discover the portrait code         |
| Sealed Observatory | Deliver the chapter's final challenge       | Multi-step deduction using earlier clues | Assemble the final access sequence |

### 3.3 Story delivery requirements

- Every story note must be short enough to read comfortably on a phone.
- Story clues must be optional to reread through a journal or discovered-notes screen.
- Critical story information must not exist only in audio.
- The player should understand why an area becomes accessible.
- The chapter ending must reward exploration and explain the result of the player's actions.
- Story text must be stored in localized content files, not hard-coded in widgets.

---

## 4. Core Gameplay Loop

### 4.1 Main loop

1. **Explore:** View a room and identify suspicious objects, drawers, symbols, locks, and mechanisms.
2. **Inspect:** Tap an interactive hotspot to zoom in or open an inspection panel.
3. **Discover:** Read a note, observe a pattern, find a key, or reveal a hidden clue.
4. **Collect:** Add usable objects to the inventory.
5. **Reason:** Connect clues from the current room, journal, and previously visited areas.
6. **Interact:** Use an item, combine compatible items, or open a puzzle interface.
7. **Solve:** Validate the answer and trigger the correct room-state transition.
8. **Unlock:** Open a drawer, activate a mechanism, or gain access to the next area.
9. **Reflect:** Record important discoveries and update chapter progress.

### 4.2 Room interaction model

Each room is a 2D illustrated scene. The scene contains:

- A background illustration.
- A set of transparent or visible interactive hotspots.
- Optional foreground elements for depth.
- An optional room title and short description.
- A navigation control to return to the chapter map or move to an adjacent unlocked area.

Hotspots should use normalized coordinates (0.0–1.0) relative to the scene image so they remain correctly positioned across screen sizes. Hotspot hit areas must be larger than the visible object when necessary to improve touch usability.

### 4.3 Inspection behavior

When a player taps a hotspot:

- Open a focused inspection view, overlay, or zoomed crop.
- Show a concise object description when relevant.
- Display available interactions, such as inspect, collect, use item, or open puzzle.
- Visually distinguish objects that have already been examined when this is useful.
- Never require pixel-perfect tapping.

### 4.4 Inventory behavior

The inventory must support:

- Collecting items.
- Viewing item names and icons.
- Opening a larger item inspection view.
- Reading an item's description and any discovered markings.
- Selecting an item and applying it to a compatible hotspot.
- Combining compatible items when the content explicitly defines a recipe.
- Removing or consuming items only when the puzzle design requires it.

Inventory actions must be deterministic and data-driven. Do not allow arbitrary item combinations to create undefined behavior.

### 4.5 Navigation and back behavior

- The player can move between previously unlocked areas.
- Returning to a room must preserve solved puzzle states and collected items.
- Leaving an active puzzle should not silently reset the player's input unless the puzzle explicitly defines that behavior.
- Android system back and iOS navigation gestures must be handled consistently.
- A pause/menu control must always be available during room exploration.

---

## 5. Puzzle Design System

### 5.1 Supported puzzle families

Implement puzzle families as reusable modules. The MVP should use at least five of the following families.

| Puzzle family           | Example interaction                                        | Main skill                 |
| ----------------------- | ---------------------------------------------------------- | -------------------------- |
| Observation             | Find a sequence of marks on furniture or paintings         | Attention to detail        |
| Keypad / code lock      | Enter a numeric or alphanumeric code                       | Clue interpretation        |
| Symbol matching         | Match symbols from a note to a device                      | Pattern recognition        |
| Sequence                | Put gears, lights, or events in the correct order          | Logical sequencing         |
| Rotation / alignment    | Rotate dials or symbols into a target arrangement          | Spatial reasoning          |
| Logic deduction         | Use several clues to infer a unique arrangement            | Deductive reasoning        |
| Item use                | Apply a key, tool, or component to an object               | Contextual reasoning       |
| Item combination        | Combine two specified components into a new item           | Multi-step problem solving |
| Hidden-object discovery | Reveal an object by examining scene details                | Observation                |
| Mechanical state puzzle | Change connected switches or gears to reach a target state | Systems thinking           |

Do not implement all families at once. Build and validate the most reusable mechanics first.

### 5.2 Puzzle quality rules

Every puzzle must have a short design specification containing:

- Puzzle ID and title.
- Room and hotspot IDs.
- Player-facing objective.
- Required prior discoveries or items.
- All clues needed to solve it.
- Correct solution and validation rules.
- Success feedback and resulting state changes.
- Wrong-answer feedback.
- Three hint levels.
- Reset behavior.
- Localization keys.
- Unit tests for the solution validator.

A puzzle is not ready for implementation until an independent reviewer can solve it using only clues available in the game.

### 5.3 Difficulty progression

Use the following progression rather than simply making codes longer:

- **Tutorial:** One obvious clue and one interaction.
- **Easy:** One clue, one-step deduction, minimal inventory use.
- **Medium:** Two or three clues that must be connected.
- **Hard:** Clues across multiple objects or areas, with a sequence of actions.
- **Final challenge:** A fair multi-step puzzle that reuses previously learned mechanics.

The difficulty must come from reasoning and clue relationships, not from tiny hotspots, unreadable symbols, or arbitrary guessing.

### 5.4 Puzzle validation

- Normalize player input where appropriate (for example, trim whitespace and normalize letter case).
- Explicitly define whether leading zeroes are meaningful in numeric codes.
- Avoid locale-dependent parsing for story-critical puzzle answers.
- Use typed validators for each puzzle family.
- Validate prerequisite conditions before allowing a puzzle to be completed.
- Make successful completion idempotent: reopening a solved puzzle must not award duplicate items or repeat one-time actions.
- Wrong attempts must not corrupt room state.

### 5.5 Example MVP puzzle distribution

A suggested first-chapter distribution:

| Area               | Puzzle examples                                            | Target count |
| ------------------ | ---------------------------------------------------------- | -----------: |
| Entrance Hall      | Observation clue, introductory code lock                   |          2–3 |
| Clockmaker's Study | Desk drawer, note sequence, item discovery                 |          3–4 |
| Workshop           | Gear alignment, component combination, mechanical sequence |          4–5 |
| Portrait Gallery   | Symbol mapping, portrait order, hidden clue                |          3–4 |
| Sealed Observatory | Multi-clue access sequence, final mechanism                |          3–4 |
| **Total**          |                                                            |    **15–20** |

These are planning targets, not permission to add filler puzzles. Every puzzle must contribute to the story, room progression, or player learning.

---

## 6. Hint System and Player Feedback

### 6.1 Three-level hints

Each puzzle should support up to three hints:

1. **Nudge:** Direct attention toward the relevant object, clue, or relationship without revealing the answer.
2. **Clue:** Explain the key deduction the player should make.
3. **Solution walkthrough:** Explain the solution step by step. Show the final answer only after an additional confirmation.

Hints must be authored per puzzle. Do not generate important hints dynamically from puzzle IDs or generic templates.

### 6.2 Hint policy

- Hints are always available in the offline game.
- Do not use a network requirement, ads, paid tokens, or energy to unlock hints.
- Do not remove chapter access or permanently punish the player for using hints.
- Remember which hint levels have already been revealed for each puzzle.
- Let the player close and reopen a hint without losing the revealed text.

### 6.3 Feedback

- Correct: clear confirmation animation and a meaningful change in the room.
- Incorrect: calm feedback that encourages another attempt.
- Missing prerequisite: explain what kind of discovery is still needed without exposing the solution.
- Already solved: show the solved state and do not repeat rewards.
- Item incompatible: explain that the item does not appear to fit, without consuming it.

---

## 7. Progression, Rewards, and Scoring

### 7.1 Progression model

- Chapters contain ordered areas.
- Areas have explicit unlock conditions.
- Puzzles can depend on collected items, clue discoveries, or other solved puzzles.
- A chapter is complete only when its final objective is fulfilled.
- Previously unlocked content remains accessible after chapter completion.

### 7.2 Optional completion rating

Use an optional three-star chapter rating based on transparent criteria such as:

- Discovering optional notes and secrets.
- Completing optional observation tasks.
- Completing a chapter without opening the full solution walkthrough (optional distinction, never a gate).

Do not make the rating depend heavily on speed. Players must be able to complete the story at their own pace. Never block story progression because a player used hints.

### 7.3 Player statistics

Local statistics may include:

- Chapters completed.
- Areas discovered.
- Puzzles solved.
- Optional clues found.
- Hints opened by level.
- Total play time, if reliable across app suspension.

These are game progress indicators only. Do not label them as clinical, educational, or standardized IQ measurements.

---

## 8. User Experience and Visual Design

### 8.1 Visual direction — Graphics Rebuild (r2)

Art identity: **"Dusty grandeur, cinematic painterly mystery"**. The Meridian House must look like a hand-painted storybook film still — rich, warm, and cinematic — not a flat vector diagram. Muted navy, charcoal, warm wood, aged paper, brass, and amber remain the core palette, but they are now rendered with material richness, gradients, texture, and hero lighting instead of flat fills.

**Diagnosis of the current (r1) art — why it cannot satisfy "đẹp, bắt mắt":**

The shipped rooms are single-layer, programmatically plotted PNGs (720×1280, ~18–23 KB/room from `tool/gen_chapter1_art.py` / `tool/gen_chapter2_art.py`). They use flat color blocks, hard pixel edges, a single dark-navy void background, sparse silhouettes with large empty negative space, no textured materials, no depth, no foreground framing, no atmospheric light, and no motion. Icon and UI art is similarly minimal (e.g. ~1.5 KB item PNGs), with no layered depth, particles, or lighting overlays (`assets/art/effects/` and `assets/art/ui/` are empty). This style reads as wireframe/placeholder in screenshots and store listings. It is adequate for hotspot alignment and logic validation, but it is not release art.

**Six art pillars for the rebuild:**

1. **Atmosphere over flatness.** Every scene has graded color, soft volumetric light cones, dust motes, vignette, and fog. Darkness is layered and directional (candle, sconce, window, moon, lantern), never a single flat navy fill.
2. **Layered depth.** Each room is a 4–5 layer parallax stack (far background → midground props → lighting/FX overlay → foreground framing → hotspot-glow UI), so the eye reads near/mid/far planes. The camera subtly parallaxes with drag/tilt (with reduced-motion fallback).
3. **Hero lighting & material richness.** Wood grain, leather, paper fibers, brass/copper/steel patina, glass reflections, pendulum brass, velvet and parchment are painted with gradients, rim light, cast shadows, and contact shadows. Objects have a light source, not just an outline.
4. **Dense, composed set dressing.** Rooms are composed like film sets: foreground silhouettes frame the view, background storytelling details (portraits, clocks, star charts, tools) fill the space, and every puzzle object is a painted hero with a readable silhouette. No empty navy voids.
5. **Motion & life.** Clocks tick and pendulums swing, flames flicker, dust drifts, gears breathe, motes catch light, and hotspot affordances pulse with a soft brass glow. Success visibly transforms the scene (door opens, light ignites, gears turn, mechanism wakes) — a checkmark alone is not a payoff.
6. **UI as jewelry.** Menus, cards, sheets, puzzle panels, and icons share one illustrated chrome: glassmorphism panels, gold-foil dividers, embossed buttons, serif display type, and consistent icon language. Screenshots must work as store art without post-processing.

The art direction should support observation. Important clues must remain visually discoverable and must not be hidden by decorative noise. Atmosphere is applied around the gameplay plane (edges, background, foreground fringe); puzzle-relevant marks, symbols, and keypad digits ship at full contrast on their own layer.

### 8.2 Main screens (art treatment)

Every screen ships with key art or illustrated chrome — no bare `Scaffold` with default Material surfaces.

1. **Splash screen:** Animated logo reveal over a dim, dust-filled key visual (hero Meridian House / grandfather clock), with a paint-fade-in and brass shimmer — not a static icon on a flat color.
2. **Main menu:** Full-bleed parallax key art (Entrance Hall hero), floating dust + light rays, large serif title with foil treatment, embossed primary actions. Continue / New Game / Chapters / Settings / Credits.
3. **Continue flow:** Resume the latest save or explain that no save exists. Uses the current room's key art as the backdrop.
4. **Chapter selection:** Illustrated chapter cards (painted thumbnail, progress seal, lock illustration), not text rows. Show chapter state: locked, available, in progress, completed.
5. **Room screen:** Full-bleed layered parallax scene (§8.6) with a glass HUD (top bar, inventory tray, guidance header), glowing hotspot affordances (§8.6), and foreground depth framing. HUD chrome never covers puzzle-relevant silhouettes.
6. **Inspection screen:** Enlarged painted inspection art with spotlight radial, parchment description card, and contextual actions in illustrated style.
7. **Puzzle screen:** Dedicated material-rich interaction UI per puzzle family — brass-and-leather keypad panels, physically shaded dials/gears/levers, star-map and parchment surfaces — built from shared puzzle chrome, not default buttons.
8. **Inventory:** Painted item icons in brass-rimmed slots with rarity glow, inspection art, and combine/use affordances in the same hand-painted language.
9. **Journal:** Aged-paper spread with hand-drawn clue art, wax-seal markers, and page-turn transitions.
10. **Hint panel:** Bottom sheet with layered parchment cards (levels 1–3) and an illustrated hint icon set.
11. **Pause/settings:** Illustrated pause emblem, grouped glass cards, and toggles in theme styling.
12. **Chapter completion:** Cinematic seal reveal with confetti-free brass particle burst, rating stars, discoveries strip, and next-chapter teaser art.

### 8.3 Mobile layout

- Design for portrait orientation first.
- Adapt to small, tall, and tablet screens without clipping controls.
- Keep primary actions within comfortable thumb reach where possible.
- Use safe areas for notches and system bars.
- Support text scaling without overlapping puzzle controls.
- Prefer scrollable puzzle panels over shrinking text below readable sizes.
- Room scene hotspots must scale with the displayed image, not with the full device screen.

### 8.4 Animation and audio

**Motion design (rebuild):** Motion sells the polish — invest in it as first-class art, not decoration.

- **Scene life (ambient):** pendulum swing, candle/sconce flicker, drifting dust motes, faint light-ray shimmer, slow fog crawl, ticking/second-hand creep, glass glint sweep. Implemented with lightweight `CustomPainter`/shader particles and `AnimatedBuilder` loops; pause off-screen and honor reduced-motion (freeze to a static lit frame).
- **Interaction juice:** hotspot press ripple + brass glow bloom, item pickup arc to inventory, sheet slide-ups with spring easing, page curls for journal, drawer/door/mechanism opens, keypad press travel, gear/lever spring-back, success shimmer + particle burst + scene transformation, wrong-answer soft shake-and-dim (never red flash), room-change crossfade + slow push-in (cinematic, ~600 ms, skippable).
- **Transitions:** short, eased, and never blocking puzzle input. No constant blinking; affordance pulses are slow (≥2 s period) and distinguishable by shape, not color alone.
- Add subtle haptic feedback for important interactions where supported.
- Provide separate music, sound-effect, and haptic toggles.
- All audio must be optional. Critical clues and game feedback must also be available visually.
- Audio playback must fail gracefully if a file is missing or the device audio system is unavailable.

### 8.5 Accessibility

- Maintain sufficient contrast for text and interactive controls.
- Provide semantic labels for interactive hotspots and inventory objects where practical.
- Do not communicate success or failure using color alone.
- Offer adjustable text size or honor system text scaling.
- Avoid rapid flashing and provide reduced-motion behavior for major animations.
- Make important symbols visually distinct, not solely color-coded.
- Support screen readers for menus, settings, journal text, and puzzle controls to a reasonable MVP standard.

### 8.6 Graphics rebuild — scene layering, art specs, and rendering contract

**Layered scene stack (portrait 9:16, full-bleed):** every room renders as a depth stack. Hotspot coordinates stay normalized to the scene canvas, so the existing hotspot system and content JSON remain valid when layers are added.

```text
foreground frame (depth) → hotspot-glow UI → lighting/FX overlay (glow, fog, particles)
→ midground props (puzzle objects, furniture) → background (far walls, windows, depth)
```

- `background`: far architecture, windows/light sources, wall treatment, base floor plane.
- `midground` (optional): furniture, machines, portraits, clocks, bookshelves — the interactive props. Puzzle-critical objects should live on this layer (or on `background` if they do not move) so lighting and parallax can treat them separately.
- `lighting`/`effects` (optional): additive light cones, lamp glows, fog, dust-mote field, vignette, solved-state overlays.
- `foreground` (optional): near-silhouette fringe (doorframe, plants, beams, blur) that frames the view and sells depth. Never occludes a hotspot or clue.
- `solvedOverlay` (optional): alternate lamps/doors/gears/lights shown when a room milestone is solved, so the room visibly transforms (§8.1 pillar 5).
- **Parallax:** far layers move less than near layers (e.g. background 4 px, midground 8 px, foreground 16 px at full drag). Driven by drag or device tilt; disabled under reduced-motion or on low-memory fallback (freeze to static full-frame).
- **Hotspot affordance:** soft brass rim glow + one slow pulse on unsolved interactive objects; solved hotspots keep a quiet static mark (no pulse). Shapes stay distinct without relying on color. Interaction remains point-and-tap — no pixel-perfect aiming.
- **Clue readability:** puzzle marks/symbols are painted at full contrast on the midground/background layer. Atmospheric overlays use screen-blend at low alpha and never sit directly over a clue digit/symbol. Any overlay that reduces clue contrast fails art QA (§8.7).

**Asset specifications (r2 release targets):**

| Asset | Spec |
| ----- | ---- |
| Room layers | 1080×1920 px source (9:16) per layer, sRGB, WebP q80 (or PNG with alpha where required). Each layer ≤ 400 KB; a full room ≤ 1.6 MB. Ship a 2×/3× resolution variant only if device profiling demands it — do not ship 2160×3840 masters as runtime assets. |
| Room source | Masters at 2× runtime size (2160×3840) kept out of the app bundle; only optimized runtime files ship. |
| Inspection art | 1080×1080 painted close-up per key hotspot, WebP, spotlight-rich, ≤ 250 KB. |
| Item icons | 512×512 with alpha, painted with soft shadow + rim light, PNG/WebP. Inspection variants 1024 px where storytelling needs them. |
| UI chrome | Shared vectors as SVG (borders, seals, icons) + WebP for textured fills. One chrome sheet per area (button, slot, sheet, card) — never per-screen one-offs. |
| Fonts | Bundled licensed display serif (story/title, full VI + EN diacritic coverage verified) + clean UI sans. System font fallback only for debug. All text respects system text scaling; display sizes are fluid (`LayoutBuilder`/media queries), never clipped. |
| Branding | App icon (512 px master + adaptive monochrome), store screenshots from real gameplay at final art, splash logo vector. |

**Rendering contract (keeps the architecture offline and honest):**

- `RoomScene` becomes a layered `Stack` of `Image` layers + a particle/glow overlay + `GestureDetector` hit layer. Single-`backgroundAsset` rooms keep working: missing layers are simply skipped.
- No Flame / physics engine. Parallax, particles, and glow use Flutter `AnimatedBuilder`, `CustomPainter`, and `Transform` — see §9.1–§9.2. Animated puzzle widgets (gears, levers, dials) can move to Rive vectors in the future; the rebuild does not add a game engine pre-emptively.
- Art is referenced from content JSON (`backgroundAsset`, `midgroundAsset`, `foregroundAsset`, `lightingAsset`, `solvedAsset`, `ambientParticle` — all optional except `backgroundAsset`). Widgets never hard-code art paths. The content validator checks every referenced file exists (§10.3, §12).
- All art is bundled and works offline (airplane mode). Precache the current room's layers + the next reachable room only; dispose off-screen layers to bound memory (§15.1).

### 8.7 Typography, color, and UI-chrome tokens (r2)

Extend `lib/app/theme/` (do not rename existing tokens; add to them) so art and code share one language:

- **Color:** Retain `inkNavy`, `charcoal`, `agedPaper`, `brass`, `amber`, `clockRed`, `parchmentText`. Add: `goldFoil` gradient (`#E8C86A → #B08D3E`), `candleGlow` (`#FFD27A` radial), `fogBlue` (`#2A3A5E` atmosphere), `parchmentShadow` (`#8A7648`), `successSeal` (muted emerald `#3E7A4E` — success is shape + motion + color, never color alone). Every surface must pass contrast checks at final art brightness, not just token values.
- **Typography scale:** `display` (splash/menu titles), `title` (room/chapter), `subtitle`, `body`, `caption`, `hint`. Display serif with generous tracking + foil gradient; body serif for story parchment; sans for UI labels. Line-height ≥ 1.4 for story; hint/body contrast ≥ 4.5:1 on final art.
- **Chrome:** `glassPanel` (dark translucent + 1 px brass border + 12–16 r radius + inner shadow), `foilDivider`, `embossedPrimaryButton`, `brassSlot` (inventory), `waxSeal` (journal/complete), `glowPulse` (hotspot). Defined once in `core/widgets` + theme extensions; screens compose, never restyle locally.
- **Iconography:** one hand-painted set (tap, inspect, collect, combine, hint, journal, pause, lock, seal, star) with consistent 2 px brass keyline + filled silhouette. Puzzle symbols differ by shape first, color second (unchanged from r1).

### 8.8 Art pipeline, production, and QA gates

**Pipeline (offline-final, reproducible):**

1. **Art Bible** (`design/05-visual-style.md` + this plan): palette, tokens, layer contract, composition grammar (foreground/mid/background, light logic), type specs, chrome specs, and 5 room styleframes (one per Chapter 1 room) approved before any batch production.
2. **Styleframe → hero room:** Entrance Hall goes first as the vertical-slice proof. Approve on a real mid-range phone at final size before painting the remaining 4 rooms.
3. **Production per room:** background → midground → lighting/effects → foreground → solved overlay → inspection art → thumbnails. Hotspot bounds are re-verified against the painted midground after every pass (see QA gate 4).
4. **Optimize:** `tool/optimize_art.py` (WebP q80, resize variants, strip metadata, alpha trim, size budget check) + `tool/validate_art.py` (dimensions, ≤ budget, sRGB, contrast sampling on clue regions). Masters stay out of the bundle.
5. **Integrate:** content JSON references the new layers; `ContentValidator` must pass; golden/widget screenshots compared per room.

**Production rules:**

- `tool/gen_*.py` output is **placeholder/fallback art only** — it guarantees hotspot alignment for engineering, but it does not ship as release art. Release art is human-finished painting (commissioned, studio, or licensed asset) with recorded provenance in `assets/licenses/` — never an unlicensed scrape, and never AI output without a confirmed commercial-use license on file.
- Hotspot alignment: painted puzzle objects must be centered in their JSON bounds (within ±0.02 of the bounds center at final canvas). If painting moves a hero object, move the JSON bounds and re-run content validation — do not hand-tune pixels in the widget.
- Every layer file is 9:16 at runtime spec; aspect mismatches fail `validate_art.py`.

**QA gates ("đẹp, bắt mắt" must be measurable):**

1. **5-second impression:** a first-time viewer describes each room's mood and one notable object within 5 s. If they describe it as "flat / empty / placeholder", the room fails.
2. **Store-screenshot test:** the 5 room screenshots + menu + one puzzle panel read as a coherent set without post-processing (same palette, same chrome, same type).
3. **Clue readability:** every puzzle-relevant mark/symbol is legible at arm's length on a mid-range phone in a bright room at final brightness, without zoom. Fails if any atmosphere overlay covers a clue.
4. **Alignment:** every hotspot is centered over its painted object; solved overlay visibly transforms the scene.
5. **Motion:** ambient loops feel alive but never distract; reduced-motion freezes to a static lit frame; parallax never displaces hotspots.
6. **Performance:** 60 fps room interaction on the agreed minimum device after full layer stack loads; first-frame time within budget (§15.1); low-memory fallback hides foreground/particles without breaking hotspot alignment.
7. **Playtest sign-off:** at least one playtester who did not design the puzzles comments unprompted that the game "looks good / premium" — not merely "functional".

---

## 9. Technical Architecture

### 9.1 Technology decisions

| Concern                | Decision                                                                 | Rationale                                                            |
| ---------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| Framework              | Flutter                                                                  | One mobile codebase for Android and iOS                              |
| Language               | Dart                                                                     | Native Flutter development language                                  |
| Architecture           | Feature-first MVVM with repositories                                     | Separates view rendering, state, game logic, and persistence         |
| State management / DI  | `flutter_riverpod`                                                       | Explicit dependencies and testable state management                  |
| Navigation             | `go_router`                                                              | Declarative routing for app screens and overlays                     |
| Local progress storage | Drift + SQLite                                                           | Transactional, structured local persistence and migrations           |
| Settings               | `shared_preferences`                                                     | Small non-critical settings such as sound and language preference    |
| Content files          | Bundled JSON assets                                                      | Versioned, offline room and puzzle definitions                       |
| Audio                  | `audioplayers` (optional)                                                | Background music and sound effects                                   |
| Scene rendering        | Flutter widgets, layered `Stack`, `GestureDetector`, `AnimatedBuilder`/`CustomPainter` particles and glow | Sufficient for r2 layered scenes and interactive hotspots without a game engine (§8.6, §9.2) |

Use the latest stable package versions compatible with the Flutter/Dart SDK selected at project initialization. Commit `pubspec.lock` for the application. Do not copy old package APIs from tutorials without checking their current documentation.

### 9.2 Why Flutter without Flame for MVP

The primary gameplay is scene exploration, hotspot tapping, inventory management, and puzzle interfaces. It does not require a continuous physics simulation, collision system, or real-time entity loop. Flutter's widget system, gestures, animation APIs, and `CustomPainter` are sufficient for the MVP and reduce architectural overhead.

Evaluate Flame only if a later chapter introduces substantial real-time movement, physics, or game-world simulation. Do not add it pre-emptively.

### 9.3 Layer responsibilities

**Presentation layer**

- Screens and reusable widgets.
- Room scene rendering and hotspot hit testing.
- Puzzle-family UI components.
- Animation and visual feedback.
- No direct database or JSON access.

**Application / ViewModel layer**

- Coordinates player actions.
- Exposes immutable screen state.
- Calls game use cases and repositories.
- Handles loading, success, and error states.

**Domain layer**

- Room, puzzle, item, clue, and progression models.
- Puzzle validators and game rules.
- Unlock-condition evaluation.
- Item-use and item-combination rules.
- No Flutter UI or database dependencies.

**Data layer**

- Content asset loader and JSON parser.
- Drift database and migrations.
- Repository implementations.
- Save conversion and schema version handling.

### 9.4 Core gameplay services

Suggested services/use cases:

- `LoadChapterUseCase`
- `LoadRoomUseCase`
- `InspectHotspotUseCase`
- `CollectItemUseCase`
- `UseInventoryItemUseCase`
- `CombineInventoryItemsUseCase`
- `StartPuzzleUseCase`
- `SubmitPuzzleAnswerUseCase`
- `RevealPuzzleHintUseCase`
- `EvaluateUnlockConditionsUseCase`
- `CompletePuzzleUseCase`
- `SaveGameProgressUseCase`
- `RestoreGameProgressUseCase`
- `CompleteChapterUseCase`

Keep simple operations in their ViewModels if extracting a dedicated use case would add unnecessary indirection. Extract shared or complex game rules into domain services.

### 9.5 State management rules

- Use immutable domain models and immutable UI state.
- Treat repositories as the source of truth for persisted progress.
- Avoid storing the same durable game state independently in multiple providers.
- Separate transient UI state (selected inventory item, open dialog) from durable game state (collected item, solved puzzle).
- Ensure successful puzzle completion and reward granting are idempotent.
- Keep puzzle validation in pure Dart classes so it can be tested without rendering widgets.

---

## 10. Content Data Model

### 10.1 Content entities

**ChapterDefinition**

- `id`
- `titleKey`
- `descriptionKey`
- `order`
- `roomIds`
- `unlockConditions`
- `endingSceneId`

**RoomDefinition**

- `id`
- `chapterId`
- `titleKey`
- `descriptionKey`
- `backgroundAsset`
- `foregroundAssets` (optional, legacy flat list)
- `midgroundAsset`, `lightingAsset`, `foregroundAsset`, `solvedAsset`, `ambientParticle` (optional r2 layers; §8.6)
- `hotspots`
- `entryConditions`
- `exitConnections`
- `ambientAudioAsset` (optional)

**r2 schema note:** the optional layer fields extend the room content format without removing any existing field, so old room JSON remains valid. Nonetheless, any change to `schemaVersion` or the on-disk save/content contract requires owner approval per `AGENTS.md` before implementation. The content validator must check every referenced layer asset exists, with `backgroundAsset` remaining the only required art field.

**HotspotDefinition**

- `id`
- `roomId`
- `bounds` (normalized x, y, width, height)
- `labelKey`
- `interactionType`
- `visibilityConditions`
- `actions`
- `inspectionAsset` (optional)

**PuzzleDefinition**

- `id`
- `roomId`
- `hotspotId`
- `type`
- `titleKey`
- `instructionsKey`
- `initialState`
- `solutionConfig`
- `validationConfig`
- `prerequisites`
- `successActions`
- `hintIds`
- `resetPolicy`

**ItemDefinition**

- `id`
- `nameKey`
- `descriptionKey`
- `iconAsset`
- `inspectionAsset` (optional)
- `tags`
- `canBeCombined`

**ItemCombinationDefinition**

- `inputItemIds`
- `resultItemId`
- `consumeInputItems`
- `resultMessageKey`

**HintDefinition**

- `id`
- `puzzleId`
- `level` (1, 2, or 3)
- `textKey`

**ClueDefinition**

- `id`
- `titleKey`
- `bodyKey`
- `sourceRoomId`
- `optional`

### 10.2 Example JSON shape

The exact schema should be finalized in Phase 2, but content should follow a predictable structure similar to:

```json
{
  "schemaVersion": 1,
  "id": "chapter_01_workshop",
  "chapterId": "chapter_01",
  "titleKey": "room.workshop.title",
  "backgroundAsset": "assets/art/rooms/workshop_background.webp",
  "midgroundAsset": "assets/art/rooms/workshop_midground.webp",
  "lightingAsset": "assets/art/effects/workshop_lighting.webp",
  "foregroundAsset": "assets/art/rooms/workshop_foreground.webp",
  "solvedAsset": "assets/art/rooms/workshop_solved.webp",
  "hotspots": [
    {
      "id": "gear_console",
      "bounds": { "x": 0.34, "y": 0.28, "width": 0.3, "height": 0.38 },
      "interactionType": "puzzle",
      "targetId": "puzzle_gear_alignment"
    }
  ]
}
```

This is an illustrative shape, not a final generated schema. Use typed Dart models and strict parsing. Unknown required fields or invalid references should fail content validation during development rather than silently producing broken gameplay.

### 10.3 Content authoring requirements

- Store visible strings behind localization keys.
- Use stable IDs; never use display text as an identifier.
- Separate room content from save-state data.
- Keep puzzle rules declarative where practical.
- Do not execute code loaded from content JSON.
- Validate all referenced asset paths, IDs, prerequisites, and puzzle types with a development-time content validator.
- Validate the optional r2 room layers (`midgroundAsset`, `lightingAsset`, `foregroundAsset`, `solvedAsset`, `ambientParticle`) with the same asset-existence check as `backgroundAsset` (§8.6).
- Provide a content version and migration strategy for save data when content changes.

---

## 11. Local Persistence and Save System

### 11.1 Data to persist

- Save slot ID and save schema version.
- Current chapter and current room.
- Unlocked chapters and rooms.
- Solved puzzle IDs.
- Per-puzzle input/progress when resuming an unfinished puzzle is supported.
- Collected inventory item IDs.
- Consumed item IDs or item state where needed.
- Discovered clue and note IDs.
- Revealed hint levels per puzzle.
- Optional objectives and completion ratings.
- Last played timestamp and accumulated play time if implemented.

### 11.2 Persistence rules

- Save after every meaningful durable change: item collection, puzzle completion, clue discovery, unlock, hint reveal, and chapter completion.
- Use database transactions when one action changes several related records.
- Store IDs and state, not duplicated copies of full content definitions.
- Restore against the currently bundled content definitions.
- Handle missing or deprecated content IDs safely.
- Include a save schema version and explicit migrations.
- Provide a destructive reset only after confirmation.
- Never overwrite a valid save with an incomplete or failed save operation.

### 11.3 Save reliability

Test these scenarios explicitly:

1. Close the app immediately after collecting an item.
2. Close the app immediately after solving a puzzle.
3. Reopen while a puzzle is unfinished.
4. Reopen after unlocking a new room.
5. Upgrade the game with an existing save.
6. Encounter a corrupted or unsupported save version.
7. Reset progress and start a clean game.

For MVP, a single local save slot is sufficient. A multi-slot system may be added later if the product requires it.

---

## 12. Suggested Project Structure

Use a feature-first structure and keep domain logic independent from Flutter widgets.

```text
escape_mind/
├── android/
├── ios/
├── assets/
│   ├── art/
│   │   ├── rooms/                 # r2: <room>_background/_midground/_foreground/_solved.webp
│   │   ├── objects/               # r2: inspection close-ups per key hotspot
│   │   ├── items/
│   │   ├── ui/                    # shared illustrated chrome (SVG + textured WebP)
│   │   └── effects/               # light cones, fog, dust motes, vignette
│   ├── licenses/                  # provenance + license ledger for shipped art/fonts
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── content/
│   │   ├── chapters/
│   │   ├── rooms/
│   │   ├── puzzles/
│   │   ├── items/
│   │   └── localization/
│   └── fonts/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   ├── theme/
│   │   └── localization/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── extensions/
│   │   ├── logging/
│   │   ├── utils/
│   │   └── widgets/
│   ├── data/
│   │   ├── content/
│   │   ├── database/
│   │   ├── repositories/
│   │   └── migrations/
│   ├── domain/
│   │   ├── models/
│   │   ├── rules/
│   │   ├── validators/
│   │   └── use_cases/
│   └── features/
│       ├── home/
│       ├── chapters/
│       ├── room/
│       ├── inspection/
│       ├── inventory/
│       ├── puzzles/
│       │   ├── keypad/
│       │   ├── sequence/
│       │   ├── symbol_matching/
│       │   ├── rotation/
│       │   └── logic_deduction/
│       ├── hints/
│       ├── journal/
│       ├── progress/
│       └── settings/
├── test/
│   ├── unit/
│   ├── widget/
│   ├── data/
│   ├── content_validation/
│   └── fixtures/
├── integration_test/
├── tool/
│   ├── gen_chapter1_art.py        # placeholder/fallback only — not release art
│   ├── gen_chapter2_art.py        # placeholder/fallback only — not release art
│   ├── optimize_art.py            # r2: WebP q80, resize, metadata strip, budget check
│   └── validate_art.py            # r2: dimensions, size, sRGB, clue-contrast sampling
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

Folder boundaries may be adjusted as the codebase grows, but do not mix UI widgets, puzzle rules, content definitions, and database implementation in one feature file.

---

## 13. Development Phases

Each phase must end with working code, tests, and a reviewable deliverable. Do not leave placeholder screens or fake puzzle success paths in a phase marked complete.

### Phase 0 — Pre-production and Game Design

**Objectives**

- Finalize the core experience and the first chapter's narrative.
- Define visual direction and interaction conventions.
- Write puzzle specifications before implementation.

**Tasks**

1. Confirm Android and iOS as the initial platforms.
2. Confirm portrait-first layout and Vietnamese/English localization.
3. Write the Chapter 1 narrative outline and room progression graph.
4. Create a room-by-room hotspot inventory.
5. Draft 15–20 puzzle briefs and map all required clues.
6. Identify optional notes and secrets.
7. Define art references and asset naming conventions.
8. Define accessibility and touch-target rules.
9. Establish content licensing and attribution requirements.

**Deliverables**

- Game design document.
- Chapter 1 story outline.
- Room progression diagram.
- Puzzle specification pack.
- Visual style guide.
- Asset checklist.

**Acceptance criteria**

- Every chapter-critical puzzle has a unique, fair solution.
- All required clues are placed in accessible locations.
- No room can become permanently unwinnable through a normal player action.
- The full chapter can be explained as a connected progression graph.

### Phase 1 — Flutter Foundation and App Architecture

**Objectives**

- Create the app foundation and establish quality gates.

**Tasks**

1. Create the Flutter project and configure Android/iOS identifiers.
2. Select a stable Flutter SDK and record it in project documentation/tooling.
3. Configure formatting, static analysis, and lint rules.
4. Add the selected state-management, routing, persistence, and optional audio packages.
5. Implement app theme, typography, colors, and shared controls.
6. Set up Riverpod providers and repository interfaces.
7. Set up navigation with named routes.
8. Add localization scaffolding for Vietnamese and English.
9. Configure unit and widget test folders.
10. Add basic CI checks for format, analyze, and tests.

**Deliverables**

- Buildable Flutter application.
- Theme and shared UI foundation.
- Router and dependency setup.
- Localization scaffolding.
- CI quality checks.

**Acceptance criteria**

- App builds for Android and iOS.
- `flutter analyze` passes without unresolved issues.
- A smoke widget test passes.
- No network permission or backend dependency is introduced without an approved reason.

### Phase 2 — Content Model and Content Validation

**Objectives**

- Define a versioned, data-driven format for chapters, rooms, hotspots, items, puzzles, and hints.

**Tasks**

1. Implement typed domain models.
2. Implement JSON parsing and schema-version handling.
3. Build a content asset loader.
4. Implement ID/reference validation.
5. Validate asset existence and normalized hotspot bounds.
6. Validate puzzle types and required configuration fields.
7. Validate hint count and localization keys.
8. Validate prerequisite references and detect circular unlock dependencies.
9. Add representative fixture content for one test room.
10. Add a development-time content validation command or test suite.

**Deliverables**

- Typed content models.
- JSON loaders.
- Content validation tests.
- Sample chapter and room definitions.

**Acceptance criteria**

- Invalid content is reported with a useful file path and field name.
- Missing assets and unknown IDs are detected before runtime.
- Content can be loaded without network access.
- Puzzle content does not execute arbitrary code.

### Phase 3 — Local Database and Save/Resume

**Objectives**

- Persist durable player progress safely.

**Tasks**

1. Define Drift tables for save slots, room progress, puzzle progress, inventory, clues, and chapter completion.
2. Implement database initialization and schema migrations.
3. Implement save and restore repositories.
4. Add settings storage for non-critical preferences.
5. Add transactional save operations.
6. Add save schema versioning and recovery handling.
7. Implement a local reset-progress flow with confirmation.
8. Add tests for app restart and migration scenarios.

**Deliverables**

- Local SQLite database.
- Save and restore repositories.
- Settings persistence.
- Migration tests.

**Acceptance criteria**

- Progress survives process termination and device restart.
- Saving a puzzle completion and its rewards is atomic.
- Corrupt or old save data does not crash the app.
- Resetting progress requires explicit confirmation.

### Phase 4 — App Shell, Home, Chapter Map, and Journal

**Objectives**

- Implement the main navigation and progression surfaces.

**Tasks**

1. Build splash and main menu.
2. Build Continue and New Game flows.
3. Build chapter selection cards and locked/unlocked states.
4. Build a chapter map or room list for Chapter 1.
5. Build journal and discovered-note screens.
6. Build pause menu and settings entry point.
7. Connect screens to persisted game state.
8. Add empty, loading, and error states.

**Deliverables**

- Navigable app shell.
- Chapter selection and map.
- Journal.
- Continue/New Game flow.

**Acceptance criteria**

- All routes work with system back behavior.
- Locked content cannot be entered through UI or direct route navigation.
- Continue restores the latest valid save.
- Journal entries appear only after their clues are discovered.

### Phase 5 — Room Exploration and Hotspot System

**Objectives**

- Build the central room exploration experience.

**Tasks**

1. Render room background assets with responsive aspect handling.
2. Position hotspots using normalized scene coordinates.
3. Implement hotspot hit testing and tap feedback.
4. Implement inspection overlays and zoomed object views.
5. Support hotspot visibility and interaction conditions.
6. Implement room transitions and back-to-map behavior.
7. Preserve solved room state when revisiting.
8. Add accessibility labels for important hotspots.
9. Test on small phones, large phones, and tablets.

**Deliverables**

- Reusable room scene widget.
- Hotspot model and interaction controller.
- Inspection view.
- Room navigation.

**Acceptance criteria**

- Hotspots remain aligned at supported aspect ratios.
- Touch targets are forgiving and reliable.
- Hidden/locked hotspots do not expose unavailable interactions.
- Reopening a room restores its durable state.

### Phase 6 — Inventory and Item Interaction

**Objectives**

- Implement item collection, inspection, application, and combination.

**Tasks**

1. Build inventory panel and item cards.
2. Implement collect-item actions.
3. Implement item inspection details.
4. Implement select-item then tap-hotspot workflow.
5. Implement data-driven item compatibility rules.
6. Implement explicitly defined item-combination recipes.
7. Implement consume/retain behavior for items.
8. Connect item actions to room state and save system.
9. Add clear feedback for invalid item use.

**Deliverables**

- Inventory UI.
- Item interaction service/use cases.
- Item combination rules.
- Persistence integration.

**Acceptance criteria**

- Items cannot be duplicated by reopening hotspots.
- Invalid combinations never destroy items.
- Item use is repeat-safe and follows its definition.
- Inventory remains correct after app restart.

### Phase 7 — Reusable Puzzle Engine and Puzzle UIs

**Objectives**

- Implement puzzle infrastructure and the puzzle families required for Chapter 1.

**Tasks**

1. Create a common puzzle interface and puzzle session state.
2. Implement puzzle loading from validated content definitions.
3. Implement keypad/code lock.
4. Implement symbol matching.
5. Implement sequence ordering.
6. Implement rotation/alignment mechanism.
7. Implement a small logic-deduction puzzle UI.
8. Implement typed answer validators.
9. Implement success, incorrect, reset, and already-solved states.
10. Make completion and rewards idempotent.
11. Add unit tests for every validator and state transition.

**Deliverables**

- Puzzle engine interfaces.
- Reusable puzzle widgets.
- Pure Dart validators.
- Puzzle-state tests.

**Acceptance criteria**

- Every supported puzzle family works with multiple content definitions.
- Puzzle rules are not hard-coded into room widgets.
- Incorrect answers do not corrupt game state.
- A solved puzzle cannot grant duplicate rewards.
- Unfinished puzzle state follows its documented resume/reset policy.

### Phase 8 — Hints, Unlock Rules, and Chapter Progression

**Objectives**

- Connect puzzle completion to a fair, understandable progression system.

**Tasks**

1. Implement prerequisite and unlock-condition evaluation.
2. Implement three-level hints.
3. Persist revealed hint levels.
4. Implement optional clues and journal discovery.
5. Implement room and chapter completion states.
6. Implement optional completion rating.
7. Add progress summary and chapter completion screen.
8. Ensure hints never block story progression.

**Deliverables**

- Hint system.
- Unlock engine.
- Chapter progress tracking.
- Completion summary.

**Acceptance criteria**

- All unlocks are deterministic and testable.
- Hint content is available offline and localized.
- Using hints never makes the chapter unwinnable.
- Chapter completion is granted exactly once.

### Phase 9 — Chapter 1 Content Production and Integration

**Objectives**

- Populate the game with a complete playable chapter.

**Tasks**

1. Produce five room backgrounds and required object/inspection art.
2. Add all hotspot definitions.
3. Implement all 15–20 reviewed puzzles.
4. Add inventory items and combination recipes.
5. Add notes, story fragments, and journal entries.
6. Add puzzle hints at all three levels where appropriate.
7. Add room transitions and chapter ending.
8. Playtest the full chapter with people who did not design the puzzles.
9. Rewrite ambiguous clues and rebalance difficulty based on feedback.

**Deliverables**

- Complete Chapter 1 content pack.
- All required art and audio assets.
- Chapter playtest report.
- Updated puzzle specifications.

**Acceptance criteria**

- A new player can finish the chapter using only in-game information.
- No progression blocker or soft lock exists.
- Story clues are understandable and can be revisited.
- The chapter contains no placeholder art, placeholder text, or fake puzzle logic in release paths.

### Phase 9A — Graphics Rebuild (r2)

**Objectives**

- Replace placeholder r1 art with the painterly, layered r2 release art defined in §8.1–§8.8.
- Prove the hero room on a real device before batch-producing the remaining rooms, while keeping every hotspot and clue readable and correctly aligned.

**Tasks**

1. Update `design/05-visual-style.md` into the r2 Art Bible: palette/tokens, layer contract, composition grammar, light logic, type and chrome specs, plus 5 room styleframes (§8.8 step 1). Obtain sign-off before batch production.
2. Gate check before implementation: obtain owner approval for any content/save schema version change or new dependency (per `AGENTS.md`). Keep `backgroundAsset` required and all new r2 layer fields optional so existing rooms keep working.
3. Paint and approve the Entrance Hall as the hero room (background → midground → lighting/effects → foreground → solved overlay → inspection art → thumbnail) at final on-device size (§8.8 step 2).
4. Extend `RoomDefinition`, `ContentValidator`, and `RoomScene` for the optional layer stack: layered `Stack`, low-memory/reduced-motion static fallback, and parallax that never moves hit regions (§8.6). Keep single-background rooms working.
5. Add r2 theme tokens and shared chrome in `lib/app/theme/` and `core/widgets` (§8.7): goldFoil, candleGlow, fogBlue, parchmentShadow, successSeal, glassPanel, foilDivider, embossed buttons, brass slots, wax seals, hotspot glow. Do not rename existing tokens.
6. Add `tool/optimize_art.py` and `tool/validate_art.py` (WebP q80, ≤ 400 KB per layer / ≤ 1.6 MB per room, 9:16 aspect, sRGB, clue-region contrast sampling). Keep 2× masters out of the app bundle (§8.8).
7. Produce the remaining four Chapter 1 rooms and their inspection art, then the shared UI chrome, item icons, fonts with verified VI/EN glyph coverage, splash/menu key art, and branding (§8.2, §8.6).
8. Wire art paths through content JSON only; never hard-code art paths in widgets. Re-verify hotspot centers against painted objects (within ±0.02) and update JSON bounds where painting moved a hero object (§8.8).
9. Record every shipped asset's source and license in `assets/licenses/`; no unlicensed scrapes and no AI art without a confirmed commercial-use license on file (§8.8).
10. Run all §8.8 QA gates, capture store screenshots from real gameplay, and integrate with Phase 10 motion/audio polish.

**Deliverables**

- Approved r2 Art Bible with 5 room styleframes.
- Layered release art for all five Chapter 1 rooms plus inspection art, UI chrome, icons, fonts, key art, and branding.
- Layer-aware `RoomScene`, extended content model/validator, r2 theme/chrome tokens, and art optimize/validate tools.
- Updated content JSON with verified hotspot alignment and completed asset license ledger.

**Acceptance criteria**

- All §8.8 QA gates pass, including the 5-second impression test, clue readability, alignment, motion, performance, and unprompted "looks premium" playtest feedback.
- Every room layer is 9:16, within size budgets, and its asset path resolves offline; the content validator flags any broken reference.
- Hotspot centers stay aligned after the art swap; no clue is obscured by atmospheric overlays; solved overlays visibly change the scene.
- Rooms with only `backgroundAsset` still render correctly; reduced-motion and low-memory fallbacks preserve hotspot alignment.
- No placeholder `tool/gen_*.py` output, unlicensed asset, or hard-coded art path remains in a release path.
- `flutter analyze` and all tests remain clean after each integration step.

---

### Phase 10 — Audio, Animation, Accessibility, and Localization Polish

**Objectives**

- Improve feel and usability without making the game slower or harder to understand.

**Tasks**

1. Add room ambience and optional background music.
2. Add interaction and puzzle feedback sound effects.
3. Add transitions for drawers, doors, mechanisms, and chapter completion.
4. Add reduced-motion behavior for major transitions.
5. Complete Vietnamese and English translations.
6. Verify text scaling and overflow in all puzzle families.
7. Review contrast, tap targets, and semantic labels.
8. Test audio toggles and device interruption handling.

**Deliverables**

- Polished audio and animation.
- Complete localization files.
- Accessibility review checklist.

**Acceptance criteria**

- The game remains fully playable with audio disabled.
- No critical clue depends on sound alone.
- Text does not overlap or disappear at supported text scales.
- Major actions remain understandable without relying on color alone.

### Phase 11 — Quality Assurance, Performance, and Release

**Objectives**

- Prepare a reliable offline mobile release.

**Tasks**

1. Run all unit, widget, content-validation, and integration tests.
2. Play through the full chapter on clean installs and upgraded installs.
3. Test save/restore under app interruption and low-storage scenarios where feasible.
4. Test Android and iOS builds on representative devices.
5. Profile scene rendering, image memory, and animation performance.
6. Compress scene art and audio without visible quality loss.
7. Verify offline behavior with network disabled.
8. Verify permissions and remove unnecessary permissions.
9. Prepare app icon, screenshots, privacy details, credits, and store descriptions.
10. Create release builds and maintain a release checklist.

**Deliverables**

- Release candidate builds.
- QA and performance report.
- Store assets and credits.
- Versioned release notes.

**Acceptance criteria**

- All critical-path tests pass.
- The complete chapter works with airplane mode enabled.
- No crash or progression blocker remains in the release candidate.
- Save data remains valid through normal app upgrades.
- Performance is acceptable on the agreed minimum supported devices.

### Phase 12 — Post-release Content Expansion

**Objectives**

- Add new chapters by reusing the existing content and puzzle systems.

**Tasks**

1. Review player feedback and crash reports only if a privacy-respecting reporting method is later approved.
2. Identify puzzle families with high reuse value.
3. Add new room art, items, clues, and puzzle definitions.
4. Add new mechanics only when they create meaningful gameplay value.
5. Add regression tests for existing chapters.
6. Version content and save migrations carefully.

**Deliverables**

- New chapter content packs.
- New puzzle families where justified.
- Updated regression suite.

**Acceptance criteria**

- Existing saves remain valid.
- New chapters work offline.
- New content does not require changes to unrelated puzzle families.

---

## 14. Testing Strategy

### 14.1 Unit tests

Prioritize pure Dart logic:

- Puzzle validators for every puzzle type.
- Unlock-condition evaluator.
- Item-use compatibility.
- Item-combination recipes.
- Duplicate reward prevention.
- Hint-level progression.
- Chapter completion calculation.
- Content parser and schema validation.
- Save-state conversion and migration logic.

### 14.2 Widget tests

Test:

- Main menu and chapter selection states.
- Room hotspot taps.
- Inspection overlay behavior.
- Inventory selection and item-use flow.
- Each puzzle family's primary controls.
- Hint reveal interactions.
- Settings persistence indicators.
- Text overflow and accessibility labels for critical controls.

### 14.3 Integration tests

At minimum, automate this player journey:

1. Launch a clean install.
2. Start a new game.
3. Complete the introductory puzzle.
4. Collect an item.
5. Use the item on a hotspot.
6. Open and solve a second puzzle.
7. Reveal a hint in another puzzle.
8. Unlock the next area.
9. Force-close and relaunch the app.
10. Continue and verify the item, puzzle, hint, and unlock states.
11. Complete the chapter and verify the completion summary.

### 14.4 Manual playtesting

- Ask testers to play without the designer explaining the solution.
- Record where players tap, what clues they notice, and where they become confused.
- Distinguish a difficult puzzle from a poorly communicated puzzle.
- Confirm that hints help without immediately spoiling the entire chapter.
- Test in bright and dim environments and on different screen sizes.

### 14.5 Quality targets

- Critical gameplay and progression logic: comprehensive unit tests.
- Every puzzle definition: content validation plus a documented expected solution.
- No known soft locks in Chapter 1.
- No critical text overflow in supported device sizes and text scales.
- Target smooth 60 FPS on agreed mid-range devices for normal room and puzzle interactions; profile before optimizing.
- App startup and room transitions should feel responsive on the minimum supported devices.

---

## 15. Performance, Build, and Engineering Standards

### 15.1 Performance

- Prefer WebP for raster room art where quality permits; follow the r2 budgets (≤ 400 KB per layer, ≤ 1.6 MB per room, 1080×1920 runtime) from §8.6.
- Avoid loading every chapter's large images into memory at startup; keep 2× masters out of the bundle.
- Precache only the current room's layers and the next reachable room; dispose off-screen layers to bound memory (§8.6).
- Provide a low-memory fallback that hides foreground/particle layers without shifting hotspots.
- Dispose audio players and controllers appropriately.
- Avoid unnecessary rebuilds of the entire room scene when inventory or journal state changes.
- Keep puzzle validation lightweight and synchronous unless there is a real need for asynchronous work.
- Profile memory and frame rendering on real devices.

### 15.2 Engineering standards

- Use null safety and sound Dart typing.
- Keep widgets focused and reasonably small.
- Keep game rules outside widget build methods.
- Use stable IDs for all content entities.
- Avoid global mutable state.
- Handle parsing, database, and asset errors explicitly.
- Do not silently swallow exceptions that can corrupt progress.
- Document non-obvious puzzle rules and save migrations.
- Keep dependencies minimal and review platform permissions introduced by each plugin.

### 15.3 Offline verification

The application must not require network access for:

- First launch and onboarding.
- Starting and continuing a game.
- Loading room art and story content.
- Solving any puzzle.
- Opening hints and the journal.
- Saving or restoring progress.
- Changing local settings.

Run an explicit airplane-mode test on release candidates. Remove network dependencies from the critical path.

---

## 16. Risks and Mitigations

| Risk                                       | Impact                                 | Mitigation                                                   |
| ------------------------------------------ | -------------------------------------- | ------------------------------------------------------------ |
| Ambiguous puzzle clues                     | Players get stuck for the wrong reason | Independent playtests and three-level hints                  |
| Hotspots are too small                     | Frustrating mobile controls            | Normalized larger hit regions and device testing             |
| Content JSON becomes inconsistent          | Runtime blockers                       | Strict schema and content validation tests                   |
| Save data breaks after updates             | Lost player progress                   | Versioned migrations and backup-safe writes                  |
| Puzzle logic becomes tightly coupled to UI | Slow content expansion                 | Pure Dart validators and reusable puzzle interfaces          |
| Art assets consume too much memory         | Slow devices or crashes                | Asset compression, lazy loading, profiling                   |
| Story text does not fit multiple languages | Broken layouts                         | Localization from the beginning and text-scaling tests       |
| Too many features delay MVP                | Incomplete first release               | Protect the MVP scope and defer online/monetization features |
| Hints reveal too much or too little        | Reduced player satisfaction            | Three-level hint design and playtesting                      |
| r2 art layers obscure clues or misalign hotspots | Puzzle becomes unreadable or unfair | QA gates 3–4 (§8.8): clue-contrast sampling, ±0.02 hotspot centering, on-device review |
| Layered art exceeds memory/size budget     | Slow devices or crashes                | Per-layer/per-room budgets, precache policy, low-memory fallback (§8.6, §15.1) |
| Art license provenance missing or invalid  | Legal/store release blocker            | `assets/licenses/` ledger; no unlicensed scrape or unlicensed AI art (§8.8) |

---

## 17. Definition of Done

A feature or phase is complete only when all applicable conditions are met:

- The implementation is functional, not a placeholder.
- UI, game rules, and persistence responsibilities are separated.
- Loading, empty, invalid, success, and error states are handled.
- Relevant unit and widget tests are included.
- Critical progression paths have integration coverage.
- Localization keys exist for all player-facing text.
- Content definitions pass validation.
- Save/resume behavior is verified when durable state changes.
- The feature works without an internet connection.
- For shipped art: the applicable §8.8 QA gates pass, art paths resolve from content JSON offline, and asset provenance is recorded in `assets/licenses/`.
- No known critical bug or soft lock remains in the affected path.
- Documentation is updated when a data model, puzzle format, or save schema changes.

---

## 18. MVP Acceptance Checklist

### Gameplay

- [ ] Player can start a new game and continue an existing game.
- [ ] Player can explore all five areas in Chapter 1.
- [ ] Hotspots respond reliably to touch.
- [ ] Player can inspect objects and collect items.
- [ ] Player can apply and combine supported inventory items.
- [ ] At least five reusable puzzle families are implemented.
- [ ] Chapter 1 contains approximately 15–20 complete, tested puzzles.
- [ ] Correct solutions unlock the intended objects and areas.
- [ ] Wrong answers do not corrupt progress.
- [ ] Three-level hints work offline.
- [ ] Journal entries and discovered clues persist.
- [ ] Chapter ending and completion summary work.

### Technical

- [ ] Android and iOS builds succeed.
- [ ] Game content is bundled locally.
- [ ] Save data survives app restarts.
- [ ] Database migrations are tested.
- [ ] Content validation catches broken IDs and assets.
- [ ] Unit, widget, and integration tests pass.
- [ ] No backend, account, or network dependency is required.

### UX and quality

- [ ] Portrait-first layouts work on small and large phones.
- [ ] Critical controls have usable tap targets.
- [ ] Vietnamese and English strings are complete.
- [ ] Text scaling does not break critical puzzle screens.
- [ ] Audio and haptics can be disabled.
- [ ] All important clues are available visually.
- [ ] Rooms use r2 layered art with legible clues, aligned hotspots, and visible solved-state transformations (§8.8 QA gates 3–5).
- [ ] Store screenshots come from real gameplay at final art with no post-processing (§8.8 QA gate 2).
- [ ] No critical soft lock, save loss, or blocker remains.

---

## 19. Initial Implementation Backlog

Recommended first sprint order:

1. Create the Flutter project and baseline architecture.
2. Implement the core domain models for chapter, room, hotspot, item, and puzzle.
3. Implement one JSON-backed room and strict content validation.
4. Render the room background and normalized hotspots.
5. Implement one inspection overlay.
6. Implement one inventory item and one item-use interaction.
7. Implement a reusable keypad puzzle and pure Dart validator.
8. Persist the solved puzzle and collected item using the local database.
9. Force-close and relaunch to verify resume behavior.
10. Expand the vertical slice to three connected puzzles before implementing all Chapter 1 content.

**Recommended first playable slice:** Entrance Hall with one inspectable clue, one collectible key, one code lock, a three-level hint panel, and a save/resume cycle. This validates the central technical risks before the team produces all five rooms.

---

## 20. Reference Documentation

Use official documentation as the source of truth and verify package APIs against the versions selected for the project.

- Flutter app architecture guide: https://docs.flutter.dev/app-architecture/guide
- Flutter architecture recommendations: https://docs.flutter.dev/app-architecture/recommendations
- Flutter architecture concepts and data flow: https://docs.flutter.dev/app-architecture/concepts
- Flutter assets and images: https://docs.flutter.dev/ui/assets/assets-and-images
- Flutter testing overview: https://docs.flutter.dev/testing/overview
- Flutter integration testing: https://docs.flutter.dev/testing/integration-tests
- `flutter_riverpod`: https://pub.dev/packages/flutter_riverpod
- `go_router`: https://pub.dev/packages/go_router
- `drift`: https://pub.dev/packages/drift
- `audioplayers` (optional): https://pub.dev/packages/audioplayers

---

## Final Product Direction

Build **Escape Mind** as a polished, offline-first escape-room adventure with a reusable puzzle framework and story-led progression. Prioritize a complete, enjoyable first chapter over a large number of shallow levels. The first vertical slice must prove that room exploration, clue discovery, inventory, puzzle solving, hints, and local persistence work together before full content production begins.
