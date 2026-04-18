# Round 2 — Intent & taste (artifact interview)

**Method:** Read the deliverables, not the authors — `art/ART-BRIEF.md`, `art/_critique/round-0-direction.md`, `art/_critique/round-1-critique.md`, `prototypes/bonnie-traversal/IMPORT-GODOT.md`, on-disk `art/export/**` (filenames + implied roles), and `art/_critique/round-1-env-grayscale-squint-strip-v02.txt` (caption for the paired strip image).

**Ground truth:** `round-1-critique.md` predates several v2 Bonnie loose frames and a longer locomotion strip; where text and pixels disagree, **pixels win**.

---

## ENV

### What this track was optimizing for (infer from pixels + filenames)

- **Affordance-first tiling:** `env-tile-ground-01`, `floor-kitchen`, `wall-kitchen`, `wall-studio`, `climbable` (+ `climbable-tall`), `smooth` (+ `smooth-tall`), `soft-landing`, `squeeze-ceiling`, `end-wall`, `baseboard` — names mirror `TestLevel.tscn` roles so a stranger can guess **floor vs cushion vs grip vs slip vs crawl** before opening the scene tree (`ART-BRIEF.md` §3.1, `round-0-direction.md` P0).
- **Grid and collision marriage:** Mostly **16×16** modules, **32×32** tall stacks, **32×16** squeeze/end strips, **20×20** `env-prop-rigid-crate-01`, plus `env-tileset-apartment-atlas-v01` — optimizes **retexture-in-place** against greybox metrics (16 px platforms, rigid prop size) over bespoke hero geometry.
- **Domestic staging, value-separated fantasy:** Kitchen/studio/baseboard variants and optional `env-parallax-apartment-backdrop-v01` — optimizes **warm apartment comedy** while keeping the gameplay plane readable (`round-0-direction.md` tone + color anchors).

### What was sacrificed

- **Cushion micro-read at 1×:** `env-tile-soft-landing-01` still leans **soft gradients / low-frequency smear** (`round-1-critique.md` P0) — trades **stitched, tile-friendly “fabric” vocabulary** for a fast **greyscale separation** from hard floor (see also `_critique/round-1-env-grayscale-squint-strip-v02`).
- **Platform lip / furniture thickness:** `env-tile-platform-edge-01` stays **slab-simple** — defers **1–2 px bevel / grout / underhang** called in round 1 to avoid violating the **single Pass 1 edge convention** (`round-0-direction.md` don’ts on mixed outline systems).
- **Depth layer restraint vs mood:** Shipping a named parallax asset risks **contrast theft** until plane affordances are locked — background richness is intentionally **underfed** vs the brief’s optional parallax dream (`round-1-critique.md` P2).

### One “borrow” suggestion (cross-discipline)

**Borrow Bonnie’s interior rim discipline for tiles:** use the same **sparse `#F4ECD8`-class catchlight logic** (`round-0-direction.md`) as **grout / edge glints** on `platform-top` + `platform-edge` so lips read without inventing a **second exterior outline language** on geometry alone.

---

## BONNIE

### What this track was optimizing for (infer from pixels + filenames)

- **Tier A state coverage for playtests:** Loose files now span `sneak`, `run`, `double-jump`, `land-skid`, `slide`, `climb`, `ledge-cling`, `ledge-pull`, `wall-jump`, `squeeze`, `dazed`, `rough-landing` (plus idle / walk / air three-beat) — optimizes **controller-shaped proof** and “can we name this state?” over marketing hero frames (`ART-BRIEF.md` §3.2).
- **Dual handoff paths:** `bonnie-locomotion-sheet.png` + `bonnie-locomotion-sheet.json` beside per-clip PNGs — optimizes **integrator choice** (atlas strip vs loose `AtlasTexture`) per the brief’s allowed fork (`ART-BRIEF.md` §1).
- **Hitbox-scale cartoon:** JSON `sourceSize` **16×32** per cel — optimizes **capsule-faithful** exaggeration (lean, squash, stars, pancake landings) over literal feline anatomy (`round-0-direction.md` Tom & Jerry beat).

### What was sacrificed

- **Silhouette richness (“someone’s cat”):** Many states are **1–2 frames**; the body can still scan as a **vertical mass** at 1× — trades **tail/ear/limb articulation** (`round-0-direction.md`) for **state count and filename clarity**.
- **Foot cadence and recovery overlap:** Minimal inbetweens on run, sneak, climb, slide, squeeze — sacrifices **skid_threshold / hard_skid_threshold sell** until land/slide timing is proven in-engine (`ART-BRIEF.md` §3.2, `round-1-critique.md`).
- **Automation purity:** Aseprite `frames` keys remain **opaque strings**; tooling must use **indices or `frameTags`** — sacrifices **string-key importer ergonomics** for a fast Aseprite round-trip (`round-1-critique.md` TA §3).

### One “borrow” suggestion (cross-discipline)

**Borrow the env affordance palette as Bonnie’s lighting rig:** rim/interior accents should **reuse the same value steps** as climb vs smooth vs soft anchors so the cat **inherits the world’s contrast budget** instead of a third luminance system that fights `#C4B6A8` floors (`round-0-direction.md` hex table + `ART-BRIEF.md` §4).

---

## SHARED

### What this track was optimizing for (infer from pixels + filenames)

- **Integrator time:** Shared `palette-traversal-v01.gpl`, lowercase hyphenated `env-*` / `bonnie-*`, `-v01` only where called out (atlas, parallax) — optimizes **merge hygiene and path grepping** (`ART-BRIEF.md` §5–6, `IMPORT-GODOT.md` §1).
- **Nearest-pixel prototype default:** Documented **nearest** filtering + mipmaps off — optimizes **1× crisp reads** over scaled UI polish (`IMPORT-GODOT.md` §2, `ART-BRIEF.md` §6).
- **Evidence culture:** `_critique/` hosts grayscale strip caption (`round-1-env-grayscale-squint-strip-v02.txt`) — optimizes **reviewability** as sidecar artifacts, not `res://` imports (`ART-BRIEF.md` §5).

### What was sacrificed

- **Single mechanical source of truth:** `IMPORT-GODOT.md` §3–4 still describe **`bonnie-locomotion-sheet.png` as 224×32 / 14 cels** and a **partial** index table, while `bonnie-locomotion-sheet.json` reports **`size` 528×32**, **33 cels (0–32)**, and **full `frameTags`** including `jump_up` on cel **11** — prose sacrifices **trust-on-first-open** for anyone who does not re-stat the PNG/JSON.
- **Indexed handoff closure:** JSON `format: RGBA8888` with no checked-in `PALETTE-NOTES.md` — sacrifices **locked 32–64 color budget** until a follow-up documents RGBA vs indexed per asset type (`ART-BRIEF.md` §4, `round-1-critique.md` TA).
- **Holistic composition proof:** `IMPORT-GODOT.md` §6 notes **greybox `ColorRect` fills** — sacrifices **Bonnie-on-real-tiles at course scale** in favor of finishing the **export library slice** first (`ART-BRIEF.md` §6 verification stills).

### One “borrow” suggestion (cross-discipline)

**Borrow QA’s fixed repro / bookmark discipline:** add **named camera bookmarks** in `TestLevel.tscn` for the **five verification poses** (`ART-BRIEF.md` §6) so art bumps and palette nudges get **regression caps** without re-inventing shot framing each pass.

---

## Round 3 — exactly three P0 tweaks (or ship)

Worth a tight round 3: the **v2** pixel library has outrun the **integration prose** and the brief’s **in-engine proof** bar.

1. **Reconcile `IMPORT-GODOT.md` with live `bonnie-locomotion-sheet.json` / PNG:** document **528×32**, **33** cels, complete **`frameTags`** (including `jump_up`), and replace the stale **224×32 / 14-cel** §3–§4.1 narrative; refresh the index table or explicitly defer to **`meta.frameTags` only**.
2. **Env 1× micro-read pass:** rebuild **`env-tile-soft-landing-01`** toward **crisp cushion vocabulary** (clean value steps, not smear) and add the **1–2 px platform lip** read on **`env-tile-platform-edge-01`** without breaking the single edge convention (`round-1-critique.md` P0 + P1).
3. **Replace greybox with exports in `TestLevel.tscn` / Bonnie placeholder and capture `_critique` verification stills:** five **1×** captures per `ART-BRIEF.md` §6 on real tiles (idle on ground, full run, slide, pre-parry air, climb + wall jump) to prove **black-cat separation** and affordance reads with parallax present.
