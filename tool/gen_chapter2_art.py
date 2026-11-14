#!/usr/bin/env python3
"""Generate Chapter 2 art assets (original, programmatic — no third-party art).

Style: "dusty grandeur" flat-vector scenes per design/05-visual-style.md,
same pipeline as tool/gen_chapter1_art.py. Objects are painted at the SAME
normalized bounds used by the Chapter 2 room hotspot JSON, and puzzle
backdrop markers sit at the coordinates authored in the puzzle JSON.

Usage: python3 tool/gen_chapter2_art.py
Outputs: assets/art/rooms/room_conservatory.png, room_pump_room.png,
         room_orangery.png (360x640), assets/art/items/*.png (144),
         assets/art/puzzles/seed_tray.png, conservatory_chart.png
"""
import math
import os
import struct
import zlib

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "art")

# palette (design/05) — same constants as chapter 1
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
LEAF = (0x3E, 0x6B, 0x46)
LEAF_D = (0x2C, 0x52, 0x36)
GLASS = (0x9F, 0xC8, 0xDE)
ORANGE = (0xD8, 0x7A, 0x3A)


def save_png(path, w, h, px):
    os.makedirs(os.path.dirname(path), exist_ok=True)
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
    def __init__(self, w, h, base=(0, 0, 0, 255)):
        self.w, self.h = w, h
        self.px = bytearray(w * h * 4)
        self.fill_rect(0, 0, w, h, base)

    def blend(self, x, y, c, a=1.0):
        if not (0 <= x < self.w and 0 <= y < self.h):
            return
        i = (y * self.w + x) * 4
        inv = 1.0 - a
        for k in range(3):
            self.px[i + k] = int(c[k] * a + self.px[i + k] * inv)
        self.px[i + 3] = 255

    def set(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            i = (y * self.w + x) * 4
            self.px[i:i + 4] = bytes(c[:3]) + (bytes(c[3:4]) if len(c) > 3 else b"\xff")

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
                elif r2 - 9 <= d2 <= r2:
                    self.set(xx, yy, c)

    def ellipse(self, cx, cy, rx, ry, c, fill=True):
        for yy in range(int(cy - ry), int(cy + ry) + 1):
            for xx in range(int(cx - rx), int(cx + rx) + 1):
                d = ((xx - cx) / max(rx, 1)) ** 2 + ((yy - cy) / max(ry, 1)) ** 2
                if fill:
                    if d <= 1.0:
                        self.set(xx, yy, c)
                elif 0.75 <= d <= 1.0:
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
                a = max(0.0, (d - 0.55)) * 0.5
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

    def plant(self, cx, cy, s, c=LEAF):
        """Simple potted-plant silhouette: pot + three leaves."""
        self.fill_rect(cx - s * 0.18, cy, s * 0.36, s * 0.3, DARKWOOD)
        self.frame(cx - s * 0.18, cy, s * 0.36, s * 0.3, BRASS, 1)
        for i, (dx, dy, r) in enumerate([(-0.28, -0.34, 0.20),
                                          (0.0, -0.5, 0.24),
                                          (0.28, -0.34, 0.20)]):
            self.ellipse(cx + dx * s, cy + dy * s, r * s, r * s * 1.4, c)


def rect_of(b):
    # b: normalized (x, y, w, h) on 360x640
    W, H = 360, 640
    return b[0] * W, b[1] * H, b[2] * W, b[3] * H


def glasshouse_base(canvas_t=0.60):
    """Conservatory walls: cool green glass panes over a dark floor."""
    c = Canvas(360, 640, (0x0D, 0x16, 0x18))
    c.vgrad(0, 0, 360, int(640 * canvas_t), (0x0D, 0x16, 0x18), (0x14, 0x26, 0x2C))
    fy = int(640 * canvas_t)
    c.fill_rect(0, fy, 360, 640 - fy, (0x24, 0x2C, 0x26))
    for i in range(fy, 640, 12):
        c.fill_rect(0, i, 360, 1, (0x18, 0x20, 0x1A))
    return c, fy


def panel(c, b, fill=CHAR, edge=BRASS):
    x, y, w, h = rect_of(b)
    c.fill_rect(x, y, w, h, fill)
    c.frame(x, y, w, h, edge, 2)
    return x, y, w, h


def room_conservatory():
    c, fy = glasshouse_base()
    # glass roof panes
    for i in range(4):
        px = 20 + i * 85
        c.line(px, 0, px + 40, int(fy * 0.55), GLASS, 1)
    for i in range(3):
        yy = 30 + i * 60
        c.line(0, yy, 360, yy - 20, GLASS, 1)
    # sundial (puzzle): semicircle + gnomon
    x, y, w, h = panel(c, (0.34, 0.14, 0.22, 0.26), (0x1A, 0x24, 0x22), BRASS)
    cx, cy = x + w / 2, y + h * 0.75
    for r in range(3):
        c.circle(cx, cy, w * (0.42 - 0.12 * r), STEEL, fill=False)
    c.line(cx, cy, cx + w * 0.18, cy - h * 0.62, BRASS, 4)  # gnomon
    c.circle(cx, cy, 4, AMBER)
    # stopped conservatory clock at 07:15 (door code 0715)
    x, y, w, h = panel(c, (0.60, 0.10, 0.13, 0.24), DARKWOOD, BRASS)
    c.clock_face(x + w / 2, y + h * 0.32, w * 0.36, 221.25, 90)
    # plant-tag bench (sequence puzzle): four tags on a bench
    x, y, w, h = panel(c, (0.05, 0.42, 0.26, 0.34), (0x33, 0x2A, 0x1E), BRASS)
    c.fill_rect(x + 4, y + h * 0.62, w - 8, 6, MIDWOOD)  # bench top
    for i in range(4):
        tx = x + w * (0.1 + 0.22 * i)
        c.fill_rect(tx, y + h * 0.3, w * 0.14, h * 0.22, PAPER)
        c.fill_rect(tx + 2, y + h * 0.34, w * 0.14 - 4, 2, CHAR)
        c.fill_rect(tx + 2, y + h * 0.4, w * 0.1, 2, CHAR)
        c.plant(tx + w * 0.07, y + h * 0.28, 10, LEAF_D)
    # irrigation valve board: five valves (mechanical_state)
    x, y, w, h = panel(c, (0.34, 0.52, 0.24, 0.34), (0x16, 0x20, 0x24), STEEL)
    for i in range(5):
        vx = x + w * (0.1 + 0.2 * i)
        c.circle(vx, y + h * 0.4, 9, BRASS, fill=False)
        c.line(vx - 7, y + h * 0.4, vx + 7, y + h * 0.4, BRASS, 2)
        c.fill_rect(vx - 1, y + h * 0.4, 2, h * 0.35, STEEL)
        if i % 2 == 0:
            c.circle(vx, y + h * 0.4, 3, RED)  # two lit
    # thermometer on bench end (inspect)
    x, y, w, h = rect_of((0.28, 0.60, 0.09, 0.20))
    c.fill_rect(x + w / 2 - 2, y, 4, h, GLASS)
    c.fill_rect(x + w / 2 - 1, y + h * 0.5, 2, h * 0.45, RED)
    c.circle(x + w / 2, y + h * 0.75, 5, BRASS)
    # Vale's note on the fountain rim (discover clue)
    x, y, w, h = rect_of((0.50, 0.64, 0.11, 0.14))
    c.fill_rect(x, y, w, h, PAPER)
    c.fill_rect(x + 3, y + 3, w - 6, 2, CHAR)
    c.fill_rect(x + 3, y + 7, w - 10, 2, CHAR)
    # central fountain (optional clue)
    x, y, w, h = rect_of((0.42, 0.70, 0.20, 0.16))
    c.ellipse(x + w / 2, y + h * 0.6, w * 0.48, h * 0.4, STEEL)
    c.ellipse(x + w / 2, y + h * 0.55, w * 0.36, h * 0.3, GLASS)
    c.line(x + w / 2, y + h * 0.2, x + w / 2, y + h * 0.6, STEEL, 4)
    c.circle(x + w / 2, y + h * 0.15, 5, BRASS)
    # pump-room glass door (right)
    x, y, w, h = panel(c, (0.80, 0.22, 0.15, 0.58), (0x1E, 0x30, 0x34), BRASS)
    c.frame(x + w * 0.1, y + h * 0.06, w * 0.8, h * 0.3, GLASS, 2)
    c.line(x + w / 2, y, x + w / 2, y + h, BRASS, 2)
    c.fill_rect(x + w * 0.42, y + h * 0.55, w * 0.16, h * 0.3, CHAR)
    # leaf silhouettes for depth
    for bx, by, s in [(0.10, 0.18, 26), (0.24, 0.12, 20), (0.70, 0.16, 22)]:
        c.plant(bx * 360, by * 640, s, LEAF_D)
    c.vignette()
    return c


def room_pump_room():
    c = Canvas(360, 640, INK)
    c.vgrad(0, 0, 360, 420, INK, (0x16, 0x1C, 0x22))
    fy = 420
    c.fill_rect(0, fy, 360, 640 - fy, (0x20, 0x22, 0x26))
    for i in range(fy, 640, 14):
        c.fill_rect(0, i, 360, 1, (0x14, 0x16, 0x1A))
    # overhead pipe run (inspect hotspot)
    c.fill_rect(20, 30, 320, 12, STEEL)
    c.frame(20, 30, 320, 12, CHAR, 1)
    for i in range(5):
        c.circle(50 + i * 65, 36, 8, CHAR, fill=False)
    # flywheel puzzle: big dual gear
    x, y, w, h = panel(c, (0.08, 0.16, 0.30, 0.40), (0x14, 0x18, 0x20), STEEL)
    c.gear(x + w * 0.5, y + h * 0.5, w * 0.34, 12, BRASS)
    c.gear(x + w * 0.78, y + h * 0.3, w * 0.16, 8, STEEL)
    c.gear(x + w * 0.24, y + h * 0.74, w * 0.15, 9, STEEL)
    # gauge board: three dials (logic puzzle backdrop)
    x, y, w, h = panel(c, (0.44, 0.14, 0.26, 0.30), (0x12, 0x18, 0x1E), BRASS)
    for i in range(3):
        gx = x + w * (0.2 + 0.3 * i)
        c.circle(gx, y + h * 0.42, w * 0.16, PAPER)
        c.circle(gx, y + h * 0.42, w * 0.16, CHAR, fill=False)
        a = math.radians(40 + i * 50)
        c.line(gx, y + h * 0.42, gx + math.cos(a) * w * 0.11,
               y + h * 0.42 + math.sin(a) * w * 0.11, RED, 2)
    # seed tray table (hidden_object backdrop sits in puzzle UI; here a table)
    x, y, w, h = panel(c, (0.44, 0.55, 0.30, 0.30), (0x2E, 0x26, 0x1E), BRASS)
    for i in range(5):
        px_ = x + w * (0.08 + 0.21 * i)
        c.fill_rect(px_, y + h * 0.2, w * 0.14, h * 0.5, DARKWOOD)
        c.frame(px_, y + h * 0.2, w * 0.14, h * 0.5, LEAF_D, 1)
        c.circle(px_ + w * 0.07, y + h * 0.34, 4, LEAF)
    # pressure manifold (logic puzzle)
    x, y, w, h = panel(c, (0.76, 0.18, 0.20, 0.30), (0x14, 0x1A, 0x20), STEEL)
    c.line(x + 4, y + h * 0.3, x + w - 4, y + h * 0.3, BRASS, 5)
    for i in range(3):
        vx = x + w * (0.25 + 0.25 * i)
        c.circle(vx, y + h * 0.3, 7, CHAR, fill=False)
        c.line(vx, y + h * 0.3, vx, y + h * 0.75, STEEL, 3)
        c.circle(vx, y + h * 0.8, 5, BRASS)
    # oil stain (optional clue)
    x, y, w, h = rect_of((0.60, 0.66, 0.14, 0.12))
    c.ellipse(x + w / 2, y + h / 2, w * 0.45, h * 0.42, (0x0C, 0x0C, 0x0E))
    c.ellipse(x + w / 2 - 3, y + h / 2 - 2, w * 0.2, h * 0.18, (0x16, 0x16, 0x18))
    # orangery door (right)
    x, y, w, h = panel(c, (0.86, 0.30, 0.12, 0.48), (0x2A, 0x24, 0x1C), BRASS)
    c.frame(x + 3, y + 3, w - 6, h - 6, (0x3E, 0x6B, 0x46), 1)
    c.fill_rect(x + w * 0.4, y + h * 0.5, w * 0.2, h * 0.16, STEEL)
    # back door (left)
    panel(c, (0.02, 0.30, 0.06, 0.44), (0x2C, 0x24, 0x1E), STEEL)
    c.vignette()
    return c


def room_orangery():
    c = Canvas(360, 640, (0x12, 0x14, 0x10))
    c.vgrad(0, 0, 360, 400, (0x14, 0x1A, 0x12), (0x1E, 0x26, 0x1A))
    fy = 400
    c.fill_rect(0, fy, 360, 640 - fy, (0x2A, 0x30, 0x24))
    for i in range(fy, 640, 14):
        c.fill_rect(0, i, 360, 1, (0x1C, 0x22, 0x18))
    # great sundial (finale puzzle)
    x, y, w, h = panel(c, (0.08, 0.16, 0.28, 0.36), (0x24, 0x2E, 0x22), BRASS)
    cx, cy = x + w / 2, y + h * 0.78
    for r in range(4):
        c.circle(cx, cy, w * (0.46 - 0.11 * r), PAPER, fill=False)
    c.line(cx, cy, cx + w * 0.2, cy - h * 0.85, AMBER, 5)
    c.circle(cx, cy, 6, AMBER)
    # bud specimen case (keypad puzzle)
    x, y, w, h = panel(c, (0.40, 0.14, 0.20, 0.26), (0x18, 0x24, 0x1C), BRASS)
    c.frame(x + 5, y + 5, w - 10, h - 10, GLASS, 2)
    c.circle(x + w / 2, y + h * 0.55, w * 0.2, LEAF)
    c.circle(x + w / 2, y + h * 0.42, w * 0.12, ORANGE)
    for i in range(3):
        c.fill_rect(x + w * 0.2, y + h * (0.3 + 0.12 * i), w * 0.6, 2, STEEL)
    # hummingbird specimen display (use_item)
    x, y, w, h = panel(c, (0.64, 0.18, 0.18, 0.24), (0x20, 0x18, 0x14), BRASS)
    c.frame(x + 4, y + 4, w - 8, h - 8, GLASS, 2)
    c.ellipse(x + w * 0.5, y + h * 0.45, w * 0.28, h * 0.2, AMBER)
    c.circle(x + w * 0.68, y + h * 0.32, w * 0.12, STEEL)
    c.line(x + w * 0.55, y + h * 0.5, x + w * 0.4, y + h * 0.3, STEEL, 2)
    # Vale's letter on the potting bench (discover clue)
    x, y, w, h = rect_of((0.40, 0.60, 0.12, 0.14))
    c.fill_rect(x, y, w, h, PAPER)
    c.fill_rect(x + 3, y + 3, w - 6, 2, CHAR)
    c.fill_rect(x + 3, y + 7, w - 10, 2, CHAR)
    c.fill_rect(x + 3, y + 11, w - 8, 2, CHAR)
    # orange trees (inspect)
    for tx, ty, s in [(0.78, 0.60, 46), (0.90, 0.55, 36)]:
        bx, by = tx * 360, ty * 640
        c.fill_rect(bx - 4, by, 8, s * 0.9, DARKWOOD)
        c.circle(bx, by - s * 0.15, s * 0.55, LEAF_D)
        c.circle(bx - s * 0.25, by - s * 0.35, s * 0.35, LEAF)
        for k in range(6):
            ox = bx + ((tx * 31 + k * 17) % 40) - 20
            oy = by - s * (0.5 + ((k * 13 + int(tx * 10)) % 30) / 100.0)
            c.circle(ox, oy, 3, ORANGE)
    # small fountain (inspect)
    x, y, w, h = rect_of((0.36, 0.60, 0.24, 0.22))
    c.ellipse(x + w / 2, y + h * 0.65, w * 0.46, h * 0.32, STEEL)
    c.ellipse(x + w / 2, y + h * 0.58, w * 0.34, h * 0.24, GLASS)
    c.line(x + w / 2, y + h * 0.15, x + w / 2, y + h * 0.6, STEEL, 4)
    # back door (left)
    panel(c, (0.02, 0.30, 0.06, 0.44), (0x2C, 0x24, 0x1E), STEEL)
    c.vignette()
    return c


def item_icon(name, glyph):
    c = Canvas(144, 144, (35, 38, 46, 255))
    c.frame(6, 6, 132, 132, BRASS, 4)
    if glyph == "ring":
        c.circle(72, 72, 34, BRASS, fill=False)
        c.circle(72, 72, 26, (0x3E, 0x6B, 0x46, 255), fill=False)
        c.circle(72, 52, 5, AMBER)
    elif glyph == "vial":
        c.fill_rect(62, 34, 20, 14, GLASS)
        c.frame(58, 30, 28, 22, BRASS, 2)
        c.fill_rect(66, 52, 12, 44, GLASS)
        c.fill_rect(68, 66, 8, 28, LEAF)
        c.circle(72, 88, 4, LEAF_D)
    elif glyph == "prism":
        c.circle(72, 72, 30, TEXT, fill=False)
        c.frame(38, 38, 68, 68, BRASS, 4)
        c.line(50, 40, 94, 40, GLASS, 3)
        c.line(50, 104, 94, 104, GLASS, 3)
    elif glyph == "shim":
        c.fill_rect(34, 58, 76, 28, STEEL)
        c.frame(34, 58, 76, 28, BRASS, 3)
        c.line(44, 66, 100, 66, CHAR, 1)
        c.line(44, 74, 100, 74, CHAR, 1)
    save_png(os.path.join(ROOT, "items", name + ".png"), 144, 144, c.px)


def seed_tray_scene():
    """Five seed pots; the answer is pot index 3 (4th from left)."""
    c = Canvas(480, 400, (0x24, 0x1E, 0x16, 255))
    # tray
    c.fill_rect(10, 100, 460, 220, DARKWOOD)
    c.frame(10, 100, 460, 220, BRASS, 3)
    for i in range(5):
        bx = 20 + i * 88
        c.fill_rect(bx, 130, 80, 170, (0x41, 0x33, 0x22))
        c.frame(bx, 130, 80, 170, (0x1E, 0x16, 0x0E), 2)
        # soil + sprout
        c.fill_rect(bx + 6, 250, 68, 44, (0x16, 0x12, 0x0C))
        for s in range(3):
            c.line(bx + 40, 250, bx + 30 + s * 10, 220 - s * 8, LEAF, 2)
        c.circle(bx + 40, 214 - 8, 4, LEAF)
        if i == 3:
            # the marked pot: brass shim wedged in the rim
            c.frame(bx - 2, 128, 84, 174, PAPER, 1)
            c.fill_rect(bx + 30, 128, 20, 8, STEEL)
            c.frame(bx + 30, 128, 20, 8, BRASS, 1)
    c.vignette()
    save_png(os.path.join(ROOT, "puzzles", "seed_tray.png"), 480, 400, c.px)


def conservatory_chart_scene():
    """Garden plan; three brass sigils at the authored region centers."""
    c = Canvas(480, 420, (0x0A, 0x12, 0x10, 255))
    # parchment plan
    c.fill_rect(30, 20, 420, 380, (0x1C, 0x2A, 0x24))
    c.frame(30, 20, 420, 380, BRASS, 3)
    # bed outlines
    for bx, by, bw, bh in [(60, 90, 130, 90), (230, 190, 130, 90),
                           (300, 300, 120, 70)]:
        c.frame(bx, by, bw, bh, LEAF_D, 2)
        for gx in range(bx + 8, bx + bw - 8, 14):
            c.fill_rect(gx, by + 6, 2, bh - 12, LEAF_D)
    # paths
    c.line(60, 300, 200, 200, PAPER, 2)
    c.line(200, 200, 360, 320, PAPER, 2)
    # three sigil markers at region centers (match puzzle JSON regions):
    # west_bed (0.25,0.35)->(120,147), fountain (0.55,0.55)->(264,231),
    # cold_frame (0.80,0.77)->(384,322)
    pts = [("bed", 120, 147), ("fountain", 264, 231), ("frame", 384, 322)]
    for name, x, y in pts:
        for _ in range(5):
            sx = x + ((x * 7 + y * 3) % 41) - 20
            sy = y + ((x * 5 + y * 11) % 37) - 18
            c.circle(sx, sy, 2, TEXT)
        c.circle(x, y, 20, BRASS, fill=False)
        if name == "bed":
            c.fill_rect(x - 6, y - 6, 12, 12, LEAF)   # sprout sigil
        elif name == "fountain":
            c.circle(x, y, 6, GLASS, fill=False)      # basin sigil
        else:
            c.fill_rect(x - 6, y - 6, 12, 12, AMBER)  # frame sigil
    c.vignette()
    save_png(os.path.join(ROOT, "puzzles", "conservatory_chart.png"),
             480, 420, c.px)


def main():
    rooms = {
        "room_conservatory.png": room_conservatory,
        "room_pump_room.png": room_pump_room,
        "room_orangery.png": room_orangery,
    }
    for name, fn in rooms.items():
        c = fn()
        save_png(os.path.join(ROOT, "rooms", name), 360, 640, c.px)
        print("rooms/%s" % name)
    for name, glyph in [("item_copper_ring", "ring"),
                        ("item_glass_vial", "vial"),
                        ("item_prismatic_lens", "prism"),
                        ("item_steel_shim", "shim")]:
        item_icon(name, glyph)
        print("items/%s.png" % name)
    seed_tray_scene()
    print("puzzles/seed_tray.png")
    conservatory_chart_scene()
    print("puzzles/conservatory_chart.png")


if __name__ == "__main__":
    main()
