# ADR-001: Production code architecture (Sprint 1)

## Status

Accepted — Session 010 (implements Sprint 1 plan `production/sprints/sprint-1.md`).

## Context

Design phase is closed (GATE 2/3 PASS). Production code lives under `src/` with strict layering. The traversal prototype under `prototypes/bonnie-traversal/` validated GATE 1 (CONDITIONAL PASS) and remains **read-only reference** until production traversal passes acceptance tests (S1-09); it must not be imported from `src/`.

## Decision: directory layout

Match the Sprint 1 architecture tree:

- `src/core/` — engine-adjacent systems (input, audio, viewport boot, level lifecycle). **Never** imports from `gameplay/` or `ui/`.
- `src/gameplay/` — BONNIE, NPC, social, chaos, objects, camera. **Never** imports from `ui/`.
- `src/ui/` — presentation only (e.g. Chaos Meter UI). May read gameplay state via injected references or signals; **does not** own simulation state.
- `src/shared/` — cross-layer types (`NpcState`, enums module).

## Decision: dependency direction

**`core` ← `gameplay` ← `ui`**, as enforced in `production/sprints/sprint-1.md`. `shared` is referenced from `core` and `gameplay` (and later `ui` for read-only display types where needed). Violations are architectural defects, not style nits.

## Decision: autoloads (four only)

| Singleton | Path | Role |
|-----------|------|------|
| `InputSystem` | `src/core/input/InputSystem.gd` | Action map, deadzone API (System 1). |
| `AudioManager` | `src/core/audio/AudioManager.gd` | Buses and playback API (System 3). |
| `LevelManager` | `src/core/level/LevelManager.gd` | Scene lifecycle, NPC registry (System 5). |
| `ChaosEventBus` | `src/gameplay/chaos/ChaosEventBus.gd` | Provisional signals for Systems 8 and 15. |

**No game state** in autoload singletons beyond wiring and service APIs (sprint invariant).

`ChaosEventBus` exposes at minimum:

- `object_chaos_event(value: float)`
- `pest_caught(pest_type: int)`

Full stub behavior and GUT coverage land in **S1-14**.

## Decision: `NpcState` pattern

- Base type: **`RefCounted`** (Pre-Sprint **B4**). Runtime-only, lightweight, not a `Node`.
- **S1-06** defines all fields per `design/gdd/npc-personality.md` §3.1 plus social extensions (`last_interaction_timestamp`, `recovering_comfort_stacks`) and moves enumeration definitions into `src/shared/enums.gd` per sprint acceptance criteria.
- **Writers:** primarily System 9 (NPC) and System 12 (Social) per GDD contracts; **readers:** Chaos Meter (13), Chaos Meter UI (23), debug overlay (S1-23). No cross-system direct calls bypassing `NpcState` for MVP NPC/social/chaos data.

## Decision: Systems 8 and 15 boundary

Environmental Chaos (8) and Pest / Survival (15) are **not** MVP-complete in Sprint 1. `ChaosEventBus` is the stable seam: MVP systems subscribe and ignore until vertical slice work fills behavior. Chaos Meter (13) consumes chaos-relevant signals only as specified in its GDD.

## Decision: frame execution order

Use Godot `process_priority` per sprint table when multiple systems must read/write in order (BonnieController → NPC → Social → ChaosMeter → ChaosMeterUI). **S1-23** Should-Have overlay may add timing assertions.

## Decision: configuration and data

- **Custom Resources (`.tres`)** plus **`.cfg` overrides** (**B5**) for tuning.
- Target layout under `assets/data/` per sprint; **S1-08** creates the typed resources.
- Sprint Definition of Done: no raw float literals in `src/gameplay/*.gd` once configs exist (enforced from S1-08 onward).

## Decision: `class_name BonnieController` conflict

The prototype script `prototypes/bonnie-traversal/BonnieController.gd` already registers global `BonnieController`. Production `src/gameplay/bonnie/BonnieController.gd` **does not** declare `class_name BonnieController` until the prototype is archived after AC validation (**S1-09**). Then production reclaims the global name if still desired.

## Decision: testing stack

- **GUT** via **bitwes/Gut v9.6.0** (Godot 4.6.x). Sprint prose referenced “GUT 7.x”; **7.x targets Godot 3.x** — this project standardizes on **GUT 9.x** for 4.6.
- After adding or upgrading editor plugins, CI and agents should run **`godot --headless --import --path .`** once so global `class_name` registrations (including GutTest) exist before **`gut_cmdln.gd`** runs.
- Primary CLI pattern: `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -- -gdir=res://tests/unit -gexit`. **gdcli** remains the preferred **lint** tool (`npx -y gdcli-godot script lint`); use Shell, not MCP `CallMcpTool`, per `.claude/skills/godot-mcp/SKILL.md`.

## Decision: `run/main_scene`

Until **S1-17** delivers the production test apartment scene, **`run/main_scene`** stays on the prototype `TestLevel.tscn` so Play in editor remains a valid traversal sandbox.

## Consequences

- Positive: clear merge boundaries for feature branches (`feat/s1-XX-*`), contract-first work on **S1-06** before parallel gameplay streams.
- Negative: temporary duplication of “Bonnie controller” naming (prototype global class vs production script without `class_name`) until S1-09 archive step.
- Neutral: `.godot/` remains local; import step is required on fresh clones before headless GUT.

## References

- `production/sprints/sprint-1.md` — Pre-Sprint Decisions, task IDs S1-01–S1-18.
- `design/gdd/npc-personality.md` §3.1 — `NpcState` contract.
- `design/gdd/systems-index.md` — MVP system set.
