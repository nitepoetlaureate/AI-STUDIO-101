# Import Godot — Bonnie Traversal (art export **v2**)

Handoff for integrators: canonical **`res://`** paths, **frame counts**, Aseprite JSON mapping, and Godot import defaults. Source art lives under `prototypes/bonnie-traversal/art/export/`; this document matches the **v2** export set on disk (filenames may still carry **`-v01`** tokens on atlas / parallax only).

---

## 1. Canonical `res://` root

Use **one** tree for runtime textures (do not duplicate into a second `assets/` folder without producer sign-off):

| Role | Path |
|------|------|
| **Prototype export root** | `res://prototypes/bonnie-traversal/art/export/` |
| Bonnie sprites | `res://prototypes/bonnie-traversal/art/export/bonnie/` |
| Environment sprites | `res://prototypes/bonnie-traversal/art/export/env/` |
| Shared palette | `res://prototypes/bonnie-traversal/art/export/palette-traversal-v01.gpl` |

**Version tokens:** `-v01` on `env-tileset-apartment-atlas-v01.png` and `env-parallax-apartment-backdrop-v01.png` marks replaceable sources. On an art bump to **v03**, rename files, re-import, and update TileSet / parallax `Texture2D` references in scenes. Bonnie locomotion JSON keys still reference the Aseprite doc name `bonnie-locomotion-v01` (metadata only; see §4).

---

## 2. Texture import policy (project + nodes)

- **Project default:** `project.godot` → `[rendering]` → `textures/canvas_textures/default_texture_filter=0` (**Nearest**). Keeps new imports pixel-crisp without per-node setup.
- **Mipmaps:** leave **off** on these PNGs (2D pixel art).
- **Per-node override:** if a subtree needs linear filtering, set only those `CanvasItem` nodes to `texture_filter = Inherit` / `Linear` in the inspector.

`BonnieController.tscn` still uses a `ColorRect` placeholder; swapping in `AnimatedSprite2D` / `Sprite2D` inherits the project default unless overridden.

---

## 3. Bonnie — loose PNGs (v2 inventory)

All **16×32** unless noted. Use for **per-frame** `AtlasTexture` / `ImageTexture` workflows or reference for sheet alignment.

| `res://` path | Frames |
|---------------|--------|
| `.../bonnie/bonnie-idle-0001.png` … `0004.png` | **4** |
| `.../bonnie/bonnie-walk-0001.png` … `0007.png` | **7** |
| `.../bonnie/bonnie-jump-up-0001.png` | **1** |
| `.../bonnie/bonnie-jump-apex-0001.png` | **1** |
| `.../bonnie/bonnie-jump-down-0001.png` | **1** |

**Spritesheet (strip):** `bonnie-locomotion-sheet.png` — **224×32** (14 columns × **16×32** cels).

---

## 4. Bonnie — `bonnie-locomotion-sheet.json` (Aseprite hash)

**File:** `res://prototypes/bonnie-traversal/art/export/bonnie/bonnie-locomotion-sheet.json`  
**Image:** `bonnie-locomotion-sheet.png` (same folder).

### 4.1 Frame index → strip `region_rect` origin

Each cel is **16×32**. `region_rect.position.x = index * 16`, `y = 0`.

| Index | JSON `frames` key (Aseprite internal) | `frameTags` tag | Notes |
|------:|----------------------------------------|-----------------|-------|
| 0–3 | `bonnie-locomotion-v01 0.aseprite` … `3.aseprite` | **idle** | 4 frames |
| 4–10 | `… 4.aseprite` … `10.aseprite` | **walk** | 7 frames |
| 11 | `… 11.aseprite` | *(none)* | **Takeoff** — matches loose `bonnie-jump-up-0001.png`; add **`jump_up`** tag in Aseprite on next export to remove ambiguity |
| 12 | `… 12.aseprite` | **jump_apex** | 1 frame |
| 13 | `… 13.aseprite` | **jump_down** | 1 frame |

**Total strip cels:** **14**. Tag durations in JSON are **100 ms** per cel (Aseprite export default).

### 4.2 `SpriteFrames` naming (recommended)

Godot `SpriteFrames` animation names are arbitrary strings; align to JSON tags + explicit takeoff:

| Suggested `SpriteFrames` animation | Source |
|-----------------------------------|--------|
| `idle` | tags `idle` → cels 0–3 |
| `walk` | tags `walk` → cels 4–10 |
| `jump_up` | cel **11** only (until JSON tag exists) |
| `jump_apex` | tag `jump_apex` → cel 12 |
| `jump_down` | tag `jump_down` → cel 13 |

**Automation note:** do not key off raw `frames` dictionary string keys in tooling; use **numeric index** or `meta.frameTags` (`from` / `to`).

### 4.3 `BonnieController.gd` state → animation (integration stub)

The controller exposes **state enum** names (`IDLE`, `WALKING`, `JUMPING`, …) but **does not** drive a sprite yet. When wiring `AnimatedSprite2D`, map gameplay to clips roughly as follows (iterate with design on edge cases):

| `BonnieController.State` | Suggested first-pass animation |
|--------------------------|--------------------------------|
| `IDLE` | `idle` |
| `SNEAKING` | `walk` (slower `speed_scale`) or duplicate clip later |
| `WALKING`, `RUNNING`, `SLIDING`, `LANDING` | `walk` / speed variants |
| `JUMPING` | `jump_up` → `jump_apex` by velocity / timer |
| `FALLING` | `jump_down` |
| `CLIMBING`, `SQUEEZING`, `DAZED`, `ROUGH_LANDING`, `LEDGE_PULLUP` | reuse nearest readable clip until Tier-B art exists |

---

## 5. Environment — loose tiles (v2 inventory)

Paths under `res://prototypes/bonnie-traversal/art/export/env/`. Sizes measured from exported PNGs.

| File | Size (px) |
|------|-----------|
| `env-tile-ground-01.png` | 16×16 |
| `env-tile-floor-kitchen-01.png` | 16×16 |
| `env-tile-platform-top-01.png` | 16×16 |
| `env-tile-platform-edge-01.png` | 16×16 |
| `env-tile-baseboard-01.png` | 16×16 |
| `env-tile-wall-kitchen-01.png` | 16×16 |
| `env-tile-wall-studio-01.png` | 16×16 |
| `env-tile-climbable-01.png` | 16×16 |
| `env-tile-climbable-tall-01.png` | **32×32** |
| `env-tile-smooth-01.png` | 16×16 |
| `env-tile-smooth-tall-01.png` | **32×32** |
| `env-tile-soft-landing-01.png` | 16×16 |
| `env-tile-squeeze-ceiling-01.png` | **32×16** |
| `env-tile-end-wall-01.png` | **32×16** |
| `env-prop-rigid-crate-01.png` | **20×20** |
| `env-tileset-apartment-atlas-v01.png` | **256×112** (TileSet atlas source) |
| `env-parallax-apartment-backdrop-v01.png` | **320×180** |

**TileSet:** prefer **single atlas texture** + manual tile regions in the Godot 4 TileSet editor, **or** individual textures per tile — pick one pipeline per layer and stay consistent. Non–power-of-two atlas height (**112**) is valid for 2D; no special Godot workaround beyond normal slicing.

**Parallax:** one full-bleed backdrop; place in a `Parallax2D` / `ParallaxLayer` with motion scale \< 1 so gameplay tiles stay primary.

---

## 6. `TestLevel.tscn` integration (current)

Greybox **ColorRect** fills still reference no textures. Replace per `StaticBody2D` child with `Sprite2D` / `TileMapLayer` using the paths above; keep collision sizes aligned with existing `RectangleShape2D` definitions unless art + design change them together.

---

## 7. Checklist before playtest art gate

- [ ] All new `Sprite2D` / `AnimatedSprite2D` / TileSet layers use **`res://prototypes/bonnie-traversal/art/export/...`** paths.
- [ ] Confirm **nearest** filtering on character (`AnimatedSprite2D`) and world sprites.
- [ ] Bonnie `SpriteFrames` uses the **five** core clips (`idle`, `walk`, `jump_up`, `jump_apex`, `jump_down`) at minimum.
- [ ] After Aseprite re-export, confirm **frame 11** gains a **`jump_up`** tag in JSON and update tooling if it relied on index-only.

---

## Mycelium

After changing this file or the export set, attach a **summary** note on `prototypes/bonnie-traversal/IMPORT-GODOT.md` and a **context** note on `HEAD` so the next agent sees path/frame deltas without re-scanning PNGs.
