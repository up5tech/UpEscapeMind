# Puzzle Specs — Clockmaker's Study (`room_study`)

> 4 puzzles. `puz_st_globe` gates `room_workshop`; the others feed the
> item/clue chain toward the observatory.

---

## English

### `puz_st_books` — The Stopped Hours / Những Giờ Đã Dừng

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_study` / `hot_st_bookshelf` |
| Family | Sequence |
| Difficulty | easy |
| Optional? | no — grants `item_lens` (required for `item_focus_lens`) |

**Objective** — Return three fallen books to the shelf in the order Vale
intended.
/ Xếp lại ba cuốn sách rơi về kệ theo đúng thứ tự Vale định.

**Prerequisites** — none.

**Clues** — `clue_book_dates`: each book's spine shows a publication year —
**1861, 1874, 1892**. The shelf's label plate reads "earliest first"
(Vietnamese: "từ sớm nhất"). Both visible in the puzzle UI.

**Solution & validation** — Order `[1861, 1874, 1892]` mapped to book slots
`[book_early, book_mid, book_late]`. Validator: `SequenceValidator` compares
ordered book IDs; the correct sequence is defined in `solutionConfig`. Books
are draggable/tappable to slots; duplicates impossible (each book used once).

**Success effects** — Hidden drawer slides open: grants `item_lens` (once),
`clue_astrolabe` (note found inside), `clue_book_dates`. Transaction:
`puzzle_solved` + `item_collected` + clues. Idempotent.

**Wrong-answer feedback** — Books settle back; "The shelf rejects the order."
No state change; in-session arrangement kept until Reset/exit.

**Reset policy** — Reset returns all books to the "fallen" pile. Session
arrangement persists on exit; solved state persists permanently.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Vale was a man of dates. Every book on this shelf has one." | "Vale là người của những con số năm. Mỗi cuốn sách trên kệ đều có một năm." |
| L2 | "Read the years on the spines — 1861, 1874, 1892 — and follow the label: earliest first." | "Đọc năm trên gáy sách — 1861, 1874, 1892 — và làm theo nhãn: từ sớm nhất." |
| L3 | "Place the 1861 book left, the 1874 book middle, the 1892 book right." | "Đặt sách 1861 bên trái, sách 1874 giữa, sách 1892 bên phải." |

**Localization keys** — `puz.puz_st_books.title`, `.instr`,
`hint.puz_st_books.l1|l2|l3`, `item.item_lens.name`, `item.item_lens.desc`,
`clue.clue_astrolabe.*`, `clue.clue_book_dates.*`.

**Validator tests** — accepts `[1861,1874,1892]`; rejects reversed/duplicate/
partial orders; rewards granted exactly once.

---

### `puz_st_safe` — Vale's Strongbox / Két sắt của Vale

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_study` / `hot_st_safe` |
| Family | Keypad / code lock |
| Difficulty | easy |
| Optional? | no — `clue_seal_year` (1892) is a required orrery input |

**Objective** — Open the strongbox with its 4-digit combination.
/ Mở két sắt bằng mã 4 số.

**Prerequisites** — none (clue is inspectable in-room).

**Clues** — `clue_apprentice_year`: the wall certificate
(`hot_st_certificate`) records "Elias Vale, apprenticed to the Meridian
Guild — **1874**". The strongbox dial has four wheels.

**Solution & validation** — Code `1874`. `KeypadValidator`, 4 digits,
leading zeros significant. The certificate is intentionally readable — this
puzzle teaches keypad use after the tutorial door.

**Success effects** — Grants `clue_vale_note_2` (apprenticeship record) and
`clue_seal_year` ("Sealed in the year of the Meridian transit: **1892**") —
the orrery date input. Idempotent.

**Wrong-answer feedback** — Dull clunk, wheels stay; "The box holds its
secrets." No state change.

**Reset policy** — Session digits only; nothing durable.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Guild records are proud of their years." | "Giấy tờ của phường hội luôn tự hào về năm tháng." |
| L2 | "The framed certificate on the wall names a year — Vale's apprenticeship. That year opens the box." | "Tấm chứng chỉ đóng khung trên tường ghi một năm — năm Vale học nghề. Năm đó mở được két." |
| L3 | "Apprenticed 1874. Enter 1-8-7-4." | "Học nghề năm 1874. Nhập 1-8-7-4." |

**Localization keys** — `puz.puz_st_safe.title`, `.instr`,
`hint.puz_st_safe.l1|l2|l3`, `clue.clue_vale_note_2.*`, `clue.clue_seal_year.*`,
`clue.clue_apprentice_year.*`.

**Validator tests** — accepts `"1874"`; rejects `"187"`, `"18740"`, `"abcd"`.

---

### `puz_st_astrolabe` — The Astrolabe / Tinh cầu

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_study` / `hot_st_astrolabe` |
| Family | Symbol matching (ring alignment) |
| Difficulty | medium |
| Optional? | no for `clue_moon_phases` chain? — **moon dial is optional**, but this puzzle also **enables `puz_st_globe`** which gates the workshop → effectively required |

**Objective** — Align the astrolabe's four rings so the pointer reads Vale's
intended sequence.
/ Xoay bốn vòng tinh cầu để kim chỉ đọc đúng trình tự Vale định.

**Prerequisites** — `clue_astrolabe` (found via `puz_st_books` reward — the
note inside the drawer).

**Clues** — `clue_astrolabe`: Vale's note describes the rings by function,
in order: *"First the guide that sailors steer by, then the mirror that
borrows its light, then the key that turns what sleeps, then the flame that
needs no spark."* Mapping: guide→`sym_star`, mirror→`sym_moon`,
turner→`sym_key`, burner→`sym_sun`.

**Solution & validation** — Ring order `[sym_star, sym_moon, sym_key,
sym_sun]` from outermost to innermost (as labeled in UI). Validator:
`RingOrderValidator` — each ring has discrete detents (4 positions each);
solution is the ordered tuple of symbol IDs.

**Success effects** — Astrolabe locks with a soft chime; grants
`clue_moon_phases` (moon order `new → crescent → half → full`, used by
`puz_ga_moon_dial`); sets prerequisite flag enabling `puz_st_globe`.
Idempotent.

**Wrong-answer feedback** — Rings turn loosely and slip back; "The astrolabe
won't hold." No state change.

**Reset policy** — Reset returns all rings to start detent; session input
kept on exit.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "Vale described the rings without naming them. Every symbol has a job." | "Vale mô tả các vòng mà không gọi tên chúng. Mỗi ký hiệu đều có một vai trò." |
| L2 | "Sailors steer by the star; the moon borrows the sun's light; the key turns the lock; the sun needs no spark. Match the descriptions, outermost ring first." | "Thủy thủ định hướng bằng sao; trăng mượn ánh mặt trời; chìa khóa vặn ổ khóa; mặt trời không cần tia lửa. Ghép mô tả, vòng ngoài cùng trước." |
| L3 | "Outer→inner: star, moon, key, sun." | "Ngoài→trong: sao, trăng, chìa khóa, mặt trời." |

**Localization keys** — `puz.puz_st_astrolabe.title`, `.instr`,
`hint.puz_st_astrolabe.l1|l2|l3`, `clue.clue_astrolabe.*`,
`clue.clue_moon_phases.*`.

**Validator tests** — accepts `[star,moon,key,sun]`; rejects partial/wrong
order; enabling flag set once.

---

### `puz_st_globe` — The Meridian Globe / Quả địa cầu Meridian

| Field | Value |
| ----- | ----- |
| Room / Hotspot | `room_study` / `hot_st_globe` |
| Family | Rotation / alignment |
| Difficulty | medium |
| Optional? | no — opens `room_workshop` |

**Objective** — Rotate the globe until its marked meridian aligns with the
brass pointer.
/ Xoay quả địa cầu đến khi kinh tuyến đánh dấu thẳng hàng kim đồng thau.

**Prerequisites** — `puz_st_astrolabe` solved (the astrolabe's arm physically
indexes the globe).

**Clues** — Vale's desk note (`hot_st_desk`, `clue_vale_letter` optional
inspect): *"Turn the world until the line that remembers faces the flame."*
The meridian is painted red; the pointer is brass. No numeric clue needed —
alignment is visual.

**Solution & validation** — Rotate globe so meridian marks align with pointer:
target angle **210°** (defined in `solutionConfig`). Validator:
`RotationValidator` — input angle normalized 0–359, tolerance ±5°, snaps on
success.

**Success effects** — Globe locks; a hidden catch releases →
`hot_st_workshop_exit` becomes navigable → `room_workshop`. Idempotent.

**Wrong-answer feedback** — Globe spins freely and settles; "The meridian
slips away." No state change.

**Reset policy** — Globe keeps last angle in-session; Reset returns to 0°.
Solved state permanent.

**Hints**

| Level | EN | VI |
| ----- | -- | -- |
| L1 | "The desk note says the world must face the flame." | "Mẩu giấy trên bàn viết rằng quả đất phải quay về phía ngọn lửa." |
| L2 | "Find the red meridian line and the small brass pointer. Turn until they meet." | "Tìm đường kinh tuyến đỏ và kim đồng thau nhỏ. Xoay đến khi chúng gặp nhau." |
| L3 | "Rotate the globe about 210 degrees — the red line should point at the pointer." | "Xoay quả địa cầu khoảng 210 độ — đường đỏ phải chỉ vào kim." |

**Localization keys** — `puz.puz_st_globe.title`, `.instr`,
`hint.puz_st_globe.l1|l2|l3`, `clue.clue_vale_letter.*`.

**Validator tests** — accepts 205–215°; rejects 0°, 180°±10; snap behavior;
prerequisite check blocks submission before astrolabe solved.

---

## Tiếng Việt

### `puz_st_books` — Những Giờ Đã Dừng

- **Mục tiêu:** Xếp ba cuốn sách về kệ đúng thứ tự Vale định.
- **Tiên quyết:** không.
- **Manh mối:** `clue_book_dates` — năm trên gáy: **1861, 1874, 1892**; nhãn
  kệ ghi "từ sớm nhất".
- **Lời giải & kiểm tra:** `[1861, 1874, 1892]`; mỗi sách dùng một lần.
- **Khi đúng:** ngăn kéo ẩn mở → `item_lens` + `clue_astrolabe` +
  `clue_book_dates`; transaction; idempotent.
- **Khi sai:** sách trở về; "Kệ sách từ chối thứ tự này."; không đổi state.
- **Reset:** sách về đống ban đầu.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Vale là người của những con số năm. Mỗi cuốn sách trên kệ đều có một năm." |
| L2 | "Đọc năm trên gáy sách — 1861, 1874, 1892 — và làm theo nhãn: từ sớm nhất." |
| L3 | "Đặt sách 1861 bên trái, sách 1874 giữa, sách 1892 bên phải." |

### `puz_st_safe` — Két sắt của Vale

- **Mục tiêu:** Mở két bằng mã 4 số.
- **Tiên quyết:** không.
- **Manh mối:** `clue_apprentice_year` — chứng chỉ "Elias Vale, học nghề
  phường Meridian — **1874**".
- **Lời giải & kiểm tra:** `1874`; 4 chữ số, số 0 đầu có nghĩa.
- **Khi đúng:** `clue_vale_note_2` + `clue_seal_year` (**1892** — đầu vào
  ngày của orrery). Idempotent.
- **Khi sai:** "Két giữ kín bí mật."; không đổi state.
- **Reset:** chỉ số nhập trong phiên.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Giấy tờ của phường hội luôn tự hào về năm tháng." |
| L2 | "Tấm chứng chỉ đóng khung trên tường ghi một năm — năm Vale học nghề. Năm đó mở được két." |
| L3 | "Học nghề năm 1874. Nhập 1-8-7-4." |

### `puz_st_astrolabe` — Tinh cầu

- **Mục tiêu:** Xoay bốn vòng để kim chỉ đọc đúng trình tự Vale định.
- **Tiên quyết:** `clue_astrolabe` (trong phần thưởng `puz_st_books`).
- **Manh mối:** `clue_astrolabe` — ghi chú mô tả vòng theo chức năng, theo
  thứ tự: "Đầu tiên người dẫn đường cho thủy thủ, rồi tấm gương mượn sáng,
  rồi chìa khóa vặn vật ngủ, rồi ngọn lửa không cần tia lửa." Ánh xạ:
  dẫn đường→`sym_star`, gương→`sym_moon`, vặn→`sym_key`, lửa→`sym_sun`.
- **Lời giải & kiểm tra:** `[sym_star, sym_moon, sym_key, sym_sun]` từ vòng
  ngoài vào trong.
- **Khi đúng:** `clue_moon_phases` (trăng: mới → lưỡi liềm → nửa → tròn,
  cho `puz_ga_moon_dial`) + mở tiên quyết cho `puz_st_globe`. Idempotent.
- **Khi sai:** vòng trượt về; "Tinh cầu không giữ được."; không đổi state.
- **Reset:** vòng về nấc đầu.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Vale mô tả các vòng mà không gọi tên chúng. Mỗi ký hiệu đều có một vai trò." |
| L2 | "Thủy thủ định hướng bằng sao; trăng mượn ánh mặt trời; chìa khóa vặn ổ khóa; mặt trời không cần tia lửa. Ghép mô tả, vòng ngoài cùng trước." |
| L3 | "Ngoài→trong: sao, trăng, chìa khóa, mặt trời." |

### `puz_st_globe` — Quả địa cầu Meridian

- **Mục tiêu:** Xoay địa cầu để kinh tuyến đánh dấu thẳng kim đồng thau.
- **Tiên quyết:** `puz_st_astrolabe` đã giải.
- **Manh mối:** `clue_vale_letter` (trên bàn, tùy chọn) — "Xoay quả đất đến
  khi đường ghi nhớ hướng về ngọn lửa." Kinh tuyến đỏ, kim đồng thau; căn
  chỉnh bằng mắt, không cần số.
- **Lời giải & kiểm tra:** góc mục tiêu **210°**, dung sai ±5°.
- **Khi đúng:** chốt mở → `hot_st_workshop_exit` → `room_workshop`. Idempotent.
- **Khi sai:** "Kinh tuyến trượt mất."; không đổi state.
- **Reset:** Reset về 0°; góc giữ trong phiên.
- **Gợi ý:**

| Mức | VI |
| --- | -- |
| L1 | "Mẩu giấy trên bàn viết rằng quả đất phải quay về phía ngọn lửa." |
| L2 | "Tìm đường kinh tuyến đỏ và kim đồng thau nhỏ. Xoay đến khi chúng gặp nhau." |
| L3 | "Xoay quả địa cầu khoảng 210 độ — đường đỏ phải chỉ vào kim." |
