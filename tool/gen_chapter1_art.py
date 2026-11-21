#!/usr/bin/env python3
"""Generate Chapter 1 art assets (original, programmatic — no third-party art).

Style: "dusty grandeur" flat-vector scenes per design/05-visual-style.md.
All objects are painted at the SAME normalized bounds used by the room
hotspot JSON (design/03-room-progression.md), so affordances line up.
Clock faces are drawn at the puzzle-relevant stopped times (fair play).

Usage: python3 tool/gen_chapter1_art.py
Outputs: assets/art/rooms/*.png (360x640), assets/art/items/*.png (144),
         assets/art/puzzles/*.png
"""
import math
import os
import struct
import zlib

import art_detail as d

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "art")

# Draw in the same logical 360x640 coordinate space as the hotspot JSON, but
# rasterise at 2x so scene art stays sharp on high-density phone screens.
SCALE = 2

# palette (design/05)
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
LEAF_D = (0x2C, 0x52, 0x36)
GLASS = (0x9F, 0xC8, 0xDE)

mix = d.mix  # shared colour helper, kept short for scene code readability


def save_png(path, w, h, px):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    w, h = w * SCALE, h * SCALE
    rows = []
    for y in range(h):
        rows.append(b"\x00" + bytes(px[y * w * 4:(y + 1) * w * 4]))
    raw = b"".join(rows)

    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    with open(path, "wb") as f:
        f.write(sig + chunk(b"IHDR", ihdr) +
                chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


class Canvas:
    """Logical-coordinate canvas with SCALE× physical pixels.

    Every public drawing method keeps the original 360x640 semantics; only
    the pixel buffer is larger. This keeps hotspot alignment byte-for-byte
    identical while giving the rendered scene much crisper edges.
    """

    def __init__(self, w, h, base=(0, 0, 0, 255)):
        self.w, self.h = w, h
        self.pw, self.ph = w * SCALE, h * SCALE
        self.px = bytearray(self.pw * self.ph * 4)
        self.fill_rect(0, 0, w, h, base)

    def _write(self, x, y, c, a=1.0):
        if not (0 <= x < self.pw and 0 <= y < self.ph):
            return
        i = (y * self.pw + x) * 4
        if a >= 1.0:
            self.px[i:i + 4] = (
                bytes(c[:3]) + (bytes(c[3:4]) if len(c) > 3 else b"\xff")
            )
            return
        inv = 1.0 - a
        for k in range(3):
            self.px[i + k] = int(c[k] * a + self.px[i + k] * inv)
        self.px[i + 3] = 255

    def set(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            px, py = int(x * SCALE), int(y * SCALE)
            for yy in range(py, py + SCALE):
                for xx in range(px, px + SCALE):
                    self._write(xx, yy, c)

    def blend(self, x, y, c, a=1.0):
        if 0 <= x < self.w and 0 <= y < self.h:
            px, py = int(x * SCALE), int(y * SCALE)
            for yy in range(py, py + SCALE):
                for xx in range(px, px + SCALE):
                    self._write(xx, yy, c, a)

    def fill_rect(self, x, y, w, h, c):
        for yy in range(int(y), int(y + h)):
            for xx in range(int(x), int(x + w)):
                self.set(xx, yy, c)

    def frame(self, x, y, w, h, c, t=2):
        self.fill_rect(x, y, w, t, c)
        self.fill_rect(x, y + h - t, w, t, c)
        self.fill_rect(x, y, t, h, c)
        self.fill_rect(x + w - t, y, t, h, c)

    def circle(self, cx, cy, r, c, fill=True):
        r2 = r * r
        for yy in range(int(cy - r), int(cy + r) + 1):
            for xx in range(int(cx - r), int(cx + r) + 1):
                d2 = (xx - cx) ** 2 + (yy - cy) ** 2
                if fill:
                    if d2 <= r2:
                        self.set(xx, yy, c)
                elif (r - 2) ** 2 <= d2 <= r2:
                    self.set(xx, yy, c)

    def ellipse(self, cx, cy, rx, ry, c, fill=True):
        for yy in range(int(cy - ry), int(cy + ry) + 1):
            for xx in range(int(cx - rx), int(cx + rx) + 1):
                dv = ((xx - cx) / max(rx, 1)) ** 2 + ((yy - cy) / max(ry, 1)) ** 2
                if fill:
                    if dv <= 1.0:
                        self.set(xx, yy, c)
                elif 0.72 <= dv <= 1.0:
                    self.set(xx, yy, c)

    def line(self, x0, y0, x1, y1, c, width=2):
        dist = max(abs(x1 - x0), abs(y1 - y0), 1)
        r = width / 2.0
        steps = int(dist * 2) + 1
        for i in range(steps + 1):
            t = i / float(steps)
            x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
            for dy in range(-int(r) - 1, int(r) + 2):
                for dx in range(-int(r) - 1, int(r) + 2):
                    if dx * dx + dy * dy <= r * r:
                        self.set(int(x + dx), int(y + dy), c)

    def vgrad(self, x, y, w, h, c0, c1):
        for yy in range(int(y), int(y + h)):
            t = (yy - y) / max(h - 1, 1)
            c = tuple(int(c0[k] * (1 - t) + c1[k] * t) for k in range(3))
            self.fill_rect(x, yy, w, 1, c)

    def vignette(self):
        cx, cy = self.w / 2.0, self.h / 2.0
        m = max(math.hypot(cx, cy), 1)
        for yy in range(0, self.h, 2):
            for xx in range(0, self.w, 2):
                d = math.hypot(xx - cx, yy - cy) / m
                # Lighter than before: clues must never be hidden by shadow.
                a = max(0.0, (d - 0.68)) * 0.28
                if a > 0.01:
                    self.blend(xx, yy, (8, 10, 16), a)
                    self.blend(xx + 1, yy, (8, 10, 16), a)
                    self.blend(xx, yy + 1, (8, 10, 16), a)
                    self.blend(xx + 1, yy + 1, (8, 10, 16), a)

    def clock_face(self, cx, cy, r, h_angle, m_angle):
        """h_angle/m_angle: degrees clockwise from 12."""
        self.circle(cx, cy, r, PAPER)
        self.circle(cx, cy, r, BRASS, fill=False)
        for i in range(12):
            a = math.radians(i * 30)
            x0 = cx + math.sin(a) * (r - 5)
            y0 = cy - math.cos(a) * (r - 5)
            x1 = cx + math.sin(a) * (r - 1)
            y1 = cy - math.cos(a) * (r - 1)
            self.line(x0, y0, x1, y1, CHAR, 2)
        ha = math.radians(h_angle)
        ma = math.radians(m_angle)
        self.line(cx, cy, cx + math.sin(ha) * r * 0.55,
                  cy - math.cos(ha) * r * 0.55, CHAR, 4)
        self.line(cx, cy, cx + math.sin(ma) * r * 0.8,
                  cy - math.cos(ma) * r * 0.8, RED, 3)
        self.circle(cx, cy, 3, BRASS)

    def gear(self, cx, cy, r, teeth, c):
        self.circle(cx, cy, r, c)
        self.circle(cx, cy, r * 0.55, CHAR)
        self.circle(cx, cy, r * 0.18, c)
        for i in range(teeth):
            a = math.radians(i * 360.0 / teeth)
            x0 = cx + math.cos(a) * r
            y0 = cy + math.sin(a) * r
            x1 = cx + math.cos(a) * (r + 6)
            y1 = cy + math.sin(a) * (r + 6)
            self.line(x0, y0, x1, y1, c, 5)


def rect_of(b):
    # b: normalized (x, y, w, h) on 360x640
    W, H = 360, 640
    return b[0] * W, b[1] * H, b[2] * W, b[3] * H


def scene_base(canvas_t=0.62):
    c = Canvas(360, 640, INK)
    c.vgrad(0, 0, 360, int(640 * canvas_t), INK, NAVY2)
    # Subtle wall panelling gives the flat background depth without noise.
    for px in range(0, 360, 72):
        c.fill_rect(px, 8, 1, int(640 * canvas_t) - 16, (0x22, 0x2C, 0x45))
    c.fill_rect(0, int(640 * canvas_t) - 6, 360, 6, (0x4A, 0x3A, 0x28))
    fy = int(640 * canvas_t)
    c.fill_rect(0, fy, 360, 640 - fy, MIDWOOD)
    for i in range(fy, 640, 12):
        c.fill_rect(0, i, 360, 1, (0x30, 0x25, 0x1C))
    for px in range(0, 360, 60):
        c.fill_rect(px, fy, 1, 640 - fy, (0x28, 0x1E, 0x15))
    return c


def panel(c, b, fill=CHAR, edge=BRASS):
    x, y, w, h = rect_of(b)
    d.bevel(c, x, y, w, h, fill, edge)
    return x, y, w, h


def room_entrance():
    c = scene_base()
    # Grandfather clock stopped at 10:24 — same bounds as its hotspot.
    x, y, w, h = rect_of((0.06, 0.14, 0.20, 0.52))
    d.clock_case(c, x, y, w, h, 312, 144)
    # Carved symbol band: the discover-clue hotspot sits at y=0.22.
    x, y, w, h = rect_of((0.40, 0.22, 0.12, 0.07))
    d.symbols(c, x, y, w, h)
    # Taller marks panel for the matching puzzle hotspot below it.
    x, y, w, h = rect_of((0.40, 0.30, 0.12, 0.30))
    d.bevel(c, x, y, w, h, INK, BRASS)
    for i, glyph in enumerate((d.moon, d.star, d.sun)):
        cy = y + h * (0.18 + 0.32 * i)
        glyph(c, x + w / 2, cy, min(w * 0.24, h * 0.10),
              AMBER if glyph is d.sun else TEXT)
    # Study door with keypad and visible lock.
    x, y, w, h = rect_of((0.52, 0.18, 0.26, 0.62))
    d.door(c, x, y, w, h)
    x, y, w, h = rect_of((0.44, 0.42, 0.07, 0.12))
    d.keypad(c, x, y, w, h)
    x, y, w, h = rect_of((0.46, 0.72, 0.22, 0.14))
    d.doormat(c, x, y, w, h)
    x, y, w, h = rect_of((0.14, 0.34, 0.18, 0.34))
    d.switch_board(c, x, y, w, h, 3)
    # Painting is aligned with its inspect hotspot at y=0.50.
    x, y, w, h = rect_of((0.30, 0.50, 0.10, 0.16))
    d.portrait(c, x, y, w, h)
    x, y, w, h = rect_of((0.78, 0.10, 0.16, 0.50))
    d.window(c, x, y, w, h)
    c.vignette()
    return c


def room_study():
    c = scene_base()
    # Book years are authored in content; the art only makes them readable.
    x, y, w, h = rect_of((0.58, 0.16, 0.32, 0.48))
    d.bookshelf(c, x, y, w, h, (1861, 1874, 1892))
    # Regulator clock stopped at 03:47.
    x, y, w, h = rect_of((0.10, 0.30, 0.16, 0.42))
    d.clock_case(c, x, y, w, h, 103.5, 282)
    # Certificate: paper, ruled lines, wax seal.
    x, y, w, h = rect_of((0.34, 0.18, 0.18, 0.22))
    d.bevel(c, x, y, w, h, PAPER, BRASS)
    for i in range(4):
        c.fill_rect(x + 5, y + 8 + i * (h - 18) / 3, w - 10, 2, CHAR)
    c.circle(x + w * 0.76, y + h * 0.78, min(w, h) * 0.14, RED)
    # Strongbox with a large combination dial.
    x, y, w, h = rect_of((0.74, 0.52, 0.18, 0.30))
    d.safe(c, x, y, w, h)
    # Astrolabe rings with a sighting arm.
    x, y, w, h = rect_of((0.36, 0.48, 0.16, 0.24))
    d.compass_rose(c, x + w / 2, y + h / 2, min(w, h) * 0.42)
    # Globe with the red meridian mark.
    x, y, w, h = rect_of((0.52, 0.55, 0.20, 0.30))
    d.bevel(c, x, y, w, h, (0x2A, 0x20, 0x1A))
    gx, gy, gr = x + w / 2, y + h * 0.40, min(w, h) * 0.36
    c.circle(gx, gy, gr, NAVY2)
    c.ellipse(gx - gr * 0.25, gy - gr * 0.15, gr * 0.42, gr * 0.30, LEAF_D)
    c.ellipse(gx + gr * 0.30, gy + gr * 0.25, gr * 0.32, gr * 0.24, LEAF_D)
    c.circle(gx, gy, gr, BRASS, fill=False)
    c.line(gx, gy - gr, gx + gr * 0.5, gy + gr, RED, 3)
    c.line(x + w - 3, gy - gr, x + w - 3, y + h - 4, BRASS, 3)
    # Desk with an open letter and an inkwell.
    x, y, w, h = rect_of((0.20, 0.62, 0.30, 0.26))
    d.bevel(c, x, y, w, h, (0x3A, 0x2C, 0x20), BRASS)
    c.fill_rect(x + w * 0.10, y + h * 0.28, w * 0.40, h * 0.20, PAPER)
    for i in range(3):
        c.fill_rect(x + w * 0.14, y + h * (0.34 + 0.05 * i), w * 0.30, 1, CHAR)
    c.fill_rect(x + w * 0.60, y + h * 0.32, w * 0.22, h * 0.16, CHAR)
    c.circle(x + w * 0.71, y + h * 0.40, 4, INK)
    x, y, w, h = rect_of((0.86, 0.30, 0.12, 0.50))
    d.door(c, x, y, w, h)
    x, y, w, h = rect_of((0.02, 0.30, 0.06, 0.44))
    d.door(c, x, y, w, h, (0x2C, 0x24, 0x1E), locked=False)
    c.vignette()
    return c


def room_workshop():
    c = scene_base()
    # Three meshing gears with red index marks.
    x, y, w, h = rect_of((0.08, 0.18, 0.30, 0.45))
    d.bevel(c, x, y, w, h, INK, BRASS)
    for gx, gy, gr, teeth, col in (
        (0.30, 0.25, 0.19, 10, STEEL),
        (0.62, 0.50, 0.17, 8, BRASS),
        (0.35, 0.76, 0.15, 12, STEEL),
    ):
        c.gear(x + w * gx, y + h * gy, w * gr, teeth, col)
        c.line(x + w * gx, y + h * gy - w * gr,
               x + w * gx, y + h * gy - w * gr - 10, RED, 3)
    c.line(x + w * 0.5, y - 2, x + w * 0.5, y + 10, TEXT, 2)
    # Wall clock stopped at 06:58.
    x, y, w, h = rect_of((0.55, 0.15, 0.14, 0.24))
    d.clock_case(c, x, y, w, h, 209, 348, pendulum=False)
    # Blueprint with recognisable gear/vent sketches.
    x, y, w, h = rect_of((0.55, 0.45, 0.22, 0.28))
    d.bevel(c, x, y, w, h, (0x2E, 0x40, 0x56), TEXT)
    c.frame(x + 5, y + 5, w - 10, h - 10, (0x2E, 0x40, 0x56), 2)
    c.circle(x + w * 0.66, y + h * 0.35, w * 0.15, TEXT, fill=False)
    for i in range(8):
        a = math.radians(i * 45)
        c.line(x + w * 0.66 + math.cos(a) * w * 0.15,
               y + h * 0.35 + math.sin(a) * w * 0.15,
               x + w * 0.66 + math.cos(a) * w * 0.20,
               y + h * 0.35 + math.sin(a) * w * 0.20, TEXT, 2)
    for i in range(5):
        c.fill_rect(x + w * 0.12 + i * w * 0.10,
                    y + h * 0.72 - (i % 2) * 6, 4, h * 0.12, TEXT)
    # Four lever switches.
    x, y, w, h = rect_of((0.30, 0.55, 0.22, 0.30))
    d.levers(c, x, y, w, h, 4)
    # Parts cabinet with drawers and a spare gear.
    x, y, w, h = rect_of((0.80, 0.45, 0.16, 0.35))
    d.bevel(c, x, y, w, h, (0x33, 0x27, 0x1C), BRASS)
    for i in range(3):
        c.frame(x + 4, y + 5 + i * h * 0.18, w - 8, h * 0.15, STEEL, 2)
    c.gear(x + w / 2, y + h * 0.72, w * 0.22, 8, BRASS)
    # Floorboard strip: the loose board sits under its hotspot (x=0.42).
    fx, fy, fw, fh = rect_of((0.06, 0.80, 0.84, 0.12))
    c.fill_rect(fx, fy, fw, fh, DARKWOOD)
    for i in range(5):
        bx = fx + i * fw / 5
        loose = i == 2
        col = (0x5C, 0x48, 0x30) if loose else (0x41, 0x33, 0x22)
        c.fill_rect(bx + 1, fy + 1, fw / 5 - 3, fh - 2, col)
        for ny in (fy + 6, fy + fh - 7):
            c.circle(bx + 6, ny, 1, BRASS)
            c.circle(bx + fw / 5 - 8, ny, 1, BRASS)
        if loose:
            c.frame(bx, fy, fw / 5, fh, PAPER, 1)
    # Crane arm with a marked crate.
    x, y, w, h = rect_of((0.08, 0.60, 0.24, 0.32))
    d.bevel(c, x, y, w, h, (0x2A, 0x24, 0x1E))
    c.line(x + 6, y + 8, x + w - 8, y + h * 0.36, BRASS, 5)
    c.circle(x + 6, y + 8, 6, STEEL)
    c.line(x + w - 8, y + h * 0.36, x + w - 8, y + h * 0.62, TEXT, 2)
    c.line(x + w - 14, y + h * 0.62, x + w - 8, y + h * 0.62, TEXT, 2)
    cx, cy, cw, ch = rect_of((0.24, 0.74, 0.10, 0.10))
    d.bevel(c, cx, cy, cw, ch, MIDWOOD, TEXT)
    c.line(cx + 3, cy + 3, cx + cw - 3, cy + ch - 3, RED, 2)
    c.line(cx + cw - 3, cy + 3, cx + 3, cy + ch - 3, RED, 2)
    x, y, w, h = rect_of((0.86, 0.28, 0.12, 0.52))
    d.door(c, x, y, w, h)
    x, y, w, h = rect_of((0.02, 0.28, 0.05, 0.40))
    d.door(c, x, y, w, h, (0x2C, 0x24, 0x1E), locked=False)
    c.vignette()
    return c


def room_gallery():
    c = scene_base(0.58)
    # Doors first: the left medallion panel overlaps them slightly, so painting
    # the doors first keeps every authored year visible.
    x, y, w, h = rect_of((0.06, 0.28, 0.12, 0.50))
    d.door(c, x, y, w, h)
    x, y, w, h = rect_of((0.02, 0.32, 0.03, 0.36))
    d.door(c, x, y, w, h, (0x2C, 0x24, 0x1E), locked=False)
    # Four dated medallions, aligned with the puzzle hotspot.
    x, y, w, h = rect_of((0.10, 0.20, 0.34, 0.40))
    d.bevel(c, x, y, w, h, (0x2A, 0x22, 0x30), BRASS)
    for i, year in enumerate((1802, 1827, 1851, 1868)):
        mx = x + w * (0.22 + 0.235 * i)
        c.circle(mx, y + h * 0.34, w * 0.095, mix(STEEL, TEXT, 0.18))
        c.circle(mx, y + h * 0.34, w * 0.095, BRASS, fill=False)
        c.circle(mx, y + h * 0.26, w * 0.035, mix(STEEL, TEXT, 0.40))
        c.ellipse(mx, y + h * 0.42, w * 0.06, w * 0.05,
                  mix(STEEL, TEXT, 0.40))
        d.digits(c, mx - w * 0.06, y + h * 0.60, year, PAPER, 1)
    x, y, w, h = rect_of((0.50, 0.22, 0.16, 0.36))
    d.portrait(c, x, y, w, h)
    # Empty frames still show where a portrait once hung.
    x, y, w, h = rect_of((0.72, 0.18, 0.24, 0.38))
    d.bevel(c, x, y, w, h, (0x2A, 0x22, 0x30), BRASS)
    for i in range(3):
        fx = x + w * (0.03 + 0.33 * i)
        fy, fw, fh = y + h * 0.12, w * 0.28, h * 0.76
        c.fill_rect(fx, fy, fw, fh, INK)
        c.frame(fx, fy, fw, fh, BRASS, 3)
        c.ellipse(fx + fw / 2, fy + fh * 0.36, fw * 0.20, fh * 0.11,
                  mix(INK, TEXT, 0.10))
        c.ellipse(fx + fw / 2, fy + fh * 0.78, fw * 0.34, fh * 0.20,
                  mix(INK, TEXT, 0.08))
    # Letter on a side table.
    x, y, w, h = rect_of((0.70, 0.60, 0.12, 0.16))
    d.bevel(c, x, y, w, h, MIDWOOD, BRASS)
    c.fill_rect(x + w * 0.10, y + h * 0.18, w * 0.80, h * 0.55, PAPER)
    for i in range(3):
        c.fill_rect(x + w * 0.18, y + h * (0.30 + 0.10 * i), w * 0.62, 1, CHAR)
    x, y, w, h = rect_of((0.36, 0.55, 0.18, 0.30))
    d.moon_phases(c, x, y, w, h)
    # Glass reliquary with a visible object inside.
    x, y, w, h = rect_of((0.86, 0.42, 0.12, 0.30))
    d.bevel(c, x, y, w, h, DARKWOOD, BRASS)
    c.fill_rect(x + 4, y + 4, w - 8, h - 8, mix(INK, GLASS, 0.18))
    c.frame(x + 4, y + 4, w - 8, h - 8, AMBER, 1)
    d.key(c, x + w / 2, y + h / 2, min(w, h) * 0.28, AMBER)
    x, y, w, h = rect_of((0.58, 0.12, 0.12, 0.20))
    d.bevel(c, x, y, w, h, CHAR, BRASS)
    c.clock_face(x + w / 2, y + h * 0.48, min(w, h) * 0.36, 247.5, 90)
    c.fill_rect(40, 560, 300, 40, (0x3A, 0x26, 0x28))
    c.frame(40, 560, 300, 40, mix((0x3A, 0x26, 0x28), TEXT, 0.18), 1)
    c.vignette()
    return c


def room_observatory():
    c = Canvas(360, 640, (0x0C, 0x10, 0x20))
    c.vgrad(0, 0, 360, 400, (0x0A, 0x0E, 0x1E), NAVY2)
    import random
    rnd = random.Random(1892)
    for _ in range(300):
        x, y = rnd.randrange(360), rnd.randrange(390)
        s = 1 if rnd.random() < 0.82 else 2
        c.fill_rect(x, y, s, s, mix(TEXT, GLASS, 0.30 if s == 2 else 0.10))
    # Vale's circled target star.
    c.circle(120, 150, 3, AMBER)
    for a in range(0, 360, 45):
        t = math.radians(a)
        c.line(120 + 6 * math.cos(t), 150 + 6 * math.sin(t),
               120 + 10 * math.cos(t), 150 + 10 * math.sin(t), AMBER, 1)
    c.circle(120, 150, 15, RED, fill=False)
    c.fill_rect(0, 400, 360, 240, MIDWOOD)
    for i in range(404, 640, 14):
        c.fill_rect(0, i, 360, 1, (0x30, 0x25, 0x1C))
    # Star-chart projector: constellation lines make it read as a chart.
    x, y, w, h = rect_of((0.30, 0.15, 0.40, 0.30))
    d.bevel(c, x, y, w, h, (0x11, 0x16, 0x28), BRASS)
    pts = [(0.16, 0.26), (0.38, 0.18), (0.58, 0.42), (0.82, 0.30),
           (0.70, 0.72), (0.30, 0.70)]
    for i in range(len(pts)):
        ax, ay = pts[i]
        bx, by = pts[(i + 1) % len(pts)]
        c.line(x + w * ax, y + h * ay, x + w * bx, y + h * by,
               mix(NAVY2, TEXT, 0.35), 1)
    for px_, py_ in pts:
        c.circle(x + w * px_, y + h * py_, 2, TEXT)
        c.circle(x + w * px_, y + h * py_, 5, BRASS, fill=False)
    x, y, w, h = rect_of((0.12, 0.45, 0.30, 0.35))
    d.orrery(c, x, y, w, h)
    x, y, w, h = rect_of((0.62, 0.35, 0.26, 0.45))
    d.telescope(c, x, y, w, h)
    x, y, w, h = rect_of((0.86, 0.30, 0.12, 0.48))
    d.door(c, x, y, w, h)
    c.frame(x + 3, y + h * 0.18, w - 6, h * 0.55, RED, 1)
    x, y, w, h = rect_of((0.02, 0.34, 0.03, 0.34))
    d.door(c, x, y, w, h, (0x2C, 0x24, 0x1E), locked=False)
    c.vignette()
    return c


def item_icon(name, glyph):
    c = Canvas(144, 144, (35, 38, 46, 255))
    c.frame(6, 6, 132, 132, BRASS, 4)
    if glyph == "key":
        c.fill_rect(50, 40, 10, 60, BRASS)
        c.circle(55, 40, 18, BRASS, fill=False)
        c.fill_rect(50, 96, 30, 8, BRASS)
        c.fill_rect(50, 82, 22, 8, BRASS)
    elif glyph == "lens":
        c.circle(72, 72, 34, (0x9F, 0xC8, 0xDE, 255), fill=False)
        c.circle(72, 72, 34, TEXT, fill=False)
        c.line(48, 52, 96, 92, TEXT, 2)
    elif glyph == "frame":
        c.frame(40, 40, 64, 64, BRASS, 6)
        c.frame(52, 52, 40, 40, STEEL, 2)
    elif glyph == "crank":
        c.fill_rect(44, 70, 56, 10, STEEL)
        c.circle(100, 75, 12, BRASS, fill=False)
        c.fill_rect(40, 50, 10, 40, BRASS)
    elif glyph == "focus":
        c.circle(72, 72, 30, TEXT, fill=False)
        c.frame(34, 34, 76, 76, BRASS, 4)
        c.line(56, 44, 88, 44, (0x9F, 0xC8, 0xDE, 255), 3)
    save_png(os.path.join(ROOT, "items", name + ".png"), 144, 144, c.px)


def floorboard_scene():
    c = Canvas(480, 400, MIDWOOD)
    c.fill_rect(0, 0, 480, 400, DARKWOOD)
    for i in range(5):
        bx = 20 + i * 88
        loose = i == 1
        col = (0x5C, 0x48, 0x30) if loose else (0x41, 0x33, 0x22)
        c.fill_rect(bx, 120, 80, 180, col)
        c.frame(bx, 120, 80, 180, (0x1E, 0x16, 0x0E), 2)
        for gy in range(140, 300, 26):
            c.fill_rect(bx + 6, gy, 68, 1, (0x1E, 0x16, 0x0E))
        for ny in (138, 282):
            c.circle(bx + 10, ny, 2, BRASS)
            c.circle(bx + 70, ny, 2, BRASS)
        if loose:
            c.frame(bx - 3, 117, 86, 186, PAPER, 2)  # dust-free gap
            c.fill_rect(bx + 2, 122, 76, 176, mix(col, TEXT, 0.10))
    c.fill_rect(20, 320, 440, 8, (0x1E, 0x16, 0x0E))
    c.vignette()
    save_png(os.path.join(ROOT, "puzzles", "floorboards.png"), 480, 400, c.px)


def star_chart_scene():
    c = Canvas(480, 420, (0x0A, 0x0E, 0x1E, 255))
    import random
    rnd = random.Random(99)
    for _ in range(320):
        x, y = rnd.randrange(480), rnd.randrange(420)
        c.fill_rect(x, y, 1, 1, TEXT)
    # three constellation markers matching region centers
    pts = [("gallery", 120, 147), ("study", 264, 231), ("workshop", 384, 322)]
    for name, x, y in pts:
        for _ in range(5):
            sx = x + rnd.randrange(-26, 27)
            sy = y + rnd.randrange(-22, 23)
            c.circle(sx, sy, 2, TEXT)
        c.circle(x, y, 20, BRASS, fill=False)
        c.fill_rect(x - 6, y - 6, 12, 12, AMBER)  # sigil plate
    # dotted path frame -> key -> gear
    def dotted(a, b):
        steps = 24
        for i in range(steps + 1):
            t = i / float(steps)
            x = a[0] + (b[0] - a[0]) * t
            y = a[1] + (b[1] - a[1]) * t
            if i % 2 == 0:
                c.fill_rect(int(x), int(y), 3, 3, PAPER)
    dotted((120, 147), (264, 231))
    dotted((264, 231), (384, 322))
    for name, x, y in pts:
        c.line(x, y + 22, x, y + 30, PAPER, 1)
    c.frame(8, 8, 464, 404, BRASS, 3)
    save_png(os.path.join(ROOT, "puzzles", "star_chart.png"), 480, 420, c.px)


def main():
    scenes = {
        "room_entrance.png": room_entrance,
        "room_study.png": room_study,
        "room_workshop.png": room_workshop,
        "room_gallery.png": room_gallery,
        "room_observatory.png": room_observatory,
    }
    for name, fn in scenes.items():
        c = fn()
        save_png(os.path.join(ROOT, "rooms", name), 360, 640, c.px)
        print("rooms/" + name)
    items = {
        "item_clock_key.png": "key",
        "item_lens.png": "lens",
        "item_brass_frame.png": "frame",
        "item_crank.png": "crank",
        "item_focus_lens.png": "focus",
    }
    for name, g in items.items():
        item_icon(name.replace(".png", ""), g)
        print("items/" + name)
    floorboard_scene()
    star_chart_scene()
    print("puzzles/floorboards.png, puzzles/star_chart.png")


if __name__ == "__main__":
    main()
