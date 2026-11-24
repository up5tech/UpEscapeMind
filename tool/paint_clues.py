#!/usr/bin/env python3
"""Paint legible, in-world clue details onto the r2 room art.

Run from the repository root:  python3 tool/paint_clues.py

The script always starts from the checkpoint copies in .trail/art_r2/clean/ so
re-running it is idempotent. It does not generate new AI art; it only adds the
small readable details the puzzle/clue text refers to (years, symbols, clock
times already painted, blueprint codes, etc.).
"""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parent.parent
CLEAN = ROOT / ".trail" / "art_r2" / "clean"
ROOMS = ROOT / "assets" / "art" / "rooms"
OBJECTS = ROOT / "assets" / "art" / "objects"
LEVER_PATCH = (
    ROOT
    / ".trail"
    / "art_r2"
    / "workshop"
    / "Repaint_ONLY_the_wooden_lever__2026-11-23T06-58-02.png"
)
FONTS = {
    "serif": ROOT / "assets" / "fonts" / "Lora" / "Lora.ttf",
    "sans": ROOT / "assets" / "fonts" / "Inter" / "Inter.ttf",
}

INK = (62, 43, 26, 255)
LIGHT_INK = (232, 214, 168, 255)
GOLD = (226, 194, 124, 255)
RED = (178, 52, 44, 220)
CHALK = (228, 226, 208, 210)


def font(size: int, kind: str = "serif") -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS[kind]), size)


def draw_text(
    im: Image.Image,
    xy: tuple[int, int],
    text: str,
    size: int,
    color: tuple[int, int, int, int] = INK,
    *,
    kind: str = "serif",
    angle: int = 0,
    anchor: str = "mm",
    shadow: bool = True,
) -> None:
    f = font(size, kind)
    bbox = f.getbbox(text)
    w = max(8, bbox[2] - bbox[0] + 10)
    h = max(8, bbox[3] - bbox[1] + 10)
    tile = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(tile)
    if shadow:
        d.text((4 - bbox[0], 4 - bbox[1]), text, font=f, fill=(16, 12, 8, 190))
    d.text((0 - bbox[0] + 2, 0 - bbox[1] + 2), text, font=f, fill=color)
    if angle:
        tile = tile.rotate(angle, expand=True, resample=Image.BICUBIC)
    x, y = xy
    if anchor[0] == "m":
        x -= tile.width // 2
    elif anchor[0] == "r":
        x -= tile.width
    if anchor[1] == "m":
        y -= tile.height // 2
    elif anchor[1] == "b":
        y -= tile.height
    im.alpha_composite(tile, (int(x), int(y)))


def label_patch(
    im: Image.Image, box: tuple[int, int, int, int], *, dark: bool = True
) -> None:
    overlay = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    fill = (26, 20, 14, 175) if dark else (226, 210, 174, 165)
    d.rounded_rectangle(box, radius=6, fill=fill, outline=GOLD if dark else INK, width=2)
    im.alpha_composite(overlay)


def arrow(
    d: ImageDraw.ImageDraw,
    start: tuple[int, int],
    end: tuple[int, int],
    color: tuple[int, int, int, int],
    width: int = 3,
    head: int = 9,
) -> None:
    d.line((start, end), fill=color, width=width)
    ang = math.atan2(end[1] - start[1], end[0] - start[0])
    for delta in (2.55, -2.55):
        a = ang + delta
        p = (
            end[0] + head * math.cos(a),
            end[1] + head * math.sin(a),
        )
        d.line((end, p), fill=color, width=width)


def symbol(kind: str, size: int, color: tuple[int, int, int, int]) -> Image.Image:
    tile = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(tile)
    m = size // 2
    if kind == "moon":
        mask = Image.new("L", (size, size), 0)
        md = ImageDraw.Draw(mask)
        md.ellipse((1, 1, size - 2, size - 2), fill=255)
        md.ellipse((size // 2, 1, size + size // 2 - 2, size - 2), fill=0)
        solid = Image.new("RGBA", (size, size), color)
        tile.paste(solid, (0, 0), mask)
    elif kind == "star":
        pts = []
        for i in range(10):
            r = m - 2 if i % 2 == 0 else (m - 2) * 0.44
            a = math.radians(i * 36 - 90)
            pts.append((m + r * math.cos(a), m + r * math.sin(a)))
        d.polygon(pts, fill=color)
    elif kind == "sun":
        d.ellipse((size * 0.28, size * 0.28, size * 0.72, size * 0.72), fill=color)
        for i in range(8):
            a = math.radians(i * 45)
            r0, r1 = size * 0.36, size * 0.48
            d.line(
                (m + r0 * math.cos(a), m + r0 * math.sin(a),
                 m + r1 * math.cos(a), m + r1 * math.sin(a)),
                fill=color,
                width=2,
            )
    elif kind == "key":
        d.ellipse((2, 2, size * 0.52, size * 0.52), outline=color, width=3)
        d.line((size * 0.36, size * 0.36, size - 4, size - 4), fill=color, width=4)
        d.line((size * 0.70, size * 0.70, size * 0.86, size * 0.60), fill=color, width=3)
        d.line((size * 0.82, size * 0.82, size * 0.94, size * 0.72), fill=color, width=3)
    elif kind == "gear":
        for i in range(8):
            a = math.radians(i * 45)
            r0, r1 = size * 0.34, size * 0.48
            d.line(
                (m + r0 * math.cos(a), m + r0 * math.sin(a),
                 m + r1 * math.cos(a), m + r1 * math.sin(a)),
                fill=color,
                width=4,
            )
        d.ellipse((size * 0.20, size * 0.20, size * 0.80, size * 0.80), outline=color, width=3)
        d.ellipse((size * 0.40, size * 0.40, size * 0.60, size * 0.60), fill=color)
    elif kind == "frame":
        d.rectangle((3, 5, size - 4, size - 5), outline=color, width=4)
        d.rectangle((size * 0.24, size * 0.27, size * 0.76, size * 0.73), outline=color, width=2)
    return tile


def paste_symbol(
    im: Image.Image,
    xy: tuple[int, int],
    kind: str,
    size: int,
    color: tuple[int, int, int, int],
) -> None:
    tile = symbol(kind, size, color)
    im.alpha_composite(tile, (xy[0] - size // 2, xy[1] - size // 2))


def feather_paste(base: Image.Image, patch: Image.Image, box: tuple[int, int, int, int]) -> None:
    x0, y0, x1, y1 = box
    patch = patch.resize((x1 - x0, y1 - y0), Image.LANCZOS).convert("RGBA")
    mask = Image.new("L", patch.size, 0)
    d = ImageDraw.Draw(mask)
    d.rectangle((0, 0, patch.width - 1, patch.height - 1), fill=255)
    feather = 10
    for i in range(feather):
        v = int(255 * i / feather)
        d.rectangle((i, i, patch.width - 1 - i, patch.height - 1 - i), outline=v, width=1)
    mask = mask.filter(ImageFilter.GaussianBlur(3))
    patch.putalpha(mask)
    base.alpha_composite(patch, (x0, y0))


def load(room: str) -> Image.Image:
    return Image.open(CLEAN / f"room_{room}_r2_background.webp").convert("RGBA")


def save_room(room: str, im: Image.Image) -> None:
    path = ROOMS / f"room_{room}_r2_background.webp"
    im.convert("RGB").save(path, "WEBP", quality=82, method=6)
    print(f"{path.name}: {path.stat().st_size // 1024} KB")


def paint_back_door(im: Image.Image, box: tuple[int, int, int, int]) -> None:
    """Paint a narrow arched back-door into a shadowed corner of a room.

    Used where the AI art did not render the doorway requested in the prompt,
    so a `navigate` hotspot has a real, visible target again. Everything is
    built on a separate layer and softened before compositing, so the result
    reads as painted wood in shadow rather than a flat vector sticker.
    """
    x0, y0, x1, y1 = box
    arch_r = (x1 - x0) // 2
    layer = Image.new("RGBA", im.size, (0, 0, 0, 0))

    def arch_mask(blur: float) -> Image.Image:
        mask = Image.new("L", im.size, 0)
        d = ImageDraw.Draw(mask)
        d.rectangle((x0, y0 + arch_r, x1, y1), fill=255)
        d.pieslice((x0, y0, x1, y0 + arch_r * 2), 180, 360, fill=255)
        return mask.filter(ImageFilter.GaussianBlur(blur))

    # Dark halo sinks the doorway into the existing shadow.
    halo = Image.new("RGBA", im.size, (6, 8, 14, 0))
    halo.putalpha(arch_mask(13).point(lambda v: min(175, int(v * 0.7))))
    im.alpha_composite(halo)

    # Interior: deep blue-black at the top, faint warm hall light near the floor.
    interior = Image.new("RGB", im.size, (0, 0, 0))
    px = interior.load()
    rng = random.Random(73)
    for y in range(y0, y1):
        t = (y - y0) / max(1, y1 - y0)
        for x in range(x0, x1):
            glow = max(0.0, 1 - abs(x - (x0 + x1) / 2) / ((x1 - x0) * 0.7))
            glow *= max(0.0, (t - 0.6) / 0.4) ** 1.4
            noise = rng.uniform(-7, 7)
            px[x, y] = (
                int(14 + 20 * t + 58 * glow + noise),
                int(19 + 18 * t + 38 * glow + noise),
                int(34 + 16 * t + 18 * glow + noise),
            )
    interior = interior.convert("RGBA")
    interior.putalpha(arch_mask(2.5))
    layer.alpha_composite(interior)

    d = ImageDraw.Draw(layer, "RGBA")
    # Worn wood frame: dark base, mid-tone body, thin worn highlight.
    d.arc((x0, y0, x1, y0 + arch_r * 2), 180, 360,
          fill=(58, 39, 23, 230), width=16)
    d.line((x0, y0 + arch_r, x0, y1), fill=(58, 39, 23, 230), width=16)
    d.line((x1, y0 + arch_r, x1, y1), fill=(58, 39, 23, 230), width=16)
    d.arc((x0 + 4, y0 + 4, x1 - 4, y0 + arch_r * 2 - 4), 180, 360,
          fill=(104, 72, 42, 210), width=9)
    d.line((x0 + 4, y0 + arch_r, x0 + 4, y1), fill=(104, 72, 42, 210), width=9)
    d.line((x1 - 4, y0 + arch_r, x1 - 4, y1), fill=(104, 72, 42, 210), width=9)
    d.arc((x0 + 10, y0 + 10, x1 - 10, y0 + arch_r * 2 - 10), 180, 360,
          fill=(158, 118, 68, 120), width=2)
    # Subtle wood grain on the jambs.
    for k in range(9):
        yy = y0 + arch_r + 24 + k * 52
        d.line((x0 + 6, yy, x0 + 13, yy + 3), fill=(150, 110, 64, 70), width=1)
        d.line((x1 - 13, yy + 5, x1 - 6, yy + 2), fill=(150, 110, 64, 70), width=1)
    # Small brass handle.
    mid = (y0 + y1) // 2
    d.ellipse((x1 - 27, mid - 6, x1 - 16, mid + 6),
              fill=(142, 106, 56, 225), outline=(44, 32, 20, 230), width=2)
    d.ellipse((x1 - 25, mid - 4, x1 - 21, mid), fill=(214, 178, 108, 190))
    # Soft warm spill on the floor (no hard stripes).
    spill = Image.new("RGBA", im.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(spill)
    sd.ellipse((x0 - 20, y1 - 24, x1 + 110, y1 + 58), fill=(206, 156, 86, 62))
    spill = spill.filter(ImageFilter.GaussianBlur(18))
    layer.alpha_composite(spill)

    layer = layer.filter(ImageFilter.GaussianBlur(1.1))
    im.alpha_composite(layer)


def repaint_entrance_hands(im: Image.Image) -> None:
    """Replace the whole AI dial with a geometrically correct 10:24 dial.

    The AI numerals are unevenly placed (IIII sits near the 4 o'clock angle and
    V near 5:30), so a mathematically correct hand still *looks* like 10:20.
    Redrawing the full parchment disc, numerals and hands keeps the reading
    unambiguous while preserving the painterly palette.
    """
    cx, cy = 200, 453
    rx, ry = 98, 94
    tw, th = rx * 2 + 12, ry * 2 + 12
    ox, oy = tw // 2, th // 2
    disc = Image.new("RGB", (tw, th))
    px = disc.load()
    rng = random.Random(24)
    for y in range(th):
        for x in range(tw):
            dist = math.hypot((x - ox) / rx, (y - oy) / ry)
            t = min(1.0, dist)
            noise = rng.uniform(-6.0, 6.0)
            px[x, y] = (
                int(176 * (1 - t) + 138 * t + noise),
                int(150 * (1 - t) + 112 * t + noise),
                int(104 * (1 - t) + 72 * t + noise),
            )
    disc = disc.convert("RGBA")
    mask = Image.new("L", (tw, th), 0)
    md = ImageDraw.Draw(mask)
    md.ellipse((ox - rx, oy - ry, ox + rx, oy + ry), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(2.0))
    disc.putalpha(mask)
    im.alpha_composite(disc, (cx - ox, cy - oy))

    d = ImageDraw.Draw(im)
    d.ellipse((cx - rx + 4, cy - ry + 4, cx + rx - 4, cy + ry - 4),
              outline=(96, 70, 40, 200), width=3)
    d.ellipse((cx - rx * 0.72, cy - ry * 0.72,
               cx + rx * 0.72, cy + ry * 0.72),
              outline=(112, 86, 52, 130), width=2)

    numerals = [
        (0, "XII"), (30, "I"), (60, "II"), (90, "III"),
        (120, "IIII"), (150, "V"), (180, "VI"), (210, "VII"),
        (240, "VIII"), (270, "IX"), (300, "X"), (330, "XI"),
    ]
    for deg, numeral in numerals:
        a = math.radians(deg)
        nx = cx + rx * 0.80 * math.sin(a)
        ny = cy - ry * 0.80 * math.cos(a)
        draw_text(im, (int(nx), int(ny)), numeral, 20, (70, 48, 28, 235),
                  shadow=False)

    def hand(angle: float, length: float, width: int) -> None:
        a = math.radians(angle)
        x2 = cx + length * math.sin(a)
        y2 = cy - length * math.cos(a)
        d.line((cx, cy, x2, y2), fill=(52, 38, 24, 255), width=width)
        ox2, oy2 = 1.5 * math.cos(a), 1.5 * math.sin(a)
        d.line(
            (cx + ox2, cy + oy2, x2 + ox2, y2 + oy2),
            fill=(118, 88, 50, 190),
            width=max(1, width - 3),
        )

    hand(312.0, 50, 6)   # hour hand: 10 + 24/60 hours
    hand(144.0, 66, 4)   # minute hand: 24 * 6 degrees
    d.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), fill=(150, 118, 58, 255),
              outline=(56, 40, 24, 255), width=2)
    d.ellipse((cx - 2, cy - 3, cx + 1, cy), fill=(232, 206, 148, 220))


def annotate_entrance(im: Image.Image) -> None:
    repaint_entrance_hands(im)
    # Engraved band beside the study door: left-to-right moon, star, sun.
    # Draw straight onto the dark wood so it reads as an engraving, not a UI label.
    paste_symbol(im, (390, 444), "moon", 26, GOLD)
    paste_symbol(im, (415, 444), "star", 26, GOLD)
    paste_symbol(im, (440, 444), "sun", 26, GOLD)
    d = ImageDraw.Draw(im)
    d.line((374, 466, 454, 466), fill=GOLD, width=2)

    # Paper note revealed by the lifted doormat: flame pattern up/down/up.
    d = ImageDraw.Draw(im)
    paste_symbol(im, (552, 1682), "moon", 26, INK)
    d.line((543, 1673, 561, 1691), fill=INK, width=3)
    d.line((561, 1673, 543, 1691), fill=INK, width=3)
    arrow(d, (585, 1695), (585, 1655), INK, width=5, head=12)
    arrow(d, (650, 1655), (650, 1695), INK, width=5, head=12)
    arrow(d, (715, 1695), (715, 1655), INK, width=5, head=12)
    draw_text(im, (650, 1718), "UP  DOWN  UP", 14, INK)


def annotate_study(im: Image.Image) -> None:
    # The AI never rendered the requested left doorway; add a real back door
    # in the shadowed lower-left corner and give the navigate hotspot a target.
    paint_back_door(im, (10, 1230, 160, 1740))

    # Framed apprenticeship certificate: the year used by the safe code.
    draw_text(im, (277, 330), "E. VALE", 22, INK)
    draw_text(im, (277, 370), "APPRENTICE", 14, INK)
    draw_text(im, (277, 427), "1874", 38, INK)
    d = ImageDraw.Draw(im)
    d.line((232, 456, 322, 456), fill=INK, width=2)

    # Book spines: the three years used by the bookshelf sequence.
    for x, year in ((848, "1861"), (900, "1874"), (952, "1892")):
        draw_text(im, (x, 655), year, 19, LIGHT_INK, angle=-90, shadow=True)

    # Globe: red meridian and brass pointer for the globe rotation puzzle.
    d = ImageDraw.Draw(im)
    pts = []
    for y in range(730, 1010):
        x = 625 + 16 * math.sin((y - 730) / 280 * math.pi)
        pts.append((x, y))
    d.line(pts, fill=RED, width=6, joint="curve")
    arrow(d, (740, 800), (678, 838), GOLD, width=5, head=14)
    d.ellipse((732, 792, 748, 808), fill=GOLD)

    # Letter on the desk: visual nudge toward the globe/flame relationship.
    paste_symbol(im, (425, 1180), "gear", 26, INK)
    arrow(d, (448, 1180), (512, 1180), RED, width=3, head=9)
    draw_text(im, (540, 1170), "FLAME", 13, INK)
    draw_text(im, (492, 1212), "RED LINE -> FLAME", 11, INK)


def annotate_workshop(im: Image.Image) -> None:
    # Regenerated four-lever board (the AI original had only three levers).
    feather_paste(im, Image.open(LEVER_PATCH).convert("RGB"), (420, 720, 680, 1040))

    # Blueprint: vent sequence and the two gear tooth counts.
    label_patch(im, (888, 205, 990, 285), dark=False)
    draw_text(im, (939, 222), "GEAR TEETH", 12, INK)
    draw_text(im, (939, 258), "24 - 36", 24, INK)
    label_patch(im, (795, 515, 940, 590), dark=False)
    draw_text(im, (818, 532), "VENT SEQUENCE", 12, INK)
    d = ImageDraw.Draw(im)
    for i, x in enumerate((818, 852, 886, 920)):
        start = (x, 578) if i % 2 == 0 else (x, 558)
        end = (x, 558) if i % 2 == 0 else (x, 578)
        arrow(d, start, end, INK, width=3, head=8)

    # Chalk X on the marked weight and a dashed chalk arc on the floor.
    d = ImageDraw.Draw(im)
    d.line((628, 1250, 672, 1294), fill=CHALK, width=6)
    d.line((672, 1250, 628, 1294), fill=CHALK, width=6)
    for i in range(16):
        t0, t1 = i / 16, (i + 0.55) / 16
        a0 = math.radians(200 + 100 * t0)
        a1 = math.radians(200 + 100 * t1)
        d.line(
            (380 + 300 * math.cos(a0), 1440 + 150 * math.sin(a0),
             380 + 300 * math.cos(a1), 1440 + 150 * math.sin(a1)),
            fill=CHALK,
            width=3,
        )


def annotate_gallery(im: Image.Image) -> None:
    # Four medallion plaques with the years used by the ordering puzzle.
    for x, year in ((250, "1802"), (320, "1827"), (390, "1851"), (458, "1868")):
        label_patch(im, (x - 25, 1105, x + 25, 1127))
        draw_text(im, (x, 1116), year, 12, GOLD, kind="sans")

    # Central portrait inscription with Elias's birth year.
    label_patch(im, (598, 916, 868, 954))
    draw_text(im, (733, 935), "ELIAS VALE  -  1849", 19, GOLD)

    # Letter on the side table: key, star, moon from left to right.
    paste_symbol(im, (952, 1470), "key", 24, INK)
    paste_symbol(im, (1010, 1470), "star", 24, INK)
    paste_symbol(im, (1064, 1470), "moon", 24, INK)
    d = ImageDraw.Draw(im)
    for i, x in enumerate((952, 1010, 1064), 1):
        draw_text(im, (x, 1498), str(i), 10, INK, kind="sans")
    d.line((930, 1512, 1075, 1512), fill=INK, width=1)


def annotate_observatory(im: Image.Image) -> None:
    # Star chart: dotted route through frame, key and gear badges.
    d = ImageDraw.Draw(im)
    points = [(420, 600), (530, 690), (650, 770)]
    for a, b in zip(points, points[1:]):
        for i in range(int(math.dist(a, b) // 12)):
            t0, t1 = i / 12, (i + 0.5) / 12
            p0 = (a[0] + (b[0] - a[0]) * t0, a[1] + (b[1] - a[1]) * t0)
            p1 = (a[0] + (b[0] - a[0]) * t1, a[1] + (b[1] - a[1]) * t1)
            d.line((p0, p1), fill=INK, width=4)
    for i, (kind, p) in enumerate(zip(("frame", "key", "gear"), points), 1):
        paste_symbol(im, p, kind, 44, INK)
        draw_text(im, (p[0] + 34, p[1] - 28), str(i), 20, INK, kind="sans")

    # Circled star the telescope must align with.
    d.ellipse((770, 410, 814, 454), outline=CHALK, width=3)
    d.ellipse((790, 430, 794, 434), fill=LIGHT_INK)


def inspection_from_room(
    source: Image.Image,
    box: tuple[int, int, int, int],
    name: str,
) -> None:
    crop = source.crop(box).convert("RGB")
    tile = ImageOps.contain(crop, (1080, 1080), Image.LANCZOS)
    canvas = Image.new("RGB", (1080, 1080), (18, 24, 40))
    canvas.paste(tile, ((1080 - tile.width) // 2, (1080 - tile.height) // 2))
    path = OBJECTS / f"{name}.webp"
    canvas.save(path, "WEBP", quality=84, method=6)
    print(f"{path.name}: {path.stat().st_size // 1024} KB")


def refresh_star_chart_inspection() -> None:
    im = Image.open(CLEAN / "inspect_star_chart.webp").convert("RGBA")
    d = ImageDraw.Draw(im)
    pts = [(0.27, 0.34), (0.53, 0.54), (0.79, 0.76)]
    pix = [(int(x * 1080), int(y * 1080)) for x, y in pts]
    for a, b in zip(pix, pix[1:]):
        for i in range(int(math.dist(a, b) // 12)):
            t0, t1 = i / 12, (i + 0.5) / 12
            p0 = (a[0] + (b[0] - a[0]) * t0, a[1] + (b[1] - a[1]) * t0)
            p1 = (a[0] + (b[0] - a[0]) * t1, a[1] + (b[1] - a[1]) * t1)
            d.line((p0, p1), fill=INK, width=5)
    for i, (kind, p) in enumerate(zip(("frame", "key", "gear"), pix), 1):
        paste_symbol(im, p, kind, 64, INK)
        draw_text(im, (p[0] + 46, p[1] - 34), str(i), 26, INK, kind="sans")
    path = OBJECTS / "inspect_star_chart.webp"
    im.convert("RGB").save(path, "WEBP", quality=84, method=6)
    print(f"{path.name}: {path.stat().st_size // 1024} KB")


def main() -> None:
    OBJECTS.mkdir(parents=True, exist_ok=True)
    rooms = {
        "entrance": annotate_entrance,
        "study": annotate_study,
        "workshop": annotate_workshop,
        "gallery": annotate_gallery,
        "observatory": annotate_observatory,
    }
    annotated: dict[str, Image.Image] = {}
    for room, annotate in rooms.items():
        im = load(room)
        annotate(im)
        save_room(room, im)
        annotated[room] = im

    crops = {
        "entrance": ((70, 240, 320, 580), "inspect_eh_clock"),
        "entrance_marks": ((350, 370, 480, 530), "inspect_eh_marks"),
        "entrance_mat": ((470, 1580, 800, 1780), "inspect_eh_doormat"),
        "study": ((180, 240, 370, 520), "inspect_st_certificate"),
        "study_books": ((790, 540, 1010, 800), "inspect_st_books"),
        "study_globe": ((400, 650, 770, 1050), "inspect_st_globe"),
        "study_desk": ((360, 1060, 650, 1260), "inspect_st_desk"),
        "workshop": ((750, 150, 1010, 630), "inspect_wk_blueprint"),
        "workshop_crane": ((80, 1150, 720, 1500), "inspect_wk_crane"),
        "gallery": ((190, 760, 500, 1180), "inspect_ga_medallions"),
        "gallery_letter": ((880, 1350, 1080, 1560), "inspect_ga_letter"),
        "gallery_clock": ((720, 1210, 900, 1450), "inspect_ga_chronometer"),
    }
    for key, (box, name) in crops.items():
        room = key.split("_")[0]
        inspection_from_room(annotated[room], box, name)
    refresh_star_chart_inspection()


if __name__ == "__main__":
    main()
