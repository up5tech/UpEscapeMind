# 01 — Game Design Document (GDD)

> Phase 0 deliverable. Scope: MVP = Prologue + Chapter 1 "The Clockmaker's Archive".
> Source of truth for design rules; PLAN.md remains the product/technical plan.

---

## English

### 1. Vision (condensed from PLAN §1)

A narrative 2D escape-room game. The player explores a mysterious house,
inspects objects, collects and combines items, discovers clues, solves
mechanisms, and unlocks new areas. Fully offline, single-player, no accounts.

Design pillars:

1. **Observation before guessing** — every answer is discoverable from clues.
2. **Fair solutions** — no hidden assumptions, no pixel-perfect tapping.
3. **Readable on mobile** — portrait-first, forgiving touch targets.
4. **Player-friendly failure** — wrong answers never corrupt state or progress.
5. **Progressive assistance** — 3-level hints, always available offline.
6. **Offline by design** — all content, art, audio, saves are local.

### 2. Core loop (per room)

Explore → Inspect → Discover → Collect → Reason → Interact → Solve → Unlock → Reflect (journal auto-updates).

### 3. Interaction conventions

- Hotspots use **normalized coordinates 0.0–1.0** relative to the scene image.
- Hit areas must be **larger than the visible object** (see §6 touch targets).
- Tapping a hotspot opens an **inspection overlay**: image/detail, description,
  and contextual actions (Inspect / Collect / Use Item / Open Puzzle / Read Note).
- Already-examined hotspots get a subtle visual marker (small dot/check) when useful.
- Inventory flow is always **select item → tap compatible hotspot**. Compatible
  hotspots show a highlight when an item is selected. Incompatible use is
  rejected with feedback and **never consumes the item**.
- Item combinations happen only through **explicit recipes** defined in content.
- Every durable action (collect, solve, hint reveal, unlock, chapter complete)
  **saves immediately**, in a transaction when it touches multiple records.

### 4. Puzzle rules (summary of PLAN §5)

- Puzzle completion is **idempotent**: reopening a solved puzzle shows the
  solved state and grants nothing twice.
- Input is normalized (trim, case); leading-zero behavior is defined per puzzle
  in its spec (`puz_*.md` files).
- Prerequisites are validated before completion is allowed.
- Wrong answers give calm feedback and never corrupt room state.
- Every puzzle has 3 authored hint levels: **nudge → clue → walkthrough**.
  Level 3 shows the answer only after an extra confirmation.
- Hints never block progression and are never gated by payment/energy/ads.
- No room may become unwinnable through normal player actions (see
  `03-room-progression.md` unlock graph).

### 5. Difficulty progression (Chapter 1)

| Stage | Puzzles | Traits |
| ----- | ------- | ------ |
| Tutorial | `puz_eh_door_lock`, `puz_eh_marks` | One obvious clue, one interaction |
| Easy | `puz_eh_sconce`, `puz_st_books`, `puz_wk_gears`, `puz_wk_crane` | One clue, one-step deduction |
| Medium | `puz_st_safe`, `puz_st_astrolabe`, `puz_st_globe`, `puz_wk_levers`, `puz_wk_code`, `puz_wk_floorboard`, `puz_ga_portraits`, `puz_ga_frames`, `puz_ga_moon_dial` | Two–three connected clues |
| Hard | `puz_ga_case_lock`, `puz_ob_starchart`, `puz_ob_orrery`, `puz_ob_telescope` | Cross-object / multi-step, reuses learned mechanics |

### 6. Accessibility & touch-target rules

- **Touch targets:** minimum interactive hotspot 48×48 dp; scene hotspots
  should be ≥ ~8% of scene width/height where the object allows. Invisible
  hit padding is encouraged over pixel-perfect art.
- **Contrast:** body text ≥ 4.5:1 against background; UI chrome ≥ 3:1.
- **Color is never the only signal:** success/failure/selection also use
  icon, shape, label, or animation.
- **Symbols:** important glyphs must differ by shape, not only color.
- **Text scaling:** honor system font scaling; puzzle panels scroll instead of
  shrinking text below 14sp equivalent.
- **Motion:** respect reduced-motion setting; no flashing; transitions ≤ 300 ms.
- **Screen readers:** semantic labels on hotspots, inventory items, and puzzle
  controls to a reasonable MVP standard.
- **Audio:** all audio optional; critical clues always duplicated visually.
  Missing audio files must fail silently, never crash.

### 7. Navigation rules

- Portrait-first; adapt to small/tall/tablet without clipping controls.
- Safe areas respected for notches/system bars.
- Android back & iOS gesture: consistent — leave inspection → leave puzzle →
  pause menu → exit room → chapter map.
- Pause/menu always reachable during room exploration.
- Locked content is unreachable via direct route navigation (enforced in router).

### 8. Localization rules

- Vietnamese (`vi`) is the **default** language; English (`en`) supported.
- All player-facing strings via localization keys — no hard-coded text.
- Puzzle answers that are locale-sensitive are avoided; codes are numeric or
  symbol-based. Any alphabetic answer defines normalization explicitly.
- Story notes ≤ ~40 words per screen on a phone.

### 9. Content & asset rules

- Content lives in versioned JSON under `assets/content/` with `schemaVersion`.
- No code execution from JSON; typed parsing; strict validation.
- Stable IDs everywhere; never use display text as identifier.
- Art/audio/fonts bundled offline.

### 10. Out of scope (MVP)

Backend, accounts, ads, IAP, multiplayer, online leaderboards, procedural
story puzzles, NLP answers, physics engine, user-generated rooms (PLAN §2.2).

---

## Tiếng Việt

### 1. Tầm nhìn (tóm tắt từ PLAN §1)

Game giải đố trốn phòng 2D có cốt truyện. Người chơi khám phá một ngôi nhà bí
ẩn, quan sát đồ vật, nhặt và kết hợp vật phẩm, tìm manh mối, giải cơ cấu và
mở khóa khu vực mới. Chơi offline hoàn toàn, một người chơi, không tài khoản.

Trụ cột thiết kế:

1. **Quan sát trước khi đoán** — mọi đáp án đều tìm được từ manh mối.
2. **Lời giải công bằng** — không giả định ẩn, không chạm chính xác từng pixel.
3. **Dễ đọc trên mobile** — ưu tiên dọc, vùng chạm rộng rãi.
4. **Thất bại thân thiện** — trả lời sai không bao giờ làm hỏng trạng thái.
5. **Hỗ trợ tăng dần** — 3 mức gợi ý, luôn có sẵn khi offline.
6. **Offline là mặc định** — mọi nội dung, hình, âm thanh, save đều lưu local.

### 2. Vòng lặp chính (mỗi phòng)

Khám phá → Quan sát → Phát hiện → Nhặt → Suy luận → Tương tác → Giải → Mở khóa → Ghi nhận (journal tự cập nhật).

### 3. Quy ước tương tác

- Hotspot dùng **tọa độ chuẩn hóa 0.0–1.0** theo ảnh scene.
- Vùng chạm phải **lớn hơn vật thể nhìn thấy** (xem §6).
- Chạm hotspot mở **panel quan sát**: mô tả + hành động (Quan sát / Nhặt /
  Dùng vật phẩm / Mở puzzle / Đọc ghi chú).
- Hotspot đã khám phá có đánh dấu nhỏ khi cần thiết.
- Inventory: luôn **chọn vật phẩm → chạm hotspot tương thích**. Hotspot tương
  thích được highlight khi đang chọn item. Dùng sai → báo lỗi, **không tiêu hao item**.
- Kết hợp vật phẩm chỉ qua **recipe khai báo sẵn** trong content.
- Mọi hành động bền (nhặt đồ, giải puzzle, mở gợi ý, mở khóa, hoàn thành
  chương) **lưu ngay**, dùng transaction khi thay đổi nhiều bản ghi.

### 4. Luật puzzle (tóm tắt PLAN §5)

- Hoàn thành puzzle **idempotent**: mở lại puzzle đã giải chỉ hiển thị trạng
  thái đã giải, không thưởng lặp.
- Chuẩn hóa input (trim, hoa/thường); behavior số 0 đầu khai báo rõ trong spec.
- Kiểm tra điều kiện tiên quyết trước khi cho hoàn thành.
- Trả lời sai chỉ báo nhẹ nhàng, không làm hỏng trạng thái phòng.
- Mỗi puzzle có 3 mức gợi ý viết sẵn: **gợi ý nhẹ → manh mối → hướng dẫn đầy đủ**.
  Mức 3 chỉ hiện đáp án sau xác nhận thêm.
- Gợi ý không bao giờ chặn tiến trình, không khóa bằng quảng cáo/thanh toán.
- Không phòng nào có thể bị kẹt vĩnh viễn qua thao tác bình thường
  (xem đồ thị mở khóa ở `03-room-progression.md`).

### 5. Tiến trình độ khó (Chương 1)

| Giai đoạn | Puzzle | Đặc điểm |
| --------- | ------ | -------- |
| Tutorial | `puz_eh_door_lock`, `puz_eh_marks` | Một manh mối rõ ràng, một thao tác |
| Dễ | `puz_eh_sconce`, `puz_st_books`, `puz_wk_gears`, `puz_wk_crane` | Một manh mối, suy luận một bước |
| Trung bình | `puz_st_safe`, `puz_st_astrolabe`, `puz_st_globe`, `puz_wk_levers`, `puz_wk_code`, `puz_wk_floorboard`, `puz_ga_portraits`, `puz_ga_frames`, `puz_ga_moon_dial` | Hai–ba manh mối liên kết |
| Khó | `puz_ga_case_lock`, `puz_ob_starchart`, `puz_ob_orrery`, `puz_ob_telescope` | Nhiều bước, dùng lại cơ chế đã học |

### 6. Quy tắc accessibility & vùng chạm

- **Vùng chạm:** hotspot tối thiểu 48×48 dp; hotspot trong scene nên ≥ ~8%
  chiều rộng/cao scene khi vật thể cho phép. Ưu tiên padding vùng chạm hơn
  chạm chính xác pixel.
- **Tương phản:** chữ ≥ 4.5:1 với nền; UI ≥ 3:1.
- **Màu không phải tín hiệu duy nhất:** thành công/thất bại/lựa chọn còn dùng
  icon, hình dáng, nhãn hoặc animation.
- **Ký hiệu:** glyph quan trọng phải khác nhau về hình dạng, không chỉ màu.
- **Co giãn chữ:** tôn trọng cài đặt font hệ thống; panel puzzle cuộn thay vì
  thu nhỏ chữ dưới ~14sp.
- **Chuyển động:** tôn trọng reduced-motion; không nhấp nháy; transition ≤ 300 ms.
- **Screen reader:** nhãn ngữ nghĩa cho hotspot, vật phẩm, điều khiển puzzle
  ở mức hợp lý cho MVP.
- **Âm thanh:** mọi âm thanh đều tùy chọn; manh mối quan trọng luôn có bản
  chữ/hình. Thiếu file âm thanh không được crash.

### 7. Quy tắc điều hướng

- Ưu tiên dọc; thích ứng màn nhỏ/cao/tablet không cắt control.
- Safe area cho notch/thanh hệ thống.
- Nút back Android & gesture iOS nhất quán: thoát inspection → thoát puzzle →
  pause → thoát phòng → map chương.
- Pause/menu luôn truy cập được khi khám phá phòng.
- Nội dung khóa không vào được qua direct route.

### 8. Quy tắc localization

- Tiếng Việt (`vi`) là **mặc định**; hỗ trợ tiếng Anh (`en`).
- Mọi chữ hiển thị qua localization key — cấm hard-code.
- Tránh đáp án phụ thuộc locale; mã là số hoặc ký hiệu. Nếu có đáp án chữ cái
  phải khai báo normalize rõ ràng.
- Ghi chú truyện ≤ ~40 từ mỗi màn hình trên điện thoại.

### 9. Quy tắc nội dung & asset

- Content là JSON có version trong `assets/content/` kèm `schemaVersion`.
- Không thực thi code từ JSON; parse typed; validate chặt.
- ID ổn định; không dùng text hiển thị làm định danh.
- Art/audio/font bundle offline.

### 10. Ngoài phạm vi (MVP)

Backend, tài khoản, quảng cáo, IAP, multiplayer, leaderboard online, puzzle
procedural, trả lời ngôn ngữ tự nhiên, physics engine, phòng do người chơi
tạo (PLAN §2.2).
