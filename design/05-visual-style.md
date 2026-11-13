# 05 — Visual Style Guide, Asset Conventions & Checklist

> Phase 0 deliverable. Art direction, naming conventions, asset inventory,
> and licensing rules for Chapter 1.

---

## English

### 1. Art direction

Modern atmospheric mystery — "dusty grandeur". The house feels old, cold,
and deliberately arranged. Lighting is the main storytelling tool: warm
brass/amber accents against cool navy-charcoal shadow.

Palette (hex values are starting points for the theme; final swatches get
approved with the first room mockup):

| Token | Hex (draft) | Use |
| ----- | ----------- | --- |
| `ink_navy` | `#141B2E` | Night shadows, UI dark surfaces |
| `charcoal` | `#23262E` | Panels, secondary surfaces |
| `aged_paper` | `#D8C9A3` | Notes, journal, aged documents |
| `brass` | `#B08D3E` | Hardware, frames, interactive accents |
| `amber` | `#E8A33D` | Highlights, lamplight, success accents |
| `clock_red` | `#A33B2E` | Meridian lines, warning/seal accents |
| `parchment_text` | `#F2EAD8` | Primary text on dark surfaces |

Typography: one readable serif for story text (draft: a licensed
old-style serif with full Vietnamese diacritic support — verify glyph
coverage before committing), one clean sans for UI labels. Minimum body
size honors system text scaling; never below ~14sp equivalent.

### 2. Visual rules for puzzle readability

- Important clues must be **visually discoverable** — no clue hidden only by
  darkness, tiny detail, or decorative noise.
- Symbols used in puzzles differ by **shape first, color second**.
- Hotspot affordance: subtle brass rim glow on hover/inspectable objects;
  no constant blinking.
- Solved state: mechanism visibly changes (door open, gears turned, light on)
  — the room should feel different, not just a checkmark.
- Wrong answer: calm feedback — slight shake/dim, never red flashing.

### 3. Asset naming conventions

All paths relative to `assets/`; referenced by content JSON, never hard-coded
in widgets.

```text
assets/art/rooms/<room_id>.webp            # background scene, e.g. room_entrance.webp
assets/art/rooms/<room_id>_fg_<n>.webp     # optional foreground layers
assets/art/objects/<hotspot_id>.webp       # inspection/zoom art per hotspot
assets/art/items/<item_id>.webp            # inventory icons (512px source)
assets/art/items/<item_id>_inspect.webp    # optional large inspection art
assets/art/ui/<component>.webp|svg         # shared UI chrome
assets/art/effects/<effect_id>.webp        # particles/overlays if any
assets/audio/music/<track_id>.ogg          # ambient loops, optional
assets/audio/sfx/<sfx_id>.ogg              # interaction sounds, optional
assets/content/chapters/chapter_01.json    # chapter definition
assets/content/rooms/<room_id>.json        # room + hotspots
assets/content/puzzles/<puzzle_id>.json    # puzzle definitions
assets/content/items/<item_id>.json        # item + recipe definitions
assets/content/clues/<clue_id>.json        # journal entries
assets/content/localization/vi.json        # Vietnamese (default)
assets/content/localization/en.json        # English
assets/fonts/<font_family>/                # licensed font files + OFL/license txt
```

Rules:

- Raster art: WebP preferred; PNG acceptable for UI with alpha.
- Source art kept at 2× display resolution; ship compressed.
- Every `backgroundAsset`/`inspectionAsset`/`iconAsset` path in content JSON
  must exist — enforced by the Phase 2 content validator.
- Audio is optional everywhere; missing files must not break gameplay.
- Fonts: bundle only licensed fonts; keep the license text next to files.

### 4. Asset checklist — Chapter 1

**Rooms (5 backgrounds + inspection art):**

| Asset | Notes |
| ----- | ----- |
| `room_entrance.webp` + fg | Grandfather clock, study door, marks band, sconces, doormat, painting, windows |
| `room_study.webp` + fg | Bookshelf, regulator, certificate, safe, astrolabe, globe, desk, exit door |
| `room_workshop.webp` + fg | Gear wall, wall clock, blueprint, lever board, parts cabinet, floorboards, crane, exit door |
| `room_gallery.webp` + fg | Medallions, central portrait, letter, empty frames, moon dial, reliquary, chronometer, exit door |
| `room_observatory.webp` + fg | Star chart, orrery, telescope, exit door |

**Puzzle UI art:** keypad panel, dial wheels (moon/star/sun/key/gear/frame…),
gear rings ×3, lever board ×4, moon phases ×4, constellation chart detail,
orrery rings, telescope mount — most can be widget-drawn; raster only where
hand-illustrated detail matters.

**Items (icons + optional inspect):** `item_clock_key`, `item_lens`,
`item_brass_frame`, `item_focus_lens`, `item_crank`.

**UI chrome:** inventory slot, hotspot hint, journal page, hint panel,
pause menu, chapter-complete seal.

**Audio (optional, can ship silent):** `music_house_ambient`,
`sfx_page_turn`, `sfx_unlock`, `sfx_correct`, `sfx_incorrect`,
`sfx_item_pickup`, `sfx_gear_turn`.

**Fonts:** story serif (VI+EN glyphs verified), UI sans (VI+EN).

### 5. Licensing & attribution

- All art/audio/fonts must be **owned, commissioned, or properly licensed**
  for commercial mobile distribution.
- Third-party assets require: license text stored in `assets/licenses/`,
  attribution entry in game Credits screen where the license demands it.
- Preferred sources: commissioned original art, CC0/public-domain with
  recorded source, or paid asset packs with app-distribution rights.
- **Never** use AI-generated or scraped art without verifying the license
  permits commercial use.
- Content JSON, story text, and puzzle designs are original IP of this
  project.
- Keep an `assets/licenses/README.md` ledger: asset → source → license →
  attribution requirement. Phase 2 validator should warn on missing entries
  for non-original assets.

---

## Tiếng Việt

### 1. Định hướng hình ảnh

Màu nhiệm hiện đại — "sự nguy nga phủ bụi". Ngôi nhà cũ, lạnh, được sắp
xếp có chủ đích. Ánh sáng là công cụ kể chuyện chính: điểm nhấn đồng thau
ấm áp trên nền navy-than lạnh.

Bảng màu (hex là điểm khởi đầu; swatch chính thức duyệt cùng mockup phòng
đầu tiên):

| Token | Hex (nháp) | Dùng cho |
| ----- | ---------- | -------- |
| `ink_navy` | `#141B2E` | Bóng đêm, nền UI tối |
| `charcoal` | `#23262E` | Panel, bề mặt phụ |
| `aged_paper` | `#D8C9A3` | Ghi chú, journal, giấy cũ |
| `brass` | `#B08D3E` | Kim loại, khung, nhấn tương tác |
| `amber` | `#E8A33D` | Highlight, ánh đèn, nhấn thành công |
| `clock_red` | `#A33B2E` | Kinh tuyến, cảnh báo/phong ấn |
| `parchment_text` | `#F2EAD8` | Chữ chính trên nền tối |

Typography: một serif đọc truyện (nháp: serif cổ licensed hỗ trợ đầy đủ
dấu tiếng Việt — kiểm tra glyph trước khi chốt), một sans sạch cho UI.
Tôn trọng text scaling hệ thống; không dưới ~14sp.

### 2. Quy tắc hình ảnh cho puzzle

- Manh mối quan trọng phải **dễ phát hiện bằng mắt** — không giấu chỉ bằng
  bóng tối, chi tiết li ti hay nhiễu trang trí.
- Ký hiệu puzzle khác nhau **hình dạng trước, màu sau**.
- Hotspot: viền đồng thau phát sáng nhẹ khi inspectable; không nhấp nháy.
- Trạng thái đã giải: cơ cấu đổi thật (cửa mở, bánh răng quay, đèn sáng) —
  phòng phải cảm thấy khác, không chỉ dấu check.
- Trả lời sai: phản hồi bình tĩnh — rung/mờ nhẹ, không nháy đỏ.

### 3. Quy ước đặt tên asset

Đường dẫn tương đối từ `assets/`; content JSON tham chiếu, widget không
hard-code.

```text
assets/art/rooms/<room_id>.webp            # nền scene
assets/art/rooms/<room_id>_fg_<n>.webp     # lớp foreground tùy chọn
assets/art/objects/<hotspot_id>.webp       # art inspect/zoom
assets/art/items/<item_id>.webp            # icon túi đồ (nguồn 512px)
assets/art/items/<item_id>_inspect.webp    # art inspect lớn (tùy chọn)
assets/art/ui/<component>.webp|svg         # UI chrome dùng chung
assets/art/effects/<effect_id>.webp        # particle/overlay nếu có
assets/audio/music/<track_id>.ogg          # ambient loop, tùy chọn
assets/audio/sfx/<sfx_id>.ogg              # âm thanh tương tác, tùy chọn
assets/content/chapters/chapter_01.json
assets/content/rooms/<room_id>.json
assets/content/puzzles/<puzzle_id>.json
assets/content/items/<item_id>.json
assets/content/clues/<clue_id>.json
assets/content/localization/vi.json        # tiếng Việt (mặc định)
assets/content/localization/en.json        # tiếng Anh
assets/fonts/<font_family>/                # font licensed + file license
```

Quy tắc:

- Raster: WebP ưu tiên; PNG chấp nhận cho UI có alpha.
- Art nguồn giữ ở 2× độ phân giải hiển thị; ship bản nén.
- Mọi đường `backgroundAsset`/`inspectionAsset`/`iconAsset` phải tồn tại —
  validator Phase 2 bắt buộc.
- Audio tùy chọn; thiếu file không được hỏng gameplay.
- Font: chỉ bundle font có license; giữ license text cạnh file.

### 4. Checklist asset — Chương 1

**Phòng (5 nền + art inspect):** `room_entrance`, `room_study`,
`room_workshop`, `room_gallery`, `room_observatory` — mỗi phòng kèm chi
tiết hotspot tương ứng (xem `03-room-progression.md`).

**Art UI puzzle:** bảng keypad, mặt số ký hiệu, vành bánh răng ×3, bảng cần
×4, pha trăng ×4, chi tiết bản đồ sao, vành orrery, mount kính thiên văn —
phần lớn vẽ bằng widget; raster chỉ nơi cần nét minh họa.

**Vật phẩm:** `item_clock_key`, `item_lens`, `item_brass_frame`,
`item_focus_lens`, `item_crank`.

**UI chrome:** ô túi đồ, gợi ý hotspot, trang journal, panel gợi ý, pause
menu, con dấu hoàn thành chương.

**Audio (tùy chọn):** `music_house_ambient`, `sfx_page_turn`, `sfx_unlock`,
`sfx_correct`, `sfx_incorrect`, `sfx_item_pickup`, `sfx_gear_turn`.

**Font:** serif truyện (đủ glyph VI+EN), sans UI (VI+EN).

### 5. License & ghi công

- Mọi art/audio/font phải **sở hữu, đặt làm riêng, hoặc licensed đúng** cho
  phát hành mobile thương mại.
- Asset bên thứ ba cần: license text trong `assets/licenses/`, mục ghi công
  ở màn Credits nếu license yêu cầu.
- Ưu tiên: art gốc đặt làm, CC0/public-domain có ghi nguồn, hoặc asset pack
  trả phí có quyền phân phối app.
- **Không** dùng art AI-generated hoặc cào mạng nếu chưa xác minh license
  cho phép dùng thương mại.
- Content JSON, văn truyện, thiết kế puzzle là IP gốc của dự án.
- Giữ sổ `assets/licenses/README.md`: asset → nguồn → license → yêu cầu ghi
  công. Validator Phase 2 nên cảnh báo khi asset không gốc thiếu entry.
