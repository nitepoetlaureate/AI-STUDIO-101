# Round 0 — Art direction (Bonnie Traversal prototype)

**Role:** Art Director pass aligned to `ART-BRIEF.md` and `design/gdd/bonnie-traversal.md`.  
**Scope:** Direction only; no Aseprite deliverables in this round.

---

## Tone (one paragraph)

Keep the read **warm domestic comedy first, ninja-cat fantasy second**: the apartment is a lived-in, slightly messy stage where ordinary surfaces—tile, cushions, a crate in the way—become slapstick props for momentum and bad decisions, not a moody action set. Bonnie should feel like **someone’s actual cat** who briefly believes she is Ryu Hayabusa: the stealth beats are cozy and observational (low, hugging geometry), and the burst beats are **Tom & Jerry / Felix** physics—big motion, comic recovery, no cruelty. Fantasy shows up in **expressive poses and cartoon consequence** (stars, flat pancake landings, scramble pop-ups), not in ornate lore dressing or cinematic grading.

---

## Color script (hex anchors)

Use these as **value-first anchors** (squint-test safe); hue can nudge ±one step in a later pass, but **do not collapse** climbable vs smooth or soft vs hard floor in greyscale.

| Hex | Role | When to use |
|-----|------|-------------|
| `#C4B6A8` | **Floor / hard domestic base** | Default ground, platform tops, kitchen-adjacent hard surfaces that behave as normal landings and skids. |
| `#8A6239` | **Climbable warmth** | `Climbable` group only—fabric, carpet pile suggestion, shelving uprights: must stay **darker mid-value** than soft landing so it still reads as “grippy mass,” not pillow. |
| `#5F7389` | **Smooth / no-grip cool** | Non-climb verticals and slick faces: **cooler and slightly lower-key** than floor so it reads “hard + no purchase” even if desaturated. |
| `#E6D3C8` | **Soft landing / cushion** | `soft_landing` group and similar interrupt surfaces: **lightest large-area anchor** so impact reads as “forgiving” without neon saturation. |
| `#F4ECD8` | **Key / rim for Bonnie** | Not a world wash—use sparingly for **interior rim, ear edges, toe catchlights** so a black cat separates from `#C4B6A8` floors and shadowed corners at 1×. |

---

## Silhouette rules — Bonnie vs furniture

- **Mass hierarchy:** Bonnie occupies roughly **one tile wide × two tiles tall** of **organic, slightly tapered** positive space; furniture and architecture read as **broader, simpler slabs** (wide horizontals for counters/platforms, tall rectangles for walls). She should **never** compete with props at the same visual weight—**props are chunkier but dumber**; Bonnie is smaller but **limb- and ear-readable**.  
- **Edge language:** Bonnie’s outline carries **small breaks** (tail, ears, slight crouch) so she parses as a **creature** at a glance; env blocks use **long straight segments** with occasional 16 px module steps, not cat-like curves.  
- **Contact clarity:** At rest and in motion, **feet and belly clearance** must read against whatever she stands on—furniture silhouettes **sit behind or beside** her dominant read during traversal states that gate playtests (run, slide, air, climb), not **merge** into her midsection.  
- **Squeeze:** In low clearance, Bonnie’s silhouette **compresses toward ≤ ~1 tile height** with a **horizontal emphasis** (low crawl); the squeeze volume reads as a **dark void or heavy overhang** above—**negative space** teaches the crawl before physics.

---

## Explicit don’ts

1. **Style drift:** No pivot toward gritty urban realism, horror mood, or “premium” painterly concept-art lighting—stay **readable pixel + domestic cartoon** per prototype scope.  
2. **Outline thickness:** Do **not** mix single-pixel exterior outlines with double-thick selective outlines on adjacent assets; pick **one** edge convention for Bonnie and env for Pass 1 (interior rim on Bonnie is allowed; **no** random bold comic ink on tiles only).  
3. **Noisy textures:** No film grain, heavy dither blankets, or high-frequency noise on **gameplay tiles** or Bonnie’s core body—detail lives in **shape breaks and limited palette steps**, not shader-y grit that eats contrast at 1×.

---

## Priorities (stack)

| Priority | Focus |
|----------|--------|
| **P0 — Environment readability** | A new playtester can **name surface affordances** (floor vs soft landing vs climb vs smooth vs squeeze) **without** reading the scene tree; grayscale squint passes **before** hue polish. |
| **P1 — Bonnie read at small size** | State silhouette and foot contact read at **100% export** on typical course backgrounds; black fur stays separated via **value + restrained rim**; motion sells Tier A states from the brief. |
| **P2 — Polish** | Parallax dressing, extra transition frames, cosmetic idle variants, marketing-level harmony—**only after** P0/P1 evidence in `_critique` stills (per `ART-BRIEF.md` verification list). |
