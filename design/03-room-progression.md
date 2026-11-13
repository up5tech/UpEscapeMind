# 03 — Room Progression & Hotspot Inventory

> Phase 0 deliverable. Defines the Chapter 1 progression graph, unlock
> conditions, and every interactive hotspot per room.
> Bounds are **provisional** — final values are set against approved room art
> in Phase 5. All bounds are normalized 0.0–1.0 (x, y, width, height).

---

## English

### 1. Progression graph

```text
room_entrance ──puz_eh_door_lock──▶ room_study ──puz_st_globe──▶ room_workshop
      │                                                        │
      │ puz_eh_marks → item_clock_key                          │ puz_wk_crane
      │ puz_eh_sconce (optional)                                │   → gallery door
      ▼                                                        ▼
                              room_gallery
              puz_ga_portraits → puz_ga_case_lock(1849)
              puz_ga_frames → puz_ga_moon_dial (optional chain)
                                      │
                                      ▼ reliquary → observatory door
                              room_observatory
              puz_ob_starchart → puz_ob_orrery → puz_ob_telescope
                                      │
                                      ▼ chapter complete
```

Rooms are freely revisitable once unlocked. Every required item/clue for the
chapter finale is obtainable in `room_entrance`, `room_study`, or
`room_workshop` — nothing required lives only in `room_gallery`/`room_observatory`.

### 2. Required-item chain (no soft locks)

```text
item_clock_key   ← puz_eh_marks (Entrance, no prerequisites)
        │ used on hot_st_regulator → clue_regulator_time (03:47) ★
item_lens        ← puz_st_books (Study, no prerequisites)
item_brass_frame ← puz_wk_floorboard (Workshop; needs puz_wk_levers)
        │ combine → item_focus_lens (consume both)
        ▼ used on hot_ob_telescope → puz_ob_telescope ★
```

Orrery inputs (all ★): `03:47` (Study regulator, needs `item_clock_key`),
`06:58` (Workshop wall clock, needs `puz_wk_gears` power), `08:15`
(Gallery chronometer, always readable), `1892` (Study strongbox `puz_st_safe`,
code from `clue_apprentice_year` on `hot_st_certificate`).

### 3. Global rules

- Hidden/locked hotspots never expose unavailable interactions; locked doors
  show a label + reason ("Locked — find how it opens").
- `use_item` hotspots highlight only when a compatible item is selected.
- Collect hotspots are single-use (idempotent).
- Every `puzzle` hotspot opens its puzzle UI; solved state persists.

### 4. Entrance Hall — `room_entrance`

| Hotspot ID | Label (EN / VI) | Bounds | Interaction | Conditions | Result |
| ---------- | --------------- | ------ | ----------- | ---------- | ------ |
| `hot_eh_grandfather_clock` | Grandfather clock / Đồng hồ quả lắc | 0.06,0.14,0.20,0.52 | inspect | always | `clue_clock_1024` ★ (stopped 10:24 → door code) |
| `hot_eh_study_door` | Study door / Cửa phòng nghiên cứu | 0.52,0.18,0.26,0.62 | puzzle `puz_eh_door_lock` | always | solved → navigate `room_study` |
| `hot_eh_marks` | Carved marks / Ký hiệu khắc | 0.40,0.30,0.12,0.30 | puzzle `puz_eh_marks` | always | `item_clock_key` + `clue_marks_order` + `clue_vale_note_1` ★ |
| `hot_eh_doormat` | Doormat / Tấm thảm chùi chân | 0.46,0.72,0.22,0.14 | inspect | always | optional note (lore; sconce hint flavor) |
| `hot_eh_sconce_panel` | Sconce panel / Bảng đèn tường | 0.14,0.34,0.18,0.34 | puzzle `puz_eh_sconce` | optional | `clue_eh_secret` optional + objective |
| `hot_eh_painting` | Faded painting / Bức tranh cũ | 0.30,0.20,0.16,0.24 | inspect | always | flavor text only |
| `hot_eh_window` | Tall window / Cửa sổ cao | 0.78,0.10,0.16,0.50 | inspect | always | flavor text only |

### 5. Clockmaker's Study — `room_study`

| Hotspot ID | Label (EN / VI) | Bounds | Interaction | Conditions | Result |
| ---------- | --------------- | ------ | ----------- | ---------- | ------ |
| `hot_st_bookshelf` | Bookshelf / Kệ sách | 0.58,0.16,0.32,0.48 | puzzle `puz_st_books` | always | `item_lens` + `clue_astrolabe` + `clue_book_dates` ★ |
| `hot_st_regulator` | Regulator clock / Đồng hồ lò xo | 0.10,0.30,0.16,0.42 | inspect / use_item | inspect always; `item_clock_key` usable | wound → `clue_regulator_time` ★ (03:47); unusable → flavor "hasn't run in years" |
| `hot_st_certificate` | Wall certificate / Chứng chỉ trên tường | 0.34,0.18,0.18,0.22 | inspect | always | `clue_apprentice_year` ★ (1874 → safe code) |
| `hot_st_safe` | Strongbox / Két sắt | 0.74,0.52,0.18,0.30 | puzzle `puz_st_safe` | always | `clue_vale_note_2` + `clue_seal_year` ★ (1892) |
| `hot_st_astrolabe` | Astrolabe / Tinh cầu | 0.36,0.48,0.16,0.24 | puzzle `puz_st_astrolabe` | always | `clue_moon_phases` ★ (moon order for Gallery) + enables `puz_st_globe` |
| `hot_st_globe` | Meridian globe / Quả địa cầu | 0.52,0.55,0.20,0.30 | puzzle `puz_st_globe` | requires `puz_st_astrolabe` solved | opens `hot_st_workshop_exit` |
| `hot_st_desk` | Desk / Bàn làm việc | 0.20,0.62,0.30,0.26 | inspect | always | flavor + optional `clue_vale_letter` |
| `hot_st_workshop_exit` | Workshop door / Cửa xưởng | 0.86,0.30,0.12,0.50 | navigate | requires `puz_st_globe` solved | → `room_workshop` |

### 6. Workshop — `room_workshop`

| Hotspot ID | Label (EN / VI) | Bounds | Interaction | Conditions | Result |
| ---------- | --------------- | ------ | ----------- | ---------- | ------ |
| `hot_wk_gear_wall` | Gear wall / Bức tường bánh răng | 0.08,0.18,0.30,0.45 | puzzle `puz_wk_gears` | always | powers room → enables `hot_wk_wall_clock` reading + `puz_wk_crane` |
| `hot_wk_wall_clock` | Wall clock / Đồng hồ treo tường | 0.55,0.15,0.14,0.24 | inspect | meaningful after `puz_wk_gears`; dead otherwise | `clue_workshop_clock` ★ (06:58) |
| `hot_wk_blueprint` | Blueprint / Bản thiết kế | 0.55,0.45,0.22,0.28 | inspect | always | `clue_blueprint` ★ (lever pattern + tooth counts) |
| `hot_wk_lever_board` | Lever board / Bảng cần gạt | 0.30,0.55,0.22,0.30 | puzzle `puz_wk_levers` | always | opens `hot_wk_floorboard` |
| `hot_wk_parts_cabinet` | Parts cabinet / Tủ đồ phụ tùng | 0.80,0.45,0.16,0.35 | puzzle `puz_wk_code` | always | `item_crank` (needed for crane) |
| `hot_wk_floorboard` | Loose floorboard / Ván sàn lỏng | 0.42,0.78,0.16,0.14 | puzzle `puz_wk_floorboard` | requires `puz_wk_levers` solved | `item_brass_frame` + `clue_vale_note_3` ★ |
| `hot_wk_crane` | Hoist crane / Cần cẩu | 0.08,0.60,0.24,0.32 | use_item `item_crank` → puzzle `puz_wk_crane` | requires `puz_wk_gears` + `item_crank` fitted | lifts crate → opens `hot_wk_gallery_exit` |
| `hot_wk_gallery_exit` | Gallery door / Cửa phòng chân dung | 0.86,0.28,0.12,0.52 | navigate | requires `puz_wk_crane` solved | → `room_gallery` |

### 7. Portrait Gallery — `room_gallery`

| Hotspot ID | Label (EN / VI) | Bounds | Interaction | Conditions | Result |
| ---------- | --------------- | ------ | ----------- | ---------- | ------ |
| `hot_ga_medallions` | Portrait medallions / Huy chương chân dung | 0.10,0.20,0.34,0.40 | puzzle `puz_ga_portraits` | always | opens central portrait → `clue_elias_birth` ★ (1849) + `clue_portrait_dates` |
| `hot_ga_central_portrait` | Central portrait / Chân dung trung tâm | 0.50,0.22,0.16,0.36 | inspect | requires `puz_ga_portraits` solved | `clue_elias_birth` ★ |
| `hot_ga_letter` | Vale's letter / Thư của Vale | 0.70,0.60,0.12,0.16 | inspect | always | `clue_gallery_letter` ★ (frame symbols) |
| `hot_ga_empty_frames` | Empty frames / Khung trống | 0.72,0.18,0.24,0.38 | puzzle `puz_ga_frames` | always | enables `hot_ga_moon_dial` |
| `hot_ga_moon_dial` | Moon dial / Mặt trăng đồng hồ | 0.36,0.55,0.18,0.30 | puzzle `puz_ga_moon_dial` | requires `puz_ga_frames` solved; pattern from `clue_moon_phases` (Study) | opens wall cabinet → `clue_vale_note_4` (optional) |
| `hot_ga_reliquary` | Reliquary / Hộp thánh vật | 0.86,0.42,0.12,0.30 | puzzle `puz_ga_case_lock` | always | code 1849 → `clue_seal_phrase` ★ + opens `hot_ga_observatory_exit` |
| `hot_ga_chronometer` | Chronometer / Đồng hồ chronometer | 0.58,0.12,0.12,0.20 | inspect | always | `clue_gallery_clock` ★ (08:15) |
| `hot_ga_observatory_exit` | Observatory door / Cửa đài thiên văn | 0.06,0.28,0.12,0.50 | navigate | requires `puz_ga_case_lock` solved | → `room_observatory` |

### 8. Sealed Observatory — `room_observatory`

| Hotspot ID | Label (EN / VI) | Bounds | Interaction | Conditions | Result |
| ---------- | --------------- | ------ | ----------- | ---------- | ------ |
| `hot_ob_star_chart` | Star chart / Bản đồ sao | 0.30,0.15,0.40,0.30 | puzzle `puz_ob_starchart` | always | `clue_dial_order` ★ (dial entry order) |
| `hot_ob_orrery` | Orrery / Mô hình thiên thể | 0.12,0.45,0.30,0.35 | puzzle `puz_ob_orrery` | always | times + 1892 → `clue_orrery_solution` ★ + arms telescope |
| `hot_ob_telescope` | Telescope / Kính thiên văn | 0.62,0.35,0.26,0.45 | use_item `item_focus_lens` → puzzle `puz_ob_telescope` | requires `puz_ob_orrery` solved + `item_focus_lens` | `clue_epilogue` ★ → chapter complete |
| `hot_ob_exit_door` | Sealed exit / Cửa thoát phong ấn | 0.86,0.30,0.12,0.48 | inspect | flavor; locked until chapter end | post-game flavor |

### 9. Soft-lock audit

| Risk | Mitigation |
| ---- | ---------- |
| Player can't find `item_clock_key` → missing 03:47 | `puz_eh_marks` has no prerequisites; hint L3 walkthrough names the cabinet location. |
| Player skips `puz_st_astrolabe` → no moon order for `puz_ga_moon_dial` | Moon dial chain is **optional** (rewards `clue_vale_note_4` only). Required path unaffected. |
| Player skips `puz_wk_levers` → no `item_brass_frame` → no `item_focus_lens` → can't finish telescope | `puz_wk_levers` pattern is in `clue_blueprint` (always inspectable); floorboard hotspot visibly "loose" after levers. Hint L3 names it. No required item is missable-permanently: all sources are repeatable inspections. |
| Orrery inputs scattered across 3 rooms | Journal auto-records every ★ clock clue; star chart gives order; hint L2 lists which clues are needed. |
| Item consumed by failed combine | Only defined recipe consumes; invalid combos rejected without consumption (Phase 6 rule). |

---

## Tiếng Việt

### 1. Đồ thị tiến trình

```text
room_entrance ──puz_eh_door_lock──▶ room_study ──puz_st_globe──▶ room_workshop
      │                                                        │
      │ puz_eh_marks → item_clock_key                          │ puz_wk_crane
      │ puz_eh_sconce (tùy chọn)                                │   → cửa gallery
      ▼                                                        ▼
                              room_gallery
              puz_ga_portraits → puz_ga_case_lock(1849)
              puz_ga_frames → puz_ga_moon_dial (chuỗi tùy chọn)
                                      │
                                      ▼ reliquary → cửa đài thiên văn
                              room_observatory
              puz_ob_starchart → puz_ob_orrery → puz_ob_telescope
                                      │
                                      ▼ hoàn thành chương
```

Phòng đã mở được quay lại tự do. Mọi vật phẩm/manh mối bắt buộc cho kết
thúc chương đều có ở `room_entrance`, `room_study` hoặc `room_workshop` —
không gì bắt buộc chỉ nằm ở `room_gallery`/`room_observatory`.

### 2. Chuỗi vật phẩm bắt buộc (không soft lock)

```text
item_clock_key   ← puz_eh_marks (Sảnh, không tiên quyết)
        │ dùng trên hot_st_regulator → clue_regulator_time (03:47) ★
item_lens        ← puz_st_books (Nghiên cứu, không tiên quyết)
item_brass_frame ← puz_wk_floorboard (Xưởng; cần puz_wk_levers)
        │ kết hợp → item_focus_lens (tiêu hao cả hai)
        ▼ dùng trên hot_ob_telescope → puz_ob_telescope ★
```

Đầu vào orrery (đều ★): `03:47` (lò xo ST, cần `item_clock_key`),
`06:58` (đồng hồ treo Xưởng, cần `puz_wk_gears` cấp điện), `08:15`
(chronometer Gallery, đọc tự do), `1892` (két ST `puz_st_safe`, mã từ
`clue_apprentice_year` trên `hot_st_certificate`).

### 3. Quy tắc chung

- Hotspot ẩn/khóa không bao giờ lộ tương tác chưa mở; cửa khóa hiển thị
  nhãn + lý do.
- `use_item` chỉ highlight khi chọn đúng vật phẩm tương thích.
- Hotspot nhặt đồ dùng một lần (idempotent).
- Mỗi `puzzle` mở UI puzzle; trạng thái đã giải được lưu.

### 4–8. Bảng hotspot

Bảng hotspot ở phần English là chuẩn. Tóm tắt VI theo phòng:

- **Sảnh Chính:** đồng hồ quả lắc (10:24→mã cửa), cửa nghiên cứu, ký hiệu
  khắc (`item_clock_key`), thảm chùi chân, bảng đèn tường (tùy chọn),
  tranh, cửa sổ.
- **Nghiên cứu:** kệ sách (kính), lò xo (dùng chìa vặn → 03:47), chứng chỉ
  (1874), két sắt (1892), tinh cầu (thứ tự trăng → `clue_moon_phases`),
  địa cầu (mở cửa xưởng), bàn, cửa xưởng.
- **Xưởng:** tường bánh răng (cấp điện), đồng hồ treo (06:58), blueprint
  (cần gạt + số răng), bảng cần, tủ đồ (mã 2436 → `item_crank`), ván sàn
  (khung đồng), cần cẩu (cần `item_crank` → mở cửa gallery), cửa gallery.
- **Gallery:** huy chương (thứ tự năm → chân dung 1849), thư Vale (ký hiệu
  khung), khung trống, mặt trăng (cần `clue_moon_phases` → `clue_vale_note_4`),
  reliquary (mã 1849 → `clue_seal_phrase` + cửa đài QT), chronometer (08:15),
  cửa đài QT.
- **Đài QT:** bản đồ sao (thứ tự mặt số), orrery (giờ + 1892), kính thiên
  văn (cần `item_focus_lens` → kết chương), cửa thoát.

### 9. Kiểm tra soft-lock

| Rủi ro | Giảm thiểu |
| ----- | ---------- |
| Không tìm thấy `item_clock_key` → thiếu 03:47 | `puz_eh_marks` không tiên quyết; hint L3 chỉ rõ vị trí tủ. |
| Bỏ qua `puz_st_astrolabe` → thiếu thứ tự trăng | Chuỗi mặt trăng là **tùy chọn**; đường bắt buộc không ảnh hưởng. |
| Bỏ qua `puz_wk_levers` → không có `item_focus_lens` | Pattern cần gạt nằm trong `clue_blueprint` (đọc tự do); hint L3 nêu rõ. Mọi nguồn vật phẩm bắt buộc đều kiểm tra lại được. |
| Đầu vào orrery rải 3 phòng | Journal tự ghi mọi manh mối giờ ★; bản đồ sao cho thứ tự; hint L2 liệt kê manh mối cần. |
| Combine sai làm mất item | Chỉ recipe định nghĩa mới tiêu hao; combo sai bị từ chối không trừ item (luật Phase 6). |
