# Round 1 — Art critique (lead critic: art direction + TA)

**Scope:** Critique only — no new art. Grounded in `ART-BRIEF.md`, `round-0-direction.md`, current `art/export/**` outputs, and `IMPORT-GODOT.md`.

**`IMPORT-GODOT.md`:** Not present anywhere under the repo at critique time; TA treats that as a **handoff blocker** until added (see TA changes §1).

**Export inventory reviewed:** `palette-traversal-v01.gpl`; `export/env/*.png` (atlas, parallax, floor/platform/walls/climb/smooth/soft/squeeze/crate/end/baseboard, etc.); `export/bonnie/` — `bonnie-locomotion-sheet.png` (**224×32**), `bonnie-locomotion-sheet.json`, loose `bonnie-idle-000[1–4].png`, `bonnie-walk-000[1–7].png`, `bonnie-jump-up-0001.png`, `bonnie-jump-apex-0001.png`, `bonnie-jump-down-0001.png`. Env tiles remain predominantly **16×16** with **32×32** tall variants, **32×16** squeeze/end strips, **20×20** crate, atlas **256×112**, parallax **320×180**.

---

## ENV (environment)

### Strengths

1. **Grid fidelity:** Core modules stay on the **16 px** brief (with **32 px** vertical strips where the course stacks height), and the **20×20** crate matches the rigid-prop collision ballpark — greybox volumes can be retextured without rescaling first.
2. **Affordance palette:** Warm climb vs cool smooth vs dark squeeze void still tracks `round-0-direction.md` anchors and `palette-traversal-v01.gpl`, so material *roles* are understandable before micro-detail.
3. **Pack coverage:** The minimum env pack from the brief remains well *represented* as named files (ground, platform top/edge, kitchen/studio, climb + tall, smooth + tall, soft landing, squeeze, crate, end wall, atlas, optional parallax).

### Concrete changes

1. **Tighten pixel reads on gameplay tiles** — several surfaces still lean on soft gradients or low-frequency blur that can read as “broken export” at **1×**; `round-0-direction.md` bans noisy grit, but **soft landing must still read as crisp cushion**, not smear. Rebuild with **clean value steps**. **Severity: P0**
2. **Ship grayscale squint proof for the five affordances** (floor, soft, climb, smooth, squeeze) on one horizontal strip — the brief’s bar is a playtester naming surfaces **without** the scene tree; attach evidence under `_critique/`. **Severity: P0**
3. **Platform edge / lip** — `env-tile-platform-edge-01` still risks a **flat slab** read at course scale; add a **1–2 px** readable break (bevel, grout, underhang shadow) consistent with the **single** Pass 1 edge convention. **Severity: P1**
4. **Smooth tall tiling** — `env-tile-smooth-tall-01` banding should **wrap predictably** on **32 px** vertical repeats so tall smooth walls do not show a drifting seam rhythm. **Severity: P1**
5. **Parallax discipline** — optional backdrop must stay **low contrast** vs gameplay plane until P0 affordance stills exist (`round-0-direction.md` priority stack). **Severity: P2**

---

## BONNIE (character)

### Strengths

1. **Handoff exists in `export/`:** Loose PNGs follow the brief’s `{category}-{subject}-{variant}-{frame}` pattern, plus **`bonnie-locomotion-sheet.png` + `.json`** — the dual path the brief allows once a pipeline is chosen.
2. **Dimensional contract met:** Cells are **16×32** in JSON `sourceSize` / `frame` rects — matches **1×2 tiles** and controller placeholder ballpark.
3. **Core loop seeds:** **Idle**, **walk**, and an **air three-beat** (up / apex / fall files present) establish motion before Tier A completion.

### Concrete changes

1. **Close Tier A coverage gap** — `ART-BRIEF.md` §3.2 still requires **SNEAK**, **RUN** (or an explicit documented cheat vs walk), **DOUBLE JUMP**, **LAND/SKID**, **SLIDE**, **CLIMB**, **LEDGE** (cling/pull-up or scramble doc), **WALL JUMP**, **SQUEEZE**, **DAZED**, **ROUGH_LANDING**; none of those ship in `export/bonnie/` yet. **Severity: P0**
2. **Silhouette / “creature” read** — direction asks for **small outline breaks** (tail, ears, crouch); current idle can scan as a **monolithic vertical mass** at **1×**; add limb/tail/ear separation and interior rim using `#F4ECD8` **sparingly** so black fur does not merge into floor or squeeze void. **Severity: P0**
3. **Fix spritesheet metadata: orphan frame 11** — `frameTags` list **idle** 0–3, **walk** 4–10, **jump_apex** 12, **jump_down** 13; **frame 11** has **no tag** while `bonnie-jump-up-0001.png` exists — tag **`jump_up`** (or equivalent) in Aseprite re-export so JSON matches loose files and engine importers. **Severity: P0**
4. **Align animation names to `BonnieController.gd`** — JSON tags use `jump_apex` / `jump_down` snake case; Godot may expect `jumping`, `falling`, `sneaking`, etc. Produce a **one-line mapping table** in `IMPORT-GODOT.md` (when it exists) or in `_critique` until then. **Severity: P1**
5. **Foot contact and motion sell** — walk exists, but **feet/skid/slide** reads from the brief are not yet enforceable without land/slide frames; when added, keep **foot baseline** consistent across frames for capsule-bottom parity. **Severity: P1**

---

## TA / PIPELINE

### Strengths

1. **Naming hygiene:** `env-*` and `bonnie-*` files remain **lowercase hyphenated** and machine-safe per `ART-BRIEF.md` §1.
2. **Shared palette:** `palette-traversal-v01.gpl` still anchors env (and future Bonnie indexing) to one swatch file in `export/`.
3. **Spritesheet JSON is parseable:** Standard Aseprite hash format with `frames`, `meta`, `frameTags` — enough for a Texture2D + manual AtlasTexture workflow or tooling.

### Concrete changes

1. **Author `prototypes/bonnie-traversal/IMPORT-GODOT.md` (or `art/IMPORT-GODOT.md`)** — document **`res://`** root, **canonical paths** (per-tile vs atlas), **CanvasItem texture_filter = off**, **mipmaps off**, TileSet setup notes, and **how** `bonnie-locomotion-sheet.json` maps to `SpriteFrames` / `AnimationPlayer`. File is **still missing**; integrators are guessing. **Severity: P0**
2. **Author `PALETTE-NOTES.md`** (`ART-BRIEF.md` §4) — state **RGBA vs indexed** per asset type, color budget (32–64), and whether Bonnie stays **RGBA8888** (current JSON `format`) while env indexes later. **Severity: P0**
3. **Frame dictionary keys vs engine** — JSON `frames` keys are Aseprite-internal (`"bonnie-locomotion-v01 0.aseprite"` …); either document the **index→tag** map or re-export with cleaner keys so automated importers do not brittle-match strings. **Severity: P1**
4. **Atlas layout contract** — `env-tileset-apartment-atlas-v01.png` (**256×112**, non-POT height): document **slice coordinates** and v02 bump rules beside Godot TileSet atlas source. **Severity: P1**
5. **Version tokens** — filenames include `-v01`; brief allows mid-pass tokens but asks to **normalize before bind**; decide stable names vs retained version suffixes and record the rule in `IMPORT-GODOT.md`. **Severity: P2**

---

## Synthesis — what round 2 must achieve

Round 2 must deliver a **playtest-credible character slice**, not only env: **full Tier A** Bonnie states (or explicitly scoped cheats documented beside the controller), **fixed `jump_up` tagging** and any other metadata drift between sheet JSON and loose PNGs, **silhouette + rim proof** for a black cat on real exported tiles at **1×**, and **locked integration prose** (`IMPORT-GODOT.md` + `PALETTE-NOTES.md`) so engineering wires `SpriteFrames` / TileSet once with correct filters, pivots, and animation name mapping — while env work finishes **grayscale affordance evidence** and **crisper** Pass 1 edges so surfaces never fight the new character reads.
