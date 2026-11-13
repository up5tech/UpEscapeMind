# 02 — Chapter 1 Story Outline: The Clockmaker's Archive

> Phase 0 deliverable. Narrative source of truth for Chapter 1.
> All story text ships via localization keys; drafts below are the approved copy direction.

---

## English

### 1. Premise (chapter scope)

The player wakes on the floor of **The Meridian House**, an old townhouse.
Every clock in the house has stopped — each at a different time. A note in
the Entrance Hall says only: *"The archive keeps what the house forgets. — E.V."*

Elias Vale, the house's clockmaker, vanished eleven years ago. His study,
workshop, portrait gallery, and a sealed observatory remain. Somewhere in the
house is the truth of his last night — and the way out.

### 2. Chapter arc

| Beat | Room | Story beat |
| ---- | ---- | ---------- |
| 1 | Entrance Hall | Player learns to inspect. Finds Vale's first note. Unlocks the study door (clock stopped at 10:24 → code). |
| 2 | Clockmaker's Study | Vale's workspace: stopped regulator, strongbox, astrolabe, globe. Learns item collection/combine basics. Learns the house's "seal year" (1892). |
| 3 | Workshop | Vale's mechanical workbench. Gears frozen mid-turn; levers, cabinet, floorboard, hoist. Finds lens + frame → focusing lens. Wall clock stopped at 6:58. |
| 4 | Portrait Gallery | Portraits of Vale's family and patrons with dates. Chronological ordering puzzle. Moon dial opens a side panel. Reliquary reveals the "seal phrase". Chronometer stopped at 8:15. |
| 5 | Sealed Observatory | Orrery and telescope. Star chart gives dial order; orrery needs the three stopped times + seal year; focusing lens reveals the final note → chapter ending. |

### 3. The central mystery (fair-play design)

- Every clock in the house stopped at a **different time** — deliberate, not random.
- The three "mechanism" clocks (regulator, wall clock, chronometer) hold the
  orrery times; the seal year 1892 is the date dial.
- The **order** of the dials is given by the observatory star chart, not guessed.
- Vale's notes (journal `clue_vale_note_*`) frame why: he sealed the observatory
  to keep the Meridian mechanism from being used against the town — a tease for
  Chapter 2.

### 4. Room-by-room narrative beats

**Entrance Hall**
- Mood: dust, cold light through tall windows, grandfather clock dominating.
- Beats: intro inspection tutorial → doormat note (optional) → door lock →
  carved marks → winding key in cabinet → dark sconce optional objective.
- Exit: study door opens; Vale's note 1 found.

**Clockmaker's Study**
- Mood: cluttered desk, stopped regulator, certificates on wall.
- Beats: book-order puzzle (dates on spines) → lens → strongbox (apprentice
  year 1874) → astrolabe (symbols) → globe (meridian) → workshop door.
- Item beat: winding key used on regulator → reveals 03:47 (journal).

**Workshop**
- Mood: industrial, half-assembled machines, oil smell implied visually.
- Beats: gear train → power → wall clock 06:58 → lever board → floorboard →
  brass frame → parts cabinet (blueprint tooth counts) → hoist crane →
  gallery door.
- Item beat: lens + frame → focusing lens (journal hint).

**Portrait Gallery**
- Mood: formal, hushed, portraits in gilt frames.
- Beats: order portraits by plaque years → central portrait (Elias, b. 1849)
  → empty frames symbol match → moon dial → reliquary (seal phrase) →
  chronometer 08:15 → observatory door.

**Sealed Observatory**
- Mood: dome, brass orrery, telescope, star chart projector.
- Beats: star chart → dial order → orrery (times + 1892) → telescope with
  focusing lens → final note → chapter complete.

### 5. Chapter ending

Solving `puz_ob_telescope` shows Vale's final note (`clue_epilogue`): the
observatory was sealed the night the Meridian Star aligned; the mechanism he
protected is still running — somewhere. Chapter completion screen: discoveries
found, optional rating, "Chapter 2 — The Meridian Mechanism" locked teaser.

### 6. Journal notes roster (all optional except marked ★)

| Key | Room | ★ | Short content (EN draft / VI draft) |
| --- | ---- | - | ----------------------------------- |
| `clue_marks_order` | Entrance | | Carved order: moon → star → sun. / Thứ tự khắc: trăng → sao → mặt trời. |
| `clue_clock_1024` | Entrance | ★ | Grandfather clock stopped at 10:24. / Đồng hồ quả lắc dừng lúc 10:24. |
| `clue_vale_note_1` | Entrance | ★ | "The archive keeps what the house forgets." / "Lưu trữ giữ lại điều ngôi nhà lãng quên." |
| `clue_vale_note_2` | Study safe | | Vale's apprenticeship record, 1874. / Hồ sơ học nghề của Vale, 1874. |
| `clue_astrolabe` | Study books | ★ | Note describing astrolabe ring symbols. / Ghi chú mô tả ký hiệu vòng tinh cầu. |
| `clue_seal_year` | Study safe | ★ | "Sealed in the year of the Meridian transit: 1892." / "Phong ấn năm sao Hậu xuyên qua: 1892." |
| `clue_book_dates` | Study books | | Book spine years used for ordering. / Năm trên gáy sách dùng để sắp xếp. |
| `clue_regulator_time` | Study item-use | ★ | Wound regulator ticks: stopped at 03:47. / Lò xo đồng hồ chạy: dừng lúc 03:47. |
| `clue_workshop_clock` | Workshop | ★ | Wall clock stopped at 06:58 once powered. / Đồng hồ treo tường dừng lúc 06:58. |
| `clue_blueprint` | Workshop cabinet | | Gear tooth counts for the cabinet code. / Số răng bánh răng cho mã tủ đồ. |
| `clue_vale_note_3` | Workshop floorboard | | Vale's note about the focusing lens. / Ghi chú của Vale về ống kính hội tụ. |
| `clue_portrait_dates` | Gallery | ★ | Plaque years ordering the medallions. / Năm trên biển tên sắp xếp các huy chương. |
| `clue_elias_birth` | Gallery | ★ | Central portrait: Elias Vale, b. 1849. / Chân dung trung tâm: Elias Vale, sinh 1849. |
| `clue_gallery_clock` | Gallery | ★ | Chronometer stopped at 08:15. / Đồng hồ chronometer dừng lúc 08:15. |
| `clue_seal_phrase` | Gallery reliquary | ★ | Reliquary phrase confirming the seal. / Câu xác nhận phong ấn trong hộp thánh vật. |
| `clue_dial_order` | Observatory | ★ | Star chart constellation → dial order. / Chòm sao trên bản đồ sao → thứ tự mặt số. |
| `clue_orrery_solution` | Observatory | | Times entered: 03:47, 06:58, 08:15 + 1892. / Giờ đã nhập: 03:47, 06:58, 08:15 + 1892. |
| `clue_epilogue` | Observatory | ★ | Vale's final note + chapter tease. / Ghi chú cuối của Vale + hé lộ chương 2. |

★ = required for chapter completion path (directly or via puzzle chain).

*Minor inspect-only clues also exist (`clue_doormat`, `clue_eh_secret`,
`clue_moon_phases`, `clue_gallery_letter`, `clue_vale_note_4`,
`clue_vale_letter`) — see `design/README.md` registry and the puzzle specs.*

### 7. Prologue (brief)

Cold open: black screen → text-only prologue (≤3 short cards): the house, the
stopped clocks, "someone arranged this for you." Then main menu → New Game →
room_entrance. Prologue text is localized, skippable, never blocks input.

---

## Tiếng Việt

### 1. Giả định (phạm vi chương)

Người chơi tỉnh dậy trên sàn **Dinh thự Meridian** — một tòa nhà cũ. Mọi đồng
hồ trong nhà đều đã dừng, mỗi chiếc một giờ khác nhau. Một mẩu giấy ở Sảnh
Chính chỉ viết: *"Kho lưu trữ giữ lại điều ngôi nhà lãng quên. — E.V."*

Elias Vale, người thợ làm đồng hồ của dinh thự, đã mất tích mười một năm
trước. Phòng nghiên cứu, xưởng, phòng chân dung và một đài thiên văn bị phong
ấn của ông vẫn còn nguyên. Đâu đó trong ngôi nhà là sự thật về đêm cuối cùng
của ông — và lối ra.

### 2. Cung truyện chương

| Nhịp | Phòng | Diễn biến |
| --- | ---- | -------- |
| 1 | Sảnh Chính | Học cách quan sát. Tìm ghi chú đầu tiên của Vale. Mở cửa phòng nghiên cứu (đồng hồ dừng 10:24 → mã). |
| 2 | Phòng Nghiên Cứu | Nơi làm việc của Vale: lò xo dừng, két sắt, tinh cầu, quả địa cầu. Học nhặt/kết hợp vật phẩm. Biết năm phong ấn (1892). |
| 3 | Xưởng | Bàn máy cơ khí của Vale. Bánh răng đông cứng; cần gạt, tủ đồ, ván sàn, cần cẩu. Tìm kính + khung → ống kính hội tụ. Đồng hồ treo tường dừng 6:58. |
| 4 | Phòng Chân Dung | Chân dung gia đình và bảo trợ của Vale kèm năm tháng. Puzzle sắp xếp niên đại. Mặt trăng mở panel bên. Hộp thánh vật lộ "câu phong ấn". Chronometer dừng 8:15. |
| 5 | Đài Thiên Văn | Orrery và kính thiên văn. Bản đồ sao cho thứ tự mặt số; orrery cần ba giờ dừng + năm phong ấn; ống kính hội tụ lộ ghi chú cuối → kết thúc chương. |

### 3. Bí ẩn trung tâm (thiết kế công bằng)

- Mọi đồng hồ đều dừng ở **giờ khác nhau** — cố ý, không ngẫu nhiên.
- Ba đồng hồ "cơ cấu" (lò xo, treo tường, chronometer) chứa giờ của orrery;
  năm phong ấn 1892 là mặt số ngày.
- **Thứ tự** mặt số do bản đồ sao trong đài thiên văn cho biết, không phải đoán.
- Ghi chú của Vale (`clue_vale_note_*`) giải thích lý do: ông phong ấn đài
  thiên văn để bảo vệ cơ cấu Meridian — gợi mở cho Chương 2.

### 4. Nhịp truyện từng phòng

**Sảnh Chính** — Ánh sáng lạnh qua cửa sổ cao, đồng hồ quả lắc lớn.
Học quan sát → ghi chú dưới thảm (tùy chọn) → khóa cửa → ký hiệu khắc →
chìa vặn trong tủ → đèn tường tối (mục tiêu phụ chọn).

**Phòng Nghiên Cứu** — Bàn bừa bộn, lò xo dừng, chứng chỉ trên tường.
Xếp sách theo năm → kính → két sắt (năm học nghề 1874) → tinh cầu → địa cầu
(meridian) → cửa xưởng. Dùng chìa vặn lò xo → lộ 03:47.

**Xưởng** — Máy móc dở dang, không khí dầu mỡ.
Bánh răng → cấp điện → đồng hồ 06:58 → bảng cần → ván sàn → khung đồng →
tủ đồ (số răng trên blueprint) → cần cẩu → cửa phòng chân dung.

**Phòng Chân Dung** — Trang trọng, yên tĩnh, khung mạ vàng.
Sắp chân dung theo năm → chân dung trung tâm (Elias, s. 1849) → khung trống
ký hiệu → mặt trăng → hộp thánh vật (câu phong ấn) → chronometer 08:15 →
cửa đài thiên văn.

**Đài Thiên Văn Phong Ấn** — Mái vòm, orrery đồng thau, kính thiên văn,
máy chiếu bản đồ sao.
Bản đồ sao → thứ tự mặt số → orrery (giờ + 1892) → kính thiên văn với ống
kính hội tụ → ghi chú cuối → hoàn thành chương.

### 5. Kết thúc chương

Giải `puz_ob_telescope` hiện ghi chú cuối của Vale (`clue_epilogue`): đài
thiên văn bị phong ấn vào đêm Sao Meridian thẳng hàng; cơ cấu ông bảo vệ vẫn
đang chạy — ở đâu đó. Màn hoàn thành: phát hiện đã tìm, đánh giá tùy chọn,
teaser "Chương 2 — Cơ Cấu Meridian" đang khóa.

### 6. Danh sách ghi chú journal (tùy chọn trừ ★)

| Key | Phòng | ★ | Nội dung ngắn |
| --- | ---- | - | ------------- |
| `clue_marks_order` | Sảnh | | Thứ tự khắc: trăng → sao → mặt trời. |
| `clue_clock_1024` | Sảnh | ★ | Đồng hồ quả lắc dừng lúc 10:24. |
| `clue_vale_note_1` | Sảnh | ★ | "Lưu trữ giữ lại điều ngôi nhà lãng quên." |
| `clue_vale_note_2` | Két ST | | Hồ sơ học nghề của Vale, 1874. |
| `clue_astrolabe` | Sách ST | ★ | Ghi chú ký hiệu vòng tinh cầu. |
| `clue_seal_year` | Két ST | ★ | "Phong ấn năm sao Hậu xuyên qua: 1892." |
| `clue_book_dates` | Sách ST | | Năm trên gáy sách dùng để sắp xếp. |
| `clue_regulator_time` | Dùng item ST | ★ | Lò xo chạy: dừng lúc 03:47. |
| `clue_workshop_clock` | Xưởng | ★ | Đồng hồ treo tường dừng 06:58. |
| `clue_blueprint` | Tủ Xưởng | | Số răng cho mã tủ đồ. |
| `clue_vale_note_3` | Ván Xưởng | | Ghi chú của Vale về ống kính hội tụ. |
| `clue_portrait_dates` | Gallery | ★ | Năm trên biển tên sắp xếp huy chương. |
| `clue_elias_birth` | Gallery | ★ | Chân dung trung tâm: Elias Vale, s. 1849. |
| `clue_gallery_clock` | Gallery | ★ | Chronometer dừng lúc 08:15. |
| `clue_seal_phrase` | Hộp GA | ★ | Câu xác nhận phong ấn. |
| `clue_dial_order` | Đài QT | ★ | Thứ tự mặt số từ bản đồ sao. |
| `clue_orrery_solution` | Đài QT | | Giờ đã nhập: 03:47, 06:58, 08:15 + 1892. |
| `clue_epilogue` | Đài QT | ★ | Ghi chú cuối của Vale + hé lộ chương 2. |

★ = cần cho đường hoàn thành chương.

*Ngoài ra còn các manh mối chỉ-đọc nhỏ (`clue_doormat`, `clue_eh_secret`,
`clue_moon_phases`, `clue_gallery_letter`, `clue_vale_note_4`,
`clue_vale_letter`) — xem registry ở `design/README.md` và puzzle specs.*

### 7. Prologue (tóm tắt)

Màn đen → 3 thẻ văn bản ngắn: ngôi nhà, những chiếc đồng hồ dừng, "có người đã
sắp xếp tất cả cho bạn." Sau đó menu → New Game → `room_entrance`. Prologue
có bản địa hóa, bỏ qua được, không chặn thao tác.
