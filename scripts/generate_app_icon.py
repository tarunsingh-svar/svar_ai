#!/usr/bin/env python3
"""Render assets/icons/svar_mark.svg to assets/icon/app_icon.png (1024×1024).

Requires Pillow. After running, regenerate platform icons:

    dart run flutter_launcher_icons
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/icon/app_icon.png"
SIZE = 1024
SCALE = SIZE / 272

# Bar geometry from svar_mark.svg (x, y, width, height, corner radius).
BARS = [
    (68.350, 96.000, 5.3, 15.000, 2.650),
    (68.350, 169.000, 5.3, 11.000, 2.650),
    (79.350, 89.000, 5.3, 33.000, 2.650),
    (79.350, 163.000, 5.3, 24.000, 2.650),
    (90.350, 76.000, 5.3, 58.000, 2.650),
    (90.350, 169.000, 5.3, 30.000, 2.650),
    (100.850, 67.000, 5.3, 74.000, 2.650),
    (100.850, 163.000, 5.3, 42.000, 2.650),
    (111.350, 61.000, 5.3, 84.000, 2.650),
    (111.350, 173.000, 5.3, 37.000, 2.650),
    (122.350, 55.000, 5.3, 31.000, 2.650),
    (122.350, 112.000, 5.3, 38.000, 2.650),
    (122.350, 185.000, 5.3, 31.000, 2.650),
    (132.850, 48.000, 5.3, 35.000, 2.650),
    (132.850, 116.000, 5.3, 39.000, 2.650),
    (132.850, 188.000, 5.3, 35.000, 2.650),
    (143.350, 55.000, 5.3, 31.000, 2.650),
    (143.350, 121.000, 5.3, 38.000, 2.650),
    (143.350, 185.000, 5.3, 31.000, 2.650),
    (154.350, 61.000, 5.3, 37.000, 2.650),
    (154.350, 126.000, 5.3, 84.000, 2.650),
    (165.350, 66.000, 5.3, 42.000, 2.650),
    (165.350, 130.000, 5.3, 75.000, 2.650),
    (175.350, 72.000, 5.3, 30.000, 2.650),
    (175.350, 137.000, 5.3, 60.000, 2.650),
    (186.350, 84.000, 5.3, 24.000, 2.650),
    (186.350, 149.000, 5.3, 37.000, 2.650),
    (197.350, 92.000, 5.3, 11.000, 2.650),
    (197.350, 160.000, 5.3, 17.000, 2.650),
]


def s(value: float) -> float:
    return value * SCALE


def main() -> None:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    radius = s(92.48)
    max_r = math.hypot(SIZE / 2, SIZE / 2)

    # Radial gradient from svar_mark.svg (#3B82F6 → #2563EB → #1D4ED8).
    for y in range(SIZE):
        gx = SIZE * 0.425
        gy = SIZE * 0.40
        for x in range(SIZE):
            d = min(max(math.hypot(x - gx, y - gy) / (max_r * 1.05), 0), 1)
            if d <= 0.55:
                t = d / 0.55
                r = int(59 + (37 - 59) * t)
                g = int(130 + (99 - 130) * t)
                b = int(246 + (235 - 246) * t)
            else:
                t = (d - 0.55) / 0.45
                r = int(37 + (29 - 37) * t)
                g = int(99 + (77 - 99) * t)
                b = int(235 + (216 - 235) * t)
            img.putpixel((x, y), (r, g, b, 255))

    mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, SIZE - 1, SIZE - 1], radius=int(radius), fill=255
    )
    img.putalpha(mask)

    bar_draw = ImageDraw.Draw(img)
    for x, y, w, h, rx in BARS:
        bar_draw.rounded_rectangle(
            [s(x), s(y), s(x + w), s(y + h)],
            radius=s(rx),
            fill=(255, 255, 255, 255),
        )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
