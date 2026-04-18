# Round 1 — Art critique (lead critic: art direction + TA)

**Scope:** Critique only — no new art. Grounded in `ART-BRIEF.md`, `round-0-direction.md`, current `art/export/**` outputs, and the integration handoff implied by `IMPORT-GODOT.md` (see TA §5 — file not present in repo at critique time).

**Export inventory reviewed:** `palette-traversal-v01.gpl`; `export/env/*.png` including atlas, parallax, floor/platform/wall/climb/smooth/soft/squeeze/crate/end variants (dimensions verified: most gameplay tiles **16×16**, tall climb/smooth **32×32**, squeeze strip **32×16**, end wall **32×16**, crate **20×20**, atlas **256×112**, parallax **320×180**).

---

## ENV (environment)

### Strengths

1. **Grid fidelity:** Core modules land on the **16 px** brief (with **32 px** vertical strips where the course needs height), and the **20×20** crate matches the documented rigid-prop collision ballpark — integrators can snap without rescaling greybox volumes first.
2. **Affordance palette:** Warm climb vs cool smooth vs dark squeeze void tracks `round-0-direction.md` value-first anchors and the shared `.gpl`, so the *intent* of material language is visible before pixel craft tightens.
3. **Pack coverage:** The minimum env pack from the brief is largely *represented* as named slices (ground, platform top/edge, kitchen/studio/wall reads, climb + tall, smooth + tall, soft landing, squeeze ceiling, crate, end wall, atlas, optional parallax) — good structural coverage for a first export pass.

### Concrete changes

1. **Remove “muddy” and heavy soft-edge reads on gameplay tiles** — several surfaces read as gradient/blur-forward rather than crisp pixel steps; `round-0-direction.md` explicitly bans noisy/high-frequency grit, but **soft ≠ out-of-focus**. Rebuild soft landing and similar modules with **clean value steps** so “cushion” reads at **1×** without looking like a failed export. **Severity: P0**
2. **Run and attach grayscale squint proof for the five affordances** (floor, soft, climb, smooth, squeeze) on a single horizontal strip mock — the brief’s bar is that a playtester can **name surfaces without the scene tree**; evidence is not yet packaged alongside exports. **Severity: P0**
3. **Platform edge / lip readability** — `env-tile-platform-edge-01` risks scanning as a flat value slab at course scale; add a **legible 1 px–2 px break** (edge bevel, grout, or shadow underhang) consistent with the single edge convention chosen for Pass 1. **Severity: P1**
4. **Fix smooth vertical strip tiling logic** — `env-tile-smooth-tall-01` shows **asymmetric** vertical banding that will create obvious repeats on tall `CollisionShape2D` stacks; rebalance pattern so left/right edges **tile predictably** on **32 px** repeats. **Severity: P1**
5. **Parallax scope check** — `env-parallax-apartment-backdrop-v01` is **optional** per brief, while direction stacks **P2 polish after P0/P1 stills**; either defer until affordance stills exist or keep contrast **extremely low** so it never competes with Bonnie or climb/soft reads. **Severity: P2**

---

## BONNIE (character)

### Strengths

1. **Authoritative source in-repo:** `bonnie/bonnie-locomotion-v01.aseprite` gives a single place for tags, timing, and iteration — better than orphaned PNGs with no upstream.
2. **Collision / scale alignment is pre-solved in design:** The brief’s **16×32** silhouette target matches existing `TestLevel.tscn` / controller placeholders, so first exported binds should not force a retune of `rough_landing_threshold` tile math on day one.
3. **Clear Tier A contract:** `ART-BRIEF.md` §3.2 lists the exact states that gate playtests — acceptance criteria exist before polish arguments start.

### Concrete changes

1. **Ship Godot handoff pixels** — there are **no** `bonnie-*.png` / sheet + JSON under `art/export/` yet; until Tier A frames exist beside env, the pass is **environment-only**. Export per §1 naming (`bonnie-idle-0001.png`, …) or commit to one **spritesheet + JSON** pipeline and output both. **Severity: P0**
2. **Rim / interior luminance pass on fur** — apply `#F4ECD8` (and adjacent steps) as **restrained** ear/toe/belly catches so the black cat **separates** from `#C4B6A8` floors and from the squeeze void; verify at **100%** export, not zoomed editor view. **Severity: P0**
3. **Foot pivot + baseline doc** — one short note (even a single diagram PNG in `_critique/`) showing **horizontal center** and **foot on ground line** vs capsule bottom so `AnimatedSprite2D` / `Sprite2D` offsets do not drift frame-to-frame across run/slide/climb. **Severity: P1**
4. **Tier A state discrimination before Tier B** — idle vs sneak vs walk vs run cheat (if used) vs slide vs air three-beat vs double jump vs climb vs ledge vs wall jump vs squeeze vs dazed vs rough landing: each needs a **silhouette-readable** delta; defer claw-brake polish until those reads land. **Severity: P1**
5. **Pad frames and state names to code** — when exporting, use **consistent `0001` padding** and mirror animation names to what `BonnieController.gd` expects (grep before bind) to avoid integration churn. **Severity: P2**

---

## TA / PIPELINE

### Strengths

1. **Naming hygiene:** `env-*` files follow **lowercase hyphenated** machine-safe patterns aligned with `ART-BRIEF.md` §1 examples.
2. **Shared palette file:** `palette-traversal-v01.gpl` under `export/` supports recolor passes and keeps env anchors synchronized with direction.
3. **Dimensional checklist:** Measured exports respect the prototype’s **16** grid and special cases (**20** crate, **32** tall modules) — reduces friction for TileSet / `TextureRect` first wiring.

### Concrete changes

1. **Add `IMPORT-GODOT.md` (or equivalent) to the prototype** — file was **not found** in the workspace; integrators need a single page: **which** textures are canonical (per-tile vs `env-tileset-apartment-atlas-v01`), **filter/mipmap** defaults, suggested **`res://`** root, and whether Godot **TileSet atlas** coords are tracked in-repo. **Severity: P0**
2. **Author `PALETTE-NOTES.md` (brief §4)** — document **indexed vs RGBA** choice per asset type, total color budget (32–64), and any exceptions; without it, compression and edge crispness decisions are implicit. **Severity: P0**
3. **Atlas layout contract** — `env-tileset-apartment-atlas-v01.png` is **256×112** (non–power-of-two height). Document **slice grid**, margins, and duplication rules (if any) so TA/engineering do not mis-cut regions when updating v02. **Severity: P1**
4. **Contrast verification artifacts** — brief asks for **≥ ~60** relative luminance steps between core fur and dominant tile in greyscale; add `_critique` stills or a tiny measurement log so “readable black cat” is **proven**, not assumed. **Severity: P1**
5. **Normalize version tokens before integration** — several filenames carry `-v01`; brief allows `-v01` mid-pass but asks to **remove or normalize** before handoff; decide whether exports stay versioned in filenames or flip to stable names at bind time. **Severity: P2**

---

## Synthesis — what round 2 must achieve

Round 2 must turn this from a **credibly tiled, palette-aligned env kit** into a **playtest-ready vertical slice**: grayscale-verified affordances on every surface class at **1×**, pixel-crisp edges that obey the **single** Pass 1 outline convention, **Bonnie Tier A pixels in `export/`** with rim-lit silhouette proof on real course tiles, and a **written handoff** (`IMPORT-GODOT.md` + `PALETTE-NOTES.md`) that pins atlas vs loose textures, Godot import defaults, and animation naming against the live controller — so engineering can wire `TestLevel.tscn` once without guessing UVs, pivots, or palette policy.
