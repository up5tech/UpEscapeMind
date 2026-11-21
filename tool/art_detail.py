#!/usr/bin/env python3
"""Shared readability helpers for the programmatic game art.

All helpers draw in the generators' *logical* 360x640 / 480x420 coordinate
space; the generators' Canvas scales every primitive to the physical output
resolution. Nothing here introduces third-party art or puzzle logic — the
helpers only make existing hotspot objects easier to recognise.
"""
import math

INK = (0x14, 0x1B, 0x2E)
CHAR = (0x23, 0x26, 0x2E)
PAPER = (0xD8, 0xC9, 0xA3)
BRASS = (0xB0, 0x8D, 0x3E)
AMBER = (0xE8, 0xA3, 0x3D)
RED = (0xA3, 0x3B, 0x2E)
TEXT = (0xF2, 0xEA, 0xD8)
DARKWOOD = (0x2A, 0x20, 0x1A)
MIDWOOD = (0x3C, 0x2E, 0x22)
NAVY2 = (0x1B, 0x24, 0x3A)
STEEL = (0x4A, 0x52, 0x62)
GLASS = (0x9F, 0xC8, 0xDE)
LEAF = (0x3E, 0x6B, 0x46)

# Tiny 3x5 bitmap numerals — used only for years/marks already authored in
# content, never as a source of new puzzle data.
DIGITS = {
    "0": ("111", "101", "101", "101", "111"),
    "1": ("010", "110", "010", "010", "111"),
    "2": ("111", "001", "111", "100", "111"),
    "3": ("111", "001", "111", "001", "111"),
    "4": ("101", "101", "111", "001", "001"),
    "5": ("111", "100", "111", "001", "111"),
    "6": ("111", "100", "111", "101", "111"),
    "7": ("111", "001", "010", "010", "010"),
    "8": ("111", "101", "111", "101", "111"),
    "9": ("111", "101", "111", "001", "111"),
}


def mix(a, b, t):
    return tuple(int(a[k] * (1 - t) + b[k] * t) for k in range(3))


def digits(c, x, y, value, color=TEXT, scale=1):
    """Draw a short numeral string (3x5 cells) at logical coordinates."""
    x, y = int(x), int(y)
    for ch in str(value):
        rows = DIGITS.get(ch, DIGITS["0"])
        for ry, row in enumerate(rows):
            for rx, bit in enumerate(row):
                if bit == "1":
                    c.fill_rect(x + rx * scale, y + ry * scale, scale, scale, color)
        x += 4 * scale


def bevel(c, x, y, w, h, fill, edge=BRASS):
    """A panel with a readable silhouette: shadow, bevel, rim, rivets."""
    x, y, w, h = int(x), int(y), int(w), int(h)
    c.fill_rect(x + 2, y + 2, w, h, (0x0B, 0x0E, 0x16))
    c.fill_rect(x, y, w, h, fill)
    c.fill_rect(x, y, w, 2, mix(fill, TEXT, 0.30))
    c.fill_rect(x, y, 2, h, mix(fill, TEXT, 0.22))
    c.fill_rect(x, y + h - 2, w, 2, mix(fill, (0, 0, 0), 0.45))
    c.fill_rect(x + w - 2, y, 2, h, mix(fill, (0, 0, 0), 0.40))
    c.frame(x, y, w, h, edge, 2)
    for rx, ry in ((x + 3, y + 3), (x + w - 4, y + 3),
                   (x + 3, y + h - 4), (x + w - 4, y + h - 4)):
        c.circle(rx, ry, 1, edge)


def moon(c, cx, cy, r, color=TEXT):
    """Crescent built from two offset discs — shape first, colour second."""
    c.circle(cx, cy, r, color)
    c.circle(cx + r * 0.45, cy - r * 0.25, r * 0.92, INK)


def star(c, cx, cy, r, color=TEXT):
    pts = []
    for i in range(10):
        a = math.radians(-90 + i * 36)
        rr = r if i % 2 == 0 else r * 0.42
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    for i in range(10):
        c.line(pts[i][0], pts[i][1], pts[(i + 1) % 10][0], pts[(i + 1) % 10][1],
               color, 2)


def sun(c, cx, cy, r, color=AMBER):
    c.circle(cx, cy, r * 0.6, color)
    for i in range(8):
        a = math.radians(i * 45)
        c.line(cx + math.cos(a) * r * 0.75, cy + math.sin(a) * r * 0.75,
               cx + math.cos(a) * r * 1.25, cy + math.sin(a) * r * 1.25,
               color, 2)


def key(c, cx, cy, r, color=BRASS):
    c.circle(cx, cy - r * 0.4, r * 0.45, color, fill=False)
    c.line(cx, cy, cx, cy + r, color, 3)
    c.line(cx, cy + r * 0.6, cx + r * 0.5, cy + r * 0.6, color, 3)


def clock_case(c, x, y, w, h, hour=0, minute=0, pendulum=True):
    """Tall clock with a lit face and a visible pendulum/glass door."""
    bevel(c, x, y, w, h, DARKWOOD, BRASS)
    cx, cy = x + w / 2, y + h * 0.17
    r = min(w * 0.38, h * 0.17)
    c.clock_face(cx, cy, r, hour, minute)
    c.frame(x + 2, y + 2, w - 4, h - 4, mix(DARKWOOD, TEXT, 0.12), 1)
    gy, gh = y + h * 0.36, h * 0.52
    gx, gw = x + w * 0.14, w * 0.72
    c.fill_rect(gx, gy, gw, gh, INK)
    c.frame(gx, gy, gw, gh, BRASS, 2)
    if pendulum:
        c.line(cx, gy + 3, cx, gy + gh * 0.62, BRASS, 2)
        c.circle(cx, gy + gh * 0.62, min(gw, gh) * 0.20, BRASS, fill=False)
    c.fill_rect(x + 2, y + h - 5, w - 4, 4, mix(DARKWOOD, TEXT, 0.18))


def door(c, x, y, w, h, fill=(0x33, 0x27, 0x1C), locked=True):
    bevel(c, x, y, w, h, fill, BRASS)
    for fy, fh in ((0.08, 0.32), (0.44, 0.30)):
        px, py = x + w * 0.14, y + h * fy
        c.fill_rect(px, py, w * 0.72, h * fh, mix(fill, TEXT, 0.10))
        c.frame(px, py, w * 0.72, h * fh, mix(fill, TEXT, 0.28), 2)
    kx, ky = x + w * 0.82, y + h * 0.46
    c.circle(kx, ky, max(3, w * 0.055), AMBER)
    if locked:
        c.fill_rect(kx - 1, ky + 5, 2, 6, CHAR)
        c.circle(kx, ky + 11, 2, CHAR)
    for hy in (y + h * 0.16, y + h * 0.80):
        c.fill_rect(x, hy, 3, h * 0.08, STEEL)


def keypad(c, x, y, w, h, cols=2, rows=3):
    bevel(c, x, y, w, h, CHAR, STEEL)
    for r in range(rows):
        for col in range(cols):
            bx = x + w * (0.16 + 0.68 * col / max(cols - 1, 1))
            by = y + h * (0.16 + 0.68 * r / max(rows - 1, 1))
            rad = max(2, min(w, h) * 0.075)
            c.circle(bx, by, rad, mix(CHAR, TEXT, 0.10))
            c.circle(bx, by, rad, BRASS, fill=False)


def window(c, x, y, w, h, night=True):
    bevel(c, x, y, w, h, (0x2E, 0x3A, 0x54) if night else GLASS, BRASS)
    c.frame(x + 3, y + 3, w - 6, h - 6, mix(BRASS, TEXT, 0.35), 2)
    c.line(x + w / 2, y + 3, x + w / 2, y + h - 3, BRASS, 2)
    c.line(x + 3, y + h / 2, x + w - 3, y + h / 2, BRASS, 2)
    if night:
        moon(c, x + w * 0.30, y + h * 0.25, min(w, h) * 0.11, TEXT)
        star(c, x + w * 0.72, y + h * 0.20, min(w, h) * 0.07, AMBER)


def portrait(c, x, y, w, h, years=None, occupied=True):
    bevel(c, x, y, w, h, (0x30, 0x28, 0x38), BRASS)
    c.frame(x + 5, y + 5, w - 10, h - 10, AMBER, 1)
    if occupied:
        cx, cy = x + w / 2, y + h * 0.44
        head = min(w, h) * 0.18
        c.circle(cx, cy, head, mix((0x30, 0x28, 0x38), TEXT, 0.35))
        c.ellipse(cx, cy + head * 2.5, head * 1.5, head * 1.7,
                  mix((0x30, 0x28, 0x38), TEXT, 0.28))
    if years:
        digits(c, x + w * 0.16, y + h - 12, years, PAPER, 1)


def bookshelf(c, x, y, w, h, years=()):
    bevel(c, x, y, w, h, DARKWOOD, BRASS)
    for shelf in range(3):
        sy = y + h * (0.16 + 0.30 * shelf)
        c.fill_rect(x + 4, sy, w - 8, 3, mix(BRASS, TEXT, 0.25))
        count = 9
        bw = (w - 16) / count
        for bi in range(count):
            bx = x + 8 + bi * bw
            bh = h * (0.17 + 0.045 * ((bi * (shelf + 1)) % 3))
            col = [MIDWOOD, (0x63, 0x37, 0x30), (0x32, 0x50, 0x60)][bi % 3]
            c.fill_rect(bx, sy - bh, bw - 2, bh, col)
            c.fill_rect(bx + 1, sy - bh + 3, bw - 4, 1, mix(col, TEXT, 0.35))
        if shelf < len(years):
            digits(c, x + w * 0.32, sy - h * 0.30, years[shelf], PAPER, 1)


def safe(c, x, y, w, h):
    bevel(c, x, y, w, h, STEEL, BRASS)
    cx, cy = x + w / 2, y + h / 2
    r = min(w, h) * 0.32
    c.circle(cx, cy, r, mix(STEEL, CHAR, 0.55))
    c.circle(cx, cy, r, BRASS, fill=False)
    for i in range(12):
        a = math.radians(i * 30)
        c.line(cx + math.sin(a) * r * 0.78, cy - math.cos(a) * r * 0.78,
               cx + math.sin(a) * r * 0.95, cy - math.cos(a) * r * 0.95,
               TEXT, 1)
    c.line(cx, cy, cx + r * 0.65, cy - r * 0.65, BRASS, 3)
    c.circle(cx, cy, 3, AMBER)
    c.line(x + w * 0.72, cy, x + w * 0.92, cy, BRASS, 4)


def arrow(c, cx, cy, up=True, color=TEXT, size=4):
    """Simple chevron used as an up/down state marker in the art."""
    if up:
        c.line(cx - size, cy + size, cx, cy - size, color, 2)
        c.line(cx + size, cy + size, cx, cy - size, color, 2)
    else:
        c.line(cx - size, cy - size, cx, cy + size, color, 2)
        c.line(cx + size, cy - size, cx, cy + size, color, 2)


def switch_board(c, x, y, w, h, count=3, up=()):
    """Wall sconces with an explicit vertical slot and up/down knob state."""
    bevel(c, x, y, w, h, CHAR, BRASS)
    for i in range(count):
        cx = x + w * (0.18 + 0.64 * i / max(count - 1, 1))
        lit = i in up
        # Candle + flame above each switch.
        c.fill_rect(cx - 2, y + h * 0.08, 4, h * 0.12, PAPER)
        c.circle(cx, y + h * 0.07, max(3, w * 0.075), AMBER if lit else STEEL)
        if lit:
            c.circle(cx, y + h * 0.07, max(1, w * 0.03), TEXT)
        # Backing plate with a dark vertical slot: the empty half of the slot
        # makes the knob's position unmistakable.
        py = y + h * 0.24
        c.fill_rect(cx - w * 0.11, py, w * 0.22, h * 0.54,
                    mix(CHAR, TEXT, 0.12))
        c.frame(cx - w * 0.11, py, w * 0.22, h * 0.54, BRASS, 1)
        slot_top, slot_bottom = y + h * 0.30, y + h * 0.70
        slot_w = max(4, w * 0.035)
        c.fill_rect(cx - slot_w / 2, slot_top, slot_w,
                    slot_bottom - slot_top, INK)
        c.frame(cx - slot_w / 2, slot_top, slot_w,
                slot_bottom - slot_top, mix(STEEL, TEXT, 0.30), 1)
        knob_y = y + h * (0.36 if lit else 0.64)
        c.line(cx, slot_bottom, cx, knob_y, STEEL, 3)
        c.circle(cx, knob_y, max(4, w * 0.07),
                 AMBER if lit else mix(BRASS, TEXT, 0.25))
        c.circle(cx, knob_y, max(1, w * 0.02), INK)
        # Up/down chevrons above and below the slot.
        arrow(c, cx, slot_top - 7, True, AMBER if lit else mix(STEEL, TEXT, 0.35))
        arrow(c, cx, slot_bottom + 7, False,
              BRASS if not lit else mix(STEEL, TEXT, 0.35))
        digits(c, cx - 2, y + h * 0.84, i + 1, PAPER, 1)


def doormat(c, x, y, w, h):
    """Mat with a lifted corner and a note peeking out underneath."""
    bevel(c, x, y, w, h, (0x4A, 0x3A, 0x28), BRASS)
    c.frame(x + 4, y + 4, w - 8, h - 8,
            mix((0x4A, 0x3A, 0x28), TEXT, 0.25), 1)
    for i in range(4):
        c.fill_rect(x + 8, y + 12 + i * (h - 24) / 3, w - 16, 2, PAPER)
    # Lifted top-right corner: a large, bright note makes the hidden clue
    # discoverable at phone size.
    lift_x, lift_y = x + w * 0.48, y + h * 0.04
    c.fill_rect(lift_x, lift_y, w * 0.48, h * 0.38,
                mix((0x4A, 0x3A, 0x28), TEXT, 0.16))
    c.line(lift_x, lift_y, lift_x + w * 0.48, lift_y + h * 0.38, BRASS, 2)
    nx, ny = x + w * 0.52, y + h * 0.06
    c.fill_rect(nx, ny, w * 0.42, h * 0.32, PAPER)
    c.frame(nx, ny, w * 0.42, h * 0.32, mix(PAPER, BRASS, 0.45), 1)
    for i in range(4):
        c.fill_rect(nx + 4, ny + 5 + i * 6, w * 0.34, 1, CHAR)


def symbols(c, x, y, w, h):
    """The authored moon → star → sun order, drawn as distinct shapes."""
    bevel(c, x, y, w, h, INK, BRASS)
    r = min(w / 4, h / 2.6)
    moon(c, x + w * 0.20, y + h * 0.5, r * 0.9, TEXT)
    star(c, x + w * 0.50, y + h * 0.5, r, TEXT)
    sun(c, x + w * 0.80, y + h * 0.5, r * 0.85, AMBER)


def moon_phases(c, x, y, w, h):
    bevel(c, x, y, w, h, INK, BRASS)
    r = min(w / 9, h / 3.6)
    for i in range(4):
        cx = x + w * (0.14 + 0.24 * i)
        cy = y + h * 0.48
        c.circle(cx, cy, r, mix(INK, TEXT, 0.12))
        c.circle(cx, cy, r, TEXT, fill=False)
        if i == 0:
            pass  # new: dark disc
        elif i == 1:
            moon(c, cx, cy, r * 0.85, TEXT)
        elif i == 2:
            c.fill_rect(cx - r, cy - r, r, 2 * r, TEXT)
        else:
            c.circle(cx, cy, r * 0.92, TEXT)


def levers(c, x, y, w, h, count=4, up=()):
    bevel(c, x, y, w, h, DARKWOOD, BRASS)
    for i in range(count):
        lx = x + w * (0.14 + 0.72 * i / max(count - 1, 1))
        base = y + h * 0.78
        top = y + h * (0.30 if i in up else 0.52)
        c.line(lx, base, lx, top, STEEL, 4)
        c.circle(lx, top, max(3, w * 0.055), AMBER if i in up else BRASS)
        c.circle(lx, base, max(3, w * 0.06), BRASS)


def telescope(c, x, y, w, h):
    bevel(c, x, y, w, h, (0x2A, 0x24, 0x1E), BRASS)
    ax, ay = x + w * 0.24, y + h * 0.74
    bx, by = x + w * 0.82, y + h * 0.22
    c.line(ax, ay, bx, by, STEEL, max(8, w * 0.14))
    c.line(ax, ay, bx, by, BRASS, max(3, w * 0.06))
    c.circle(bx, by, max(5, w * 0.10), GLASS)
    c.circle(bx, by, max(5, w * 0.10), BRASS, fill=False)
    c.line(x + w * 0.46, y + h * 0.58, x + w * 0.46, y + h * 0.92, STEEL, 5)
    c.line(x + w * 0.28, y + h * 0.92, x + w * 0.66, y + h * 0.92, STEEL, 4)


def orrery(c, x, y, w, h):
    bevel(c, x, y, w, h, CHAR, BRASS)
    cx, cy = x + w / 2, y + h / 2
    for i, rad in enumerate((0.42, 0.30, 0.17)):
        c.circle(cx, cy, w * rad, BRASS, fill=False)
        a = math.radians(40 + i * 115)
        c.circle(cx + math.cos(a) * w * rad, cy + math.sin(a) * w * rad,
                 max(2, w * 0.035), AMBER if i == 0 else GLASS)
    c.circle(cx, cy, max(3, w * 0.06), AMBER)
    c.line(cx, cy, cx, cy - h * 0.42, BRASS, 2)


def plant(c, cx, cy, s, pot=(0x5A, 0x38, 0x26)):
    c.fill_rect(cx - s * 0.20, cy, s * 0.40, s * 0.30, pot)
    c.frame(cx - s * 0.20, cy, s * 0.40, s * 0.30, BRASS, 1)
    for dx, dy, r in ((-0.30, -0.34, 0.22), (0.0, -0.52, 0.26),
                      (0.30, -0.34, 0.22)):
        c.ellipse(cx + dx * s, cy + dy * s, r * s, r * s * 1.35, LEAF)
        c.line(cx, cy, cx + dx * s, cy + dy * s, mix(LEAF, TEXT, 0.25), 1)


def compass_rose(c, cx, cy, r):
    c.circle(cx, cy, r, INK)
    c.circle(cx, cy, r, BRASS, fill=False)
    for i in range(8):
        a = math.radians(i * 45)
        c.line(cx, cy, cx + math.cos(a) * r * 0.9, cy + math.sin(a) * r * 0.9,
               TEXT if i % 2 == 0 else STEEL, 2)
    c.circle(cx, cy, max(2, r * 0.14), AMBER)
