# Production scaffold register (gameplay + UI)

**Purpose:** Honest snapshot of `src/gameplay/**` and `src/ui/**` scripts vs Sprint 1 task IDs. Line counts from `wc -l` (approximate; rerun after edits).

**Legend:** **Substantive** = behavior beyond `_ready` logging. **Scaffold** = placeholder / print only until task lands. **Resource** = `@export` config type only.

| Path | Lines (approx.) | Kind | Sprint / notes |
|------|-----------------|------|----------------|
| `src/gameplay/bonnie/BonnieController.gd` | ~390 | Substantive | **S1-09** — traversal + LOS + **interactive object impulse bridge** |
| `src/gameplay/bonnie/BonnieTraversalConfig.gd` | ~58 | Resource | **S1-08** / S1-09 / S1-13 tuning |
| `src/gameplay/camera/BonnieCamera.gd` | ~117 | Substantive | **S1-10** |
| `src/gameplay/camera/BonnieCameraConfig.gd` | ~38 | Resource | **S1-10** |
| `src/gameplay/npc/NpcController.gd` | ~201 | Substantive | **S1-11** — decay, REACTING/RECOVERING/VULNERABLE/FED, cascade, overwhelm |
| `src/gameplay/npc/NpcProfile.gd` | ~35 | Resource | **S1-08** / S1-11 — includes overwhelm + receptivity tuning |
| `src/gameplay/npc/NpcRoutinePhase.gd` | ~4 | Resource | **S1-11** data (minimal) |
| `src/gameplay/social/SocialSystem.gd` | ~77 | Substantive | **S1-12** — proximity + interact charm + levity window |
| `src/gameplay/social/SocialSystemConfig.gd` | ~9 | Resource | **S1-08** |
| `src/gameplay/chaos/ChaosEventBus.gd` | ~9 | Scaffold (autoload) | **S1-14** — signals only |
| `src/gameplay/chaos/ChaosMeter.gd` | ~137 | Substantive | **S1-15** — REACTING + object/pest + social_fill + meter_state |
| `src/gameplay/chaos/ChaosMeterConfig.gd` | ~18 | Resource | **S1-08** / S1-15 |
| `src/gameplay/objects/InteractiveObjectStub.gd` | ~6 | Intentional stub | Legacy placeholder; **S1-13** uses `InteractiveObject.gd` |
| `src/gameplay/objects/InteractiveObject.gd` | ~109 | Substantive | **S1-13** — RigidBody2D, weight classes, bus + goodwill radius |
| `src/ui/chaos_meter/ChaosMeterUI.gd` | ~97 | Substantive | **S1-16** — ColorRect bowl + chase (MVP visuals) |
| `src/ui/chaos_meter/ChaosMeterUIConfig.gd` | ~9 | Resource | **S1-08** / S1-16 |

**Core layer** (`src/core/`) is not duplicated here; **`LevelManager`** includes LOS + registry + **`level_elapsed_time`** + **`get_npc_node` / `get_npc_profile`**.

**Production scene:** [`scenes/production/test_apartment.tscn`](../scenes/production/test_apartment.tscn) (S1-17 MVP).

**Handoff:** Treat this table as mandatory context before claiming “Sprint 1 gameplay is done.”
