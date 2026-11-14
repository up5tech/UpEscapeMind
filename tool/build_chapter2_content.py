#!/usr/bin/env python3
"""Build the Chapter 2 content pack into assets/content/ and merge the
localization tables in assets/content/localization/strings_{vi,en}.json.

Chapter 2 "The Sunken Conservatory" reuses every existing puzzle family —
no new mechanics (Phase 12 task 4). The chapter entry room is gated by
`chapter.unlockConditions` (chapter_completed chapter_01) and evaluated by
`isRoomAccessible` in lib/domain/rules/room_access.dart, so saves that
finished Chapter 1 before this pack shipped can enter without migration.

Re-runnable (idempotent). Run AFTER tool/build_chapter1_content.py if both
are regenerated; this script merges into manifest.json instead of
overwriting it.

Usage: python3 tool/build_chapter2_content.py
"""
import json
import os

BASE = os.path.join(os.path.dirname(__file__), "..", "assets", "content")
SCHEMA = 1


def w(path, obj):
    full = os.path.join(BASE, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("wrote", path)


def pre(kind=None, target=None):
    return {"type": kind, "targetId": target}


def act(kind, target):
    return {"type": kind, "targetId": target}


def hint(idn):
    return [
        {"level": 1, "textKey": "hint.%s.l1" % idn},
        {"level": 2, "textKey": "hint.%s.l2" % idn},
        {"level": 3, "textKey": "hint.%s.l3" % idn},
    ]


# ---------------------------------------------------------------- chapters
CHAPTER = {
    "schemaVersion": SCHEMA,
    "type": "chapter",
    "id": "chapter_02",
    "titleKey": "chapter02Title",
    "descriptionKey": "chapter02Description",
    "order": 1,
    "roomIds": [
        "room_conservatory",
        "room_pump_room",
        "room_orangery",
    ],
    "unlockConditions": [pre("chapter_completed", "chapter_01")],
}

# ------------------------------------------------------------------- rooms
def hotspot(hid, x, y, bw, bh, label_key, kind, **kw):
    d = {
        "id": hid,
        "bounds": {
            "x": x, "y": y, "width": bw, "height": bh
        },
        "labelKey": label_key,
        "interactionType": kind,
    }
    for k in ("targetId", "descriptionKey", "inspectionAsset"):
        if k in kw:
            d[k] = kw[k]
    if "visibility" in kw:
        d["visibilityConditions"] = kw["visibility"]
    if "accepted" in kw:
        d["acceptedItemIds"] = kw["accepted"]
        d["consumeItemOnUse"] = kw.get("consume", False)
    if "actions" in kw:
        d["successActions"] = kw["actions"]
    return d


ROOM_CONSERVATORY = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_conservatory",
    "chapterId": "chapter_02",
    "titleKey": "roomConservatoryTitle",
    "descriptionKey": "roomConservatoryDescription",
    "backgroundAsset": "assets/art/rooms/room_conservatory.png",
    "hotspots": [
        hotspot("hot_cv_pump_door", 0.80, 0.22, 0.15, 0.58,
                "hotCvPumpDoor", "puzzle", targetId="puz_cv_door_lock"),
        hotspot("hot_cv_pump_exit", 0.83, 0.34, 0.09, 0.44,
                "hotCvPumpExit", "navigate", targetId="room_pump_room",
                visibility=[pre("puzzle_solved", "puz_cv_door_lock")]),
        hotspot("hot_cv_plant_tags", 0.05, 0.42, 0.26, 0.34,
                "hotCvPlantTags", "puzzle", targetId="puz_cv_bloom_order"),
        hotspot("hot_cv_sun_sigil", 0.34, 0.14, 0.22, 0.26,
                "hotCvSunSigil", "puzzle", targetId="puz_cv_sun_sigil"),
        hotspot("hot_cv_irrigation", 0.34, 0.52, 0.24, 0.34,
                "hotCvIrrigation", "puzzle", targetId="puz_cv_irrigation"),
        hotspot("hot_cv_clock", 0.60, 0.10, 0.13, 0.24,
                "hotCvClock", "discover_clue", targetId="clue_cv_sundial_time"),
        hotspot("hot_cv_calendar", 0.58, 0.38, 0.10, 0.10,
                "hotCvCalendar", "discover_clue",
                targetId="clue_cv_bloom_order"),
        hotspot("hot_cv_sigil_band", 0.08, 0.30, 0.16, 0.08,
                "hotCvSigilBand", "discover_clue",
                targetId="clue_cv_sigil_marks"),
        hotspot("hot_cv_vale_note", 0.50, 0.64, 0.11, 0.14,
                "hotCvValeNote", "discover_clue",
                targetId="clue_cv_vale_note"),
        hotspot("hot_cv_fountain", 0.42, 0.70, 0.20, 0.16,
                "hotCvFountain", "discover_clue",
                targetId="clue_cv_fountain"),
    ],
    "entryConditions": [],
}

ROOM_PUMP_ROOM = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_pump_room",
    "chapterId": "chapter_02",
    "titleKey": "roomPumpRoomTitle",
    "descriptionKey": "roomPumpRoomDescription",
    "backgroundAsset": "assets/art/rooms/room_pump_room.png",
    "hotspots": [
        hotspot("hot_pm_back", 0.02, 0.30, 0.06, 0.44,
                "hotPmBack", "navigate", targetId="room_conservatory"),
        hotspot("hot_pm_flywheel", 0.08, 0.16, 0.30, 0.40,
                "hotPmFlywheel", "puzzle", targetId="puz_pm_flywheel"),
        hotspot("hot_pm_gauge_board", 0.44, 0.14, 0.26, 0.30,
                "hotPmGaugeBoard", "puzzle", targetId="puz_pm_gauge_chart"),
        hotspot("hot_pm_manifold", 0.76, 0.18, 0.20, 0.30,
                "hotPmManifold", "puzzle", targetId="puz_pm_pressure"),
        hotspot("hot_pm_seed_tray", 0.44, 0.55, 0.30, 0.30,
                "hotPmSeedTray", "puzzle", targetId="puz_pm_seed_tray",
                visibility=[pre("puzzle_solved", "puz_pm_flywheel")]),
        hotspot("hot_pm_oil_stain", 0.60, 0.66, 0.14, 0.12,
                "hotPmOilStain", "discover_clue",
                targetId="clue_pm_oil_stain"),
        hotspot("hot_pm_pipes", 0.08, 0.62, 0.30, 0.24,
                "hotPmPipes", "inspect", descriptionKey="hotPmPipesDesc"),
        hotspot("hot_pm_orangery_exit", 0.86, 0.30, 0.12, 0.48,
                "hotPmOrangeryExit", "navigate",
                targetId="room_orangery",
                visibility=[pre("puzzle_solved", "puz_pm_pressure")]),
    ],
    "entryConditions": [],
}

ROOM_ORANGERY = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_orangery",
    "chapterId": "chapter_02",
    "titleKey": "roomOrangeryTitle",
    "descriptionKey": "roomOrangeryDescription",
    "backgroundAsset": "assets/art/rooms/room_orangery.png",
    "hotspots": [
        hotspot("hot_or_back", 0.02, 0.30, 0.06, 0.44,
                "hotOrBack", "navigate", targetId="room_pump_room"),
        hotspot("hot_or_sundial", 0.08, 0.16, 0.28, 0.36,
                "hotOrSundial", "puzzle", targetId="puz_or_sundial"),
        hotspot("hot_or_bud_case", 0.40, 0.14, 0.20, 0.26,
                "hotOrBudCase", "puzzle", targetId="puz_or_bud_case"),
        hotspot("hot_or_specimen", 0.64, 0.18, 0.18, 0.24,
                "hotOrSpecimen", "use_item", accepted=["item_steel_shim"],
                consume=False,
                actions=[act("discover_clue", "clue_or_specimen")],
                descriptionKey="hotOrSpecimenDesc"),
        hotspot("hot_or_letter", 0.40, 0.60, 0.12, 0.14,
                "hotOrLetter", "discover_clue",
                targetId="clue_or_vale_letter"),
        hotspot("hot_or_tree", 0.66, 0.48, 0.28, 0.40,
                "hotOrTree", "inspect", descriptionKey="hotOrTreeDesc"),
        hotspot("hot_or_fountain", 0.36, 0.60, 0.24, 0.22,
                "hotOrFountain", "inspect",
                descriptionKey="hotOrFountainDesc"),
    ],
    "entryConditions": [],
}

ROOMS = [ROOM_CONSERVATORY, ROOM_PUMP_ROOM, ROOM_ORANGERY]

# ----------------------------------------------------------------- puzzles


def puzzle(pid, room, hs, ptype, initial, solution, validation, prereqs,
           actions, reset="keep"):
    return {
        "schemaVersion": SCHEMA,
        "type": "puzzle",
        "id": pid,
        "roomId": room,
        "hotspotId": hs,
        "puzzleType": ptype,
        "titleKey": "puz.%s.title" % pid,
        "instructionsKey": "puz.%s.instr" % pid,
        "initialState": initial,
        "solutionConfig": solution,
        "validationConfig": validation,
        "prerequisites": prereqs,
        "successActions": actions,
        "hints": hint(pid),
        "resetPolicy": reset,
    }


SEED_REGIONS = [
    {"id": "pot_1", "x": 0.0417, "y": 0.32, "width": 0.1667, "height": 0.44},
    {"id": "pot_2", "x": 0.225, "y": 0.32, "width": 0.1667, "height": 0.44},
    {"id": "pot_3", "x": 0.4083, "y": 0.32, "width": 0.1667, "height": 0.44},
    {"id": "pot_4", "x": 0.5917, "y": 0.32, "width": 0.1667, "height": 0.44},
    {"id": "pot_5", "x": 0.775, "y": 0.32, "width": 0.1667, "height": 0.44},
]

CHART_REGIONS = [
    {"id": "bed", "x": 0.18, "y": 0.27, "width": 0.14, "height": 0.16},
    {"id": "fountain", "x": 0.48, "y": 0.47, "width": 0.14, "height": 0.16},
    {"id": "frame", "x": 0.73, "y": 0.69, "width": 0.14, "height": 0.16},
]

PUZZLES = [
    puzzle("puz_cv_door_lock", "room_conservatory", "hot_cv_pump_door",
           "keypad", {"digits": 4}, {"code": "0715"}, {},
           [pre("clue_discovered", "clue_cv_sundial_time")],
           [act("unlock_room", "room_pump_room")], reset="reset_on_exit"),
    puzzle("puz_cv_bloom_order", "room_conservatory", "hot_cv_plant_tags",
           "sequence",
           {"labelKeys": {
               "tag_spring": "seasonSpring", "tag_summer": "seasonSummer",
               "tag_autumn": "seasonAutumn", "tag_winter": "seasonWinter"}},
           {"order": ["tag_spring", "tag_summer", "tag_autumn",
                      "tag_winter"]},
           {}, [pre("clue_discovered", "clue_cv_bloom_order")],
           [act("collect_item", "item_glass_vial"),
            act("discover_clue", "clue_cv_vale_note")]),
    puzzle("puz_cv_sun_sigil", "room_conservatory", "hot_cv_sun_sigil",
           "symbol_matching",
           {"labelKeys": {
               "sun": "symSun", "star": "symStar", "moon": "symMoon",
               "gear": "symGear", "key": "symKey"}},
           {"symbols": ["sun", "star", "moon"],
            "choices": ["sun", "star", "moon", "gear", "key"]},
           {}, [pre("clue_discovered", "clue_cv_sigil_marks")],
           [act("collect_item", "item_copper_ring"),
            act("discover_clue", "clue_cv_irrigation_schedule")]),
    puzzle("puz_cv_irrigation", "room_conservatory", "hot_cv_irrigation",
           "mechanical_state", {},
           {"targetState": [True, False, True, False, True]}, {},
           [pre("clue_discovered", "clue_cv_irrigation_schedule")],
           [act("discover_clue", "clue_cv_greenhouse_secret")]),
    puzzle("puz_pm_flywheel", "room_pump_room", "hot_pm_flywheel",
           "rotation", {}, {"steps": [90, 270]}, {}, [],
           [act("discover_clue", "clue_pm_gauge_marks")]),
    puzzle("puz_pm_seed_tray", "room_pump_room", "hot_pm_seed_tray",
           "hidden_object",
           {"imageAsset": "assets/art/puzzles/seed_tray.png"},
           {"regions": SEED_REGIONS, "targetId": "pot_4"},
           {"hitPadding": 0.02},
           [pre("puzzle_solved", "puz_pm_flywheel")],
           [act("collect_item", "item_steel_shim"),
            act("discover_clue", "clue_pm_vale_note_2")]),
    puzzle("puz_pm_gauge_chart", "room_pump_room", "hot_pm_gauge_board",
           "observation",
           {"imageAsset": "assets/art/puzzles/conservatory_chart.png",
            "labelKeys": {
                "bed": "chartBed", "fountain": "chartFountain",
                "frame": "chartColdFrame"}},
           {"regions": CHART_REGIONS,
            "targets": ["bed", "fountain", "frame"]},
           {"hitPadding": 0.03},
           [pre("clue_discovered", "clue_pm_gauge_marks")],
           [act("discover_clue", "clue_pm_pressure_plate")]),
    puzzle("puz_pm_pressure", "room_pump_room", "hot_pm_manifold",
           "logic_deduction",
           {"fields": [
               {"id": "inlet", "kind": "digits", "maxLength": 4,
                "labelKey": "pmInlet"},
               {"id": "outlet", "kind": "digits", "maxLength": 4,
                "labelKey": "pmOutlet"},
               {"id": "relief", "kind": "digits", "maxLength": 4,
                "labelKey": "pmRelief"},
           ]},
           {"answer": {"inlet": "0415", "outlet": "0930",
                       "relief": "1268"}},
           {}, [pre("clue_discovered", "clue_pm_pressure_plate")],
           [act("unlock_room", "room_orangery")]),
    puzzle("puz_or_bud_case", "room_orangery", "hot_or_bud_case",
           "keypad", {"digits": 4}, {"code": "2863"}, {},
           [pre("clue_discovered", "clue_or_vale_letter")],
           [act("discover_clue", "clue_or_bud_secret")],
           reset="reset_on_exit"),
    puzzle("puz_or_sundial", "room_orangery", "hot_or_sundial",
           "rotation", {}, {"steps": [195]}, {},
           [pre("puzzle_solved", "puz_pm_pressure"),
            pre("item_collected", "item_prismatic_lens")],
           [act("consume_item", "item_prismatic_lens"),
            act("discover_clue", "clue_or_farewell"),
            act("complete_chapter", "chapter_02")]),
]

# ------------------------------------------------------------------- items
def item(iid, name_key, desc_key, icon, tags, combine=False):
    return {
        "schemaVersion": SCHEMA,
        "type": "item",
        "id": iid,
        "nameKey": name_key,
        "descriptionKey": desc_key,
        "iconAsset": "assets/art/items/%s.png" % iid,
        "tags": tags,
        "canBeCombined": combine,
    }


ITEMS = [
    item("item_copper_ring", "itemCopperRingName", "itemCopperRingDesc",
         "ring", ["part"], combine=True),
    item("item_glass_vial", "itemGlassVialName", "itemGlassVialDesc",
         "vial", ["part"], combine=True),
    item("item_prismatic_lens", "itemPrismaticLensName",
         "itemPrismaticLensDesc", "prism", ["part"]),
    item("item_steel_shim", "itemSteelShimName", "itemSteelShimDesc",
         "shim", ["tool"]),
]

COMBINATION = {
    "schemaVersion": SCHEMA,
    "type": "item_combination",
    "id": "comb_prismatic_lens",
    "inputItemIds": ["item_copper_ring", "item_glass_vial"],
    "resultItemId": "item_prismatic_lens",
    "consumeInputItems": True,
    "resultMessageKey": "combPrismaticLensResult",
}

# ------------------------------------------------------------------- clues
def clue(cid, room, title_key, body_key, optional):
    return {
        "schemaVersion": SCHEMA,
        "type": "clue",
        "id": cid,
        "titleKey": title_key,
        "bodyKey": body_key,
        "sourceRoomId": room,
        "optional": optional,
    }


CLUES = [
    clue("clue_cv_sundial_time", "room_conservatory",
         "clueCvSundialTimeTitle", "clueCvSundialTimeBody", False),
    clue("clue_cv_bloom_order", "room_conservatory",
         "clueCvBloomOrderTitle", "clueCvBloomOrderBody", False),
    clue("clue_cv_sigil_marks", "room_conservatory",
         "clueCvSigilMarksTitle", "clueCvSigilMarksBody", False),
    clue("clue_cv_irrigation_schedule", "room_conservatory",
         "clueCvIrrigationTitle", "clueCvIrrigationBody", False),
    clue("clue_cv_vale_note", "room_conservatory",
         "clueCvValeNoteTitle", "clueCvValeNoteBody", True),
    clue("clue_cv_fountain", "room_conservatory",
         "clueCvFountainTitle", "clueCvFountainBody", True),
    clue("clue_cv_greenhouse_secret", "room_conservatory",
         "clueCvGreenhouseTitle", "clueCvGreenhouseBody", True),
    clue("clue_pm_gauge_marks", "room_pump_room",
         "cluePmGaugeMarksTitle", "cluePmGaugeMarksBody", False),
    clue("clue_pm_pressure_plate", "room_pump_room",
         "cluePmPressureTitle", "cluePmPressureBody", False),
    clue("clue_pm_vale_note_2", "room_pump_room",
         "cluePmValeNoteTitle", "cluePmValeNoteBody", True),
    clue("clue_pm_oil_stain", "room_pump_room",
         "cluePmOilStainTitle", "cluePmOilStainBody", True),
    clue("clue_or_vale_letter", "room_orangery",
         "clueOrValeLetterTitle", "clueOrValeLetterBody", False),
    clue("clue_or_bud_secret", "room_orangery",
         "clueOrBudSecretTitle", "clueOrBudSecretBody", True),
    clue("clue_or_specimen", "room_orangery",
         "clueOrSpecimenTitle", "clueOrSpecimenBody", True),
    clue("clue_or_farewell", "room_orangery",
         "clueOrFarewellTitle", "clueOrFarewellBody", False),
]

# ------------------------------------------------------------------ strings
S = {
    "chapter02Title": ("The Sunken Conservatory",
                       "Nhà Kính Chìm"),
    "chapter02Description": (
        "Behind the sealed observatory, a glasshouse where Vale grew "
        "hours as flowers — and stopped mid-bloom.",
        "Sau đài thiên văn bị phong ấn là một nhà kính — nơi Vale "
        "trồng thời gian như hoa, và đã dừng lại giữa lúc nở."),
    "roomConservatoryTitle": ("Glasshouse Conservatory",
                              "Khu Vườn Kính"),
    "roomConservatoryDescription": (
        "Condensation on every pane. Plants stand frozen mid-growth, "
        "tags still tied to their stems.",
        "Hơi nước đọng trên từng ô kính. Cây cối đứng im giữa lúc lớn, "
        "thẻ tên vẫn buộc trên cành."),
    "roomPumpRoomTitle": ("Pump Room", "Phòng Máy Bơm"),
    "roomPumpRoomDescription": (
        "The heart of the conservatory: flywheels, gauges, and a "
        "manifold that hasn't moved in years.",
        "Trái tim của nhà kính: bánh đà, đồng hồ đo, và một hệ thống "
        "van đã bất động nhiều năm."),
    "roomOrangeryTitle": ("Orangery", "Phòng Cam"),
    "roomOrangeryDescription": (
        "Orange trees heavy with fruit that never ripened. At the "
        "center, a great sundial waits for its light.",
        "Cây cam nặng trĩu quả chưa từng chín. Giữa phòng, một mặt "
        "trời đồng hồ lớn chờ ánh sáng của nó."),
    # hotspot labels
    "hotCvPumpDoor": ("Pump room door", "Cửa phòng máy bơm"),
    "hotCvPumpExit": ("Pump room door", "Cửa phòng máy bơm"),
    "hotCvPlantTags": ("Planting tags", "Thẻ cây trồng"),
    "hotCvSunSigil": ("Sun sigil dial", "Mặt trời ký hiệu"),
    "hotCvIrrigation": ("Irrigation valves", "Van tưới"),
    "hotCvClock": ("Stopped clock", "Đồng hồ đã dừng"),
    "hotCvCalendar": ("Planting calendar", "Lịch gieo trồng"),
    "hotCvSigilBand": ("Carved band", "Dải khắc"),
    "hotCvValeNote": ("Tucked note", "Mẩu giấy nhét kín"),
    "hotCvFountain": ("Dry fountain", "Đài phun nước khô"),
    "hotPmBack": ("Back to the conservatory", "Về khu vườn kính"),
    "hotPmFlywheel": ("Flywheel assembly", "Cụm bánh đà"),
    "hotPmGaugeBoard": ("Gauge board", "Bảng đồng hồ đo"),
    "hotPmManifold": ("Pressure manifold", "Hệ thống van áp suất"),
    "hotPmSeedTray": ("Seed tray", "Khay hạt giống"),
    "hotPmOilStain": ("Dark stain", "Vết bẩn sẫm màu"),
    "hotPmPipes": ("Overhead pipes", "Ống trên trần"),
    "hotPmPipesDesc": (
        "Condensate drips from a joint that was meant to be sealed. "
        "Someone fixed it with wire and hope.",
        "Nước ngưng nhỏ giọt từ một khớp nối lẽ ra phải được bịt kín. "
        "Có người đã sửa nó bằng dây kẽm và hy vọng."),
    "hotPmOrangeryExit": ("Orangery door", "Cửa phòng cam"),
    "hotOrBack": ("Back to the pump room", "Về phòng máy bơm"),
    "hotOrSundial": ("Great sundial", "Mặt trời đồng hồ lớn"),
    "hotOrBudCase": ("Bud specimen case", "Hộp mẫu nụ hoa"),
    "hotOrSpecimen": ("Hummingbird specimen", "Mẫu chim ruồi"),
    "hotOrSpecimenDesc": (
        "A hummingbird frozen mid-hover behind cloudy glass. The "
        "mounting pin is bent — it needs something flat and thin to "
        "pry the case open.",
        "Một con chim ruồi đông cứng giữa không trung sau lớp kính "
        "đục. Chốt gắn bị cong — cần một vật dẹt và mỏng để nạy hộp."),
    "hotOrLetter": ("Vale's letter", "Thư của Vale"),
    "hotOrTree": ("Orange trees", "Cây cam"),
    "hotOrTreeDesc": (
        "The fruit is perfect and unreachable — every orange hangs "
        "exactly at the height of a stopped clock hand.",
        "Quả cam hoàn hảo nhưng không với tới — mỗi quả treo đúng "
        "tầm của một kim đồng hồ đã dừng."),
    "hotOrFountain": ("Stone fountain", "Đài phun đá"),
    "hotOrFountainDesc": (
        "The basin is dry but the stone is warm, as if water ran here "
        "only moments ago.",
        "Lòng chậu khô nhưng đá vẫn ấm, như thể nước vừa mới chảy qua "
        "đây."),
    # labels / symbols
    "seasonSpring": ("Spring", "Mùa xuân"),
    "seasonSummer": ("Summer", "Mùa hè"),
    "seasonAutumn": ("Autumn", "Mùa thu"),
    "seasonWinter": ("Winter", "Mùa đông"),
    "chartBed": ("West bed", "Luống tây"),
    "chartFountain": ("Fountain", "Đài phun"),
    "chartColdFrame": ("Cold frame", "Khung lạnh"),
    "pmInlet": ("Inlet pressure", "Áp suất đầu vào"),
    "pmOutlet": ("Outlet pressure", "Áp suất đầu ra"),
    "pmRelief": ("Relief setting", "Cài đặt xả"),
    # items
    "itemCopperRingName": ("Copper Ring", "Vòng Đồng"),
    "itemCopperRingDesc": (
        "A heavy copper ring, warm to the touch even now.",
        "Một vòng đồng nặng, vẫn ấm dù đã nhiều năm."),
    "itemGlassVialName": ("Seed Vial", "Lọ Hạt Giống"),
    "itemGlassVialDesc": (
        "A stoppered vial of glowing seeds — one of each season, "
        "Vale's handwriting on the label.",
        "Lọ nút thủy tinh đựng hạt giống phát sáng — mỗi mùa một "
        "loại, chữ viết tay của Vale trên nhãn."),
    "itemPrismaticLensName": ("Prismatic Lens", "Lăng Kính"),
    "itemPrismaticLensDesc": (
        "Copper ring cradling the seed vial's glass — it bends light "
        "into a single, honest beam.",
        "Vòng đồng nâng lọ hạt giống bằng thủy tinh — bẻ ánh sáng "
        "thành một chùm duy nhất, trung thực."),
    "itemSteelShimName": ("Steel Shim", "Lá Thép Mỏng"),
    "itemSteelShimDesc": (
        "A paper-thin steel shim, wedged loose from the seed tray.",
        "Một lá thép mỏng như giấy, nạy ra từ khay hạt giống."),
    "combPrismaticLensResult": (
        "The copper ring closes around the vial with a soft chime: "
        "a prismatic lens.",
        "Vòng đồng khép quanh lọ thủy tinh với một tiếng vang nhẹ: "
        "lăng kính."),
}

# ------------------------------------------------------- puzzle + hints
PZ = {
    "puz_cv_door_lock": (
        ("The Sealed Pump Door", "Cánh cửa Phòng Máy Bơm bị Phong ấn"),
        ("Enter the 4-digit code on the pump-room door panel.",
         "Nhập mã 4 số trên bảng cửa phòng máy bơm."),
        [
            ("The conservatory kept perfect time once — its clocks "
             "only stopped when the house did.",
             "Nhà kính từng giữ thời gian hoàn hảo — đồng hồ chỉ dừng "
             "khi cả ngôi nhà dừng."),
            ("Find the stopped clock in the glasshouse. The time it "
             "froze at is the code.",
             "Tìm chiếc đồng hồ đã dừng trong nhà kính. Giờ nó đông "
             "cứng chính là mã."),
            ("The clock stopped at 07:15. Enter 0-7-1-5.",
             "Đồng hồ dừng lúc 07:15. Nhập 0-7-1-5."),
        ]),
    "puz_cv_bloom_order": (
        ("The Planting Tags", "Các Thẻ Cây Trồng"),
        ("Arrange the four season tags in the order Vale planted "
         "them.",
         "Sắp xếp bốn thẻ mùa theo thứ tự Vale gieo trồng."),
        [
            ("Each tag names a season. Vale never planted out of "
             "turn — the calendar on the wall remembers the order.",
             "Mỗi thẻ ghi một mùa. Vale không bao giờ gieo lệch mùa — "
             "tờ lịch trên tường ghi nhớ thứ tự."),
            ("Read the planting calendar first: it lists the seasons "
             "in the order the beds were sown.",
             "Đọc lịch gieo trồng trước: nó liệt kê các mùa theo thứ "
             "tự các luống được gieo."),
            ("Spring, summer, autumn, winter — tap the tags in that "
             "order.",
             "Xuân, hạ, thu, đông — chạm các thẻ theo thứ tự đó."),
        ]),
    "puz_cv_sun_sigil": (
        ("The Sun Sigils", "Các Ký Hiệu Mặt Trời"),
        ("Set the sigils in the order carved into the band.",
         "Đặt các ký hiệu theo thứ tự khắc trên dải trang trí."),
        [
            ("A carved band runs along the conservatory wall — its "
             "sequence is the gardener's signature.",
             "Một dải khắc chạy dọc tường nhà kính — trình tự của nó "
             "là chữ ký của người làm vườn."),
            ("The band shows three marks in order. Match them on the "
             "dial, ignoring the extra symbols.",
             "Dải khắc có ba dấu theo thứ tự. Khớp chúng trên mặt "
             "quay, bỏ qua ký hiệu thừa."),
            ("Sun, star, moon — set the dial to that sequence.",
             "Mặt trời, ngôi sao, mặt trăng — đặt mặt quay theo trình "
             "tự đó."),
        ]),
    "puz_cv_irrigation": (
        ("The Irrigation Valves", "Các Van Tưới"),
        ("Set each valve to the position shown on the schedule.",
         "Đặt mỗi van về vị trí ghi trong lịch trình."),
        [
            ("Five valves feed the glasshouse. The schedule Vale left "
             "behind says which were open and which were shut.",
             "Năm van cấp nước cho nhà kính. Lịch trình Vale để lại "
             "cho biết van nào mở, van nào đóng."),
            ("The irrigation schedule lists five positions: open, "
             "shut, open, shut, open.",
             "Lịch trình tưới liệt kê năm vị trí: mở, đóng, mở, đóng, "
             "mở."),
            ("Toggle the valves to open-shut-open-shut-open, left to "
             "right.",
             "Gạt các van theo trình tự mở-đóng-mở-đóng-mở, từ trái "
             "sang phải."),
        ]),
    "puz_pm_flywheel": (
        ("The Flywheel Assembly", "Cụm Bánh Đà"),
        ("Align both flywheel dials to their marked angles.",
         "Chỉnh cả hai mặt quay bánh đà về góc đánh dấu."),
        [
            ("The pump room's heart is frozen mid-turn. Two dials "
             "must agree before anything downstream moves.",
             "Trái tim phòng máy bơm đông cứng giữa vòng quay. Hai "
             "mặt quay phải khớp nhau thì hạ lưu mới chuyển động."),
            ("Each dial has a painted mark. Turn both until the marks "
             "meet the pointer.",
             "Mỗi mặt quay có một vạch sơn. Xoay cả hai đến khi vạch "
             "gặp kim chỉ."),
            ("Set the dials to 90° and 270° — quarter and three-quarter "
             "turns.",
             "Đặt các mặt quay ở 90° và 270° — một phần tư và ba "
             "phần tư vòng."),
        ]),
    "puz_pm_seed_tray": (
        ("The Seed Tray", "Khay Hạt Giống"),
        ("Find the one pot that doesn't belong.",
         "Tìm chậu không thuộc về khay."),
        [
            ("Five pots sit in the tray. Four hold seeds; one hides "
             "something Vale left behind.",
             "Năm chậu trong khay. Bốn chậu đựng hạt; một chậu giấu "
             "thứ Vale để lại."),
            ("Look for the pot with the clean rim — dust can't "
             "settle where something was recently moved.",
             "Tìm chậu có viền sạch — bụi không thể bám nơi vừa có "
             "vật bị dịch chuyển."),
            ("Tap the fourth pot from the left.",
             "Chạm vào chậu thứ tư từ trái sang."),
        ]),
    "puz_pm_gauge_chart": (
        ("The Gauge Board", "Bảng Đồng Hồ Đo"),
        ("Mark the three beds Vale flagged on the garden plan.",
         "Đánh dấu ba luống Vale đánh dấu trên bản vẽ vườn."),
        [
            ("The chart hanging by the gauges marks three growing "
             "beds. The gauges only feed the pump when all three are "
             "found.",
             "Bản đồ treo cạnh đồng hồ đo đánh dấu ba luống cây. Đồng "
             "hồ chỉ cấp cho bơm khi tìm đủ cả ba."),
            ("Find the west bed, the fountain, and the cold frame — "
             "each has a brass sigil.",
             "Tìm luống tây, đài phun và khung lạnh — mỗi nơi có một "
             "ký hiệu đồng."),
            ("Tap the sigils in any order: west bed, fountain, cold "
             "frame.",
             "Chạm các ký hiệu theo thứ tự bất kỳ: luống tây, đài "
             "phun, khung lạnh."),
        ]),
    "puz_pm_pressure": (
        ("The Pressure Manifold", "Hệ Thống Van Áp Suất"),
        ("Enter the three pressure settings from the manifold plate.",
         "Nhập ba trị số áp suất ghi trên tấm manifold."),
        [
            ("The brass plate on the manifold lists three settings: "
             "inlet, outlet, and relief.",
             "Tấm đồng trên manifold ghi ba trị số: đầu vào, đầu ra "
             "và xả."),
            ("Read the plate carefully — each value is four "
             "characters, leading zeros count.",
             "Đọc kỹ tấm biển — mỗi trị số gồm bốn ký tự, số 0 đầu "
             "có ý nghĩa."),
            ("Inlet 0415, outlet 0930, relief 1268.",
             "Đầu vào 0415, đầu ra 0930, xả 1268."),
        ]),
    "puz_or_bud_case": (
        ("The Bud Specimen Case", "Hộp Mẫu Nụ Hoa"),
        ("Enter the 4-digit combination that opens the bud case.",
         "Nhập mã 4 số mở hộp mẫu nụ hoa."),
        [
            ("Vale sealed this case himself. His letter mentions the "
             "combination — but not plainly.",
             "Vale tự tay niêm phong hộp này. Thư của ông có nhắc đến "
             "mã — nhưng không nói thẳng."),
            ("The letter's last line gives the digits: two, eight, "
             "six, three.",
             "Dòng cuối bức thư cho các chữ số: hai, tám, sáu, ba."),
            ("Enter 2-8-6-3.",
             "Nhập 2-8-6-3."),
        ]),
    "puz_or_sundial": (
        ("The Great Sundial", "Mặt Trời Đồng Hồ Lớn"),
        ("Turn the sundial's beam until it strikes the marked hour.",
         "Xoay chùm sáng mặt trời đồng hồ đến khi trúng giờ đánh dấu."),
        [
            ("The orangery's heart is a sundial that never saw noon. "
             "It needs the prismatic lens to catch the light.",
             "Trái tim phòng cam là một mặt trời đồng hồ chưa từng "
             "thấy buổi trưa. Nó cần lăng kính để hứng ánh sáng."),
            ("Set the dial so the beam falls on the painted mark — "
             "195 degrees from north.",
             "Đặt mặt quay sao cho chùm sáng rọi đúng vạch sơn — 195 "
             "độ từ hướng bắc."),
            ("Turn the dial to 195°.",
             "Xoay mặt quay đến 195°."),
        ]),
}

# ------------------------------------------------------------------ clues
CL = {
    "clueCvSundialTime": (
        "The Stopped Hour",
        "Giờ Đã Dừng",
        "The conservatory clock froze at 07:15 — the same instant "
        "every other clock in the house stopped.",
        "Đồng hồ nhà kính đông cứng lúc 07:15 — đúng khoảnh khắc mọi "
        "đồng hồ khác trong nhà đều dừng.",
    ),
    "clueCvBloomOrder": (
        "Vale's Planting Calendar",
        "Lịch Gieo Trồng của Vale",
        "The wall calendar lists the seasons in sowing order: "
        "spring, summer, autumn, winter. Each entry is crossed out "
        "in a different ink.",
        "Tờ lịch treo tường liệt kê các mùa theo thứ tự gieo: xuân, "
        "hạ, thu, đông. Mỗi mục bị gạch bằng một loại mực khác nhau.",
    ),
    "clueCvSigilMarks": (
        "The Gardener's Band",
        "Dải Khắc của Người Làm Vườn",
        "Carved into the wall band: sun, then star, then moon — "
        "Vale's order for waking the conservatory.",
        "Khắc trên dải tường: mặt trời, rồi ngôi sao, rồi mặt trăng "
        "— thứ tự của Vale để đánh thức nhà kính.",
    ),
    "clueCvIrrigation": (
        "The Irrigation Schedule",
        "Lịch Trình Tưới",
        "Five valves, five positions: open, shut, open, shut, open. "
        "The schedule is pinned beneath the sun sigils.",
        "Năm van, năm vị trí: mở, đóng, mở, đóng, mở. Lịch trình "
        "được ghim dưới các ký hiệu mặt trời.",
    ),
    "clueCvValeNote": (
        "Note in the Fountain Rim",
        "Mẩu Giấy ở Thành Đài Phun",
        "\"If the house wakes, burn this page first. — E.V.\"",
        "\"Nếu ngôi nhà thức giấc, hãy đốt trang này trước. — E.V.\"",
    ),
    "clueCvFountain": (
        "The Dry Fountain",
        "Đài Phun Khô",
        "The basin is cracked but the stone is warm — water reached "
        "here long after every clock stopped.",
        "Lòng chậu nứt nhưng đá vẫn ấm — nước từng chảy qua đây rất "
        "lâu sau khi mọi đồng hồ dừng.",
    ),
    "clueCvGreenhouse": (
        "What the Valves Were For",
        "Các Van Dùng Để Làm Gì",
        "The irrigation fed more than plants — the pipes run under "
        "the whole house, keeping the stopped clocks merely dormant "
        "rather than dead.",
        "Hệ thống tưới không chỉ nuôi cây — đường ống chạy khắp ngôi "
        "nhà, giữ cho những chiếc đồng hồ đã dừng chỉ ngủ đông chứ "
        "không chết hẳn.",
    ),
    "cluePmGaugeMarks": (
        "The Flywheel's Markings",
        "Các Vạch Trên Bánh Đà",
        "Under the flywheel's grease, three gauge numbers are "
        "scratched in order: the west bed, the fountain, the cold "
        "frame.",
        "Dưới lớp mỡ của bánh đà, ba số đồng hồ được khắc theo thứ "
        "tự: luống tây, đài phun, khung lạnh.",
    ),
    "cluePmPressure": (
        "The Manifold Plate",
        "Tấm Khắc Manifold",
        "The brass plate reads: inlet 0415, outlet 0930, relief "
        "1268. Vale adjusted these the night he left.",
        "Tấm đồng ghi: đầu vào 0415, đầu ra 0930, xả 1268. Vale đã "
        "chỉnh chúng vào đêm ông rời đi.",
    ),
    "cluePmValeNote": (
        "Note Under the Tray",
        "Mẩu Giấy Dưới Khay",
        "\"The shim you found is the only honest metal in this "
        "house. Keep it for the specimen case. — E.V.\"",
        "\"Lá thép mỏng bạn tìm thấy là kim loại trung thực duy nhất "
        "trong ngôi nhà này. Giữ nó cho hộp mẫu vật. — E.V.\"",
    ),
    "cluePmOilStain": (
        "The Dark Stain",
        "Vết Bẩn Sẫm Màu",
        "Something dark soaked into the floorboards years ago — "
        "thicker than oil, older than the pump.",
        "Thứ gì đó sẫm màu đã thấm vào ván sàn nhiều năm trước — "
        "đặc hơn dầu, cũ hơn cả máy bơm.",
    ),
    "clueOrValeLetter": (
        "Vale's Final Letter",
        "Bức Thư Cuối của Vale",
        "\"The bud case opens at 2-8-6-3 — the year the house was "
        "built, read backwards. Inside is proof I was never mad. "
        "— E.V.\"",
        "\"Hộp nụ hoa mở ở 2-8-6-3 — năm ngôi nhà được xây, đọc "
        "ngược lại. Bên trong là bằng chứng tôi chưa từng điên. "
        "— E.V.\"",
    ),
    "clueOrBudSecret": (
        "Inside the Bud Case",
        "Bên Trong Hộp Nụ Hoa",
        "A pressed flower and a brass key, stamped with the year "
        "1892 — the year the archive's seal was made.",
        "Một đóa hoa ép và một chìa khóa đồng, đóng dấu năm 1892 — "
        "năm phong ấn kho lưu trữ được tạo ra.",
    ),
    "clueOrSpecimen": (
        "The Specimen's Secret",
        "Bí Mật của Mẫu Vật",
        "Behind the hummingbird's glass, a tiny brass capsule holds "
        "a single grain of glowing seed — the same kind as in the "
        "vial.",
        "Sau lớp kính của chim ruồi, một viên nang đồng nhỏ đựng "
        "một hạt giống phát sáng — cùng loại với trong lọ.",
    ),
    "clueOrFarewell": (
        "Vale's Farewell",
        "Lời Từ Biệt của Vale",
        "The sundial drinks the light and the conservatory exhales "
        "twenty years of held breath. Somewhere below, a clock "
        "begins — very quietly — to tick.",
        "Mặt trời đồng hồ uống ánh sáng và nhà kính thở ra hai mươi "
        "năm nín thở. Đâu đó bên dưới, một chiếc đồng hồ bắt đầu "
        "— rất khẽ — tích tắc.",
    ),
}


def strings_for():
    out_en, out_vi = {}, {}
    for k, (e, v) in S.items():
        out_en[k], out_vi[k] = e, v
    for pid, (title, instr, hints) in PZ.items():
        out_en["puz.%s.title" % pid] = title[0]
        out_vi["puz.%s.title" % pid] = title[1]
        out_en["puz.%s.instr" % pid] = instr[0]
        out_vi["puz.%s.instr" % pid] = instr[1]
        for i, (e, v) in enumerate(hints, start=1):
            out_en["hint.%s.l%d" % (pid, i)] = e
            out_vi["hint.%s.l%d" % (pid, i)] = v
    for stem, (et, vt, eb, vb) in CL.items():
        out_en[stem + "Title"] = et
        out_vi[stem + "Title"] = vt
        out_en[stem + "Body"] = eb
        out_vi[stem + "Body"] = vb
    return out_en, out_vi


def merge_strings():
    en_add, vi_add = strings_for()
    for locale, add in (("en", en_add), ("vi", vi_add)):
        path = os.path.join(BASE, "localization",
                            "strings_%s.json" % locale)
        table = {}
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                table = json.load(f)
        table.update(add)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(table, f, ensure_ascii=False, indent=2,
                      sort_keys=True)
            f.write("\n")
        print("strings_%s merged %d keys" % (locale, len(add)))


def merge_manifest(new_files):
    path = os.path.join(BASE, "manifest.json")
    with open(path, encoding="utf-8") as f:
        manifest = json.load(f)
    files = manifest["files"]
    for rel in new_files:
        if rel not in files:
            files.append(rel)
    manifest["files"] = files
    w("manifest.json", manifest)


def main():
    w("chapters/chapter_02.json", CHAPTER)
    for r in ROOMS:
        w("rooms/%s.json" % r["id"], r)
    for p in PUZZLES:
        w("puzzles/%s.json" % p["id"], p)
    for it in ITEMS:
        w("items/%s.json" % it["id"], it)
    w("items/comb_prismatic_lens.json", COMBINATION)
    for c in CLUES:
        w("clues/%s.json" % c["id"], c)

    new_files = (
        ["chapters/chapter_02.json"]
        + ["rooms/%s.json" % r["id"] for r in ROOMS]
        + ["puzzles/%s.json" % p["id"] for p in PUZZLES]
        + ["items/%s.json" % it["id"] for it in ITEMS]
        + ["items/comb_prismatic_lens.json"]
        + ["clues/%s.json" % c["id"] for c in CLUES]
    )
    merge_manifest(new_files)
    merge_strings()
    print("done: %d content files" % len(new_files))


if __name__ == "__main__":
    main()
