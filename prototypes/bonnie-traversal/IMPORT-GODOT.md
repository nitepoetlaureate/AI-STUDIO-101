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

- **Project default:** `project.godot` → `[rendering]` → `textures/canvas_textures/default_texture_filter=1` (`CanvasItem.TEXTURE_FILTER_NEAREST`). Required by `ViewportConfig` on boot. Keeps new imports pixel-crisp without per-node setup.
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

**Spritesheet (strip):** `bonnie-locomotion-sheet.png` — **528×32** (**33** cels × **16×32**). Authoritative numbers come from `meta.size` and `frames` in `bonnie-locomotion-sheet.json` (Aseprite 1.3.15 export).

---

## 4. Bonnie — `bonnie-locomotion-sheet.json` (Aseprite hash)

**File:** `res://prototypes/bonnie-traversal/art/export/bonnie/bonnie-locomotion-sheet.json`  
**Image:** `bonnie-locomotion-sheet.png` (same folder).

### 4.1 Frame index → strip `region_rect` origin

Each cel is **16×32**. `region_rect.position.x = index * 16`, `y = 0`. Indices **0–32** inclusive.

| Index | `frameTags` (from `meta.frameTags`) |
|------:|-------------------------------------|
| 0–3 | **idle** |
| 4–10 | **walk** |
| 11 | **jump_up** |
| 12 | **jump_apex** |
| 13 | **jump_down** |
| 14–15 | **sneak** |
| 16–17 | **run** |
| 18 | **double_jump** |
| 19–20 | **land_skid** |
| 21–22 | **slide** |
| 23–24 | **climb** |
| 25 | **ledge_cling** |
| 26 | **ledge_pull** |
| 27 | **wall_jump** |
| 28–29 | **squeeze** |
| 30 | **dazed** |
| 31–32 | **rough_landing** |

**Total strip cels:** **33**. Tag durations in JSON default to **100 ms** per cel unless changed in Aseprite.

### 4.2 `SpriteFrames` naming (recommended)

Use **one clip per `frameTags.name`** (snake_case in Godot to match export tags where useful):

| `SpriteFrames` animation | Source |
|--------------------------|--------|
| `idle` | `idle` |
| `walk` | `walk` |
| `jump_up` | `jump_up` |
| `jump_apex` | `jump_apex` |
| `jump_down` | `jump_down` |
| `sneak` | `sneak` |
| `run` | `run` |
| `double_jump` | `double_jump` |
| `land_skid` | `land_skid` |
| `slide` | `slide` |
| `climb` | `climb` |
| `ledge_cling` | `ledge_cling` |
| `ledge_pull` | `ledge_pull` |
| `wall_jump` | `wall_jump` |
| `squeeze` | `squeeze` |
| `dazed` | `dazed` |
| `rough_landing` | `rough_landing` |

**Automation note:** Prefer **`meta.frameTags`** (`from` / `to`) over parsing `frames` dictionary keys. If tooling must use indices, use the table in §4.1.

### 4.2b Loose PNGs

Loose files under `.../bonnie/` remain valid for per-frame QA; the **strip + JSON** is the canonical animation source for `SpriteFrames` generation.

### 4.3 `BonnieController.gd` state → animation (integration stub)

The controller exposes **state enum** names (`IDLE`, `WALKING`, `JUMPING`, …) but **does not** drive a sprite yet. When wiring `AnimatedSprite2D`, map gameplay to clips roughly as follows (iterate with design on edge cases):

| `BonnieController.State` | Suggested clip (Tier-A on disk) |
|--------------------------|----------------------------------|
| `IDLE` | `idle` |
| `SNEAKING` | `sneak` (or `walk` + lower `speed_scale` if preferred) |
| `WALKING` | `walk` |
| `RUNNING` | `run` |
| `SLIDING` | `slide` |
| `LANDING` / skid reads | `land_skid` |
| `JUMPING` | `jump_up` → `jump_apex` / `double_jump` by context |
| `FALLING` | `jump_down` |
| `CLIMBING` | `climb` |
| `SQUEEZING` | `squeeze` |
| `DAZED` | `dazed` |
| `ROUGH_LANDING` | `rough_landing` |
| `LEDGE_PULLUP` (cling vs pull) | `ledge_cling` / `ledge_pull` |
| Wall jump | `wall_jump` |
| *Missing clip* | **Hold last frame** of current clip (producer rule) |

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
| `env-prop-rigid-crate-01.png` | **20×20** on disk until art v3 — **Session 013 collision target: 32×32** rigid body + re-export |
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
- [ ] Bonnie `SpriteFrames` covers **all Tier-A tags** in §4.2 (producer “done” line for Session 013).
- [ ] JSON already includes **`jump_up`** on cel 11 — tooling should use **`meta.frameTags`**, not hard-coded 14-cel assumptions.

---

## Mycelium

After changing this file or the export set, attach a **summary** note on `prototypes/bonnie-traversal/IMPORT-GODOT.md` and a **context** note on `HEAD` so the next agent sees path/frame deltas without re-scanning PNGs.
