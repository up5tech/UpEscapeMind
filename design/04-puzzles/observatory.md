# Puzzle Specs — Sealed Observatory (`room_observatory`)

> 3 puzzles — the chapter finale. `puz_ob_orrery` consumes clues gathered
> across all previous rooms; `puz_ob_telescope` ends the chapter.

---

## English

### `puz_ob_starchart` — The Star Chart / Bản Đồ Sao

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_observatory` / `hot_ob_star_chart` |
| Family | Observation (sequence discovery) |
| Difficulty | hard |
| Optional? | no — `clue_dial_order` is required for `puz_ob_orrery` |

**Objective** — Read the star chart and record the order Vale hid in it.
/ Đọc bản đồ sao và ghi lại thứ tự Vale giấu trong đó.

**Prerequisites** — none (chart is always inspectable; puzzle is the
interpretation step).

**Clues** — The chart shows three marked constellations, each carrying a
small room sigil: **frame** (Gallery), **key** (Study), **gear** (Workshop).
A dotted path connects them in this order: **frame → key → gear**
(Gallery → Study → Workshop). fainter fourth mark = the seal year note.

**Solution & validation** — The puzzle is a "confirm order" interaction:
player taps the three constellations in path order; validator
`ConstellationOrderValidator` expects `[gallery, study, workshop]`. Tapping
in any other order gives gentle feedback. On success the chart zooms and
`clue_dial_order` is journaled.

**Success effects** — `clue_dial_order` ★ persisted: "Orrery order —
Gallery time, then Study time, then Workshop time; year last."
Idempotent.

**Wrong-answer feedback** — Stars dim briefly; "The chart realigns itself."
No state change.

**Reset policy** — Reset clears taps; session order kept on exit.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The chart isn't decoration — it has a path drawn through it." | "Bản đồ sao không phải đồ trang trí — có một đường kẻ xuyên qua nó." |
| L2 | "Follow the dotted line. Each constellation carries a small sigil: frame, key, gear." | "Đi theo đường chấm. Mỗi chòm sao mang một huy hiệu nhỏ: khung, chìa khóa, bánh răng." |
| L3 | "Tap in path order: frame (Gallery) → key (Study) → gear (Workshop)." | "Chạm theo thứ tự đường kẻ: khung (Gallery) → chìa khóa (Study) → bánh răng (Workshop)." |

**Localization keys** — `puz.puz_ob_starchart.title`, `.instr`,
`hint.puz_ob_starchart.l1|l2|l3`, `clue.clue_dial_order.*`.

**Validator tests** — accepts `[gallery,study,workshop]`; rejects other
permutations; journal write once.

---

### `puz_ob_orrery` — The Orrery / Mô Hình Thiên Thể

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_observatory` / `hot_ob_orrery` |
| Family | Logic deduction (multi-field entry) |
| Difficulty | hard |
| Optional? | no — arms `hot_ob_telescope` |

**Objective** — Set the orrery's three time rings and date ring to the
stopped times, in the chart's order.
/ Đặt ba vành giờ và vành ngày của orrery theo giờ dừng, theo thứ tự bản đồ.

**Prerequisites** — `clue_dial_order` (from `puz_ob_starchart`) + all clock
clues ideally journaled. Mechanically only `clue_dial_order` gates the UI;
missing time clues simply mean the player must revisit rooms.

**Clues** — Four journal ★ clues:

| Source | Clue key | Value |
| ------ | -------- | ----- |
| Study regulator (`item_clock_key` wound) | `clue_regulator_time` | **03:47** |
| Workshop wall clock (after `puz_wk_gears`) | `clue_workshop_clock` | **06:58** |
| Gallery chronometer | `clue_gallery_clock` | **08:15** |
| Study strongbox | `clue_seal_year` | **1892** |

Chart order `frame → key → gear` = Gallery → Study → Workshop, so ring
inputs are: **0815, 0347, 0658**, date ring **1892**.

**Solution & validation** — Four HHMM/year fields. Validator:
`OrrerySequenceValidator` — compares `[t1,t2,t3,year]` to
`["0815","0347","0658","1892"]`; each field normalized to 4 digits;
leading zeros significant (`0347`, `0658`, `0815` MUST keep their zero —
this is the puzzle's core trap, stated in instructions).

**Success effects** — Orrery rings turn; telescope mount releases →
`hot_ob_telescope` interactive. `clue_orrery_solution` journaled.
Idempotent.

**Wrong-answer feedback** — Rings shudder and reset; "The mechanism rejects
the heavens." No partial durable state.

**Reset policy** — Reset clears all four fields; session input kept.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Three clocks in this house kept their stopping times. The chart tells you the order." | "Ba chiếc đồng hồ trong nhà giữ giờ dừng của chúng. Bản đồ cho bạn thứ tự." |
| L2 | "Journal clues: regulator 03:47, wall clock 06:58, chronometer 08:15, seal year 1892. Chart order: gallery, study, workshop — then the year." | "Ghi chú journal: lò xo 03:47, đồng hồ treo 06:58, chronometer 08:15, năm phong ấn 1892. Thứ tự bản đồ: gallery, study, workshop — rồi đến năm." |
| L3 | "Enter 0-8-1-5, then 0-3-4-7, then 0-6-5-8, then year 1-8-9-2. Keep the leading zeros!" | "Nhập 0-8-1-5, rồi 0-3-4-7, rồi 0-6-5-8, rồi năm 1-8-9-2. Giữ số 0 đầu!" |

**Localization keys** — `puz.puz_ob_orrery.title`, `.instr`,
`hint.puz_ob_orrery.l1|l2|l3`, `clue.clue_orrery_solution.*`,
`msg.puzzle.incorrect`.

**Validator tests** — accepts `["0815","0347","0658","1892"]`; rejects
chronological order `["0347","0658","0815"]`, missing leading zeros
`["815","347","658","1892"]`, wrong year; field-level normalization.

---

### `puz_ob_telescope` — The Last Lens / Ống Kính Cuối Cùng

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_observatory` / `hot_ob_telescope` |
| Family | Item use + rotation |
| Difficulty | hard (finale) |
| Optional? | no — completes the chapter |

**Objective** — Fit the focusing lens, then turn the telescope until its
crosshair rests on the marked star.
/ Lắp ống kính hội tụ, rồi xoay kính thiên văn đến khi tâm ngắm trùng sao đánh dấu.

**Prerequisites** — `puz_ob_orrery` solved (mount released) AND
`item_focus_lens` in inventory (combine `item_lens` + `item_brass_frame`).

**Clues** — Visual: brass crosshair etching on the mount; one star in the
projected sky is circled in Vale's ink. `clue_vale_note_3` (Workshop
floorboard) explains the lens "makes far things close enough to read."

**Solution & validation** — Two-step: (1) `use_item(item_focus_lens)` —
item **consumed** on success (it becomes part of the telescope; this is the
one intentional consumption in Chapter 1); (2) rotate to target **150°**
±5° (`RotationValidator`).

**Success effects** — Telescope locks; final note projected →
`clue_epilogue` ★ journaled; chapter completion state persisted
(`chapter_01` complete, optional rating computed); `hot_ob_exit_door`
flavor unlocked. Transactional, idempotent — replaying shows the solved
telescope and epilogue note.

**Wrong-answer feedback** — Crosshair drifts past the star; "The sky
rearranges its lies." Lens on wrong hotspot: "It needs the telescope's
eyes." (item kept).

**Reset policy** — Angle session-only; lens stays fitted once used; solved
state permanent.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The lens was made for this. The star was waiting for it." | "Ống kính được làm ra vì việc này. Ngôi sao đã chờ nó." |
| L2 | "Combine lens + frame into the focusing lens (inventory), fit it to the telescope, then find the circled star." | "Kết hợp kính + khung thành ống kính hội tụ (túi đồ), lắp vào kính thiên văn, rồi tìm ngôi sao khoanh tròn." |
| L3 | "Use the focusing lens on the telescope, then rotate to about 150 degrees until the crosshair sits on the circled star." | "Dùng ống kính hội tụ lên kính thiên văn, rồi xoay khoảng 150 độ để tâm ngắm trùng ngôi sao khoanh tròn." |

**Localization keys** — `puz.puz_ob_telescope.title`, `.instr`,
`hint.puz_ob_telescope.l1|l2|l3`, `clue.clue_epilogue.*`,
`msg.chapter.complete`, `msg.item.does_not_fit`.

**Validator tests** — blocks without orrery solved or lens; accepts
145–155°; lens consumed exactly once; chapter-complete flag idempotent.

---

## Tiếng Việt

### `puz_ob_starchart` — Bản Đồ Sao

- **Mục tiêu:** Đọc bản đồ sao, ghi lại thứ tự Vale giấu.
- **Tiên quyết:** không.
- **Manh mối:** ba chòm sao đánh dấu, mỗi chòm mang huy hiệu phòng:
  **khung** (Gallery), **chìa khóa** (Study), **bánh răng** (Workshop);
  đường chấm nối theo thứ tự **khung → chìa khóa → bánh răng**
  (Gallery → Study → Workshop).
- **Lời giải & kiểm tra:** chạm các chòm theo thứ tự đường kẻ
  `[gallery, study, workshop]`; sai thứ tự → phản hồi nhẹ.
- **Khi đúng:** `clue_dial_order` ★ — "Thứ tự orrery: giờ Gallery, giờ
  Study, giờ Workshop; năm cuối." Idempotent.
- **Khi sai:** "Bản đồ tự sắp lại."; không đổi state.
- **Reset:** xóa lượt chạm.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Bản đồ sao không phải đồ trang trí — có một đường kẻ xuyên qua nó." |
| L2 | "Đi theo đường chấm. Mỗi chòm sao mang một huy hiệu nhỏ: khung, chìa khóa, bánh răng." |
| L3 | "Chạm theo thứ tự đường kẻ: khung (Gallery) → chìa khóa (Study) → bánh răng (Workshop)." |

### `puz_ob_orrery` — Mô Hình Thiên Thể

- **Mục tiêu:** Đặt ba vành giờ + vành năm theo giờ dừng, theo thứ tự bản đồ.
- **Tiên quyết:** `clue_dial_order`. Thiếu manh mối giờ → quay lại các phòng.
- **Manh mối:** bốn clue ★ —

| Nguồn | Giá trị |
| ----- | ------- |
| Lò xo Study (đã vặn `item_clock_key`) | **03:47** |
| Đồng hồ treo Workshop (sau `puz_wk_gears`) | **06:58** |
| Chronometer Gallery | **08:15** |
| Két Study | **1892** |

Thứ tự bản đồ `khung → chìa khóa → bánh răng` = Gallery → Study → Workshop
→ nhập **0815, 0347, 0658**, vành năm **1892**.

- **Lời giải & kiểm tra:** `["0815","0347","0658","1892"]`; **số 0 đầu có
  nghĩa** — bẫy cốt lõi, đã ghi trong hướng dẫn.
- **Khi đúng:** orrery quay → mount kính thiên văn mở; `clue_orrery_solution`.
  Idempotent.
- **Khi sai:** "Cơ cấu từ chối bầu trời."; không đổi state.
- **Reset:** xóa bốn ô.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Ba chiếc đồng hồ trong nhà giữ giờ dừng của chúng. Bản đồ cho bạn thứ tự." |
| L2 | "Ghi chú journal: lò xo 03:47, đồng hồ treo 06:58, chronometer 08:15, năm phong ấn 1892. Thứ tự bản đồ: gallery, study, workshop — rồi đến năm." |
| L3 | "Nhập 0-8-1-5, rồi 0-3-4-7, rồi 0-6-5-8, rồi năm 1-8-9-2. Giữ số 0 đầu!" |

### `puz_ob_telescope` — Ống Kính Cuối Cùng

- **Mục tiêu:** Lắp ống kính hội tụ, xoay kính thiên văn đến khi tâm ngắm
  trùng sao đánh dấu.
- **Tiên quyết:** `puz_ob_orrery` đã giải + `item_focus_lens` trong túi đồ
  (kết hợp `item_lens` + `item_brass_frame`).
- **Manh mối:** tâm ngắm đồng thau trên mount; một sao trong bầu trời chiếu
  được khoanh mực của Vale; `clue_vale_note_3` giải thích ống kính "làm vật
  xa đủ gần để đọc".
- **Lời giải & kiểm tra:** (1) `use_item(item_focus_lens)` — item **bị tiêu
  hao** khi thành công (lần tiêu hao cố ý duy nhất của Chương 1); (2) xoay
  **150°** ±5°.
- **Khi đúng:** ghi chú cuối → `clue_epilogue` ★; `chapter_01` hoàn thành +
  đánh giá tùy chọn; transaction, idempotent.
- **Khi sai:** "Bầu trời sắp xếp những lời nói dối."; sai chỗ: "Nó cần đôi
  mắt của kính thiên văn." (giữ item).
- **Reset:** góc chỉ trong phiên; kính đã lắp thì giữ.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Ống kính được làm ra vì việc này. Ngôi sao đã chờ nó." |
| L2 | "Kết hợp kính + khung thành ống kính hội tụ (túi đồ), lắp vào kính thiên văn, rồi tìm ngôi sao khoanh tròn." |
| L3 | "Dùng ống kính hội tụ lên kính thiên văn, rồi xoay khoảng 150 độ để tâm ngắm trùng ngôi sao khoanh tròn." |
