# Production scaffold register (gameplay + UI)

**Purpose:** Honest snapshot of `src/gameplay/**` and `src/ui/**` scripts vs Sprint 1 task IDs. Line counts from `wc -l` (approximate; rerun after edits).

**Legend:** **Substantive** = behavior beyond `_ready` logging. **Scaffold** = placeholder / print only until task lands. **Resource** = `@export` config type only.

| Path | Lines (approx.) | Kind | Sprint / notes |
|------|-----------------|------|----------------|
| `src/gameplay/bonnie/BonnieController.gd` | ~370 | Substantive | **S1-09** — production traversal + LOS rig API |
| `src/gameplay/bonnie/BonnieTraversalConfig.gd` | ~51 | Resource | **S1-08** / S1-09 tuning |
| `src/gameplay/camera/BonnieCamera.gd` | ~6 | Scaffold | **S1-10** — Camera2D shell |
| `src/gameplay/npc/NpcController.gd` | ~6 | Scaffold | **S1-11** |
| `src/gameplay/npc/NpcProfile.gd` | ~20 | Resource | **S1-08** / S1-11 data |
| `src/gameplay/npc/NpcRoutinePhase.gd` | ~4 | Resource | **S1-11** data |
| `src/gameplay/social/SocialSystem.gd` | ~6 | Scaffold | **S1-12** |
| `src/gameplay/social/SocialSystemConfig.gd` | ~9 | Resource | **S1-08** |
| `src/gameplay/chaos/ChaosEventBus.gd` | ~9 | Scaffold (autoload) | **S1-14** — signals only |
| `src/gameplay/chaos/ChaosMeter.gd` | ~6 | Scaffold | **S1-15** |
| `src/gameplay/chaos/ChaosMeterConfig.gd` | ~13 | Resource | **S1-08** |
| `src/gameplay/objects/InteractiveObjectStub.gd` | ~6 | Intentional stub | **S1-13** placeholder per sprint |
| `src/ui/chaos_meter/ChaosMeterUI.gd` | ~6 | Scaffold | **S1-16** |
| `src/ui/chaos_meter/ChaosMeterUIConfig.gd` | ~9 | Resource | **S1-08** / S1-16 |

**Core layer** (`src/core/`) is not duplicated here; **`LevelManager`** (~247 lines) includes Session 015 LOS + registry.

**Handoff:** Treat this table as mandatory context before claiming “Sprint 1 gameplay is done.”
