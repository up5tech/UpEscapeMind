# Puzzle Specs — Entrance Hall (`room_entrance`)

> 3 puzzles: 2 required-path (tutorial), 1 optional.
> See `README.md` in this folder for the spec template and global conventions.

---

## English

### `puz_eh_door_lock` — The Sealed Study Door / Cánh cửa Phòng Nghiên Cứu bị Phong ấn

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_entrance` / `hot_eh_study_door` |
| Family | Keypad / code lock |
| Difficulty | tutorial |
| Optional? | no — gates `room_study` |

**Objective** — Enter the 4-digit code that opens the study door.
/ Nhập mã 4 số mở cửa phòng nghiên cứu.

**Prerequisites** — none.

**Clues** — `clue_clock_1024`: the grandfather clock
(`hot_eh_grandfather_clock`) is stopped at **10:24**; the door panel has a
small clock motif suggesting "the hour it stopped". Both are in the same room.

**Solution & validation** — Code `1024`. Validator: `KeypadValidator` expects
exactly 4 digits; leading zeros significant (not used here); whitespace trimmed;
non-digit input rejected at UI level. Case/locale irrelevant (numeric).

**Success effects** — `puzzle_solved(puz_eh_door_lock)` persisted;
`hot_eh_study_door` becomes navigable → `room_study`. Idempotent: revisiting
shows the open door; no rewards are re-granted.

**Wrong-answer feedback** — Short dull "thunk", panel shake ≤200 ms, digits
clear after 600 ms. No state change. After 3 failures the hint button pulses
once (does not auto-open hints).

**Reset policy** — Leaving the puzzle keeps entered digits in-session only;
nothing durable is stored for this puzzle.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The house keeps time in its own way. One clock here never stopped — it just forgot how to start again." | "Ngôi nhà này giữ thời gian theo cách riêng. Có một chiếc đồng hồ ở đây chưa từng dừng — chỉ là quên cách chạy lại." |
| L2 | "Inspect the large clock on the left wall. Its hands point to a time — that time is the code." | "Quan sát chiếc đồng hồ lớn bên trái. Kim chỉ một giờ — giờ đó chính là mã." |
| L3 | "The grandfather clock stopped at 10:24. Enter 1-0-2-4 on the door panel." | "Đồng hồ quả lắc dừng lúc 10:24. Nhập 1-0-2-4 trên bảng cửa." |

**Localization keys** — `puz.puz_eh_door_lock.title`, `.instr`,
`hint.puz_eh_door_lock.l1|l2|l3`, `msg.puzzle.incorrect`, `msg.door.unlocked`.

**Validator tests** — accepts `"1024"`; rejects `"102"`, `"10245"`, `"10a4"`,
`" 1024 "` (trim → accept), `"0102"`; idempotent success transition.

---

### `puz_eh_marks` — Marks Beside the Door / Ký hiệu bên cạnh Cửa

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_entrance` / `hot_eh_marks` |
| Family | Symbol matching (order-based) |
| Difficulty | tutorial |
| Optional? | no — `item_clock_key` is required for the orrery clue chain |

**Objective** — Reproduce the carved symbol sequence on the three dials.
/ Tái hiện trình tự ký hiệu khắc lên ba mặt số.

**Prerequisites** — none.

**Clues** — `clue_marks_order`: the carved marks beside the door read, left
to right: **moon → star → sun**. The hotspot's Inspect action reveals the
carved band and adds this clue to the journal *before* the puzzle is opened —
the puzzle UI also shows the reference carving.

**Solution & validation** — Dial order `[moon, star, sun]`. Validator:
`SymbolOrderValidator` compares the ordered list of symbol IDs to the
solution config; order-sensitive; exactly 3 positions, each a distinct symbol.
No duplicates allowed (UI enforces).

**Success effects** — Wall cabinet opens: grants `item_clock_key` (once),
`clue_vale_note_1`, `clue_marks_order` already journaled. State:
`puzzle_solved` + `item_collected(item_clock_key)` in one transaction.
Idempotent.

**Wrong-answer feedback** — Dials wiggle and return to start; message
"The marks don't align." No state change. Reset button restores all dials.

**Reset policy** — Reset restores dials to blank; per-session input kept on
exit; solved state never resets.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Someone carved a message beside the door. Whatever order they carved it in — that's the answer." | "Có người đã khắc một thông điệp bên cạnh cửa. Thứ tự họ khắc — đó chính là đáp án." |
| L2 | "Inspect the marks closely: moon first, then star, then sun. Set the dials in that order, left to right." | "Nhìn kỹ các ký hiệu: trăng trước, rồi sao, rồi mặt trời. Đặt các mặt số theo thứ tự đó, từ trái sang phải." |
| L3 | "Dial 1 = moon, dial 2 = star, dial 3 = sun. Then pull the brass lever." | "Mặt số 1 = trăng, mặt số 2 = sao, mặt số 3 = mặt trời. Sau đó kéo cần đồng thau." |

**Localization keys** — `puz.puz_eh_marks.title`, `.instr`,
`hint.puz_eh_marks.l1|l2|l3`, `item.item_clock_key.name`,
`item.item_clock_key.desc`, `clue.clue_marks_order.*`, `clue.clue_vale_note_1.*`.

**Validator tests** — accepts `[moon,star,sun]`; rejects wrong order,
duplicate symbols, wrong length; success grants item exactly once across
repeated submissions.

---

### `puz_eh_sconce` — The Dark Sconces / Những Ngọn Đèn Tường Tắt (optional)

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_entrance` / `hot_eh_sconce_panel` |
| Family | Mechanical state |
| Difficulty | easy |
| Optional? | **yes** — rewards optional objective + lore only |

**Objective** — Flip the three sconce switches to match the pattern noted
under the doormat.
/ Gạt ba công tắc đèn tường theo mẫu ghi dưới thảm chùi chân.

**Prerequisites** — none. Clue `clue_doormat` is a plain inspect (not gated).

**Clues** — `clue_doormat`: note under the doormat reads "Wax where the moon
hides — up, down, up." Pattern: **up, down, up** on switches 1–3.

**Solution & validation** — Lever states `[up, down, up]`. Validator:
`LeverPatternValidator`, fixed 3-position boolean pattern, order-sensitive.
Individual flips are allowed freely; only the full pattern completes.

**Success effects** — Sconces light up (visual reward); grants
`clue_eh_secret` (Vale's hidden note) + completes optional objective
`obj_eh_sconces` for the chapter rating. No items, no unlocks.

**Wrong-answer feedback** — A "confirm" press with wrong pattern: one sconce
flickers and dies; message "One flame refuses." No state change.

**Reset policy** — Reset returns all switches to down; session input kept.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The doormat is heavier than it looks." | "Tấm thảm chùi chân nặng hơn vẻ ngoài của nó." |
| L2 | "Lift the doormat and read the note. It describes which flames should burn." | "Nhấc thảm chùi chân lên và đọc mẩu giấy. Nó mô tả ngọn lửa nào nên cháy." |
| L3 | "Note says: up, down, up. Set switch 1 up, switch 2 down, switch 3 up." | "Mẩu giấy viết: lên, xuống, lên. Công tắc 1 lên, công tắc 2 xuống, công tắc 3 lên." |

**Localization keys** — `puz.puz_eh_sconce.title`, `.instr`,
`hint.puz_eh_sconce.l1|l2|l3`, `clue.clue_doormat.*`,
`clue.clue_eh_secret.*`, `obj.obj_eh_sconces.*`.

**Validator tests** — accepts `[U,D,U]`; rejects `[D,U,D]`, partial patterns,
extra positions; lighting effect idempotent.

---

## Tiếng Việt

### `puz_eh_door_lock` — Cánh cửa Phòng Nghiên Cứu bị Phong ấn

- **Mục tiêu:** Nhập mã 4 số mở cửa phòng nghiên cứu.
- **Tiên quyết:** không.
- **Manh mối:** `clue_clock_1024` — đồng hồ quả lắc dừng lúc **10:24**;
  bảng cửa có hình đồng hồ gợi ý "giờ nó dừng".
- **Lời giải & kiểm tra:** mã `1024`; đúng 4 chữ số, số 0 đầu có nghĩa,
  trim khoảng trắng.
- **Khi đúng:** lưu `puzzle_solved`, cửa mở → `room_study`. Idempotent.
- **Khi sai:** tiếng "cạch" ngắn, rung nhẹ, xóa số sau 600 ms; không đổi state.
- **Reset:** số nhập chỉ giữ trong phiên.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Ngôi nhà này giữ thời gian theo cách riêng. Có một chiếc đồng hồ ở đây chưa từng dừng — chỉ là quên cách chạy lại." |
| L2 | "Quan sát chiếc đồng hồ lớn bên trái. Kim chỉ một giờ — giờ đó chính là mã." |
| L3 | "Đồng hồ quả lắc dừng lúc 10:24. Nhập 1-0-2-4 trên bảng cửa." |

### `puz_eh_marks` — Ký hiệu bên cạnh Cửa

- **Mục tiêu:** Tái hiện trình tự ký hiệu khắc lên ba mặt số.
- **Tiên quyết:** không.
- **Manh mối:** `clue_marks_order` — thứ tự khắc trái→phải: **trăng → sao →
  mặt trời**. Inspect hotspot hiện dải khắc và thêm clue vào journal trước
  khi mở puzzle; UI puzzle cũng hiện hình tham chiếu.
- **Lời giải & kiểm tra:** `[moon, star, sun]`; so sánh có thứ tự, đúng 3
  vị trí, không trùng ký hiệu.
- **Khi đúng:** tủ mở → `item_clock_key` + `clue_vale_note_1`; transaction
  nguyên tử; idempotent.
- **Khi sai:** mặt số nảy về đầu; "Các ký hiệu chưa thẳng hàng."; không đổi state.
- **Reset:** mặt số về trống; state đã giải không reset.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Có người đã khắc một thông điệp bên cạnh cửa. Thứ tự họ khắc — đó chính là đáp án." |
| L2 | "Nhìn kỹ các ký hiệu: trăng trước, rồi sao, rồi mặt trời. Đặt các mặt số theo thứ tự đó, từ trái sang phải." |
| L3 | "Mặt số 1 = trăng, mặt số 2 = sao, mặt số 3 = mặt trời. Sau đó kéo cần đồng thau." |

### `puz_eh_sconce` — Những Ngọn Đèn Tường Tắt (tùy chọn)

- **Mục tiêu:** Gạt ba công tắc đèn theo mẫu dưới thảm chùi chân.
- **Tiên quyết:** không; `clue_doormat` là inspect thường.
- **Manh mối:** `clue_doormat` — "Đốt sáp nơi trăng ẩn — lên, xuống, lên."
  Pattern: **lên, xuống, lên** cho công tắc 1–3.
- **Lời giải & kiểm tra:** `[up, down, up]`; so sánh có thứ tự, cố định 3 vị trí.
- **Khi đúng:** đèn sáng; `clue_eh_secret` + objective `obj_eh_sconces`
  (đánh giá ★ chương). Không vật phẩm, không mở khóa.
- **Khi sai:** một đèn chớp tắt; "Một ngọn lửa từ chối."; không đổi state.
- **Reset:** công tắc về xuống.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Tấm thảm chùi chân nặng hơn vẻ ngoài của nó." |
| L2 | "Nhấc thảm chùi chân lên và đọc mẩu giấy. Nó mô tả ngọn lửa nào nên cháy." |
| L3 | "Mẩu giấy viết: lên, xuống, lên. Công tắc 1 lên, công tắc 2 xuống, công tắc 3 lên." |
