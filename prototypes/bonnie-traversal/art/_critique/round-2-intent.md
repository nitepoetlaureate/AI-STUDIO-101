# Round 2 — Intent & taste (artifact interview)

**Sources (read, not people):** `art/ART-BRIEF.md`, `art/_critique/round-0-direction.md`, `art/_critique/round-1-critique.md`, `prototypes/bonnie-traversal/IMPORT-GODOT.md`, plus current pixels + filenames under `art/export/**` and `art/_critique/round-1-env-grayscale-squint-strip-v02.*`.

**Note:** `round-1-critique.md` predates several v2 exports; this pass treats **on-disk `export/`** as ground truth for what shipped while the critique text still frames the problems.

---

## ENV

### What this track was optimizing for (infer from pixels + filenames)

- **Affordance-first tiling:** `env-tile-*` names encode roles (ground, kitchen vs studio walls, `climbable` vs `smooth`, `soft-landing`, `squeeze-ceiling`, `end-wall`) aligned to `TestLevel.tscn` greybox groups — optimize a stranger naming surfaces without opening the scene tree.
- **Grid + course modularity:** Dominant **16×16** modules with **32×32** tall variants, **32×16** squeeze/end strips, **20×20** `env-prop-rigid-crate-01`, plus `env-tileset-apartment-atlas-v01` — optimize **collision parity** and fast Godot TileSet slicing over bespoke hero props.
- **Domestic read, value-separated fantasy:** Kitchen/studio/baseboard variants and the optional `env-parallax-apartment-backdrop-v01` — optimize **warm-apartment comedy staging** while keeping gameplay plane legible (`round-0-direction.md`).

### What was sacrificed

- **Micro-crisp cushion language:** `env-tile-soft-landing-01` still reads as a **soft value blob** (low-frequency, almost “filtered” at 1×) versus a **stitched fabric / pile** read; `round-1-critique.md` called this out — detail budget went to **separating soft from floor in greyscale**, not to tile-friendly edge craft.
- **Platform lip storytelling:** `env-tile-platform-edge-01` remains structurally minimal — sacrifices **“furniture thickness”** called for in round 1 (1–2 px break / underhang) to avoid breaking the **single Pass 1 edge convention** (`round-0-direction.md` don’ts).
- **Parallax restraint vs mood:** Backdrop exists as a named deliverable — risks stealing contrast until affordance stills are locked (`round-1-critique.md` P2) — sacrifices **environmental richness** on the depth layer for **P0 plane clarity**.

### One “borrow” suggestion (cross-discipline)

**Borrow Bonnie’s “interior break” rule for tiles:** apply the same **1 px interior accent** logic the character track uses for ear/toe separation (`#F4ECD8` discipline in `round-0-direction.md`) as **controlled grout / edge catchlights** on `platform-top` + `platform-edge` so lips read without adding a second outline system.

---

## BONNIE

### What this track was optimizing for (infer from pixels + filenames)

- **State coverage over hero render:** Filenames span **Tier A** verbs (`sneak`, `run`, `double-jump`, `land-skid`, `slide`, `climb`, `ledge-cling` / `ledge-pull`, `wall-jump`, `squeeze`, `dazed`, `rough-landing`) — optimize **playtest gating** and `BonnieController.gd` enum alignment (`bonnie-godot-animation-map.md`) ahead of marketing silhouette.
- **Strip + loose redundancy:** `bonnie-locomotion-sheet.png` + `bonnie-locomotion-sheet.json` alongside per-state PNGs — optimize **pipeline escape hatches** (tooling vs hand-placed `AtlasTexture`) per `ART-BRIEF.md` §1 dual-path allowance.
- **Hitbox-scale cartoon:** Cells stay **16×32** in JSON — optimize **capsule-faithful** motion with **squash/lean/exaggerated air phases** on the sheet over anatomical cats.

### What was sacrificed

- **“Someone’s cat” silhouette richness:** At 1× the body can still scan as a **dominant vertical mass** with states sold by **pose math** more than fur/tail/ear articulation — trades **creature legibility** (`round-0-direction.md`) for **state count**.
- **Per-state animation depth:** Many clips are **1–2 frames** (run, sneak, climb, slide, squeeze, etc.) — sacrifices **foot cadence, overlap, and recovery overlap** until integration proves which beats need inbetweens.
- **Strict controller naming parity:** JSON tags (`jump_apex`, `land_skid`, …) vs Godot `SpriteFrames` vs `State` enum still require **human mapping** — sacrifices **drop-in automation** until `IMPORT-GODOT.md` / tooling fully chases the expanded strip.

### One “borrow” suggestion (cross-discipline)

**Borrow the env affordance palette as a lighting rig:** paint Bonnie’s rim/interior accents using the **same value steps** as `climbable` vs `smooth` vs `soft` anchors so the cat **inherits the world’s contrast budget** instead of inventing a third luminance system that fights tiles.

---

## SHARED

### What this track was optimizing for (infer from pixels + filenames)

- **Handoff contract:** Shared `palette-traversal-v01.gpl`, hyphenated `env-*` / `bonnie-*` tokens, `-v01` only on replaceable atlas/parallax — optimize **integrator time** and merge hygiene (`ART-BRIEF.md` §5–6, `IMPORT-GODOT.md`).
- **Nearest-pixel pipeline:** Documented **nearest** default + mipmaps off — optimize **crisp 1× prototype reads** over scaled UI polish.
- **Evidence culture:** `_critique/` grayscale strip + txt caption — optimize **reviewability** (squint test) as a shippable sidecar, not engine content.

### What was sacrificed

- **Single mechanical source of truth:** `IMPORT-GODOT.md` §3–4 still describe a **224×32 / 14-cel** strip while `bonnie-locomotion-sheet.json` reports **`size`: 528×32** and **33 cels** with full `frameTags` — prose drift sacrifices **trust-on-first-open** for whoever skipped re-statting PNGs.
- **Indexed endgame:** JSON `format: RGBA8888` while the brief prefers indexed handoff — sacrifices **palette lock** until `PALETTE-NOTES.md` (still called for in round 1) closes the loop.
- **In-engine proof:** Exports exist, but `IMPORT-GODOT.md` §6 notes **greybox ColorRects** — sacrifices **holistic composition proof** (Bonnie on real tiles at course scale) in favor of finishing the **asset library slice** first.

### One “borrow” suggestion (cross-discipline)

**Borrow QA’s repro discipline for art gates:** define a **fixed camera bookmark set** in `TestLevel.tscn` (idle-on-floor, run, slide, pre-parry air, climb + wall jump) that mirrors the **five stills** in `ART-BRIEF.md` §6 — same shots become regression caps for any future palette bump.

---

## Round 3 — exactly three P0 tweaks (or ship)

Worth a tight round 3: integration and evidence still lag the **v2** art library.

1. **Reconcile `IMPORT-GODOT.md` with the live locomotion strip:** update dimensions, cel count, tag list, and the §4.1 index table to match `bonnie-locomotion-sheet.json` / PNG on disk (remove stale **224×32 / 14** facts).
2. **Rebuild `env-tile-soft-landing-01` toward crisp cushion vocabulary:** replace smear with **2–3 explicit value steps / stitch pattern** that survives 1× and matches the grayscale strip intent (`round-1-critique.md` P0).
3. **Ship the five `ART-BRIEF.md` verification stills from a running scene:** Bonnie on exported tiles at **1×** (not only isolated tiles + strip) to prove black-cat separation and affordance reads under parallax.
