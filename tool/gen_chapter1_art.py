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

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "art")

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


def rect_of(b):
    # b: normalized (x, y, w, h) on 360x640
    W, H = 360, 640
    return b[0] * W, b[1] * H, b[2] * W, b[3] * H


def scene_base(canvas_t=0.62):
    c = Canvas(360, 640, INK)
    c.vgrad(0, 0, 360, int(640 * canvas_t), INK, NAVY2)
    fy = int(640 * canvas_t)
    c.fill_rect(0, fy, 360, 640 - fy, MIDWOOD)
    for i in range(fy, 640, 12):
        c.fill_rect(0, i, 360, 1, (0x30, 0x25, 0x1C))
    return c


def panel(c, b, fill=CHAR, edge=BRASS):
    x, y, w, h = rect_of(b)
    c.fill_rect(x, y, w, h, fill)
    c.frame(x, y, w, h, edge, 2)
    return x, y, w, h


def room_entrance():
    c = scene_base()
    # grandfather clock, stopped 10:24
    x, y, w, h = panel(c, (0.06, 0.14, 0.20, 0.52), DARKWOOD, BRASS)
    c.clock_face(x + w / 2, y + h * 0.18, w * 0.36, 312, 144)
    c.fill_rect(x + w * 0.42, y + h * 0.45, w * 0.16, h * 0.4, CHAR)
    # study door with keypad panel
    x, y, w, h = panel(c, (0.52, 0.18, 0.26, 0.62), (0x33, 0x27, 0x1C), BRASS)
    c.frame(x + w * 0.15, y + h * 0.08, w * 0.7, h * 0.35, TEXT, 1)
    c.fill_rect(x + w * 0.02, y + h * 0.5, 10, 14, STEEL)
    # keypad box beside door
    kx, ky, kw, kh = panel(c, (0.44, 0.42, 0.07, 0.12), CHAR, STEEL)
    for r in range(3):
        for col in range(2):
            c.circle(kx + kw * (0.3 + 0.4 * col), ky + kh * (0.22 + 0.28 * r),
                     3, BRASS)
    # carved marks band (moon, star, sun)
    x, y, w, h = panel(c, (0.40, 0.30, 0.12, 0.10), INK, BRASS)
    c.circle(x + w * 0.2, y + h * 0.5, 4, TEXT, fill=False)  # moon crescent
    c.circle(x + w * 0.2 + 2, y + h * 0.45, 4, INK)
    sx, sy = x + w * 0.5, y + h * 0.5  # star
    for i in range(5):
        a1 = math.radians(-90 + i * 72)
        a2 = math.radians(-90 + i * 72 + 72)
        c.line(sx + 5 * math.cos(a1), sy + 5 * math.sin(a1),
               sx + 5 * math.cos(a2), sy + 5 * math.sin(a2), TEXT, 1)
    c.circle(x + w * 0.8, y + h * 0.5, 4, AMBER)  # sun
    # doormat
    x, y, w, h = panel(c, (0.46, 0.72, 0.22, 0.14), (0x4A, 0x3A, 0x28), BRASS)
    for i in range(4):
        c.fill_rect(x + 3, y + 4 + i * (h / 4), w - 6, 2, TEXT)
    # sconce panel (3 sconces, dark)
    x, y, w, h = panel(c, (0.14, 0.34, 0.18, 0.34), CHAR, BRASS)
    for i in range(3):
        cx = x + w * (0.2 + 0.3 * i)
        cyy = y + h * 0.4
        c.fill_rect(cx - 2, cyy, 4, h * 0.3, BRASS)
        c.circle(cx, cyy - 3, 4, STEEL)
    # faded painting
    x, y, w, h = panel(c, (0.30, 0.20, 0.16, 0.24), (0x30, 0x2A, 0x38), BRASS)
    c.line(x + 4, y + h - 6, x + w - 4, y + h - 6, STEEL, 2)
    # tall window, cold light
    x, y, w, h = panel(c, (0.78, 0.10, 0.16, 0.50), (0x2E, 0x3A, 0x54))
    c.frame(x, y, w, h, BRASS, 3)
    c.line(x + w / 2, y, x + w / 2, y + h, BRASS, 2)
    c.line(x, y + h / 2, x + w, y + h / 2, BRASS, 2)
    c.vignette()
    return c


def room_study():
    c = scene_base()
    # bookshelf with three visible spine years as bands
    x, y, w, h = panel(c, (0.58, 0.16, 0.32, 0.48), DARKWOOD, BRASS)
    for shelf in range(3):
        sy = y + h * (0.12 + 0.3 * shelf)
        c.fill_rect(x + 4, sy, w - 8, 3, BRASS)
        for bi in range(9):
            bx = x + 8 + bi * (w - 16) / 9
            bh = h * (0.16 + 0.04 * ((bi * shelf) % 3))
            col = [MIDWOOD, (0x50, 0x2A, 0x28), (0x2A, 0x40, 0x50)][bi % 3]
            c.fill_rect(bx, sy - bh, (w - 16) / 9 - 2, bh, col)
    # regulator clock, stopped 03:47
    x, y, w, h = panel(c, (0.10, 0.30, 0.16, 0.42), (0x33, 0x27, 0x1C), BRASS)
    c.clock_face(x + w / 2, y + h * 0.25, w * 0.34, 103.5, 282)
    c.circle(x + w / 2, y + h * 0.6, w * 0.2, BRASS, fill=False)  # pendulum
    # certificate
    x, y, w, h = panel(c, (0.34, 0.18, 0.18, 0.22), PAPER, BRASS)
    for i in range(4):
        c.fill_rect(x + 4, y + 6 + i * (h / 5), w - 8, 2, CHAR)
    # strongbox
    x, y, w, h = panel(c, (0.74, 0.52, 0.18, 0.30), STEEL, BRASS)
    c.circle(x + w / 2, y + h / 2, min(w, h) * 0.3, CHAR, fill=False)
    c.line(x + w / 2, y + h / 2, x + w * 0.75, y + h * 0.35, BRASS, 3)
    # astrolabe: rings
    x, y, w, h = panel(c, (0.36, 0.48, 0.16, 0.24), INK, BRASS)
    for i in range(4):
        c.circle(x + w / 2, y + h / 2, w * (0.45 - 0.1 * i), BRASS, fill=False)
    c.circle(x + w / 2, y + h * 0.08, 3, AMBER)
    # globe with red meridian
    x, y, w, h = panel(c, (0.52, 0.55, 0.20, 0.30), (0x2A, 0x20, 0x1A))
    gx, gy, gr = x + w / 2, y + h * 0.4, min(w, h) * 0.36
    c.circle(gx, gy, gr, NAVY2)
    c.circle(gx, gy, gr, BRASS, fill=False)
    c.line(gx, gy - gr, gx + gr * 0.5, gy + gr, RED, 3)  # meridian mark
    c.line(x + w - 3, gy - gr, x + w - 3, y + h - 4, BRASS, 3)  # pointer post
    # desk
    x, y, w, h = panel(c, (0.20, 0.62, 0.30, 0.26), (0x3A, 0x2C, 0x20), BRASS)
    c.fill_rect(x + w * 0.1, y + h * 0.3, w * 0.35, h * 0.12, PAPER)
    c.fill_rect(x + w * 0.55, y + h * 0.35, w * 0.3, h * 0.1, CHAR)
    # workshop exit door (far right)
    panel(c, (0.86, 0.30, 0.12, 0.50), (0x33, 0x27, 0x1C), BRASS)
    # back door left
    panel(c, (0.02, 0.30, 0.06, 0.44), (0x2C, 0x24, 0x1E), STEEL)
    c.vignette()
    return c


def room_workshop():
    c = scene_base()
    # gear wall: three frozen rings A/B/C
    x, y, w, h = panel(c, (0.08, 0.18, 0.30, 0.45), INK, BRASS)
    c.gear(x + w * 0.3, y + h * 0.25, w * 0.18, 10, STEEL)
    c.gear(x + w * 0.62, y + h * 0.5, w * 0.16, 8, BRASS)
    c.gear(x + w * 0.35, y + h * 0.75, w * 0.14, 12, STEEL)
    for gx, gy in [(0.3, 0.25), (0.62, 0.5), (0.35, 0.75)]:
        c.line(x + w * gx, y + h * gy - 4, x + w * gx, y + h * gy - 14,
               RED, 3)  # marked tooth
    c.line(x + w * 0.5, y - 2, x + w * 0.5, y + 8, TEXT, 2)  # top pointer
    # wall clock, stopped 06:58 (dark until powered)
    x, y, w, h = panel(c, (0.55, 0.15, 0.14, 0.24), CHAR, BRASS)
    c.clock_face(x + w / 2, y + h * 0.35, w * 0.38, 209, 348)
    # blueprint (paper with diagrams)
    x, y, w, h = panel(c, (0.55, 0.45, 0.22, 0.28), (0x2E, 0x40, 0x56), TEXT)
    c.frame(x + 4, y + 4, w - 8, h - 8, (0x2E, 0x40, 0x56), 1)
    c.line(x + 8, y + h - 10, x + w * 0.4, y + h - 10, TEXT, 1)  # vent diag
    for i in range(4):
        c.fill_rect(x + 8 + i * 8, y + h - 18 - (i % 2) * 6, 3, 8, TEXT)
    c.circle(x + w * 0.75, y + h * 0.3, w * 0.12, TEXT, fill=False)  # teeth
    # lever board: 4 levers, all down
    x, y, w, h = panel(c, (0.30, 0.55, 0.22, 0.30), DARKWOOD, BRASS)
    for i in range(4):
        lx = x + w * (0.15 + 0.22 * i)
        c.fill_rect(lx - 2, y + h * 0.55, 4, h * 0.3, STEEL)
        c.circle(lx, y + h * 0.55, 5, BRASS)
    # parts cabinet
    x, y, w, h = panel(c, (0.80, 0.45, 0.16, 0.35), (0x33, 0x27, 0x1C), BRASS)
    c.frame(x + 3, y + 3, w - 6, h * 0.4, STEEL, 2)
    c.circle(x + w / 2, y + h * 0.6, w * 0.2, STEEL, fill=False)
    # floorboards strip (one loose, 2nd from left)
    fx, fy, fw, fh = rect_of((0.06, 0.80, 0.84, 0.12))
    c.fill_rect(fx, fy, fw, fh, DARKWOOD)
    for i in range(5):
        bx = fx + i * fw / 5
        col = (0x4A, 0x38, 0x26) if i != 1 else (0x5C, 0x48, 0x30)
        c.fill_rect(bx + 1, fy + 1, fw / 5 - 3, fh - 2, col)
        if i == 1:
            c.frame(bx + 1, fy + 1, fw / 5 - 3, fh - 2, PAPER, 1)
    # crane arm + marked crate
    x, y, w, h = panel(c, (0.08, 0.60, 0.24, 0.32), (0x2A, 0x24, 0x1E))
    c.line(x + 4, y + 6, x + w - 6, y + h * 0.4, BRASS, 4)
    c.circle(x + 4, y + 6, 5, STEEL)
    c.line(x + w - 6, y + h * 0.4, x + w - 6, y + h * 0.7, TEXT, 1)  # hook
    cx, cy, cw, ch = rect_of((0.24, 0.74, 0.10, 0.10))
    c.fill_rect(cx, cy, cw, ch, MIDWOOD)
    c.frame(cx, cy, cw, ch, TEXT, 1)
    c.line(cx + 2, cy + 2, cx + cw - 2, cy + ch - 2, RED, 2)
    c.line(cx + cw - 2, cy + 2, cx + 2, cy + ch - 2, RED, 2)
    # gallery exit
    panel(c, (0.86, 0.28, 0.12, 0.52), (0x33, 0x27, 0x1C), BRASS)
    panel(c, (0.02, 0.28, 0.05, 0.40), (0x2C, 0x24, 0x1E), STEEL)
    c.vignette()
    return c


def room_gallery():
    c = scene_base(0.58)
    # four medallion spots
    x, y, w, h = rect_of((0.10, 0.20, 0.34, 0.40))
    c.fill_rect(x, y, w, h, (0x2A, 0x22, 0x30))
    for i in range(4):
        mx = x + w * (0.13 + 0.24 * i)
        c.circle(mx, y + h * 0.4, w * 0.09, STEEL, fill=False)
        c.fill_rect(mx - w * 0.05, y + h * 0.62, w * 0.1, 4, BRASS)  # plaque
    # central portrait (closed case)
    x, y, w, h = panel(c, (0.50, 0.22, 0.16, 0.36), (0x30, 0x28, 0x38), BRASS)
    c.frame(x + 5, y + 5, w - 10, h - 10, AMBER, 1)
    c.circle(x + w / 2, y + h * 0.4, w * 0.2, TEXT, fill=False)
    # three empty frames
    x, y, w, h = rect_of((0.72, 0.18, 0.24, 0.38))
    c.fill_rect(x, y, w, h, (0x2A, 0x22, 0x30))
    for i in range(3):
        fx = x + w * (0.02 + 0.33 * i)
        c.frame(fx, y + h * 0.15, w * 0.28, h * 0.7, BRASS, 3)
        c.fill_rect(fx + 3, y + h * 0.15 + 3, w * 0.28 - 6, h * 0.7 - 6, INK)
    # letter on table
    x, y, w, h = panel(c, (0.70, 0.60, 0.12, 0.16), MIDWOOD)
    c.fill_rect(x + w * 0.15, y - 4, w * 0.7, h * 0.3, PAPER)
    # moon dial
    x, y, w, h = panel(c, (0.36, 0.55, 0.18, 0.30), INK, BRASS)
    for i in range(4):
        px_ = x + w * (0.2 + 0.2 * i)
        c.circle(px_, y + h * 0.3, w * 0.1,
                 TEXT if i == 0 else STEEL, fill=False)
    # reliquary
    x, y, w, h = panel(c, (0.86, 0.42, 0.12, 0.30), DARKWOOD, BRASS)
    c.frame(x + 3, y + 3, w - 6, h - 6, AMBER, 1)
    c.line(x + w / 2, y + 6, x + w / 2, y + h - 6, AMBER, 1)
    # chronometer
    x, y, w, h = panel(c, (0.58, 0.12, 0.12, 0.20), CHAR, BRASS)
    c.clock_face(x + w / 2, y + h * 0.4, w * 0.34, 247.5, 90)
    # observatory door
    panel(c, (0.06, 0.28, 0.12, 0.50), (0x33, 0x27, 0x1C), BRASS)
    panel(c, (0.02, 0.32, 0.03, 0.36), (0x2C, 0x24, 0x1E), STEEL)
    # floor runner
    c.fill_rect(40, 560, 300, 40, (0x3A, 0x26, 0x28))
    c.vignette()
    return c


def room_observatory():
    c = Canvas(360, 640, (0x0C, 0x10, 0x20))
    # dome gradient + stars field on dome
    c.vgrad(0, 0, 360, 400, (0x0A, 0x0E, 0x1E), NAVY2)
    import random
    rnd = random.Random(1892)
    for _ in range(240):
        x, y = rnd.randrange(360), rnd.randrange(380)
        s = 1 if rnd.random() < 0.8 else 2
        c.fill_rect(x, y, s, s, TEXT)
    # circled star (telescope target, upper-left-ish at 150 deg line later)
    c.circle(120, 150, 3, AMBER)
    for a in range(0, 360, 45):
        t = math.radians(a)
        c.line(120 + 5 * math.cos(t), 150 + 5 * math.sin(t),
               120 + 8 * math.cos(t), 150 + 8 * math.sin(t), AMBER, 1)
    c.circle(120, 150, 14, RED, fill=False)  # Vale's ink circle
    # floor
    c.fill_rect(0, 400, 360, 240, MIDWOOD)
    for i in range(404, 640, 14):
        c.fill_rect(0, i, 360, 1, (0x30, 0x25, 0x1C))
    # star chart projector panel
    panel(c, (0.30, 0.15, 0.40, 0.30), (0x11, 0x16, 0x28), BRASS)
    # orrery base + rings
    x, y, w, h = panel(c, (0.12, 0.45, 0.30, 0.35), CHAR, BRASS)
    for i in range(3):
        c.circle(x + w / 2, y + h / 2, w * (0.4 - 0.11 * i), BRASS,
                 fill=False)
    c.circle(x + w / 2, y + h / 2, 5, AMBER)
    # telescope
    x, y, w, h = panel(c, (0.62, 0.35, 0.26, 0.45), (0x2A, 0x24, 0x1E))
    c.line(x + w * 0.2, y + h * 0.75, x + w * 0.85, y + h * 0.2, STEEL, 10)
    c.line(x + w * 0.2, y + h * 0.75, x + w * 0.85, y + h * 0.2, BRASS, 4)
    c.circle(x + w * 0.85, y + h * 0.2, 8, BRASS)
    c.fill_rect(x + w * 0.45, y + h * 0.6, 6, h * 0.35, STEEL)
    # sealed exit door
    x, y, w, h = panel(c, (0.86, 0.30, 0.12, 0.48), (0x33, 0x27, 0x1C), BRASS)
    c.frame(x + 3, y + 3, w - 6, h - 6, RED, 1)
    panel(c, (0.02, 0.34, 0.03, 0.34), (0x2C, 0x24, 0x1E), STEEL)
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
        if loose:
            c.frame(bx - 2, 118, 84, 184, PAPER, 1)  # dust-free gap
        for gy in range(140, 300, 26):
            c.fill_rect(bx + 6, gy, 68, 1, (0x1E, 0x16, 0x0E))
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
