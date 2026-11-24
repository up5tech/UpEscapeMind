#!/usr/bin/env python3
"""Convert master rasters to budgeted WebP runtime assets.

Usage: python3 tool/optimize_art.py INPUT_DIR OUTPUT_DIR [--quality 80]

Masters stay outside the app bundle. Output files keep their base names with
a .webp extension. Room layers are resized to 1080x1920 (9:16).
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

ROOM_SIZE = (1080, 1920)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--quality", type=int, default=80)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    for source in sorted(args.input_dir.iterdir()):
        if source.suffix.lower() not in {".png", ".jpg", ".jpeg"}:
            continue
        with Image.open(source) as im:
            image = im.convert("RGBA" if "A" in im.getbands() else "RGB")
            if "/rooms/" in str(args.output_dir) or "room_" in source.stem:
                image = image.resize(ROOM_SIZE, Image.LANCZOS)
            target = args.output_dir / f"{source.stem}.webp"
            image.save(target, "WEBP", quality=args.quality, method=6)
            print(f"{source.name} -> {target.name} ({target.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
