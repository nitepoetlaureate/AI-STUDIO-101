# Session 015 — LOS + visibility architecture (A+C) + handoff execution

**Status:** **Closed (2026-04-19)** — A+C visibility in `LevelManager` + `LineOfSightEvaluator` + `VisibilityLedger` + Bonnie LOS rig. Consumer inventory complete (table below). **§10:** hard cutover recorded (no runtime `los_enabled`). `bonnie-traversal.md` LOS blurb added.

**Read first (order):**

| # | Path | Why |
|---|------|-----|
| 1 | `NEXT.md` | Current priorities |
| 2 | This file | LOS spec summary + tasks + consumer inventory |
| 3 | `SESSION-014-PROMPT.md` | Prior **S1-09** handoff program; **visibility = LevelManager A+C** (Phase B4 + goal aligned with Session 015). **`SESSION-015-PROMPT.md`** is the LOS spec of record. |
| 4 | `design/gdd/bonnie-traversal.md` | Stimulus, AC-T, §3.4 |
| 5 | `design/gdd/los-portal.md` | Door / vent phased LOS (stub) |
| 6 | `src/core/level/LevelManager.gd` | Registry + hook for LOS pass |
| 7 | `src/gameplay/bonnie/BonnieController.gd` | **`get_los_*` / `get_current_stimulus_radius`**; **`add_to_group("bonnie")`** |
| 8 | `project.godot` | Physics layers `world`, `semisolid`, **`npc`** — production NPC hulls must **use** layer `npc` when they should block LOS |

---

## Goal

1. **`visible_to_bonnie` = A + C** — Euclidean **distance (A)** to NPC **root** ≤ stimulus radius **and** **line-of-sight (C)** per locked geometry (dual-ray origins on Bonnie, **high-primary** to anatomical **chest**).
2. **Level-owned LOS pass** — `LevelManager` (or autoload entry) runs tier policy + ray queries; **`BonnieController` stays thin** (rig / marker positions only, no per-NPC LOS loop long-term).
3. **`VisibilityLedger`** — canonical read model; **`npc_id` (`StringName`)** key from registration; optional debug mirror on `NpcState` only if kept in sync from ledger (document single writer).
4. **GUT** — atomic tests with **real** `PhysicsDirectSpaceState2D` and **real** layers; **no** fabricated ray results.
5. **Consumer inventory** — complete table below before merge PR; then **§10** decision (hard cutover vs time-boxed flag).

---

## Locked LOS summary (MVP)

| Topic | Lock |
|--------|------|
| **§3 Distance** | 2D Euclidean; **NPC anchor = registered `Node2D.global_position` (root)** |
| **§4 Geometry** | Dual-ray (low + high on Bonnie **`Marker2D` rig**); **high-primary** gates MVP flag |
| **§4 Target** | **Chest** from **nose-bridge** in character-local space; per-profile / art (`*_profile.tres` / IMPORT-GODOT) |
| **§4 Mask** | `world` + `semisolid`; **data-driven** extensibility; **semisolids block**; **NPC bodies** on mask layer when added; **exclude** Bonnie self-hit |
| **§4 Doors** | Phase 1 binary physics; Phase 2 typed LOS — see `design/gdd/los-portal.md` |
| **§5 Ray length** | Segment **Bonnie high → chest**; hits count only **before** target along segment; **early-out** if **A** fails |
| **§5 Appendix** | `max(R, d_chest)` / root–chest tension documented in plan; default LOS length = **`d_chest`** |
| **§6 Occlusion** | Strict + **origin slack** — **provisional `N_origin = 2 px`** on **both** rays until collider audit (document in `BonnieTraversalConfig` or LOS Resource) |
| **§6 Hysteresis** | **Post-MVP** |
| **§7 Cadence** | Tier **A** every `_physics_process` for **in-radius** (+ optional mission-critical ids); Tier **B** in **`(R, R_outer]`** with **`R_outer = R + m·R`**, **`m = 0.75`** (tune 0.5–1.0), **`N = 2`** frames, **`δ = 4 px`** dirty; Tier **C** **zero** casts |
| **§8** | **`LevelManager.gd` > 450 lines (`wc -l`)** → extract **`LevelVisibilityPipeline`**; MVP LOS inline in `LevelManager` |
| **§9 Tests** | Real fixtures; scenarios: clear, wall, cover, out-of-radius, high-primary low-block/high-clear |
| **§10** | **Hard cutover** — no runtime `los_enabled`; A+C authoritative in `LevelManager`. *Time-boxed flag only if Ed documents exception + removal date in Mycelium.* |

---

## Consumer inventory (required before LOS merge PR)

**Complete** = every row filled; **discovery** = `rg visible_to_bonnie`, `rg VisibilityLedger`, design mentions.

| # | Path / system | Read or write site | Owner | Raw vs smoothed (MVP) | Behavior when false |
|---|----------------|-------------------|-------|----------------------|---------------------|
| 1 | `src/gameplay/bonnie/BonnieController.gd` | **`notify_bonnie_stimulus_changed`** → LevelManager; **no** direct `visible_to_bonnie` writes; LOS rig API only | Traversal / gameplay | raw | NPC not in Bonnie bubble for awareness |
| 2 | `src/shared/NpcState.gd` | Field **`visible_to_bonnie`** (synced from LOS pass) | Shared state | raw | Consumers read “not visible” |
| 3 | `src/core/level/LevelManager.gd` | **`register_npc` / `unregister_npc`**; LOS pass writes **`VisibilityLedger`** + **`NpcState.visible_to_bonnie`**; **`get_visibility_ledger()`** | Level / systems | raw | Ledger + state stay false until pass sets true |
| 4 | `src/core/visibility/visibility_ledger.gd` | **`get_visible` / `set_visible`** — single writer: LevelManager LOS pass | Visibility | raw | `get_visible` → false for unknown id |
| 5 | `src/core/visibility/line_of_sight_evaluator.gd` | **N/A** — segment-clear helper only; does not read or write `visible_to_bonnie` | Visibility | N/A | N/A |
| 6 | `tests/unit/test_bonnie_controller_production.gd` | Asserts **`NpcState.visible_to_bonnie`** after LevelManager LOS | QA / agent | raw | Tests expect false when wall blocks / out of radius |
| 7 | `tests/unit/test_npc_state.gd` | Default **`visible_to_bonnie` false** on reset | QA | raw | — |
| 8 | `tests/unit/test_line_of_sight_evaluator.gd` | **N/A** for `visible_to_bonnie` — tests ray segment helper only | QA | N/A | N/A |
| 9 | `design/gdd/bonnie-traversal.md` | Doc / stimulus + LOS (Session 015) | design | — | — |
| 10 | `design/gdd/npc-personality.md` | Doc; field on shared state | design | — | — |
| 11 | `design/gdd/bidirectional-social-system.md` | Preconditions (future S1-12) | design | raw (future) | Social interaction range |
| 12 | `design/gdd/chaos-meter.md` | May read flag (S1-15) — **confirm when implemented** | TBD | raw | TBD |
| 13 | `design/gdd/los-portal.md` | Doc — doors / vents phased LOS | design | — | — |
| 14 | `production/sprints/sprint-1.md` | AC wording; frame order | producer | — | — |
| 15 | `CHANGELOG.md` | Documents LOS + `visible_to_bonnie` behavior | producer / release | — | — |
| 16 | `DEVLOG.md` | Session log references LOS stack | producer | — | — |

**Discovery (`src/` rg, 2026-04-19):** `visible_to_bonnie` / ledger sync — `NpcState.gd`, `LevelManager.gd`. **`VisibilityLedger` / `get_visibility_ledger`:** `LevelManager.gd` only. **`register_npc`:** `LevelManager.gd` only.

---

## Implementation checklist (suggested order)

1. **Resource(s)** — LOS mask bits, `m`, `N`, `δ`, `N_origin`, `R_outer` formula from config; extend `BonnieTraversalConfig` or add `LineOfSightConfig.tres`.
2. **`LineOfSightEvaluator`** — pure API: `space_state`, `from`, `to`, `mask`, `exclude` → `bool`; unit-tested in minimal real scene.
3. **`VisibilityLedger`** — `get_visible(npc_id)`, `set_visible(...)`, optional `visibility_changed` signal; **single writer** from LOS pass.
4. **`LevelManager`** — `_physics_process` (or deferred tick): Tier A/B/C; call evaluator (high + optional low); update ledger; **sync** `NpcState.visible_to_bonnie` from ledger **if** sprint AC still expects field on `NpcState` (or migrate consumers to ledger — **inventory gate**).
5. **Bonnie** — Export **`get_los_high_global()` / `get_los_low_global()`** (or `Marker2D` paths); distance-only visibility loop **removed** — **`LevelManager`** owns LOS + ledger sync; keep **`stimulus_radius_updated`** for invalidation/dirty.
6. **`project.godot`** — Add **`npc`** layer when NPC hulls block LOS; document mask.
7. **GUT** — New tests under `res://tests/unit/` per §9; update `test_bonnie_controller_production.gd`.
8. **Docs** — `CHANGELOG.md`, `DEVLOG.md`, Mycelium notes with **SHA**; **`bonnie-traversal.md`** short LOS paragraph if needed.
9. **§10** — **Hard cutover** chosen for Session 015 closure; no `los_enabled` toggle. Revisit only via producer-documented exception in Mycelium.

---

## Integration constraints

- **No `class_name`** on production `BonnieController.gd` (ADR-001).
- **Parallel branches** + **integration session** if camera (S1-10) and traversal touch shared seams (locked producer policy).
- **S1-09 Done** remains **human AC-T01–T08 in S1-17 apartment** — LOS code can land on `main` before that gate.
- **gdcli** + **GUT** green before merge.

---

## Deliverables (session closure)

- [x] `LineOfSightEvaluator` + tests; `VisibilityLedger`; `LevelManager` LOS pass; Bonnie thin rig API.
- [x] Consumer inventory table **complete** in this file (+ PR body as needed).
- [x] **§10 — Hard cutover** recorded here + Mycelium `HEAD` context note after commit; optional `NEXT.md` pointer updated.
- [x] `NEXT.md` — Session 016 working-title stub (S1-10 Camera) for handoff continuity.
- [x] `wc -l` on `LevelManager.gd` — **245** lines (extract pipeline if **> 450**).

---

## Risks

- **Root vs chest** distance edge cases — use §5 appendix; escalate to Ed if §3 anchor must change.
- **Tier B staleness** — `N = 2` + `δ = 4` may need tuning after playtest.
- **Line count** — extract pipeline before `LevelManager` becomes monolithic.
- **NPC hulls** — production `CharacterBody2D` / `Area2D` bodies that should occlude LOS must opt into physics layer **`npc`** when those scenes land (`scenes/` currently has no NPC bodies; audit under **Track C** in closure plan).
