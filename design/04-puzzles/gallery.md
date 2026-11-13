# Puzzle Specs — Portrait Gallery (`room_gallery`)

> 4 puzzles. `puz_ga_case_lock` gates `room_observatory`;
> `puz_ga_frames` → `puz_ga_moon_dial` is an optional lore chain.

---

## English

### `puz_ga_portraits` — The Gallery Order / Trật Tự Phòng Chân Dung

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_gallery` / `hot_ga_medallions` |
| Family | Sequence (chronology) |
| Difficulty | medium |
| Optional? | no — reveals `clue_elias_birth` (1849), required for `puz_ga_case_lock` |

**Objective** — Hang the four portrait medallions in chronological order.
/ Treo bốn huy chương chân dung theo đúng thứ tự thời gian.

**Prerequisites** — none.

**Clues** — `clue_portrait_dates`: each medallion's brass plaque shows a
year — **1802, 1827, 1851, 1868**. A small gallery plaque reads "the dead
keep their places — earliest at the left" (VI: "người đã khuất giữ vị trí
của họ — sớm nhất bên trái").

**Solution & validation** — Left→right order `[1802, 1827, 1851, 1868]`.
Validator: `SequenceValidator` on ordered medallion IDs; each medallion
used once.

**Success effects** — The central portrait case swings open → inspectable
`hot_ga_central_portrait` yields `clue_elias_birth` ("Elias Vale, b. **1849**")
+ `clue_portrait_dates` journaled. Idempotent.

**Wrong-answer feedback** — Medallions settle back; "The gallery keeps its
own order." No state change.

**Reset policy** — Reset returns medallions to the floor pile; session order
kept on exit.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Every brass plaque has a year. Time only runs one way in a gallery." | "Mỗi biển đồng đều có một năm. Thời gian trong phòng chân dung chỉ chạy một chiều." |
| L2 | "Read the plaque years — 1802, 1827, 1851, 1868 — earliest at the left." | "Đọc năm trên biển — 1802, 1827, 1851, 1868 — sớm nhất bên trái." |
| L3 | "Left to right: 1802, 1827, 1851, 1868." | "Từ trái sang phải: 1802, 1827, 1851, 1868." |

**Localization keys** — `puz.puz_ga_portraits.title`, `.instr`,
`hint.puz_ga_portraits.l1|l2|l3`, `clue.clue_portrait_dates.*`,
`clue.clue_elias_birth.*`.

**Validator tests** — accepts the chronological tuple; rejects reverse,
duplicates, partial; central-portrait flag set once.

---

### `puz_ga_frames` — Empty Frames / Những Khung Trống

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_gallery` / `hot_ga_empty_frames` |
| Family | Symbol matching |
| Difficulty | medium |
| Optional? | effectively — gates only the optional `puz_ga_moon_dial` chain |

**Objective** — Set the three empty frames' symbols as Vale's letter
describes.
/ Đặt ký hiệu cho ba khung trống theo đúng thư của Vale.

**Prerequisites** — `clue_gallery_letter` (inspect `hot_ga_letter`).

**Clues** — `clue_gallery_letter`: Vale's letter reads *"What turns guards
the left frame; what guides the center; what waxes the right."* Mapping:
turns→`sym_key` (left), guides→`sym_star` (center), waxes→`sym_moon` (right).

**Solution & validation** — Frame symbols left→right `[sym_key, sym_star,
sym_moon]`. Validator: `FrameSymbolValidator` — three discrete symbol
choices per frame, order-sensitive comparison.

**Success effects** — Frames lock; a gear train audibly(visual-only) turns →
`hot_ga_moon_dial` becomes interactive. Idempotent.

**Wrong-answer feedback** — Frames stay empty; "The frames keep their
silence." No state change.

**Reset policy** — Reset clears all three frames; session input kept.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The letter doesn't name symbols — it names jobs." | "Bức thư không gọi tên ký hiệu — nó gọi tên vai trò." |
| L2 | "What turns = key, what guides = star, what waxes = moon. Left, center, right." | "Vặn = chìa khóa, dẫn đường = sao, tròn dần = trăng. Trái, giữa, phải." |
| L3 | "Left: key. Center: star. Right: moon." | "Trái: chìa khóa. Giữa: sao. Phải: trăng." |

**Localization keys** — `puz.puz_ga_frames.title`, `.instr`,
`hint.puz_ga_frames.l1|l2|l3`, `clue.clue_gallery_letter.*`.

**Validator tests** — accepts `[key,star,moon]`; rejects wrong positions,
duplicates; enables moon-dial flag once.

---

### `puz_ga_moon_dial` — The Moon Dial / Mặt Trăng Đồng Hồ (optional chain)

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_gallery` / `hot_ga_moon_dial` |
| Family | Rotation / alignment (phase order) |
| Difficulty | medium |
| Optional? | **yes** — rewards `clue_vale_note_4` lore only |

**Objective** — Rotate the moon dial so the four phases sit in Vale's order.
/ Xoay mặt trăng đồng hồ để bốn pha nằm đúng thứ tự của Vale.

**Prerequisites** — `puz_ga_frames` solved AND `clue_moon_phases` (from
`puz_st_astrolabe` in the Study — revisit if needed).

**Clues** — `clue_moon_phases`: the astrolabe note's last line — *"the moon
writes its name in order: new, crescent, half, full."*

**Solution & validation** — Four phase rings set to `[moon_new,
moon_crescent, moon_half, moon_full]` mapped to dial positions 1–4.
Validator: `PhaseOrderValidator` — discrete phase choices, order-sensitive.

**Success effects** — Wall cabinet opens → `clue_vale_note_4` (Vale's note
about the observatory's last night — lore). Optional objective
`obj_ga_moon` for chapter rating. No required rewards.

**Wrong-answer feedback** — Dial slips; "The moon keeps its own counsel."
No state change.

**Reset policy** — Reset clears all phases; session input kept.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The astrolabe note ended with the moon's order. The Study remembers it." | "Mẩu giấy tinh cầu kết thúc bằng thứ tự của mặt trăng. Phòng nghiên cứu còn nhớ." |
| L2 | "Revisit the astrolabe clue: new, crescent, half, full — positions 1 to 4." | "Xem lại manh mối tinh cầu: mới, lưỡi liềm, nửa, tròn — vị trí 1 đến 4." |
| L3 | "Dial 1: new moon. 2: crescent. 3: half. 4: full." | "Mặt số 1: trăng mới. 2: lưỡi liềm. 3: nửa. 4: tròn." |

**Localization keys** — `puz.puz_ga_moon_dial.title`, `.instr`,
`hint.puz_ga_moon_dial.l1|l2|l3`, `clue.clue_moon_phases.*`,
`clue.clue_vale_note_4.*`, `obj.obj_ga_moon.*`.

**Validator tests** — accepts the phase tuple; rejects wrong order;
prerequisite flags enforced.

---

### `puz_ga_case_lock` — The Reliquary / Hộp Thánh Vật

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_gallery` / `hot_ga_reliquary` |
| Family | Keypad / code lock |
| Difficulty | hard (deduction across puzzles, simple mechanism) |
| Optional? | no — grants `clue_seal_phrase` ★ and opens `room_observatory` |

**Objective** — Open the reliquary with its 4-digit code.
/ Mở hộp thánh vật bằng mã 4 số.

**Prerequisites** — `clue_elias_birth` (from `puz_ga_portraits` → central
portrait). The reliquary has no in-room clue of its own — the birth year IS
the code.

**Clues** — `clue_elias_birth`: central portrait inscription — "Elias Vale,
born **1849**". Reliquary is "his" box; the portrait sits meters away.

**Solution & validation** — Code `1849`. `KeypadValidator`, 4 digits,
leading zeros significant.

**Success effects** — Reliquary opens → `clue_seal_phrase` ★ ("SEALED BY
E.V. — THE MERIDIAN KEEPS WHAT IT IS GIVEN") + `hot_ga_observatory_exit`
becomes navigable → `room_observatory`. Idempotent.

**Wrong-answer feedback** — Soft knock; "The reliquary is patient." No
state change.

**Reset policy** — Session digits only.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Whose reliquary is this? Whose year would it keep?" | "Đây là hộp thánh vật của ai? Nó sẽ giữ năm của ai?" |
| L2 | "The central portrait was just revealed. Read the birth year on its inscription." | "Chân dung trung tâm vừa được mở. Đọc năm sinh trên dòng chữ của nó." |
| L3 | "Elias Vale, born 1849. Enter 1-8-4-9." | "Elias Vale, sinh 1849. Nhập 1-8-4-9." |

**Localization keys** — `puz.puz_ga_case_lock.title`, `.instr`,
`hint.puz_ga_case_lock.l1|l2|l3`, `clue.clue_seal_phrase.*`.

**Validator tests** — accepts `"1849"`; rejects `"184"`, `"18490"`, `"1851"`;
unlock flag set once.

---

## Tiếng Việt

### `puz_ga_portraits` — Trật Tự Phòng Chân Dung

- **Mục tiêu:** Treo bốn huy chương theo thứ tự thời gian.
- **Tiên quyết:** không.
- **Manh mối:** `clue_portrait_dates` — năm trên biển: **1802, 1827, 1851,
  1868**; biển phòng ghi "người đã khuất giữ vị trí — sớm nhất bên trái".
- **Lời giải & kiểm tra:** `[1802, 1827, 1851, 1868]` trái→phải.
- **Khi đúng:** hộp chân dung trung tâm mở → `clue_elias_birth` (**1849**) +
  `clue_portrait_dates`. Idempotent.
- **Khi sai:** "Phòng chân dung giữ trật tự riêng."; không đổi state.
- **Reset:** huy chương về đống.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Mỗi biển đồng đều có một năm. Thời gian trong phòng chân dung chỉ chạy một chiều." |
| L2 | "Đọc năm trên biển — 1802, 1827, 1851, 1868 — sớm nhất bên trái." |
| L3 | "Từ trái sang phải: 1802, 1827, 1851, 1868." |

### `puz_ga_frames` — Những Khung Trống

- **Mục tiêu:** Đặt ký hiệu ba khung theo thư của Vale.
- **Tiên quyết:** `clue_gallery_letter` (`hot_ga_letter`).
- **Manh mối:** `clue_gallery_letter` — "Vặn giữ khung trái; dẫn đường giữ
g  giữa; tròn dần giữ phải." Ánh xạ: vặn→`sym_key` (trái), dẫn→`sym_star`
  (giữa), tròn→`sym_moon` (phải).
- **Lời giải & kiểm tra:** `[sym_key, sym_star, sym_moon]` trái→phải.
- **Khi đúng:** khung khóa → `hot_ga_moon_dial` mở. Idempotent.
- **Khi sai:** "Các khung giữ im lặng."; không đổi state.
- **Reset:** xóa cả ba khung.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Bức thư không gọi tên ký hiệu — nó gọi tên vai trò." |
| L2 | "Vặn = chìa khóa, dẫn đường = sao, tròn dần = trăng. Trái, giữa, phải." |
| L3 | "Trái: chìa khóa. Giữa: sao. Phải: trăng." |

### `puz_ga_moon_dial` — Mặt Trăng Đồng Hồ (chuỗi tùy chọn)

- **Mục tiêu:** Xoay mặt trăng để bốn pha đúng thứ tự Vale.
- **Tiên quyết:** `puz_ga_frames` đã giải + `clue_moon_phases` (từ
  `puz_st_astrolabe` — quay lại phòng nghiên cứu nếu cần).
- **Manh mối:** `clue_moon_phases` — dòng cuối mẩu tinh cầu: "mặt trăng
  viết tên theo thứ tự: mới, lưỡi liềm, nửa, tròn."
- **Lời giải & kiểm tra:** `[moon_new, moon_crescent, moon_half,
  moon_full]` cho vị trí 1–4.
- **Khi đúng:** tủ tường mở → `clue_vale_note_4` (ghi chú về đêm cuối ở
  đài thiên văn — lore) + objective `obj_ga_moon`. Không thưởng bắt buộc.
- **Khi sai:** "Mặt trăng giữ bí mật riêng."; không đổi state.
- **Reset:** xóa các pha.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Mẩu giấy tinh cầu kết thúc bằng thứ tự của mặt trăng. Phòng nghiên cứu còn nhớ." |
| L2 | "Xem lại manh mối tinh cầu: mới, lưỡi liềm, nửa, tròn — vị trí 1 đến 4." |
| L3 | "Mặt số 1: trăng mới. 2: lưỡi liềm. 3: nửa. 4: tròn." |

### `puz_ga_case_lock` — Hộp Thánh Vật

- **Mục tiêu:** Mở hộp bằng mã 4 số.
- **Tiên quyết:** `clue_elias_birth` (từ `puz_ga_portraits`). Hộp không có
  manh mối riêng trong phòng — năm sinh CHÍNH LÀ mã.
- **Manh mối:** `clue_elias_birth` — "Elias Vale, sinh **1849**".
- **Lời giải & kiểm tra:** `1849`; 4 chữ số.
- **Khi đúng:** `clue_seal_phrase` ★ + `hot_ga_observatory_exit` →
  `room_observatory`. Idempotent.
- **Khi sai:** "Hộp thánh vật kiên nhẫn."; không đổi state.
- **Reset:** chỉ phiên.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Đây là hộp thánh vật của ai? Nó sẽ giữ năm của ai?" |
| L2 | "Chân dung trung tâm vừa được mở. Đọc năm sinh trên dòng chữ của nó." |
| L3 | "Elias Vale, sinh 1849. Nhập 1-8-4-9." |
