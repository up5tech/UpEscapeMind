#!/usr/bin/env python3
"""Validate r2 shipped art against PLAN.md §8.6 budgets and content references.

Usage: python3 tool/validate_art.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ART = ROOT / "assets" / "art"
CONTENT = ROOT / "assets" / "content"
MAX_LAYER_KB = 400
MAX_ROOM_KB = 1600


def main() -> int:
    errors: list[str] = []

    # Every asset path referenced by content must exist.
    for path in CONTENT.rglob("*.json"):
        data = json.loads(path.read_text())
        for key, value in _walk_strings(data):
            if key.endswith("Asset") and isinstance(value, str):
                if value == "dust":  # procedural particle token
                    continue
                if not (ROOT / value).is_file():
                    errors.append(f"{path.relative_to(ROOT)}: missing {value}")

    # Room layers: 9:16, within per-layer and per-room budgets.
    room_totals: dict[str, int] = {}
    for image in sorted(ART.rglob("*.webp")) + sorted(ART.rglob("*.png")):
        rel = image.relative_to(ROOT)
        # Legacy r1 placeholders are excluded; they ship only as fallback.
        if "_r2_" not in image.stem:
            continue
        with Image.open(image) as im:
            if im.mode not in {"RGB", "RGBA"}:
                errors.append(f"{rel}: unexpected color mode {im.mode}")
            if "/rooms/" in rel.as_posix() and im.width and im.height:
                if abs(im.width / im.height - 9 / 16) > 0.01:
                    errors.append(f"{rel}: not 9:16 ({im.width}x{im.height})")
                if im.size != (1080, 1920):
                    errors.append(f"{rel}: expected 1080x1920, got {im.size}")
        size_kb = image.stat().st_size // 1024
        if size_kb > MAX_LAYER_KB:
            errors.append(f"{rel}: {size_kb} KB exceeds {MAX_LAYER_KB} KB")
        if "/rooms/" in rel.as_posix():
            room = image.stem.split("_r2_")[0]
            room_totals[room] = room_totals.get(room, 0) + size_kb

    for room, total in room_totals.items():
        if total > MAX_ROOM_KB:
            errors.append(f"room {room}: {total} KB exceeds {MAX_ROOM_KB} KB")

    if errors:
        print("Art validation FAILED:")
        for error in errors:
            print(f"  - {error}")
        return 1
    print(f"Art validation OK ({len(room_totals)} rooms checked)")
    return 0


def _walk_strings(value, key: str = ""):
    if isinstance(value, dict):
        for child_key, child in value.items():
            yield from _walk_strings(child, child_key)
    elif isinstance(value, list):
        for child in value:
            yield from _walk_strings(child, key)
    else:
        yield key, value


if __name__ == "__main__":
    sys.exit(main())
