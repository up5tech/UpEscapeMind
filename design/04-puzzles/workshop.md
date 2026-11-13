# Puzzle Specs — Workshop (`room_workshop`)

> 5 puzzles. `puz_wk_crane` gates `room_gallery`; `puz_wk_floorboard` +
> `puz_wk_code` feed the `item_focus_lens` chain.

---

## English

### `puz_wk_gears` — The Frozen Gear Train / Dãy Bánh Răng Đông Cứng

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_workshop` / `hot_wk_gear_wall` |
| Family | Rotation / alignment |
| Difficulty | easy |
| Optional? | no — powers the room (wall clock clue + crane prerequisite) |

**Objective** — Rotate the three gear rings until each brass marker sits at
the top pointer.
/ Xoay ba vành bánh răng đến khi mỗi dấu đồng thau nằm ở kim chỉ trên.

**Prerequisites** — none.

**Clues** — A chalk arrow and three small "12 o'clock" marks painted beside
the mechanism (`hot_wk_gear_wall` inspect shows them). No written clue
needed — the target is visual alignment.

**Solution & validation** — Each ring has a marked tooth that must reach the
top detent: ring A = 0°, ring B = 120°, ring C = 240° (values in
`solutionConfig`). Validator: `MultiRotationValidator` — three independent
angles, each normalized 0–359, tolerance ±5°, all must hold simultaneously.

**Success effects** — Mechanism engages (audible-free visual: gears turn,
dust sifts); room power flag set → `hot_wk_wall_clock` now yields
`clue_workshop_clock` (06:58) ★; `puz_wk_crane` prerequisite satisfied.
Idempotent.

**Wrong-answer feedback** — Gears grind and slip back a few degrees; "The
train won't hold." No state change.

**Reset policy** — Reset all rings to 0°; session angles kept on exit.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Three rings, three markers, one pointer each." | "Ba vành, ba dấu, mỗi vành một kim chỉ." |
| L2 | "Turn each ring until its brass mark reaches the small pointer at the top." | "Xoay mỗi vành đến khi dấu đồng thau chạm kim chỉ nhỏ ở trên." |
| L3 | "Ring A: 0°, ring B: 120°, ring C: 240° — all markers at top." | "Vành A: 0°, vành B: 120°, vành C: 240° — mọi dấu đều ở trên." |

**Localization keys** — `puz.puz_wk_gears.title`, `.instr`,
`hint.puz_wk_gears.l1|l2|l3`, `clue.clue_workshop_clock.*`.

**Validator tests** — accepts the triple within tolerance; rejects two-of-
three correct; independent ring state; power flag set once.

---

### `puz_wk_levers` — The Lever Board / Bảng Cần Gạt

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_workshop` / `hot_wk_lever_board` |
| Family | Mechanical state |
| Difficulty | medium |
| Optional? | no — opens `hot_wk_floorboard` → `item_brass_frame` |

**Objective** — Set the four levers to the pattern on Vale's blueprint.
/ Đặt bốn cần gạt theo mẫu trong bản thiết kế của Vale.

**Prerequisites** — `clue_blueprint` (inspect `hot_wk_blueprint` — always
available).

**Clues** — `clue_blueprint`: the wall blueprint's lower-left corner shows
the lever diagram labeled "VENT SEQUENCE": positions 1–4 = **up, down, up,
down**. (Same blueprint also carries gear tooth counts for `puz_wk_code`.)

**Solution & validation** — Lever states `[U, D, U, D]`. Validator:
`LeverPatternValidator`, 4 positions, order-sensitive. Levers flip freely;
only full match completes.

**Success effects** — A floor panel releases with a heavy slide →
`hot_wk_floorboard` becomes interactive. Idempotent.

**Wrong-answer feedback** — "Confirm" with wrong pattern: levers shudder,
none move; "The board stays sealed." No state change.

**Reset policy** — Reset returns all levers to down; session input kept.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The blueprint on the wall has more than one diagram on it." | "Bản thiết kế trên tường có nhiều hơn một sơ đồ." |
| L2 | "Check the lower-left corner of the blueprint — a small 'VENT SEQUENCE' diagram shows four positions." | "Xem góc dưới trái bản thiết kế — sơ đồ 'VENT SEQUENCE' nhỏ ghi bốn vị trí." |
| L3 | "Up, down, up, down — levers 1 through 4." | "Lên, xuống, lên, xuống — cần 1 đến 4." |

**Localization keys** — `puz.puz_wk_levers.title`, `.instr`,
`hint.puz_wk_levers.l1|l2|l3`, `clue.clue_blueprint.*`.

**Validator tests** — accepts `[U,D,U,D]`; rejects rotations of the pattern,
partial sets, wrong length.

---

### `puz_wk_code` — The Parts Cabinet / Tủ Đồ Phụ Tùng

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_workshop` / `hot_wk_parts_cabinet` |
| Family | Keypad / code lock |
| Difficulty | medium |
| Optional? | no — grants `item_crank`, required for `puz_wk_crane` |

**Objective** — Enter the 4-digit cabinet code.
/ Nhập mã 4 số của tủ đồ.

**Prerequisites** — `clue_blueprint` helpful but not strictly required —
tooth counts are engraved on the gears themselves; blueprint makes it easy.

**Clues** — `clue_blueprint`: "CABINET CODE — count teeth, small gear
first: **24**, **36** → `2436`. The gear wall inspection also shows tooth
counts if the player counts manually (24 and 36 teeth on the two marked gears).

**Solution & validation** — Code `2436`. `KeypadValidator`, 4 digits,
leading zeros significant (not used). Order matters: small gear first —
stated on the blueprint.

**Success effects** — Cabinet opens → grants `item_crank` (winch handle,
required to operate `hot_wk_crane`). Idempotent.

**Wrong-answer feedback** — Metallic clunk; "The cabinet keeps its order."
No state change.

**Reset policy** — Session digits only.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The cabinet doesn't want a word. It wants numbers the gears already know." | "Tủ đồ không cần một từ. Nó cần những con số mà bánh răng đã biết." |
| L2 | "Blueprint, upper-right: tooth counts, small gear first — 24 then 36." | "Bản thiết kế, góc trên phải: số răng, bánh nhỏ trước — 24 rồi 36." |
| L3 | "Enter 2-4-3-6." | "Nhập 2-4-3-6." |

**Localization keys** — `puz.puz_wk_code.title`, `.instr`,
`hint.puz_wk_code.l1|l2|l3`, `item.item_crank.name`, `item.item_crank.desc`,
`clue.clue_blueprint.*`.

**Validator tests** — accepts `"2436"`; rejects `"3624"`, `"243"`, `"24360"`.

---

### `puz_wk_floorboard` — The Loose Floorboard / Ván Sàn Lỏng

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_workshop` / `hot_wk_floorboard` |
| Family | Hidden-object discovery |
| Difficulty | medium |
| Optional? | no — grants `item_brass_frame` (required for `item_focus_lens`) |

**Objective** — Find the loose floorboard among its neighbors and lift it.
/ Tìm ván sàn lỏng giữa các tấm bên cạnh và nhấc lên.

**Prerequisites** — `puz_wk_levers` solved (floor panel released).

**Clues** — Visual only: the loose board sits proud by ~2 mm with a dust-free
gap on its north edge; the cavity below holds a felt-wrapped bundle.
`clue_vale_note_3` is the *reward*, not an input.

**Solution & validation** — Tap the correct board region
(`bounds.floorboard_target`, one of five candidates). Validator:
`HotspotHitValidator` — normalized tap inside target rect (with padding);
wrong taps produce gentle feedback; found state persists.

**Success effects** — Board lifts (animation) → grants `item_brass_frame`
(once) + `clue_vale_note_3` ("The frame is for something that looks far —
keep it polished."). Idempotent.

**Wrong-answer feedback** — Board rattles dully; "Solid wood." No state
change; up to all wrong boards can be tapped without penalty.

**Reset policy** — Within a session, found boards stay found; leaving and
re-entering puzzle keeps solved state.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "One board in this floor wasn't laid by the same hands." | "Có một tấm ván trong sàn này không do cùng một đôi tay lát." |
| L2 | "Look for the board that sits slightly higher, with a clean gap where dust can't settle." | "Tìm tấm ván hơi nhô lên, có khe sạch nơi bụi không lắng được." |
| L3 | "The middle board, second from the left — tap it firmly." | "Tấm giữa, thứ hai từ trái — chạm mạnh vào." |

**Localization keys** — `puz.puz_wk_floorboard.title`, `.instr`,
`hint.puz_wk_floorboard.l1|l2|l3`, `item.item_brass_frame.name`,
`item.item_brass_frame.desc`, `clue.clue_vale_note_3.*`.

**Validator tests** — accepts tap in target rect; rejects taps in sibling
rects; single-grant idempotency; prerequisite gate.

---

### `puz_wk_crane` — The Hoist Crane / Cần Cẩu

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_workshop` / `hot_wk_crane` |
| Family | Item use + rotation |
| Difficulty | hard |
| Optional? | no — gates `room_gallery` |

**Objective** — Fit the winch handle, then swing the crane arm until the
hook catches the marked crate.
/ Lắp tay quay, rồi xoay cần cẩu đến khi móc trúng thùng đánh dấu.

**Prerequisites** — `puz_wk_gears` solved (power) AND `item_crank` in
inventory (from `puz_wk_code`).

**Clues** — Visual: a chalk arrow on the floor shows the swing path; the
target crate is chalked with an X. `clue_vale_note_3` hints the mechanism
"sleeps until it is fed and turned" (item + rotation).

**Solution & validation** — Two-step: (1) `use_item(item_crank)` on
`hot_wk_crane` — item is **retained** (not consumed); (2) rotate arm to
target **300°** ±5° (`RotationValidator`). Both steps required; order
flexible (rotate first, fit later also completes).

**Success effects** — Crate lifts; gallery door mechanism releases →
`hot_wk_gallery_exit` navigable → `room_gallery`. Idempotent.

**Wrong-answer feedback** — Arm swings and settles; "The hook misses."
Crank fit on wrong hotspot: "It doesn't fit here." (item kept).

**Reset policy** — Arm angle session-only; crank stays fitted once used.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The crane is hungry for a handle, and patient for an angle." | "Cần cẩu đói một tay quay, và kiên nhẫn chờ một góc." |
| L2 | "The parts cabinet held a winch handle. Fit it, then follow the chalk arrow on the floor." | "Tủ phụ tùng có tay quay. Lắp vào, rồi theo vạch phấn trên sàn." |
| L3 | "Use the crank on the crane, then rotate the arm to about 300 degrees so the hook reaches the X-marked crate." | "Dùng tay quay lên cần cẩu, rồi xoay cần khoảng 300 độ để móc chạm thùng đánh dấu X." |

**Localization keys** — `puz.puz_wk_crane.title`, `.instr`,
`hint.puz_wk_crane.l1|l2|l3`, `item.item_crank.*`, `msg.item.does_not_fit`.

**Validator tests** — blocks completion without crank; accepts 295–305°;
crank retained after success; prerequisites enforced.

---

## Tiếng Việt

### `puz_wk_gears` — Dãy Bánh Răng Đông Cứng

- **Mục tiêu:** Xoay ba vành đến khi mỗi dấu đồng thau ở kim chỉ trên.
- **Tiên quyết:** không.
- **Manh mối:** mũi tên phấn + ba dấu "12 giờ" cạnh cơ cấu — căn chỉnh bằng mắt.
- **Lời giải & kiểm tra:** vành A=0°, B=120°, C=240°; dung sai ±5°,
  cả ba cùng đúng.
- **Khi đúng:** cấp điện phòng → `hot_wk_wall_clock` cho `clue_workshop_clock`
  (06:58) ★ + tiên quyết cho `puz_wk_crane`. Idempotent.
- **Khi sai:** bánh răng trượt; "Cỗ máy không giữ được."; không đổi state.
- **Reset:** về 0°.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Ba vành, ba dấu, mỗi vành một kim chỉ." |
| L2 | "Xoay mỗi vành đến khi dấu đồng thau chạm kim chỉ nhỏ ở trên." |
| L3 | "Vành A: 0°, vành B: 120°, vành C: 240° — mọi dấu đều ở trên." |

### `puz_wk_levers` — Bảng Cần Gạt

- **Mục tiêu:** Đặt bốn cần theo mẫu trong bản thiết kế.
- **Tiên quyết:** `clue_blueprint` (`hot_wk_blueprint`, đọc tự do).
- **Manh mối:** `clue_blueprint` — góc dưới trái: sơ đồ "VENT SEQUENCE",
  vị trí 1–4 = **lên, xuống, lên, xuống**.
- **Lời giải & kiểm tra:** `[U, D, U, D]`; so sánh có thứ tự.
- **Khi đúng:** panel sàn nhả → `hot_wk_floorboard` mở. Idempotent.
- **Khi sai:** "Bảng vẫn kín."; không đổi state.
- **Reset:** cần về xuống.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Bản thiết kế trên tường có nhiều hơn một sơ đồ." |
| L2 | "Xem góc dưới trái bản thiết kế — sơ đồ 'VENT SEQUENCE' nhỏ ghi bốn vị trí." |
| L3 | "Lên, xuống, lên, xuống — cần 1 đến 4." |

### `puz_wk_code` — Tủ Đồ Phụ Tùng

- **Mục tiêu:** Nhập mã 4 số của tủ.
- **Tiên quyết:** không bắt buộc (`clue_blueprint` giúp dễ hơn; số răng
  khắc trên bánh răng).
- **Manh mối:** `clue_blueprint` — "CABINET CODE — đếm răng, bánh nhỏ
  trước: **24**, **36**" → `2436`.
- **Lời giải & kiểm tra:** `2436`; thứ tự quan trọng (bánh nhỏ trước).
- **Khi đúng:** `item_crank` (tay quay cần cho `puz_wk_crane`). Idempotent.
- **Khi sai:** "Tủ giữ trật tự của nó."; không đổi state.
- **Reset:** chỉ phiên.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Tủ đồ không cần một từ. Nó cần những con số mà bánh răng đã biết." |
| L2 | "Bản thiết kế, góc trên phải: số răng, bánh nhỏ trước — 24 rồi 36." |
| L3 | "Nhập 2-4-3-6." |

### `puz_wk_floorboard` — Ván Sàn Lỏng

- **Mục tiêu:** Tìm ván sàn lỏng và nhấc lên.
- **Tiên quyết:** `puz_wk_levers` đã giải.
- **Manh mối:** chỉ quan sát — ván lỏng nhô ~2mm, mép bắc sạch bụi; hốc
  chứa gói bọc nhung.
- **Lời giải & kiểm tra:** chạm đúng vùng ván (`bounds.floorboard_target`,
  1 trong 5 ứng viên).
- **Khi đúng:** `item_brass_frame` + `clue_vale_note_3`. Idempotent.
- **Khi sai:** "Gỗ đặc."; không đổi state; chạm sai không phạt.
- **Reset:** ván đã tìm giữ trong phiên.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Có một tấm ván trong sàn này không do cùng một đôi tay lát." |
| L2 | "Tìm tấm ván hơi nhô lên, có khe sạch nơi bụi không lắng được." |
| L3 | "Tấm giữa, thứ hai từ trái — chạm mạnh vào." |

### `puz_wk_crane` — Cần Cẩu

- **Mục tiêu:** Lắp tay quay, xoay cần đến khi móc trúng thùng đánh dấu.
- **Tiên quyết:** `puz_wk_gears` đã giải + `item_crank` trong túi đồ.
- **Manh mối:** mũi tên phấn trên sàn chỉ quỹ đạo; thùng mục tiêu đánh dấu X;
  `clue_vale_note_3` gợi ý cơ cấu "ngủ cho đến khi được cho ăn và vặn".
- **Lời giải & kiểm tra:** hai bước — `use_item(item_crank)` (item **giữ
  lại**) rồi xoay cần **300°** ±5°.
- **Khi đúng:** thùng nhấc lên → `hot_wk_gallery_exit` mở → `room_gallery`.
  Idempotent.
- **Khi sai:** "Móc trượt."; dùng sai chỗ: "Không vừa." (giữ item).
- **Reset:** góc chỉ trong phiên; tay quay đã lắp thì giữ.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Cần cẩu đói một tay quay, và kiên nhẫn chờ một góc." |
| L2 | "Tủ phụ tùng có tay quay. Lắp vào, rồi theo vạch phấn trên sàn." |
| L3 | "Dùng tay quay lên cần cẩu, rồi xoay cần khoảng 300 độ để móc chạm thùng đánh dấu X." |
