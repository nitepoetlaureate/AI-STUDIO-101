# ART-BRIEF — Bonnie Traversal Prototype (Art Pass 1)

**Producer:** AI-STUDIO-101  
**Prototype:** `prototypes/bonnie-traversal`  
**References:** `prototypes/bonnie-traversal/README.md`, `design/gdd/bonnie-traversal.md`, `prototypes/bonnie-traversal/TestLevel.tscn`  
**Intent:** Greybox → **readable pixel** for playtest clarity — not final marketing art.

---

## 1. Target resolution, grid, character scale, export naming

### Base tile

**16 px** square base tile for environment and layout alignment.

**Justification**

- `TestLevel.tscn` primitives already snap to **16-aligned** geometry: platforms are **16 px** tall; climbable / smooth walls are **32 px** wide (**2 tiles**); rigid props are **20 px** (acceptable off-grid for “messy object” reads until a later pass).
- GDD tuning (e.g. `rough_landing_threshold` **144 px**, `parry_detection_radius` **24 px**) maps cleanly to tile math on a **16** grid (**144 = 9 tiles**, **24 = 1.5 tiles**), which helps level and art stay in sync while values are still being iterated.
- `BonnieController.tscn` uses a **16×32 px** placeholder footprint (`ColorRect` −8..8, −16..16). Keeping the grid at **16** preserves **1 tile wide × 2 tiles tall** as the default silhouette target without forcing a rescale of collision-led tuning on day one.

### Character height (tiles)

- **Standing / default locomotion:** **2 tiles tall** (~**32 px** body height in sprite space, **1 tile** wide ~**16 px**), matching the current prototype visual/collision ballpark.
- **SQUEEZING:** must read clearly under low clearance — plan **≤ ~1 tile** vertical read (~**16 px** or compressed silhouette) while hitbox logic remains authoritative in code.

### Export naming (machine-safe, lowercase, hyphenated)

Pattern: `{category}-{subject}-{variant}-{frame}.{ext}`

Examples:

- `bonnie-idle-0001.png` … `bonnie-idle-0004.png`
- `bonnie-run-0001.png` … `bonnie-run-0006.png`
- `bonnie-jump-up-0001.png`, `bonnie-jump-apex-0001.png`, `bonnie-jump-down-0001.png`
- `bonnie-ledge-cling-0001.png`, `bonnie-ledge-pullup-0001.png`
- `env-tile-ground-01.png`, `env-tile-platform-top-01.png`
- `env-prop-rigid-crate-01.png`
- Spritesheet (if used): `bonnie-locomotion-sheet.png` + **`bonnie-locomotion-sheet.json`** (Godot TileSet / external JSON — pick one pipeline and stick to it for this pass)

**Version token (optional):** append `-v01` only when replacing files mid-pass to avoid broken references; remove or normalize before handoff to integration.

---

## 2. Scope for this pass

| In scope | Out of scope |
|----------|----------------|
| Replace `ColorRect` / flat greys with **readable** tiles, edges, and material reads | Final character design, marketing key art, trailer polish |
| **Silhouette + motion clarity** for traversal states that gate playtests | Full furniture set dressing, NPCs, VFX-heavy polish |
| **Material language** for climbable vs non-climbable vs soft landing (color + pattern, not narrative props) | Audio (SFX timing can be noted in `_critique` only) |
| **Contrast-safe** reads for a **dark cat** on typical apartment surfaces | Brand-final palette, UI, logo |

Quality bar: a new playtester can **name what each surface is for** without reading node names in the scene tree.

---

## 3. Deliverables

### 3.1 Environment — screens / tilesets

`TestLevel.tscn` is a **single long horizontal course** (ground strip + ascending platforms + parry ledges + climb wall + smooth wall + squeeze + props + end wall). Treat it as **one continuous “greybox apartment strip”** rather than multiple discrete menu screens.

**Minimum env pack**

| Deliverable | Purpose |
|-------------|---------|
| **Ground / floor tileset** (repeatable) | Long `Ground` strip reads as floor, not infinite grey slab |
| **Platform top + edge** (modular) | Standard **16 px**-tall platforms + **wide/narrow** variants share one top treatment |
| **Hard vs soft landing read** | `soft_landing` group area must **read cushion** vs kitchen tile (GDD §3.4 cushion surfaces) |
| **Climbable vs smooth vertical surfaces** | `Climbable` group wall (**brown** placeholder) vs **cool** smooth wall — must survive **grayscale squint test** (not hue-only) |
| **Squeeze zone read** | Low ceiling + trigger zone: player should see **“low crawl”** before physics kicks in |
| **Rigid prop** (shared crate/box) | Slide collision readability — same module for `CollisionBox*` instances |
| **End wall / terminator** | Visual closure at course end (optional simple pattern) |

**Optional if time remains:** distant **parallax block-in** (2 layers max, low detail) — must not steal contrast from gameplay tiles.

### 3.2 Bonnie — animation states (minimum for playtest)

Priority is **state discrimination** and **hitbox-relative motion** (feet/skid/slide), not full animation count.

**Tier A — required**

| State / need | Notes |
|----------------|-------|
| **IDLE** | Neutral weight; tail/ear micro-motion optional (1–2 px) |
| **Locomotion** | At least **WALK** cycle; **RUN** may be **WALK + speed lines / stretch smear** if timeboxed — must still sell `run_max_speed` vs walk |
| **SNEAK** | Lower profile, smaller stimulus **read** (even if tuning is code-driven) |
| **AIR package** | Distinct **rise / apex / fall** (can be 1 frame each for this pass) |
| **DOUBLE JUMP** | Distinct from first jump (GDD: “little twist”) — even **one** dedicated frame is enough |
| **LAND / SKID** | Visually supports `skid_threshold` / `hard_skid_threshold` (dust skew, body lean) |
| **SLIDE** | Horizontal commitment read (Kaneda); distinct from run |
| **CLIMB** | Vertical strip: up idle + move (mirror OK) |
| **LEDGE PARRY success** | **Phase 1 cling** + **Phase 2** pull-up vs pop-forward variant **or** single readable “scramble” if timeboxed (document which) |
| **WALL JUMP** | Push-off read perpendicular to wall |
| **SQUEEZE** | Crawl / flattened cycle |
| **DAZED** | Stars / wobble silhouette (GDD §3.1) |
| **ROUGH_LANDING** | Flat → recover beat (GDD §3.1) |

**Tier B — strongly recommended if Tier A lands early**

| State / need | Notes |
|--------------|-------|
| **Separate RUN** (if Tier A used combined cheat) | Better sell of stimulus fantasy |
| **CLAW BRAKE** (during SLIDE) | Claws-down pose or sparks — helps teach E context map |

**Explicitly defer:** polish-specific transition frames beyond what `BonnieController.gd` actually drives today; cosmetic idle variants; costume changes.

---

## 4. Palette rules and contrast

### Indexed vs RGB

- **Working files:** RGBA in the art tool of choice (layers on).
- **Handoff for Godot integration (this pass):** prefer **indexed PNG** (e.g. **32–64 colors** total for env + Bonnie combined budget) **or** RGBA if indexed compression harms edge clarity — **pick one per asset type** and document in `_critique/PALETTE-NOTES.md`.
- **Single shared palette file** under `art/export/` (e.g. `palette-traversal-v01.gpl` or `.png` swatch) so recolor passes do not fork the world.

### Contrast vs background (Bonnie is a black cat)

- **Silhouette:** maintain **interior line or rim luminance** on Bonnie so she does not merge into dark floors / shadows at 1× scale.
- **Squint test:** at **100%** export scale, Bonnie’s **full-body bbox** must remain separable from any **dominant mid-tone** tile she occupies (aim for **≥ ~60 relative luminance steps** between core fur and immediate background in greyscale — use `_critique` screen captures as evidence).
- **State FX:** DAZED stars / ROUGH_LANDING dust must **not** rely on saturation alone; value separation required.
- **Climbable vs smooth:** duplicate the **value** difference shown in greybox (warm vs cool) when moving to pixel — **hue is insufficient** for accessibility.

---

## 5. File layout

All art for this prototype lives under:

```text
prototypes/bonnie-traversal/art/
├── env/           # Source tiles, PSD/Aseprite, tile paint exports (editable)
├── bonnie/        # Character source (Aseprite / PSD with layers + tags)
├── export/        # Godot-ready PNG / spritesheets + palette swatch ONLY
└── _critique/     # Notes, paint-overs, before/afters, contrast checks (not imported by game)
```

**Rules**

- Nothing in `_critique/` is referenced by `res://` scenes.
- **`export/` is the only folder** integrators pull into `res://` (suggest mirror: `prototypes/bonnie-traversal/assets/` later — **do not** duplicate without producer sign-off).

---

## 6. “Done” checklist (Godot integration)

Use this when closing the pass to `TestLevel.tscn` / `BonnieController.tscn`.

### Paths & imports

- [ ] All textures live under a **`res://`** path the prototype owns (e.g. `res://prototypes/bonnie-traversal/art/export/...` or a dedicated `res://prototypes/bonnie-traversal/assets/...` — **one** root only).
- [ ] **No** absolute machine paths in `.tscn` / `.import` commits.
- [ ] **Filter:** `CanvasItem` texture filter = **off** (pixel crisp) unless producer approves exception for specific layer.
- [ ] **Mipmaps:** off for small pixel textures.

### Naming

- [ ] Files match **Export naming** (§1); no spaces; frame padding consistent (`0001` not mixed with `1`).
- [ ] Animation names in `SpriteFrames` (or equivalent) **mirror GDD state names** where 1:1 (`idle`, `sneaking`, `walking`, `running`, `sliding`, `jumping`, `falling`, `climbing`, `squeeze`, `dazed`, `ledge_pullup`, `rough_landing`, etc.) — exact list must match what `BonnieController.gd` expects **today** (grep script before bind).

### Pivots & alignment

- [ ] **Feet / contact pivot** consistent: horizontal center, **foot** on local **y** baseline aligned to **ground contact** (matches capsule bottom behavior — verify in-editor with grid snap **16**).
- [ ] **Hitbox parity:** sprite bbox **does not imply** a different hurtbox than `CollisionShape2D` / squeeze shapes — art stays inside or documents intentional overhang in `_critique/OVERHANG.md`.
- [ ] **ParryCast** (`ShapeCast2D` radius **24**) — art should not visually suggest grab range **wider** than design (no “ghost hand” per GDD).

### Tileset / env

- [ ] Tiles **snap to 16×16** grid; collision `ColorRect` sizes remain source of truth unless design approves collision edit.
- [ ] **Climbable** group nodes use **shared** climbable texture region; smooth wall visually distinct.
- [ ] **`soft_landing` group** visually distinct from hard floor.

### Verification pass

- [ ] Run `TestLevel.tscn` at **intended prototype resolution** (per GDD dependency: internal render assumptions — confirm against `project.godot` viewport / stretch settings).
- [ ] Capture **5 `_critique` stills**: idle on ground, full run, slide, mid-air before parry, climb + wall jump — all **readable at 1×**.

---

## 7. Summary for other agents (5 lines)

1. **Use a 16 px tile grid**; Bonnie targets **~2 tiles tall** and **1 tile wide**, matching current `BonnieController` placeholder and **16 px** platform strips in `TestLevel.tscn`.  
2. This pass is **readable pixel replacement** of greybox shapes — **not** marketing-final art or full environment dressing.  
3. Deliver **one env module set** (floor, platform, walls, soft landing, squeeze, prop) plus **Tier A Bonnie states** listed in §3.2, exported under `art/export/` with **hyphenated lowercase** names.  
4. **Palette:** shared swatch, prefer **indexed** handoff with **value-based** contrast so a **black cat** reads on dark floors; document exceptions in `_critique`.  
5. Integration **done** means correct **`res://` paths**, **16 px** snap, **foot pivots**, **`SpriteFrames` names aligned to code**, and **climbable / soft / squeeze** reads verified in running `TestLevel.tscn`.
