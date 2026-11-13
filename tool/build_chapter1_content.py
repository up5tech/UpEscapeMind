#!/usr/bin/env python3
"""Build the Chapter 1 content pack into assets/content/ and merge the
localization tables in assets/content/localization/strings_{vi,en}.json.

Source of truth: design/02 (story), design/03 (rooms/hotspots),
design/04-puzzles (puzzle specs). Re-runnable (idempotent).

Usage: python3 tool/build_chapter1_content.py
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
    "id": "chapter_01",
    "titleKey": "chapter01Title",
    "descriptionKey": "chapter01Description",
    "order": 0,
    "roomIds": [
        "room_entrance",
        "room_study",
        "room_workshop",
        "room_gallery",
        "room_observatory",
    ],
    "unlockConditions": [],
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


ROOM_ENTRANCE = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_entrance",
    "chapterId": "chapter_01",
    "titleKey": "roomEntranceTitle",
    "descriptionKey": "roomEntranceDescription",
    "backgroundAsset": "assets/art/rooms/room_entrance.png",
    "hotspots": [
        hotspot("hot_eh_grandfather_clock", 0.06, 0.14, 0.20, 0.52,
                "hotEhClock", "discover_clue", targetId="clue_clock_1024"),
        hotspot("hot_eh_marks_band", 0.40, 0.22, 0.12, 0.07,
                "hotEhMarksBand", "discover_clue", targetId="clue_marks_order"),
        hotspot("hot_eh_study_door", 0.52, 0.18, 0.26, 0.62,
                "hotEhStudyDoor", "puzzle", targetId="puz_eh_door_lock"),
        hotspot("hot_eh_study_exit", 0.56, 0.30, 0.18, 0.44,
                "hotEhStudyExit", "navigate", targetId="room_study",
                visibility=[pre("puzzle_solved", "puz_eh_door_lock")]),
        hotspot("hot_eh_marks", 0.40, 0.30, 0.12, 0.30,
                "hotEhMarks", "puzzle", targetId="puz_eh_marks"),
        hotspot("hot_eh_doormat", 0.46, 0.72, 0.22, 0.14,
                "hotEhDoormat", "discover_clue", targetId="clue_doormat"),
        hotspot("hot_eh_sconce_panel", 0.14, 0.34, 0.18, 0.34,
                "hotEhSconce", "puzzle", targetId="puz_eh_sconce"),
        hotspot("hot_eh_painting", 0.30, 0.50, 0.10, 0.16,
                "hotEhPainting", "inspect", descriptionKey="hotEhPaintingDesc"),
        hotspot("hot_eh_window", 0.78, 0.10, 0.16, 0.50,
                "hotEhWindow", "inspect", descriptionKey="hotEhWindowDesc"),
    ],
    "entryConditions": [],
}

ROOM_STUDY = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_study",
    "chapterId": "chapter_01",
    "titleKey": "roomStudyTitle",
    "descriptionKey": "roomStudyDescription",
    "backgroundAsset": "assets/art/rooms/room_study.png",
    "hotspots": [
        hotspot("hot_st_back_entrance", 0.02, 0.30, 0.06, 0.44,
                "hotStBack", "navigate", targetId="room_entrance"),
        hotspot("hot_st_bookshelf", 0.58, 0.16, 0.32, 0.48,
                "hotStBookshelf", "puzzle", targetId="puz_st_books"),
        hotspot("hot_st_regulator", 0.10, 0.30, 0.16, 0.42,
                "hotStRegulator", "use_item", accepted=["item_clock_key"],
                consume=False,
                actions=[act("discover_clue", "clue_regulator_time")],
                descriptionKey="hotStRegulatorDesc"),
        hotspot("hot_st_certificate", 0.34, 0.18, 0.18, 0.22,
                "hotStCertificate", "discover_clue",
                targetId="clue_apprentice_year"),
        hotspot("hot_st_safe", 0.74, 0.52, 0.18, 0.30,
                "hotStSafe", "puzzle", targetId="puz_st_safe"),
        hotspot("hot_st_astrolabe", 0.36, 0.48, 0.16, 0.24,
                "hotStAstrolabe", "puzzle", targetId="puz_st_astrolabe"),
        hotspot("hot_st_globe", 0.52, 0.55, 0.20, 0.30,
                "hotStGlobe", "puzzle", targetId="puz_st_globe"),
        hotspot("hot_st_desk", 0.20, 0.62, 0.30, 0.26,
                "hotStDesk", "discover_clue", targetId="clue_vale_letter"),
        hotspot("hot_st_workshop_exit", 0.86, 0.30, 0.12, 0.50,
                "hotStWorkshopExit", "navigate", targetId="room_workshop",
                visibility=[pre("puzzle_solved", "puz_st_globe")]),
    ],
    "entryConditions": [],
}

ROOM_WORKSHOP = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_workshop",
    "chapterId": "chapter_01",
    "titleKey": "roomWorkshopTitle",
    "descriptionKey": "roomWorkshopDescription",
    "backgroundAsset": "assets/art/rooms/room_workshop.png",
    "hotspots": [
        hotspot("hot_wk_back_study", 0.02, 0.28, 0.05, 0.40,
                "hotWkBack", "navigate", targetId="room_study"),
        hotspot("hot_wk_gear_wall", 0.08, 0.18, 0.30, 0.45,
                "hotWkGearWall", "puzzle", targetId="puz_wk_gears"),
        hotspot("hot_wk_wall_clock", 0.55, 0.15, 0.14, 0.24,
                "hotWkWallClock", "discover_clue",
                targetId="clue_workshop_clock",
                visibility=[pre("puzzle_solved", "puz_wk_gears")]),
        hotspot("hot_wk_blueprint", 0.55, 0.45, 0.22, 0.28,
                "hotWkBlueprint", "discover_clue", targetId="clue_blueprint"),
        hotspot("hot_wk_lever_board", 0.30, 0.55, 0.22, 0.30,
                "hotWkLevers", "puzzle", targetId="puz_wk_levers"),
        hotspot("hot_wk_parts_cabinet", 0.80, 0.45, 0.16, 0.35,
                "hotWkCabinet", "puzzle", targetId="puz_wk_code"),
        hotspot("hot_wk_floorboard", 0.42, 0.78, 0.16, 0.14,
                "hotWkFloorboard", "puzzle", targetId="puz_wk_floorboard",
                visibility=[pre("puzzle_solved", "puz_wk_levers")]),
        hotspot("hot_wk_crane", 0.08, 0.60, 0.24, 0.32,
                "hotWkCrane", "puzzle", targetId="puz_wk_crane"),
        hotspot("hot_wk_gallery_exit", 0.86, 0.28, 0.12, 0.52,
                "hotWkGalleryExit", "navigate", targetId="room_gallery",
                visibility=[pre("puzzle_solved", "puz_wk_crane")]),
    ],
    "entryConditions": [],
}

ROOM_GALLERY = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_gallery",
    "chapterId": "chapter_01",
    "titleKey": "roomGalleryTitle",
    "descriptionKey": "roomGalleryDescription",
    "backgroundAsset": "assets/art/rooms/room_gallery.png",
    "hotspots": [
        hotspot("hot_ga_back_workshop", 0.02, 0.32, 0.03, 0.36,
                "hotGaBack", "navigate", targetId="room_workshop"),
        hotspot("hot_ga_medallions", 0.10, 0.20, 0.34, 0.40,
                "hotGaMedallions", "puzzle", targetId="puz_ga_portraits"),
        hotspot("hot_ga_central_portrait", 0.50, 0.22, 0.16, 0.36,
                "hotGaPortrait", "discover_clue", targetId="clue_elias_birth",
                visibility=[pre("puzzle_solved", "puz_ga_portraits")]),
        hotspot("hot_ga_letter", 0.70, 0.60, 0.12, 0.16,
                "hotGaLetter", "discover_clue", targetId="clue_gallery_letter"),
        hotspot("hot_ga_empty_frames", 0.72, 0.18, 0.24, 0.38,
                "hotGaFrames", "puzzle", targetId="puz_ga_frames"),
        hotspot("hot_ga_moon_dial", 0.36, 0.55, 0.18, 0.30,
                "hotGaMoonDial", "puzzle", targetId="puz_ga_moon_dial",
                visibility=[pre("puzzle_solved", "puz_ga_frames")]),
        hotspot("hot_ga_reliquary", 0.86, 0.42, 0.12, 0.30,
                "hotGaReliquary", "puzzle", targetId="puz_ga_case_lock"),
        hotspot("hot_ga_chronometer", 0.58, 0.12, 0.12, 0.20,
                "hotGaChronometer", "discover_clue",
                targetId="clue_gallery_clock"),
        hotspot("hot_ga_observatory_exit", 0.06, 0.28, 0.12, 0.50,
                "hotGaObsExit", "navigate", targetId="room_observatory",
                visibility=[pre("puzzle_solved", "puz_ga_case_lock")]),
    ],
    "entryConditions": [],
}

ROOM_OBSERVATORY = {
    "schemaVersion": SCHEMA,
    "type": "room",
    "id": "room_observatory",
    "chapterId": "chapter_01",
    "titleKey": "roomObservatoryTitle",
    "descriptionKey": "roomObservatoryDescription",
    "backgroundAsset": "assets/art/rooms/room_observatory.png",
    "hotspots": [
        hotspot("hot_ob_back_gallery", 0.02, 0.34, 0.03, 0.34,
                "hotObBack", "navigate", targetId="room_gallery"),
        hotspot("hot_ob_star_chart", 0.30, 0.15, 0.40, 0.30,
                "hotObStarChart", "puzzle", targetId="puz_ob_starchart"),
        hotspot("hot_ob_orrery", 0.12, 0.45, 0.30, 0.35,
                "hotObOrrery", "puzzle", targetId="puz_ob_orrery"),
        hotspot("hot_ob_telescope", 0.62, 0.35, 0.26, 0.45,
                "hotObTelescope", "puzzle", targetId="puz_ob_telescope"),
        hotspot("hot_ob_exit_door", 0.86, 0.30, 0.12, 0.48,
                "hotObExitDoor", "inspect",
                descriptionKey="hotObExitDoorDesc"),
    ],
    "entryConditions": [],
}

ROOMS = [ROOM_ENTRANCE, ROOM_STUDY, ROOM_WORKSHOP, ROOM_GALLERY,
         ROOM_OBSERVATORY]

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


FLOOR_REGIONS = [
    {"id": "board_1", "x": 0.0417, "y": 0.30, "width": 0.1667, "height": 0.45},
    {"id": "board_2", "x": 0.225, "y": 0.30, "width": 0.1667, "height": 0.45},
    {"id": "board_3", "x": 0.4083, "y": 0.30, "width": 0.1667, "height": 0.45},
    {"id": "board_4", "x": 0.5917, "y": 0.30, "width": 0.1667, "height": 0.45},
    {"id": "board_5", "x": 0.775, "y": 0.30, "width": 0.1667, "height": 0.45},
]

CHART_REGIONS = [
    {"id": "gallery", "x": 0.18, "y": 0.27, "width": 0.14, "height": 0.16},
    {"id": "study", "x": 0.48, "y": 0.47, "width": 0.14, "height": 0.16},
    {"id": "workshop", "x": 0.73, "y": 0.69, "width": 0.14, "height": 0.16},
]

PUZZLES = [
    puzzle("puz_eh_door_lock", "room_entrance", "hot_eh_study_door",
           "keypad", {"digits": 4}, {"code": "1024"}, {}, [],
           [act("unlock_room", "room_study")], reset="reset_on_exit"),
    puzzle("puz_eh_marks", "room_entrance", "hot_eh_marks",
           "symbol_matching",
           {"labelKeys": {
               "moon": "symMoon", "star": "symStar", "sun": "symSun",
               "key": "symKey"}},
           {"symbols": ["moon", "star", "sun"],
            "choices": ["moon", "star", "sun", "key"]},
           {}, [],
           [act("collect_item", "item_clock_key"),
            act("discover_clue", "clue_vale_note_1")]),
    puzzle("puz_eh_sconce", "room_entrance", "hot_eh_sconce_panel",
           "mechanical_state", {}, {"targetState": [True, False, True]},
           {}, [], [act("discover_clue", "clue_eh_secret")]),
    puzzle("puz_st_books", "room_study", "hot_st_bookshelf", "sequence",
           {"labelKeys": {
               "book_1861": "year1861", "book_1874": "year1874",
               "book_1892": "year1892"}},
           {"order": ["book_1861", "book_1874", "book_1892"]}, {}, [],
           [act("collect_item", "item_lens"),
            act("discover_clue", "clue_astrolabe"),
            act("discover_clue", "clue_book_dates")]),
    puzzle("puz_st_safe", "room_study", "hot_st_safe", "keypad",
           {"digits": 4}, {"code": "1874"}, {}, [],
           [act("discover_clue", "clue_vale_note_2"),
            act("discover_clue", "clue_seal_year")],
           reset="reset_on_exit"),
    puzzle("puz_st_astrolabe", "room_study", "hot_st_astrolabe",
           "symbol_matching",
           {"labelKeys": {
               "star": "symStar", "moon": "symMoon", "key": "symKey",
               "sun": "symSun", "gear": "symGear"}},
           {"symbols": ["star", "moon", "key", "sun"],
            "choices": ["star", "moon", "key", "sun", "gear"]},
           {}, [pre("clue_discovered", "clue_astrolabe")],
           [act("discover_clue", "clue_moon_phases")]),
    puzzle("puz_st_globe", "room_study", "hot_st_globe", "rotation",
           {}, {"steps": [210]}, {},
           [pre("puzzle_solved", "puz_st_astrolabe")],
           [act("unlock_room", "room_workshop")]),
    puzzle("puz_wk_gears", "room_workshop", "hot_wk_gear_wall", "rotation",
           {}, {"steps": [0, 120, 240]}, {}, [], []),
    puzzle("puz_wk_levers", "room_workshop", "hot_wk_lever_board",
           "mechanical_state", {},
           {"targetState": [True, False, True, False]}, {}, [], []),
    puzzle("puz_wk_code", "room_workshop", "hot_wk_parts_cabinet", "keypad",
           {"digits": 4}, {"code": "2436"}, {}, [],
           [act("collect_item", "item_crank")], reset="reset_on_exit"),
    puzzle("puz_wk_floorboard", "room_workshop", "hot_wk_floorboard",
           "hidden_object",
           {"imageAsset": "assets/art/puzzles/floorboards.png"},
           {"regions": FLOOR_REGIONS, "targetId": "board_2"},
           {"hitPadding": 0.02},
           [pre("puzzle_solved", "puz_wk_levers")],
           [act("collect_item", "item_brass_frame"),
            act("discover_clue", "clue_vale_note_3")]),
    puzzle("puz_wk_crane", "room_workshop", "hot_wk_crane", "rotation",
           {}, {"steps": [300]}, {},
           [pre("puzzle_solved", "puz_wk_gears"),
            pre("item_collected", "item_crank")],
           [act("unlock_room", "room_gallery")]),
    puzzle("puz_ga_portraits", "room_gallery", "hot_ga_medallions",
           "sequence",
           {"labelKeys": {
               "med_1802": "year1802", "med_1827": "year1827",
               "med_1851": "year1851", "med_1868": "year1868"}},
           {"order": ["med_1802", "med_1827", "med_1851", "med_1868"]},
           {}, [], [act("discover_clue", "clue_portrait_dates")]),
    puzzle("puz_ga_frames", "room_gallery", "hot_ga_empty_frames",
           "symbol_matching",
           {"labelKeys": {
               "key": "symKey", "star": "symStar", "moon": "symMoon",
               "gear": "symGear"}},
           {"symbols": ["key", "star", "moon"],
            "choices": ["key", "star", "moon", "gear"]},
           {}, [pre("clue_discovered", "clue_gallery_letter")], []),
    puzzle("puz_ga_moon_dial", "room_gallery", "hot_ga_moon_dial",
           "symbol_matching",
           {"labelKeys": {
               "moon_new": "moonNew", "moon_crescent": "moonCrescent",
               "moon_half": "moonHalf", "moon_full": "moonFull"}},
           {"symbols": ["moon_new", "moon_crescent", "moon_half",
                        "moon_full"]},
           {},
           [pre("puzzle_solved", "puz_ga_frames"),
            pre("clue_discovered", "clue_moon_phases")],
           [act("discover_clue", "clue_vale_note_4")]),
    puzzle("puz_ga_case_lock", "room_gallery", "hot_ga_reliquary", "keypad",
           {"digits": 4}, {"code": "1849"}, {},
           [pre("clue_discovered", "clue_elias_birth")],
           [act("discover_clue", "clue_seal_phrase"),
            act("unlock_room", "room_observatory")],
           reset="reset_on_exit"),
    puzzle("puz_ob_starchart", "room_observatory", "hot_ob_star_chart",
           "observation",
           {"imageAsset": "assets/art/puzzles/star_chart.png",
            "labelKeys": {
                "gallery": "sigilFrame", "study": "sigilKey",
                "workshop": "sigilGear"}},
           {"regions": CHART_REGIONS,
            "targets": ["gallery", "study", "workshop"]},
           {"hitPadding": 0.03}, [],
           [act("discover_clue", "clue_dial_order")]),
    puzzle("puz_ob_orrery", "room_observatory", "hot_ob_orrery",
           "logic_deduction",
           {"fields": [
               {"id": "t1", "kind": "digits", "maxLength": 4,
                "labelKey": "orreryRing1"},
               {"id": "t2", "kind": "digits", "maxLength": 4,
                "labelKey": "orreryRing2"},
               {"id": "t3", "kind": "digits", "maxLength": 4,
                "labelKey": "orreryRing3"},
               {"id": "year", "kind": "digits", "maxLength": 4,
                "labelKey": "orreryYear"},
           ]},
           {"answer": {"t1": "0815", "t2": "0347", "t3": "0658",
                       "year": "1892"}},
           {}, [pre("clue_discovered", "clue_dial_order")],
           [act("discover_clue", "clue_orrery_solution")]),
    puzzle("puz_ob_telescope", "room_observatory", "hot_ob_telescope",
           "rotation", {}, {"steps": [150]}, {},
           [pre("puzzle_solved", "puz_ob_orrery"),
            pre("item_collected", "item_focus_lens")],
           [act("consume_item", "item_focus_lens"),
            act("discover_clue", "clue_epilogue"),
            act("complete_chapter", "chapter_01")]),
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
    item("item_clock_key", "itemClockKeyName", "itemClockKeyDesc",
         "key", ["tool"]),
    item("item_lens", "itemLensName", "itemLensDesc", "lens",
         ["part"], combine=True),
    item("item_brass_frame", "itemFrameName", "itemFrameDesc", "frame",
         ["part"], combine=True),
    item("item_crank", "itemCrankName", "itemCrankDesc", "crank", ["tool"]),
    item("item_focus_lens", "itemFocusName", "itemFocusDesc", "focus",
         ["part"]),
]

COMBINATION = {
    "schemaVersion": SCHEMA,
    "type": "item_combination",
    "id": "comb_focus_lens",
    "inputItemIds": ["item_lens", "item_brass_frame"],
    "resultItemId": "item_focus_lens",
    "consumeInputItems": True,
    "resultMessageKey": "combFocusLensResult",
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
    clue("clue_clock_1024", "room_entrance", "clueClock1024Title",
         "clueClock1024Body", False),
    clue("clue_doormat", "room_entrance", "clueDoormatTitle",
         "clueDoormatBody", True),
    clue("clue_marks_order", "room_entrance", "clueMarksOrderTitle",
         "clueMarksOrderBody", False),
    clue("clue_vale_note_1", "room_entrance", "clueValeNote1Title",
         "clueValeNote1Body", False),
    clue("clue_eh_secret", "room_entrance", "clueEhSecretTitle",
         "clueEhSecretBody", True),
    clue("clue_apprentice_year", "room_study", "clueApprenticeTitle",
         "clueApprenticeBody", False),
    clue("clue_vale_note_2", "room_study", "clueValeNote2Title",
         "clueValeNote2Body", True),
    clue("clue_seal_year", "room_study", "clueSealYearTitle",
         "clueSealYearBody", False),
    clue("clue_astrolabe", "room_study", "clueAstrolabeTitle",
         "clueAstrolabeBody", False),
    clue("clue_book_dates", "room_study", "clueBookDatesTitle",
         "clueBookDatesBody", True),
    clue("clue_moon_phases", "room_study", "clueMoonPhasesTitle",
         "clueMoonPhasesBody", True),
    clue("clue_vale_letter", "room_study", "clueValeLetterTitle",
         "clueValeLetterBody", True),
    clue("clue_regulator_time", "room_study", "clueRegulatorTitle",
         "clueRegulatorBody", False),
    clue("clue_workshop_clock", "room_workshop", "clueWkClockTitle",
         "clueWkClockBody", False),
    clue("clue_blueprint", "room_workshop", "clueBlueprintTitle",
         "clueBlueprintBody", True),
    clue("clue_vale_note_3", "room_workshop", "clueValeNote3Title",
         "clueValeNote3Body", True),
    clue("clue_portrait_dates", "room_gallery", "cluePortraitDatesTitle",
         "cluePortraitDatesBody", False),
    clue("clue_elias_birth", "room_gallery", "clueEliasBirthTitle",
         "clueEliasBirthBody", False),
    clue("clue_gallery_letter", "room_gallery", "clueGaLetterTitle",
         "clueGaLetterBody", True),
    clue("clue_gallery_clock", "room_gallery", "clueGaChronoTitle",
         "clueGaChronoBody", False),
    clue("clue_seal_phrase", "room_gallery", "clueSealPhraseTitle",
         "clueSealPhraseBody", False),
    clue("clue_vale_note_4", "room_gallery", "clueValeNote4Title",
         "clueValeNote4Body", True),
    clue("clue_dial_order", "room_observatory", "clueDialOrderTitle",
         "clueDialOrderBody", False),
    clue("clue_orrery_solution", "room_observatory",
         "clueOrrerySolTitle", "clueOrrerySolBody", True),
    clue("clue_epilogue", "room_observatory", "clueEpilogueTitle",
         "clueEpilogueBody", False),
]

# ------------------------------------------------------------------ strings
S = {
    # keys -> (en, vi)
    "chapter01Title": ("The Clockmaker's Archive",
                       "Kho Lưu Trữ của Thợ Đồng Hồ"),
    "chapter01Description": (
        "Every clock in the Meridian House has stopped. Find Elias Vale's "
        "last night — and the way out.",
        "Mọi chiếc đồng hồ trong dinh thự Meridian đều đã dừng. Tìm đêm "
        "cuối của Elias Vale — và lối ra."),
    "roomEntranceTitle": ("Entrance Hall", "Sảnh Chính"),
    "roomEntranceDescription": (
        "Cold light through tall windows. One grandfather clock looms over "
        "the door.",
        "Ánh sáng lạnh qua những ô cửa cao. Một chiếc đồng hồ quả lắc lớn "
        "ché trước cửa."),
    "roomStudyTitle": ("Clockmaker's Study", "Phòng Nghiên Cứu"),
    "roomStudyDescription": (
        "A cluttered desk, a stopped regulator, certificates on the wall.",
        "Bàn làm việc bừa bộn, chiếc lò xo dừng, chứng chỉ trên tường."),
    "roomWorkshopTitle": ("Workshop", "Xưởng"),
    "roomWorkshopDescription": (
        "Half-assembled machines under a frozen gear train.",
        "Máy móc dở dang dưới dãy bánh răng đông cứng."),
    "roomGalleryTitle": ("Portrait Gallery", "Phòng Chân Dung"),
    "roomGalleryDescription": (
        "Portraits in gilt frames, and three that hang empty.",
        "Chân dung trong khung mạ vàng, và ba khung bỏ trống."),
    "roomObservatoryTitle": ("Sealed Observatory",
                             "Đài Thiên Văn Phong Ấn"),
    "roomObservatoryDescription": (
        "A dome of brass stars, an orrery, and one circled light.",
        "Mái vòm sao đồng thau, một mô hình thiên thể, và một vì sao "
        "được khoanh."),
    # hotspot labels
    "hotEhClock": ("Grandfather clock", "Đồng hồ quả lắc"),
    "hotEhMarksBand": ("Carved band", "Dải khắc"),
    "hotEhStudyDoor": ("Study door panel", "Bảng cửa nghiên cứu"),
    "hotEhStudyExit": ("Study door", "Cửa phòng nghiên cứu"),
    "hotEhMarks": ("Marks beside the door", "Ký hiệu bên cạnh cửa"),
    "hotEhDoormat": ("Doormat", "Tấm thảm chùi chân"),
    "hotEhSconce": ("Sconce panel", "Bảng đèn tường"),
    "hotEhPainting": ("Faded painting", "Bức tranh cũ"),
    "hotEhPaintingDesc": (
        "A townhouse under a night sky. The signature has worn away.",
        "Một dinh thự dưới bầu trời đêm. Chữ ký đã mòn mất."),
    "hotEhWindow": ("Tall window", "Cửa sổ cao"),
    "hotEhWindowDesc": (
        "Beyond the glass, the street is asleep. The latch is sealed shut.",
        "Sau lớp kính, con phố chìm trong giấc ngủ. Chốt đã bị niêm kín."),
    "hotStBack": ("Back to the hall", "Về sảnh"),
    "hotStBookshelf": ("Bookshelf", "Kệ sách"),
    "hotStRegulator": ("Regulator clock", "Đồng hồ lò xo"),
    "hotStRegulatorDesc": (
        "It hasn't run in years — a winding keyhole gleams under the dial.",
        "Nó đã không chạy bao năm — lỗ chìa vặn sáng lên dưới mặt số."),
    "hotStCertificate": ("Wall certificate", "Chứng chỉ trên tường"),
    "hotStSafe": ("Strongbox", "Két sắt"),
    "hotStAstrolabe": ("Astrolabe", "Tinh cầu"),
    "hotStGlobe": ("Meridian globe", "Quả địa cầu"),
    "hotStDesk": ("Desk", "Bàn làm việc"),
    "hotStWorkshopExit": ("Workshop door", "Cửa xưởng"),
    "hotWkBack": ("Back to the study", "Về phòng nghiên cứu"),
    "hotWkGearWall": ("Gear wall", "Bức tường bánh răng"),
    "hotWkWallClock": ("Wall clock", "Đồng hồ treo tường"),
    "hotWkBlueprint": ("Blueprint", "Bản thiết kế"),
    "hotWkLevers": ("Lever board", "Bảng cần gạt"),
    "hotWkCabinet": ("Parts cabinet", "Tủ đồ phụ tùng"),
    "hotWkFloorboard": ("Loose floorboard", "Ván sàn lỏng"),
    "hotWkCrane": ("Hoist crane", "Cần cẩu"),
    "hotWkGalleryExit": ("Gallery door", "Cửa phòng chân dung"),
    "hotGaBack": ("Back to the workshop", "Về xưởng"),
    "hotGaMedallions": ("Portrait medallions", "Huy chương chân dung"),
    "hotGaPortrait": ("Central portrait", "Chân dung trung tâm"),
    "hotGaLetter": ("Vale's letter", "Thư của Vale"),
    "hotGaFrames": ("Empty frames", "Khung trống"),
    "hotGaMoonDial": ("Moon dial", "Mặt trăng đồng hồ"),
    "hotGaReliquary": ("Reliquary", "Hộp thánh vật"),
    "hotGaChronometer": ("Chronometer", "Đồng hồ chronometer"),
    "hotGaObsExit": ("Observatory door", "Cửa đài thiên văn"),
    "hotObBack": ("Back to the gallery", "Về phòng chân dung"),
    "hotObStarChart": ("Star chart", "Bản đồ sao"),
    "hotObOrrery": ("Orrery", "Mô hình thiên thể"),
    "hotObTelescope": ("Telescope", "Kính thiên văn"),
    "hotObExitDoor": ("Sealed exit", "Cửa thoát phong ấn"),
    "hotObExitDoorDesc": (
        "The house's front door. Chains of brass run through its handles — "
        "Vale sealed it himself. Something still ticks behind the walls.",
        "Cửa chính của ngôi nhà. Những xiềng đồng luồn qua tay nắm — Vale "
        "tự tay niêm phong nó. Đâu đó sau bức tường vẫn có tiếng kim chạy."),
    # symbols
    "symMoon": ("Moon", "Trăng"),
    "symStar": ("Star", "Sao"),
    "symSun": ("Sun", "Mặt trời"),
    "symKey": ("Key", "Chìa khóa"),
    "symGear": ("Gear", "Bánh răng"),
    "moonNew": ("New moon", "Trăng mới"),
    "moonCrescent": ("Crescent", "Lưỡi liềm"),
    "moonHalf": ("Half moon", "Nửa trăng"),
    "moonFull": ("Full moon", "Trăng tròn"),
    "sigilFrame": ("Frame", "Khung tranh"),
    "sigilKey": ("Key", "Chìa khóa"),
    "sigilGear": ("Gear", "Bánh răng"),
    "year1802": ("1802", "1802"),
    "year1827": ("1827", "1827"),
    "year1851": ("1851", "1851"),
    "year1861": ("1861", "1861"),
    "year1868": ("1868", "1868"),
    "year1874": ("1874", "1874"),
    "year1892": ("1892", "1892"),
    "orreryRing1": ("Time ring 1", "Vành giờ 1"),
    "orreryRing2": ("Time ring 2", "Vành giờ 2"),
    "orreryRing3": ("Time ring 3", "Vành giờ 3"),
    "orreryYear": ("Seal year", "Năm phong ấn"),
    # items
    "itemClockKeyName": ("Winding Key", "Chìa Vặn"),
    "itemClockKeyDesc": (
        "A brass key sized for regulator movements.",
        "Chiếc chìa đồng dành cho bộ máy đồng hồ lò xo."),
    "itemLensName": ("Crystal Lens", "Kính Thủy Tinh"),
    "itemLensDesc": (
        "A plain lens, chipped at one edge. It wants a frame.",
        "Một thấu kính thường, sứt một cạnh. Nó cần một cái khung."),
    "itemFrameName": ("Brass Frame", "Khung Đồng"),
    "itemFrameDesc": (
        "A precision ring frame, machined for that lens.",
        "Vành khung cơ khí chính xác, được tiện ra cho đúng thấu kính đó."),
    "itemCrankName": ("Winch Handle", "Tay Quay"),
    "itemCrankDesc": (
        "A heavy crank for the hoist.",
        "Tay quay nặng cho cần cẩu."),
    "itemFocusName": ("Focusing Lens", "Ống Kính Hội Tụ"),
    "itemFocusDesc": (
        "Lens in frame — it makes far things close enough to read.",
        "Kính đặt trong khung — làm vật xa đủ gần để đọc."),
    "combFocusLensResult": (
        "The lens seats into the brass frame with a click: a focusing "
        "lens.",
        "Viên kính khớp vào khung đồng một tiếng tách: ống kính hội tụ."),
}

# ---------------------------------------------------------------- puzzle + hints
PZ = {
    "puz_eh_door_lock": (
        ("The Sealed Study Door", "Cánh cửa Phòng Nghiên Cứu bị Phong ấn"),
        ("Enter the 4-digit code that opens the study door.",
         "Nhập mã 4 số mở cửa phòng nghiên cứu."),
        [
            ("The house keeps time in its own way. One clock here never "
             "stopped — it just forgot how to start again.",
             "Ngôi nhà này giữ thời gian theo cách riêng. Có một chiếc đồng "
             "hồ ở đây chưa từng dừng — chỉ là quên cách chạy lại."),
            ("Inspect the large clock on the left wall. Its hands point to "
             "a time — that time is the code.",
             "Quan sát chiếc đồng hồ lớn bên trái. Kim chỉ một giờ — giờ đó "
             "chính là mã."),
            ("The grandfather clock stopped at 10:24. Enter 1-0-2-4 on the "
             "door panel.",
             "Đồng hồ quả lắc dừng lúc 10:24. Nhập 1-0-2-4 trên bảng cửa."),
        ]),
    "puz_eh_marks": (
        ("Marks Beside the Door", "Ký hiệu bên cạnh Cửa"),
        ("Reproduce the carved symbol sequence on the three dials.",
         "Tái hiện trình tự ký hiệu khắc lên ba mặt số."),
        [
            ("Someone carved a message beside the door. Whatever order they "
             "carved it in — that's the answer.",
             "Có người đã khắc một thông điệp bên cạnh cửa. Thứ tự họ khắc "
             "— đó chính là đáp án."),
            ("Inspect the marks closely: moon first, then star, then sun. "
             "Set the dials in that order, left to right.",
             "Nhìn kỹ các ký hiệu: trăng trước, rồi sao, rồi mặt trời. Đặt "
             "các mặt số theo thứ tự đó, từ trái sang phải."),
            ("Dial 1 = moon, dial 2 = star, dial 3 = sun. Then pull the "
             "brass lever.",
             "Mặt số 1 = trăng, mặt số 2 = sao, mặt số 3 = mặt trời. Sau đó "
             "kéo cần đồng thau."),
        ]),
    "puz_eh_sconce": (
        ("The Dark Sconces", "Những Ngọn Đèn Tường Tắt"),
        ("Flip the three sconce switches to match the pattern noted under "
         "the doormat.",
         "Gạt ba công tắc đèn tường theo mẫu ghi dưới thảm chùi chân."),
        [
            ("The doormat is heavier than it looks.",
             "Tấm thảm chùi chân nặng hơn vẻ ngoài của nó."),
            ("Lift the doormat and read the note. It describes which flames "
             "should burn.",
             "Nhấc thảm chùi chân lên và đọc mẩu giấy. Nó mô tả ngọn lửa "
             "nào nên cháy."),
            ("Note says: up, down, up. Set switch 1 up, switch 2 down, "
             "switch 3 up.",
             "Mẩu giấy viết: lên, xuống, lên. Công tắc 1 lên, công tắc 2 "
             "xuống, công tắc 3 lên."),
        ]),
    "puz_st_books": (
        ("The Stopped Hours", "Những Giờ Đã Dừng"),
        ("Return three fallen books to the shelf in the order Vale "
         "intended. The shelf label says: earliest first.",
         "Xếp lại ba cuốn sách rơi về kệ theo đúng thứ tự Vale định. Nhãn "
         "kệ ghi: từ sớm nhất."),
        [
            ("Vale was a man of dates. Every book on this shelf has one.",
             "Vale là người của những con số năm. Mỗi cuốn sách trên kệ đều "
             "có một năm."),
            ("Read the years on the spines — 1861, 1874, 1892 — and follow "
             "the label: earliest first.",
             "Đọc năm trên gáy sách — 1861, 1874, 1892 — và làm theo nhãn: "
             "từ sớm nhất."),
            ("Place the 1861 book left, the 1874 book middle, the 1892 "
             "book right.",
             "Đặt sách 1861 bên trái, sách 1874 giữa, sách 1892 bên phải."),
        ]),
    "puz_st_safe": (
        ("Vale's Strongbox", "Két sắt của Vale"),
        ("Open the strongbox with its 4-digit combination.",
         "Mở két sắt bằng mã 4 số."),
        [
            ("Guild records are proud of their years.",
             "Giấy tờ của phường hội luôn tự hào về năm tháng."),
            ("The framed certificate on the wall names a year — Vale's "
             "apprenticeship. That year opens the box.",
             "Tấm chứng chỉ đóng khung trên tường ghi một năm — năm Vale "
             "học nghề. Năm đó mở được két."),
            ("Apprenticed 1874. Enter 1-8-7-4.",
             "Học nghề năm 1874. Nhập 1-8-7-4."),
        ]),
    "puz_st_astrolabe": (
        ("The Astrolabe", "Tinh cầu"),
        ("Align the astrolabe's four rings so the pointer reads Vale's "
         "intended sequence, outermost first.",
         "Xoay bốn vòng tinh cầu để kim chỉ đọc đúng trình tự Vale định, "
         "vòng ngoài cùng trước."),
        [
            ("Vale described the rings without naming them. Every symbol "
             "has a job.",
             "Vale mô tả các vòng mà không gọi tên chúng. Mỗi ký hiệu đều "
             "có một vai trò."),
            ("Sailors steer by the star; the moon borrows the sun's light; "
             "the key turns the lock; the sun needs no spark. Match the "
             "descriptions, outermost ring first.",
             "Thủy thủ định hướng bằng sao; trăng mượn ánh mặt trời; chìa "
             "khóa vặn ổ khóa; mặt trời không cần tia lửa. Ghép mô tả, vòng "
             "ngoài cùng trước."),
            ("Outer to inner: star, moon, key, sun.",
             "Ngoài vào trong: sao, trăng, chìa khóa, mặt trời."),
        ]),
    "puz_st_globe": (
        ("The Meridian Globe", "Quả địa cầu Meridian"),
        ("Rotate the globe until its marked meridian aligns with the brass "
         "pointer.",
         "Xoay quả địa cầu đến khi kinh tuyến đánh dấu thẳng hàng kim đồng "
         "thau."),
        [
            ("The desk note says the world must face the flame.",
             "Mẩu giấy trên bàn viết rằng quả đất phải quay về phía ngọn "
             "lửa."),
            ("Find the red meridian line and the small brass pointer. Turn "
             "until they meet.",
             "Tìm đường kinh tuyến đỏ và kim đồng thau nhỏ. Xoay đến khi "
             "chúng gặp nhau."),
            ("Rotate the globe about 210 degrees — the red line should "
             "point at the pointer.",
             "Xoay quả địa cầu khoảng 210 độ — đường đỏ phải chỉ vào kim."),
        ]),
    "puz_wk_gears": (
        ("The Frozen Gear Train", "Dãy Bánh Răng Đông Cứng"),
        ("Rotate the three gear rings until each marked tooth sits at the "
         "top pointer.",
         "Xoay ba vành bánh răng đến khi mỗi dấu đã đánh nằm ở kim chỉ trên."),
        [
            ("Three rings, three markers, one pointer each.",
             "Ba vành, ba dấu, mỗi vành một kim chỉ."),
            ("Turn each ring until its brass mark reaches the small "
             "pointer at the top.",
             "Xoay mỗi vành đến khi dấu đồng thau chạm kim chỉ nhỏ ở trên."),
            ("Ring A: 0 degrees, ring B: 120 degrees, ring C: 240 degrees "
             "— all markers at top.",
             "Vành A: 0 độ, vành B: 120 độ, vành C: 240 độ — mọi dấu đều ở "
             "trên."),
        ]),
    "puz_wk_levers": (
        ("The Lever Board", "Bảng Cần Gạt"),
        ("Set the four levers to the pattern on Vale's blueprint.",
         "Đặt bốn cần gạt theo mẫu trong bản thiết kế của Vale."),
        [
            ("The blueprint on the wall has more than one diagram on it.",
             "Bản thiết kế trên tường có nhiều hơn một sơ đồ."),
            ("Check the lower-left corner of the blueprint — a small VENT "
             "SEQUENCE diagram shows four positions.",
             "Xem góc dưới trái bản thiết kế — sơ đồ VENT SEQUENCE nhỏ ghi "
             "bốn vị trí."),
            ("Up, down, up, down — levers 1 through 4.",
             "Lên, xuống, lên, xuống — cần 1 đến 4."),
        ]),
    "puz_wk_code": (
        ("The Parts Cabinet", "Tủ Đồ Phụ Tùng"),
        ("Enter the 4-digit cabinet code.",
         "Nhập mã 4 số của tủ đồ."),
        [
            ("The cabinet doesn't want a word. It wants numbers the gears "
             "already know.",
             "Tủ đồ không cần một từ. Nó cần những con số mà bánh răng đã "
             "biết."),
            ("Blueprint, upper-right: tooth counts, small gear first — 24 "
             "then 36.",
             "Bản thiết kế, góc trên phải: số răng, bánh nhỏ trước — 24 rồi "
             "36."),
            ("Enter 2-4-3-6.", "Nhập 2-4-3-6."),
        ]),
    "puz_wk_floorboard": (
        ("The Loose Floorboard", "Ván Sàn Lỏng"),
        ("Find the loose floorboard among its neighbors and lift it.",
         "Tìm ván sàn lỏng giữa các tấm bên cạnh và nhấc lên."),
        [
            ("One board in this floor wasn't laid by the same hands.",
             "Có một tấm ván trong sàn này không do cùng một đôi tay lát."),
            ("Look for the board that sits slightly higher, with a clean "
             "gap where dust can't settle.",
             "Tìm tấm ván hơi nhô lên, có khe sạch nơi bụi không lắng được."),
            ("The middle row, second board from the left — tap it firmly.",
             "Hàng giữa, tấm thứ hai từ trái — chạm mạnh vào."),
        ]),
    "puz_wk_crane": (
        ("The Hoist Crane", "Cần Cẩu"),
        ("With the winch handle fitted, swing the crane arm until the hook "
         "catches the X-marked crate.",
         "Với tay quay đã lắp, xoay cần cẩu đến khi móc trúng thùng đánh "
         "dấu X."),
        [
            ("The crane is hungry for a handle, and patient for an angle.",
             "Cần cẩu đói một tay quay, và kiên nhẫn chờ một góc."),
            ("The parts cabinet held a winch handle. Fit it, then follow "
             "the chalk arrow on the floor.",
             "Tủ phụ tùng có tay quay. Lắp vào, rồi theo vạch phấn trên "
             "sàn."),
            ("Rotate the arm to about 300 degrees so the hook reaches the "
             "X-marked crate.",
             "Xoay cần khoảng 300 độ để móc chạm thùng đánh dấu X."),
        ]),
    "puz_ga_portraits": (
        ("The Gallery Order", "Trật Tự Phòng Chân Dung"),
        ("Hang the four portrait medallions in chronological order.",
         "Treo bốn huy chương chân dung theo đúng thứ tự thời gian."),
        [
            ("Every brass plaque has a year. Time only runs one way in a "
             "gallery.",
             "Mỗi biển đồng đều có một năm. Thời gian trong phòng chân dung "
             "chỉ chạy một chiều."),
            ("Read the plaque years — 1802, 1827, 1851, 1868 — earliest at "
             "the left.",
             "Đọc năm trên biển — 1802, 1827, 1851, 1868 — sớm nhất bên "
             "trái."),
            ("Left to right: 1802, 1827, 1851, 1868.",
             "Từ trái sang phải: 1802, 1827, 1851, 1868."),
        ]),
    "puz_ga_frames": (
        ("Empty Frames", "Những Khung Trống"),
        ("Set the three empty frames' symbols as Vale's letter describes.",
         "Đặt ký hiệu cho ba khung trống theo đúng thư của Vale."),
        [
            ("The letter doesn't name symbols — it names jobs.",
             "Bức thư không gọi tên ký hiệu — nó gọi tên vai trò."),
            ("What turns is the key, what guides is the star, what waxes "
             "is the moon. Left, center, right.",
             "Vặn là chìa khóa, dẫn đường là sao, tròn dần là trăng. Trái, "
             "giữa, phải."),
            ("Left: key. Center: star. Right: moon.",
             "Trái: chìa khóa. Giữa: sao. Phải: trăng."),
        ]),
    "puz_ga_moon_dial": (
        ("The Moon Dial", "Mặt Trăng Đồng Hồ"),
        ("Set the moon dial so the four phases sit in Vale's order.",
         "Đặt mặt trăng đồng hồ để bốn pha nằm đúng thứ tự của Vale."),
        [
            ("The astrolabe note ended with the moon's order. The Study "
             "remembers it.",
             "Mẩu giấy tinh cầu kết thúc bằng thứ tự của mặt trăng. Phòng "
             "nghiên cứu còn nhớ."),
            ("Revisit the astrolabe clue: new, crescent, half, full — "
             "positions 1 to 4.",
             "Xem lại manh mối tinh cầu: mới, lưỡi liềm, nửa, tròn — vị trí "
             "1 đến 4."),
            ("Dial 1: new moon. 2: crescent. 3: half. 4: full.",
             "Mặt số 1: trăng mới. 2: lưỡi liềm. 3: nửa. 4: tròn."),
        ]),
    "puz_ga_case_lock": (
        ("The Reliquary", "Hộp Thánh Vật"),
        ("Open the reliquary with its 4-digit code.",
         "Mở hộp thánh vật bằng mã 4 số."),
        [
            ("Whose reliquary is this? Whose year would it keep?",
             "Đây là hộp thánh vật của ai? Nó sẽ giữ năm của ai?"),
            ("The central portrait was just revealed. Read the birth year "
             "on its inscription.",
             "Chân dung trung tâm vừa được mở. Đọc năm sinh trên dòng chữ "
             "của nó."),
            ("Elias Vale, born 1849. Enter 1-8-4-9.",
             "Elias Vale, sinh 1849. Nhập 1-8-4-9."),
        ]),
    "puz_ob_starchart": (
        ("The Star Chart", "Bản Đồ Sao"),
        ("Tap the three marked constellations in the order the dotted path "
         "draws them.",
         "Chạm ba chòm sao được đánh dấu theo thứ tự đường chấm kẻ ra."),
        [
            ("The chart isn't decoration — it has a path drawn through it.",
             "Bản đồ sao không phải đồ trang trí — có một đường kẻ xuyên "
             "qua nó."),
            ("Follow the dotted line. Each constellation carries a small "
             "sigil: frame, key, gear.",
             "Đi theo đường chấm. Mỗi chòm sao mang một huy hiệu nhỏ: khung, "
             "chìa khóa, bánh răng."),
            ("Tap in path order: frame (Gallery), then key (Study), then "
             "gear (Workshop).",
             "Chạm theo thứ tự đường kẻ: khung (Gallery), rồi chìa khóa "
             "(Study), rồi bánh răng (Workshop)."),
        ]),
    "puz_ob_orrery": (
        ("The Orrery", "Mô Hình Thiên Thể"),
        ("Set the three time rings and the year ring to the stopped times, "
         "in the star chart's order. Keep every leading zero!",
         "Đặt ba vành giờ và vành năm theo các giờ dừng, theo thứ tự bản đồ "
         "sao. Giữ nguyên mọi chữ số 0 đầu!"),
        [
            ("Three clocks in this house kept their stopping times. The "
             "chart tells you the order.",
             "Ba chiếc đồng hồ trong nhà giữ giờ dừng của chúng. Bản đồ cho "
             "bạn thứ tự."),
            ("Journal clues: regulator 03:47, wall clock 06:58, "
             "chronometer 08:15, seal year 1892. Chart order: gallery, "
             "study, workshop — then the year.",
             "Ghi chú journal: lò xo 03:47, đồng hồ treo 06:58, chronometer "
             "08:15, năm phong ấn 1892. Thứ tự bản đồ: gallery, study, "
             "workshop — rồi đến năm."),
            ("Enter 0-8-1-5, then 0-3-4-7, then 0-6-5-8, then year "
             "1-8-9-2. Keep the leading zeros!",
             "Nhập 0-8-1-5, rồi 0-3-4-7, rồi 0-6-5-8, rồi năm 1-8-9-2. Giữ "
             "số 0 đầu!"),
        ]),
    "puz_ob_telescope": (
        ("The Last Lens", "Ống Kính Cuối Cùng"),
        ("With the focusing lens mounted, turn the telescope until its "
         "crosshair rests on the circled star.",
         "Với ống kính hội tụ đã lắp, xoay kính thiên văn đến khi tâm ngắm "
         "trùng ngôi sao khoanh tròn."),
        [
            ("The lens was made for this. The star was waiting for it.",
             "Ống kính được làm ra vì việc này. Ngôi sao đã chờ nó."),
            ("Combine lens and frame in your satchel into the focusing "
             "lens, fit it here, then find the circled star.",
             "Kết hợp kính và khung trong túi đồ thành ống kính hội tụ, "
             "lắp vào đây, rồi tìm ngôi sao khoanh tròn."),
            ("Rotate to about 150 degrees until the crosshair sits on the "
             "ink-circled star.",
             "Xoay khoảng 150 độ để tâm ngắm trùng ngôi sao khoanh mực."),
        ]),
}

# ---------------------------------------------------------------- clue text
CL = {
    "clueClock1024": ("Stopped at 10:24", "Dừng lúc 10:24",
                      "The grandfather clock's hands rest at 10:24.",
                      "Hai kim đồng hồ quả lắc nghỉ tại 10:24."),
    "clueDoormat": ("Note under the doormat", "Ghi chú dưới thảm",
                    "Wax where the moon hides — up, down, up.",
                    "Đốt sáp nơi trăng ẩn — lên, xuống, lên."),
    "clueMarksOrder": ("The carved band", "Dải khắc",
                       "Carved left to right: moon, then star, then sun.",
                       "Khắc từ trái sang phải: trăng, rồi sao, rồi mặt "
                       "trời."),
    "clueValeNote1": ("Vale's note", "Ghi chú của Vale",
                      "The archive keeps what the house forgets. — E.V.",
                      "Lưu trữ giữ lại điều ngôi nhà lãng quên. — E.V."),
    "clueEhSecret": ("Vale's hidden note", "Ghi chú ẩn của Vale",
                     "Light returns to those who set the flames right.",
                     "Ánh sáng trở lại với ai đặt đúng ngọn lửa."),
    "clueApprentice": ("Apprenticeship record", "Hồ sơ học nghề",
                       "Elias Vale, apprenticed to the Meridian Guild — "
                       "1874.",
                       "Elias Vale, học nghề phường Meridian — 1874."),
    "clueValeNote2": ("Folded folder", "Hồ sơ gấp",
                      "Vale's apprenticeship record, 1874 — guild seals "
                      "still attached.",
                      "Hồ sơ học nghề của Vale, 1874 — còn nguyên dấu "
                      "phường hội."),
    "clueSealYear": ("The seal year", "Năm phong ấn",
                     "Sealed in the year of the Meridian transit: 1892.",
                     "Phong ấn năm sao Hậu xuyên qua: 1892."),
    "clueAstrolabe": ("Astrolabe note", "Ghi chú tinh cầu",
                      "First the guide sailors steer by, then the mirror "
                      "that borrows its light, then the key that turns "
                      "what sleeps, then the flame that needs no spark.",
                      "Đầu tiên là người dẫn đường cho thủy thủ, rồi tấm "
                      "gương mượn sáng, rồi chìa khóa vặn vật ngủ, rồi "
                      "ngọn lửa không cần tia lửa."),
    "clueBookDates": ("Spine years", "Năm trên gáy",
                      "Three spines: 1861, 1874, 1892. The shelf plate "
                      "reads: earliest first.",
                      "Ba gáy sách: 1861, 1874, 1892. Nhãn kệ ghi: từ sớm "
                      "nhất."),
    "clueMoonPhases": ("The moon's order", "Thứ tự mặt trăng",
                       "The moon writes its name in order: new, crescent, "
                       "half, full.",
                       "Mặt trăng viết tên theo thứ tự: mới, lưỡi liềm, "
                       "nửa, tròn."),
    "clueValeLetter": ("Desk note", "Giấy trên bàn",
                       "Turn the world until the line that remembers "
                       "faces the flame.",
                       "Xoay quả đất đến khi đường ghi nhớ hướng về ngọn "
                       "lửa."),
    "clueRegulator": ("Regulator time", "Giờ lò xo",
                      "Wound, the regulator ticks once and stops: 03:47.",
                      "Vặn cót, đồng hồ lò xo điểm một cái rồi dừng: "
                      "03:47."),
    "clueWkClock": ("Wall clock time", "Giờ đồng hồ treo",
                    "Once powered, the wall clock still shows where it "
                    "died: 06:58.",
                    "Có điện lại, đồng hồ treo vẫn chỉ đúng lúc nó tắt: "
                    "06:58."),
    "clueBlueprint": ("Blueprint", "Bản thiết kế",
                      "Lower-left VENT SEQUENCE: up, down, up, down. "
                      "Upper-right CABINET CODE — count teeth, small gear "
                      "first: 24, 36.",
                      "Góc dưới trái VENT SEQUENCE: lên, xuống, lên, "
                      "xuống. Góc trên phải CABINET CODE — đếm răng, bánh "
                      "nhỏ trước: 24, 36."),
    "clueValeNote3": ("Felt-wrapped note", "Ghi chú bọc nhung",
                      "The frame is for something that looks far — keep "
                      "it polished.",
                      "Khung dành cho thứ nhìn xa — giữ cho sáng."),
    "cluePortraitDates": ("Plaque years", "Năm trên biển tên",
                          "Medallion plaques: 1802, 1827, 1851, 1868. "
                          "Gallery rule: the dead keep their places — "
                          "earliest at the left.",
                          "Biển huy chương: 1802, 1827, 1851, 1868. Luật "
                          "phòng tranh: người đã khuất giữ vị trí của họ "
                          "— sớm nhất bên trái."),
    "clueEliasBirth": ("Central portrait", "Chân dung trung tâm",
                       "Elias Vale, born 1849.",
                       "Elias Vale, sinh 1849."),
    "clueGaLetter": ("Vale's letter", "Thư của Vale",
                     "What turns guards the left frame; what guides the "
                     "center; what waxes the right.",
                     "Vặn giữ khung trái; dẫn đường giữ giữa; tròn dần "
                     "giữ phải."),
    "clueGaChrono": ("Chronometer time", "Giờ chronometer",
                     "The chronometer stopped at 08:15.",
                     "Chronometer dừng lúc 08:15."),
    "clueSealPhrase": ("Seal phrase", "Câu phong ấn",
                       "SEALED BY E.V. — THE MERIDIAN KEEPS WHAT IT IS "
                       "GIVEN.",
                       "PHONG ẤN BỞI E.V. — CƠ CẤU GIỮ LẠI THỨ NÓ ĐƯỢC "
                       "GIAO PHÓ."),
    "clueValeNote4": ("Vale's note 4", "Ghi chú 4 của Vale",
                      "The last night: he set every clock to stop at a "
                      "piece of the truth, and trusted the house to keep "
                      "it until someone cared enough to look.",
                      "Đêm cuối: ông đặt mỗi đồng hồ dừng ở một mảnh sự "
                      "thật, và gửi ngôi nhà giữ hộ đến khi có người đủ "
                      "quan tâm mà nhìn."),
    "clueDialOrder": ("Dial order", "Thứ tự mặt số",
                      "Orrery order — Gallery time, then Study time, then "
                      "Workshop time; the year last.",
                      "Thứ tự orrery — giờ Gallery, rồi giờ Study, rồi "
                      "giờ Workshop; năm cuối cùng."),
    "clueOrrerySol": ("Orrery set", "Orrery đã đặt",
                      "Times entered: 08:15, 03:47, 06:58 — year 1892.",
                      "Giờ đã nhập: 08:15, 03:47, 06:58 — năm 1892."),
    "clueEpilogue": ("The final note", "Ghi chú cuối cùng",
                     "The observatory was sealed the night the Meridian "
                     "Star aligned. The mechanism I protected is still "
                     "running — somewhere. If you are reading this, the "
                     "house has chosen you next. — E.V.",
                     "Đài thiên văn bị phong ấn vào đêm Sao Meridian thẳng "
                     "hàng. Cơ cấu tôi bảo vệ vẫn đang chạy — ở đâu đó. "
                     "Nếu bạn đọc được dòng này, ngôi nhà đã chọn bạn "
                     "tiếp theo. — E.V."),
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


SAMPLE_FILES = [
    "chapters/chapter_sample.json",
    "rooms/room_sample.json",
    "rooms/room_sample_exit.json",
    "puzzles/puz_sample_lock.json",
    "items/item_sample_key.json",
    "items/item_sample_gear.json",
    "items/item_sample_hook.json",
    "items/comb_sample_hook.json",
    "clues/clue_sample_note.json",
    "clues/clue_sample_lock_opened.json",
]


def main():
    w("chapters/chapter_01.json", CHAPTER)
    for r in ROOMS:
        w("rooms/%s.json" % r["id"], r)
    for p in PUZZLES:
        w("puzzles/%s.json" % p["id"], p)
    for it in ITEMS:
        w("items/%s.json" % it["id"], it)
    w("items/comb_focus_lens.json", COMBINATION)
    for c in CLUES:
        w("clues/%s.json" % c["id"], c)

    files = (
        ["chapters/chapter_01.json"]
        + ["rooms/%s.json" % r["id"] for r in ROOMS]
        + ["puzzles/%s.json" % p["id"] for p in PUZZLES]
        + ["items/%s.json" % it["id"] for it in ITEMS]
        + ["items/comb_focus_lens.json"]
        + ["clues/%s.json" % c["id"] for c in CLUES]
    )
    w("manifest.json", {"schemaVersion": SCHEMA, "files": files})
    w("manifest.sample.json", {"schemaVersion": SCHEMA,
                               "files": SAMPLE_FILES})
    merge_strings()
    print("done: %d content files" % len(files))


if __name__ == "__main__":
    main()
