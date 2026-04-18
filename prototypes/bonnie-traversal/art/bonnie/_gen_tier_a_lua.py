#!/usr/bin/env python3
"""Emit Lua table `TIER_A` — 32×16 strings per pose ( '.' = transparent ). """
from __future__ import annotations

W, H = 16, 32

EMPTY = "." * W


def ensure_grid(name: str, rows: list[str]) -> list[str]:
    """Pad or trim to H×W; warn on trim."""
    out: list[str] = []
    for i, row in enumerate(rows):
        if len(row) != W:
            raise ValueError(f"{name} row {i} width {len(row)} expected {W}: {row!r}")
        out.append(row)
    if len(out) < H:
        out.extend([EMPTY] * (H - len(out)))
    elif len(out) > H:
        out = out[:H]
    return out


# Chars -> will become Lua color keys in importer
# . transparent, K black outline, d dark fur, m mid fur, F face, E eye, n nose
# s cyan speed, x dust, v wall grey, z squeeze flat, * dazed star, y recover

def lines_to_lua(name: str, rows: list[str]) -> str:
    rows = ensure_grid(name, rows)
    assert len(rows) == H and all(len(r) == W for r in rows), name
    parts = [f'  {{ name = "{name}", rows = {{']
    for row in rows:
        parts.append(f'    "{row}",')
    parts.append("  } },")
    return "\n".join(parts)


# --- Shared head (facing right) top rows reused in several poses ---
def head_front() -> list[str]:
    return [
        "................",
        "................",
        "................",
        "................",
        "...#.#...#.#....",
        "...#F#..#F#.....",
        "..#FFF##FFF#....",
        "..#FFFFFFFF#....",
        "..#FFEEEEFF#....",
        "..#FFFnFFFF#....",
        "..#FFFFFFFF#....",
    ]


def sneak_a() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",  # compact torso
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "...#mmmmmm#.....",  # slight crouch taper
        "...#mmmmmm#.....",
        "....#mmmm#......",
        "....#mmmm#......",
        ".....#mm#.......",
        ".....#mm#.......",
        "......##........",
        "......####......",  # feet row 30 (0-based)
        "......F##F......",  # feet row 31 — capsule baseline
    ]
    return r


def sneak_b() -> list[str]:
    r = sneak_a()
    # nudge ears / body 1px for loop
    out = []
    for i, row in enumerate(r):
        if 23 <= i <= 28:
            out.append("." + row[:15])
        else:
            out.append(row)
    return out


def run_a() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        ".##mmmmmmmm##...",
        "ssssmmmmmmmmssss",  # speed lines through lower body
        "ssssmmmmmmmmssss",
        "....mmmmmmmm....",
        "....F######F....",
        "................",
    ]
    return r


def run_b() -> list[str]:
    r = run_a()
    out = []
    for i, row in enumerate(r):
        if i in (28, 29):
            out.append(row.replace("ssss", "ssss", 1))  # keep
        elif i == 30:
            out.append("...F########F...")
        else:
            out.append(row)
    return out


def double_jump() -> list[str]:
    r = [
        "................",
        "................",
        "................",
        "................",
        "....#.#...#.#...",  # torso rotated feel
        "....#F#..#F#....",
        "...#FFF##FFF#...",
        "...#FFFFFFFF#...",
        "...#FEEEEEEFF#..",
        "...#FFFnFFFF#...",
        "...#FFFFFFFF#...",
        "..#mmmmmmmmmm#..",
        "..#mmmmmmmmmm#..",
        ".#mmmmmmmmmmmm#.",
        ".#mmmmmmmmmmmm#.",
        "..mmmmmmmmmmmm..",
        "...mmmmmmmmmm...",
        "....mmmmmmmm....",
        ".....mmmmmm.....",
        "......mmmm......",
        ".......mm.......",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    return r


def land_skid_soft() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        ".##mmmmmmmm#....",  # lean back
        "###mmmmmmmm#....",
        "xx#mmmmmmmm#....",  # dust
        "xxxF######Fxx...",  # feet + dust
        "................",
    ]
    return r


def land_skid_hard() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        ".##mmmmmmmm#....",
        "###mmmmmmmm##...",
        "xx##mmmmmm##xx..",
        "xxxxF####Fxxxx..",
        "................",
    ]
    return r


def slide_a() -> list[str]:
    return [
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "ssssssssssssssss",  # speed
        "KKKKKKKKKKKKKKKK",  # flat slide silhouette
        "FFFFFFFFFFFFFFFF",  # underbelly / rim
    ]


def slide_b() -> list[str]:
    r = slide_a()
    out = list(r)
    out[30] = "ssssssssssssssss"
    out[31] = "FFFFFFFFFFFFFFFF"
    return out


def climb_idle() -> list[str]:
    return [
        "................",
        "................",
        "................",
        "................",
        "..........#.#...",  # wall on right
        "..........#F#...",
        ".........#FFF#..",
        ".........#FFF#..",
        ".........#FEEF#.",
        ".........#FnF#..",
        ".........#FFF#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........#mmm#..",
        ".........vvvv#..",
        ".........vvvv#..",
        ".........F####F.",
    ]


def climb_up() -> list[str]:
    r = climb_idle()
    out = []
    for i, row in enumerate(r):
        if 11 <= i <= 22:
            out.append(row[:8] + ".#mmm#..")
        else:
            out.append(row)
    return out


def ledge_cling() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "...#mmmmmm#.....",  # legs dangling
        "....#mmmm#......",
        "....#mmmm#......",
        ".....#mm#.......",
        ".....#mm#.......",
        "......##........",
        "......##........",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    return r


def ledge_pull() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "...#mmmmmm#.....",
        "....#mmmm#......",
        ".....#mm#.......",
        "......##........",
        "......F##F......",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]
    return r


def wall_jump() -> list[str]:
    return [
        "................",
        "................",
        "................",
        "................",
        "..........#.#...",
        "..........#F#...",
        ".........#FFF#..",
        ".........#FFF#..",
        ".........#FEEF#.",
        ".........#FnF#..",
        ".........#FFF#..",
        "........#mmmmm#.",
        ".......#mmmmmmm#",
        "......#mmmmmmmmm",
        ".....#mmmmmmmmm.",
        "....#mmmmmmmmm..",
        "...#mmmmmmmmm...",
        "..#mmmmmmmmm....",
        ".#mmmmmmmmm.....",
        "#mmmmmmmmm......",
        "ssssssssssssssss",  # push streak
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
    ]


def squeeze_a() -> list[str]:
    r = ["."] * H
    for i in range(H):
        r[i] = "................"
    # flat cat 8px tall at bottom — matches crawl read
    r[22] = "....KKKKKKKK...."
    r[23] = "...KmmmmmmmmK..."
    r[24] = "...KmmmmmmmmK..."
    r[25] = "...KFFEEEEFFK..."
    r[26] = "...KFFFnFFFFK..."
    r[27] = "...KFFFFFFFFK..."
    r[28] = "...KmmmmmmmmK..."
    r[29] = "....KKKKKKKK...."
    r[30] = "......F##F......"
    r[31] = "................"
    return r


def squeeze_b() -> list[str]:
    r = squeeze_a()
    out = []
    for i, row in enumerate(r):
        if i in (25, 26, 27):
            out.append("...." + row[4:12] + "....")
        else:
            out.append(row)
    return out


def dazed() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "*...*...*...*...",  # stars
        ".*.*.*.*.*.*.*..",
        "...*...*...*....",
        "................",
        "......####......",
        "......F##F......",
        "................",
    ]
    return r


def rough_flat() -> list[str]:
    r = ["."] * H
    for i in range(H):
        r[i] = "................"
    r[28] = "...KKKKKKKKKK..."
    r[29] = "..KmmmmmmmmmmK.."
    r[30] = "..KFFFFFFFFFFK.."
    r[31] = "...KKKKKKKKKK..."
    return r


def rough_recover() -> list[str]:
    r = head_front()
    r += [
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "..#mmmmmmmm#....",
        "....y......y....",  # recovery spark
        "...y........y...",
        "................",
        "................",
        "......####......",
        "......F##F......",
        "................",
    ]
    return r


POSES = [
    ("sneak_a", sneak_a()),
    ("sneak_b", sneak_b()),
    ("run_a", run_a()),
    ("run_b", run_b()),
    ("double_jump", double_jump()),
    ("land_skid_soft", land_skid_soft()),
    ("land_skid_hard", land_skid_hard()),
    ("slide_a", slide_a()),
    ("slide_b", slide_b()),
    ("climb_idle", climb_idle()),
    ("climb_up", climb_up()),
    ("ledge_cling", ledge_cling()),
    ("ledge_pull", ledge_pull()),
    ("wall_jump", wall_jump()),
    ("squeeze_a", squeeze_a()),
    ("squeeze_b", squeeze_b()),
    ("dazed", dazed()),
    ("rough_flat", rough_flat()),
    ("rough_recover", rough_recover()),
]


def main() -> None:
    lines = [
        "-- Auto-generated by _gen_tier_a_lua.py — do not hand-edit grids.",
        "return {",
    ]
    for name, grid in POSES:
        lines.append(lines_to_lua(name, grid))
    lines.append("}")
    out = "/Users/michaelraftery/AI-STUDIO-101/prototypes/bonnie-traversal/art/bonnie/_tier_a_grids.lua"
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("wrote", out, "poses", len(POSES))


if __name__ == "__main__":
    main()
