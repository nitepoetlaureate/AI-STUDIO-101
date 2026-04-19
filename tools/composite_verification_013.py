#!/usr/bin/env python3
"""
Session 013: build five 720×540 verification PNGs from real export art (PIL composite).
Used when Godot headless cannot read ViewportTexture (dummy GL). Run:

  python3 tools/composite_verification_013.py
"""

from __future__ import annotations

from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError as e:
    raise SystemExit("PIL required: pip install pillow") from e

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "prototypes/bonnie-traversal/art/_critique/verification-013"
ART = ROOT / "prototypes/bonnie-traversal/art/export"


def load_rgba(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    return im


def scale_nearest(im: Image.Image, w: int, h: int) -> Image.Image:
    return im.resize((w, h), Image.Resampling.NEAREST)


def tile_strip(im: Image.Image, tw: int, th: int, out_w: int) -> Image.Image:
    """Repeat first tw×th cell horizontally."""
    cell = im.crop((0, 0, tw, th))
    tiles = (out_w + tw - 1) // tw
    strip = Image.new("RGBA", (tiles * tw, th), (0, 0, 0, 0))
    for i in range(tiles):
        strip.paste(cell, (i * tw, 0))
    if strip.width > out_w:
        strip = strip.crop((0, 0, out_w, th))
    return strip


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    parallax = load_rgba(ART / "env" / "env-parallax-apartment-backdrop-v01.png")
    ground = load_rgba(ART / "env" / "env-tile-ground-01.png")
    bonnie_sheet = load_rgba(ART / "bonnie" / "bonnie-locomotion-sheet.png")
    michael_sheet = load_rgba(ART / "npc" / "michael-idle-sheet.png")
    christen_sheet = load_rgba(ART / "npc" / "christen-idle-sheet.png")

    W, H = 720, 540
    # Parallax: cover width, keep pixel look
    bg = scale_nearest(parallax, W, int(parallax.height * W / parallax.width))
    if bg.height < H:
        bg2 = Image.new("RGBA", (W, H), (18, 20, 24, 255))
        bg2.paste(bg, (0, (H - bg.height) // 2))
        bg = bg2
    else:
        bg = bg.crop((0, 0, W, H))

    floor_y = 420
    floor_h = 96
    floor_strip = tile_strip(ground, 16, 16, W)
    floor_strip = scale_nearest(floor_strip, W, floor_h)

    # Bonnie cels 16×32 from strip
    def bonnie_cel(idx: int) -> Image.Image:
        return bonnie_sheet.crop((idx * 16, 0, idx * 16 + 16, 32))

    def npc_idle_frame(sheet: Image.Image, frame: int) -> Image.Image:
        return sheet.crop((frame * 16, 0, frame * 16 + 16, 32))

    shots = [
        ("01_idle_floor.png", 0, (120, floor_y - 32), "Idle on floor", None, None),
        ("02_run_moving.png", 6, (280, floor_y - 32), "Run clip (strip cel 6)", None, None),
        ("03_jump_rising.png", 11, (200, 300), "Jump up (cel 11)", None, None),
        (
            "04_near_npcs.png",
            0,
            (400, floor_y - 32),
            "Near NPC exports",
            (340, floor_y - 32),
            (460, floor_y - 32),
        ),
        ("05_semisolid_strip.png", 0, (360, floor_y - 48), "Lower Y (semisolid row demo)", None, None),
    ]

    for fname, b_idx, (bx, by), caption, m_pos, c_pos in shots:
        canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        canvas.paste(bg, (0, 0), bg)
        canvas.paste(floor_strip, (0, floor_y), floor_strip)

        b = bonnie_cel(b_idx)
        canvas.paste(b, (bx, by), b)

        if m_pos:
            m = npc_idle_frame(michael_sheet, 0)
            canvas.paste(m, m_pos, m)
        if c_pos:
            c = npc_idle_frame(christen_sheet, 0)
            canvas.paste(c, c_pos, c)

        draw = ImageDraw.Draw(canvas)
        draw.rectangle([8, 8, W - 8, 44], fill=(0, 0, 0, 160))
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", 18)
        except OSError:
            font = ImageFont.load_default()
        draw.text((16, 14), caption + "  (composite from export PNGs)", fill=(240, 235, 228, 255), font=font)

        out_path = OUT / fname
        canvas.convert("RGB").save(out_path, "PNG", optimize=True)
        print("wrote", out_path.relative_to(ROOT))


if __name__ == "__main__":
    main()
