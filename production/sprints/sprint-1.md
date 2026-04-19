# Sprint 1 — 2026-04-20 to 2026-05-15

## Sprint Goal

Establish the complete production code scaffold and implement all 11 MVP systems, culminating in a playable core loop: BONNIE traverses the Apartment test level, causes chaos with Michael, the social axis unlocks, the Chaos Meter fills on both axes, and the Chaos Meter UI confirms that feeding is achievable — without a debugger or explanation required.

---

## Pre-Sprint Decisions (Locked — Session 009)

All decisions below were made with the user during Session 009 pre-sprint Q&A. They are **immutable** for Sprint 1. Every implementing agent must be briefed on the subset relevant to their task.

### Process Decisions

| ID | Decision | Choice | Notes |
|----|----------|--------|-------|
| B1 | Git branching | Feature branches per system (`feat/s1-XX-name`) | Merge to main after validation |
| B2 | Commit/review cadence | Agent writes, orchestrator reviews and commits | No autonomous commits |
| B3 | Testing approach | Interface/contract tests first → implement → unit tests | GUT test tasks are Should Have |
| B4 | NpcState base class | `RefCounted` | Runtime-only, lightweight, garbage-collected |
| B5 | Config file format | Custom Resource classes (`.tres`) + `.cfg` override layer | Type-safe Inspector editing + headless override |
| C1 | Signal naming | snake_case, no prefix, descriptive verb | e.g., `reacting_started`, `goodwill_changed` |
| C2 | Error handling | `assert()` in debug, graceful degradation in release | Standard practice |

### Level & Art Decisions

| ID | Decision | Choice | Notes |
|----|----------|--------|-------|
| B6 | Test level scope | 3 rooms (living room, kitchen, bedroom) — expand to all 7 as goal | Covers tier 0–2 attenuation |
| B7 | Placeholder art | Minimal pixel art via pixel-plugin (16x16 blobs, color-coded) | Looks like a game, not a debug view |
| S4 | Surface detection | Physics layer metadata on TileMap cells | Requires TileMap-based floors in test level |
| S9 | Chaos Meter UI margin | 8px from viewport edges | Tunable later |

### Gameplay Decisions

| ID | Decision | Choice | Notes |
|----|----------|--------|-------|
| B8 | `interact` button mapping | Rub: F near NPC (WALKING/SNEAKING). Lap Sit: F near seated NPC (IDLE). Meow: F from any distance. Proximity + Purr: automatic. | Confirmed by user |
| S1 | Michael's routine | Morning (0–90s): kitchen. Afternoon (90–180s): living room work. Evening (180s+): TV in living room or bedroom asleep. | Configurable phase timers |
| S2 | Christen arrival | Timer-based, 120 seconds after level start | Configurable |
| S3 | Starting positions | Michael: kitchen. Christen: not present (arrives via S2 timer). | |
| S5 | BONNIE stimulus radius | Area2D circle, 200px default | If player can see NPC, BONNIE is aware |
| S6 | Footstep timing (no sprites) | Timer-based: WALKING 0.4s, RUNNING 0.2s, SNEAKING 0.6s | Replace with animation events when sprites exist |
| S7 | Music mood thresholds | Aligned to UI visual states: calm=EMPTY/CALM, chaotic=WARMING/HOT, dangerous=CONVERGING | |
| S8 | Hunger boost in Sprint 1 | Always false (`bonnie_hunger_context = false`) | Debug toggle in overlay for testing |
| S10 | Interactive Object collision | Real RigidBody2D physics with CharacterBody2D impulse | Not stubs — full physics foundation |

### Audio Decisions

| ID | Decision | Choice | Notes |
|----|----------|--------|-------|
| C4 | Sprint 1 audio | Generate simple placeholder WAV files (beeps, clicks) | Audio feedback testable |
| C5 | AudioStreamRandomizer property | Check `docs/engine-reference/godot/breaking-changes.md` | Resolve before S1-05 |
| C6 | NPC vocal samples | User will deliver when needed | No programmatic tool yet |
| C7 | Level 2 music | User will compose; team discusses direction with audio-director | Placeholder tracks for Sprint 1 |

### Debug Overlay (S1-23)

Confirmed content: BONNIE state, velocity, current room, Michael NpcState (emotional_level, goodwill, behavior), Christen NpcState, chaos_fill, social_fill, meter_value, meter_state, FeedingPathType, frame time. F1 toggle.

---

## Production Code Architecture

### Directory Structure

```
src/
├── core/                                 # Engine-layer — NEVER imports from gameplay/
│   ├── input/
│   │   ├── InputSystem.gd                # Autoload — action maps, deadzone config
│   │   └── InputSystemConfig.gd          # Resource type
│   ├── audio/
│   │   ├── AudioManager.gd               # Autoload — bus management
│   │   └── AudioEventBus.gd              # Enums + signal hub
│   ├── viewport/
│   │   └── ViewportConfig.gd             # Boot-time script
│   └── level/
│       ├── LevelManager.gd               # Autoload — scene lifecycle, NPC registry
│       └── LevelConfig.gd                # Resource type
├── gameplay/                             # Gameplay — NEVER imports from ui/
│   ├── bonnie/
│   │   ├── BonnieController.gd           # CharacterBody2D — production traversal
│   │   └── BonnieTraversalConfig.gd      # Resource — all tuning knobs
│   ├── camera/
│   │   └── BonnieCamera.gd               # Camera2D
│   ├── npc/
│   │   ├── NpcController.gd              # Node — NPC state machine + routine
│   │   ├── NpcProfile.gd                 # Resource — per-NPC knobs
│   │   └── NpcRoutinePhase.gd            # Resource — per-phase config
│   ├── social/
│   │   ├── SocialSystem.gd               # Node — reads/writes NpcState
│   │   └── SocialSystemConfig.gd         # Resource
│   ├── chaos/
│   │   ├── ChaosMeter.gd                 # Node — aggregates fills
│   │   ├── ChaosMeterConfig.gd           # Resource
│   │   └── ChaosEventBus.gd              # Autoload — stub for Systems 8 & 15
│   └── objects/
│       └── InteractiveObjectStub.gd      # Node — MVP chaos event emitter
├── ui/                                   # Display only — reads gameplay, writes nothing
│   └── chaos_meter/
│       ├── ChaosMeterUI.gd               # CanvasLayer — bowl widget
│       └── ChaosMeterUIConfig.gd         # Resource
└── shared/
    ├── NpcState.gd                       # class_name NpcState — shared data object
    └── enums.gd                          # All project-wide enums
```

**Dependency direction strictly enforced:** `core/` ← `gameplay/` ← `ui/`. No reverse imports.

### Autoloads

| Singleton | Script | Role |
|-----------|--------|------|
| `InputSystem` | `src/core/input/InputSystem.gd` | Action map, deadzone API |
| `AudioManager` | `src/core/audio/AudioManager.gd` | Bus management |
| `LevelManager` | `src/core/level/LevelManager.gd` | Scene loading, NPC registry |
| `ChaosEventBus` | `src/gameplay/chaos/ChaosEventBus.gd` | Systems 8 & 15 provisional signal relay |

No game state lives in autoloads.

### Frame Execution Order (process_priority)

| Order | Node | Priority | Responsibility |
|-------|------|:--------:|----------------|
| 1 | `BonnieController` | 10 | Traversal; writes `visible_to_bonnie` on nearby NpcState |
| 2 | `NpcController` (all) | 20 | Stimulus processing; state machine tick; `emotional_level` decay |
| 3 | `SocialSystem` | 30 | Reads NpcState → resolves interactions → writes `goodwill` + timestamps |
| 4 | `ChaosMeter` | 40 | Reads NpcState goodwill; aggregates fills |
| 5 | `ChaosMeterUI` | `_process` | Reads ChaosMeter → draws widget (no 1-frame lag) |

### Data / Config Structure

All tuning knobs in `assets/data/` as typed `.tres` Resource files. No float literals in gameplay `.gd` files.

```
assets/data/
├── bonnie_traversal_config.tres
├── npc/
│   ├── michael_profile.tres
│   └── christen_profile.tres
├── social_system_config.tres
├── chaos_meter_config.tres
├── chaos_meter_ui_config.tres
└── levels/
    └── apartment_config.tres     # level_chaos_baseline = 0.0
```

**Runtime invariant:** `ChaosMeter._ready()` asserts `chaos_fill_cap + social_fill_weight == 1.0` and fails loud if violated.

---

## Capacity

4-week sprint. 5 concurrent agents × 20 days = 100 raw agent-sessions → ~80 effective (20% coordination overhead). Estimated sprint load: ~36.5 sessions. Significant headroom exists; parallelism is maximal in Weeks 1–2 (Foundation Layer systems are fully independent).

**Critical path (serialized):**
`NpcState definition → Traversal → NPC System → Social System → Chaos Meter → Chaos Meter UI → Test Level Assembly`

---

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Sessions | Dependencies | Acceptance Criteria | Status |
|----|------|-------------|:---:|---|---|---|
| **S1-01** | Infrastructure: `src/` scaffold, GUT 7.x install, `project.godot` baseline | `godot-specialist` | 1 | — | `src/` structure matches spec; GUT installed and first run exits clean; autoloads registered; `gdcli lint src/` exits 0 | Pending |
| **S1-02** | ADR-001: Production Architecture | `lead-programmer` | 1 | — | `docs/architecture/ADR-001-production-architecture.md` committed; covers autoload rationale, dependency direction, NpcState pattern, Systems 8 & 15 stub contracts, frame execution order | Pending |
| **S1-03** | System 2: Viewport / Rendering Config | `godot-specialist` | 1 | S1-01 | 720×540 internal; nearest-neighbor filtering; GL Compatibility; `ViewportConfig.gd` validates on boot; no blur at 2× window scale confirmed by QA | **Done** (Session 010b) |
| **S1-04** | System 1: Input System | `godot-gdscript-specialist` | 1 | S1-01, S1-03 | `get_move_vector()` deadzone-normalized; all 9 actions in `project.godot`; keyboard + gamepad both bound; `InputSystemConfig.tres` holds `stick_deadzone = 0.2`, `sneak_threshold = 0.35`; GUT test: analog input within deadzone spec | **Done** (Session 010b) |
| **S1-05** | System 3: Audio Manager | `godot-gdscript-specialist` | 1 | S1-01, S1-03 | 4 buses (Master, Music, SFX, Ambient); `play_sfx()`, `play_music()`, `crossfade_music()`, `set_bus_volume()` API; no direct `AudioStreamPlayer` calls from gameplay; GUT: all API callable headless without error | **Done** (Session 013 — merged to **`main` 2026-04-19**; buses + API + `test_audio_manager.gd`; catalog WAV/OGG under `res://assets/audio/` optional) |
| **S1-06** | `NpcState` data object + shared enums | `godot-gdscript-specialist` | 1 | S1-01 | All fields from npc-personality §3.1 + Social extensions (`last_interaction_timestamp: float`, `recovering_comfort_stacks: int`); `NpcBehavior` (11), `InteractionType`, `MeterState` (6), `ChaosSeverity` (4), `FeedingPathType`, `BonnieState` (13) all in `enums.gd`; GUT: initializes with Michael defaults | Pending |
| **S1-07** | System 5: Level Manager | `godot-gdscript-specialist` | 2 | S1-01, S1-03, S1-06 | `register_npc()`, `get_npc_state()`, `get_active_npc_count()`, `get_room_id_at()` API; `apartment_config.tres` with `level_chaos_baseline = 0.0`; GUT: NPC registration round-trip; baseline applied on level load | Pending |
| **S1-08** | Config `.tres` data files — all 11 MVP systems | `godot-gdscript-specialist` | 1 | S1-06 | All 7 files in `assets/data/` with GDD §7 defaults; zero float literals in any `src/gameplay/*.gd`; `gdcli` validates all resources load clean | Pending |
| **S1-09** | System 6: BONNIE Traversal — production rewrite | `godot-gdscript-specialist` | 3 | S1-04, S1-08 | All 13 states; all values from `.tres`; signals `state_changed`, `stimulus_radius_updated`; writes `visible_to_bonnie` on NpcState; AC-T01 through AC-T08 all pass; prototype moved to `prototypes/archived/` only after AC validation | Pending |
| **S1-10** | System 4: Camera System | `godot-gdscript-specialist` | 2 | S1-09 | Look-ahead per state via `LOOK_AHEAD_BY_STATE` table; smooth follow (no whip on reversal); ground-biased vertical framing; all AC-T08 pass | Pending |
| **S1-11** | System 9: Reactive NPC System | `godot-gdscript-specialist` | 3 | S1-06, S1-07, S1-09 | 11-state machine; `emotional_level` decay (§4.1); `comfort_receptivity` transitions (§4.3); Domino Rally cascade depth ≤ 2 with `cascade_source_id` loop prevention; Michael + Christen from `.tres`; phase routine timer (pauses outside ROUTINE); Christen arrival trigger on Michael Afternoon → Evening; AC-01 through AC-11 pass; GUT: decay formula, cascade loop blocked, FED gate both-conditions required | Pending |
| **S1-12** | System 12: Bidirectional Social System | `godot-gdscript-specialist` | 2 | S1-11 | All 5 interactions (Proximity, Rub, Lap Sit, Purr, Meow); NPC state gate + BONNIE movement state gate enforced; levity multiplier with timestamp; RECOVERING always levity-eligible; `recovering_comfort_stacks` per NPC; `passive_accumulator` levity-window protection; AWARE conversion via `deescalation_event` signal; AC-S01 through AC-S13 pass; GUT: levity truth table, passive equilibrium math, meow resolution | Pending |
| **S1-13** | System 7: Interactive Objects — physics foundation | `godot-gdscript-specialist` | 2 | S1-09, S1-05 | `InteractiveObject.gd` on RigidBody2D with explicit CharacterBody2D→RigidBody2D impulse application (Godot 4 requires this); weight classes (Light/Medium/Heavy/Glass/Liquid) from GDD §3.1; emits `chaos_event_received(npc_id, severity)` to `SocialSystem` and `object_chaos_event(value)` to `ChaosEventBus`; two objects in test scene (CoffeeMug Light, Bookshelf Medium); physics material tuning for weight feel; acceptance: slide into CoffeeMug at full speed sends it off table, decrements Michael's goodwill by `0.10`, increments `chaos_fill` by `0.02` within 1 frame; object feels like it has real mass | Pending |
| **S1-14** | Stub interfaces: Systems 8 & 15 | `godot-gdscript-specialist` | 1 | S1-01 | `ChaosEventBus` defines `object_chaos_event(value: float)` and `pest_caught(pest_type: int)`; `ChaosMeter` subscribes; stubs silent in Sprint 1; GUT: manual signal emit correctly increments `chaos_fill` | Pending |
| **S1-15** | System 13: Chaos Meter | `godot-gdscript-specialist` | 2 | S1-11, S1-12, S1-14 | Accumulates `chaos_fill` from REACTING events (§4.1 formula); derives `social_fill` each frame (§4.4 formula, normalized by `active_npc_count`); `chaos_event_count` session counter; `meter_value` + `meter_state` computed; overwhelm check (Michael 8, Christen 7); `FeedingPathType` tracked; invariant asserted in `_ready()`; AC-CM-01 through AC-CM-09 pass; GUT: pure chaos plateau, pure charm gate, combined path, hunger boost | Pending |
| **S1-16** | System 23: Chaos Meter UI | `ui-programmer` | 2 | S1-15, S1-05, S1-03 | Bowl widget bottom-right; chaos zone 16×35px, social zone 16×29px, cap line always visible; fill chase interpolation at `fill_chase_speed = 4.0` with integer pixel quantization; all 6 state visual changes; overwhelm anti-signal (stays HOT); audio signals on state transitions; reduced-motion mode; programmer-art placeholders (ColorRect layers); AC-UI-01 through AC-UI-13 pass | Pending |
| **S1-17** | Test Apartment Level Assembly | `godot-specialist` | 2 | S1-09–S1-16 | `test_apartment.tscn` with 3 rooms (kitchen, living room, bedroom) as TileMap-based floors with surface type metadata (hardwood=kitchen, carpet=living room+bedroom); room boundary Area2D triggers; all signal connections at scene level; `LevelManager` loads correctly; Christen deactivated until 120s arrival timer; Michael starts in kitchen; 2+ interactive objects placed on surfaces; `gdcli run --headless` completes without errors | Pending |
| **S1-18** | Core Loop Playtest Validation | `qa-tester` | 1 | S1-17 | Undocumented playtester can: move BONNIE through all key states, trigger Michael REACTING ×2, charm during RECOVERING, watch meter fill on both axes, see all 6 UI states, confirm FED fires, confirm overwhelm path withholds FEEDING visual; playtest report → `prototypes/bonnie-traversal/PLAYTEST-004.md` | Pending |

**Must Have total: ~35 agent-sessions** (adjusted: S1-13 1→2, S1-17 1→2)

### Should Have

| ID | Task | Agent/Owner | Est. Sessions | Dependencies | Status |
|----|------|-------------|:---:|---|---|
| S1-19 | GUT tests: Traversal state machine | `godot-gdscript-specialist` | 1 | S1-09 | Pending |
| S1-20 | GUT tests: NPC System formulas | `godot-gdscript-specialist` | 1 | S1-11 | Pending |
| S1-21 | GUT tests: Social System | `godot-gdscript-specialist` | 1 | S1-12 | Pending |
| S1-22 | GUT tests: Chaos Meter formulas | `godot-gdscript-specialist` | 1 | S1-15 | Pending |
| S1-23 | Debug overlay (NpcState + meter values, F1 toggle) | `godot-gdscript-specialist` | 1 | S1-11, S1-15 | Pending |
| S1-24 | ADR-002: NPC State Machine Architecture | `lead-programmer` | 0.5 | S1-11 | Pending |

### Nice to Have (Cut First)

| ID | Task | Agent/Owner | Est. Sessions | Notes |
|----|------|-------------|:---:|---|
| S1-25 | Christen flee behavior — full implementation | `godot-gdscript-specialist` | 1 | Likely absorbed into S1-11; only needed as separate task if S1-11 scopes it out |
| S1-26 | Cascade depth-2 explicit validation test | `godot-gdscript-specialist` | 0.5 | Validates AC-CM-05 and AC-07 in isolation |
| S1-27 | `gdcli` CI validation shell script | `devops-engineer` | 0.5 | `scripts/validate.sh` — lint + headless GUT |

---

## Risks to This Sprint

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| Traversal production rewrite loses prototype feel | High | Critical | Retain prototype in `prototypes/bonnie-traversal/` until all AC-T0x pass; run both side-by-side; same agent who reviewed the prototype validates the AC | `lead-programmer` |
| NPC System exceeds 3 sessions | High | High | Scope Michael-only first; Christen can be a zero-behavior stub for the first playtest; validate AC-01 through AC-08 before starting Christen implementation | `lead-programmer` |
| GUT 7.x incompatible with Godot 4.6 | Medium | High | Verify in S1-01 before any test work; fallback: inline `assert()` in a test scene; Should Have test tasks slip, not Must Have implementation | `godot-specialist` |
| `NpcState` field gaps mid-implementation | Medium | High | S1-06 cross-references npc-personality §3.1, bidirectional-social §3.1, and chaos-meter §6 before any downstream task starts; any gap after S1-06 ships simultaneously blocks S1-11, S1-12, and S1-15 | `lead-programmer` |
| Frame execution order not clean in Godot | Medium | Medium | `process_priority` specified in each task's AC; debug overlay (S1-23) includes timing assertion to confirm ordering | `godot-specialist` |
| Interactive Object stub insufficient for social axis wiring | Low | High | Scope S1-13 to signal-emission only — no physics, no destruction animation; the signal is what matters | `lead-programmer` |
| Chaos Meter UI blocked on bowl pixel art | Low | Low | `ColorRect` programmer art is sufficient for all AC-UI criteria; no Aseprite assets required in Sprint 1 | `ui-programmer` |

---

## External Dependencies

| Dependency | Status | Impact if Delayed | Contingency |
|------------|--------|------------------|-------------|
| Godot 4.6.2 stable binary | Assumed available | Sprint blocked | Use 4.6.1; document in ADR-001 |
| GUT addon v7.x | Unverified | Should Have tests blocked; Must Have unaffected | Inline `assert()` fallback |
| `gdcli` (`npx -y gdcli-godot`) | Assumed available | CI validation unavailable | Manual editor validation; not a sprint blocker |
| Audio assets | Not available | AudioManager tests use silent stubs | `AudioStreamWAV` placeholder; headless-safe |

---

## Definition of Done

- [ ] All 18 Must Have tasks in Completed status
- [ ] All Must Have acceptance criteria verified by `qa-tester` in S1-18 playtest
- [ ] `gdcli lint src/` exits 0 — zero linting errors
- [ ] GUT suite passes headless (S1-19 through S1-22)
- [ ] `gdcli run --headless test_apartment.tscn` completes without errors
- [ ] Debug overlay (S1-23) active and confirming live values during playtest
- [ ] Zero hardcoded float literals in `src/gameplay/` (verified by `grep`)
- [ ] `chaos_fill_cap + social_fill_weight == 1.0` invariant passes in ChaosMeter GUT test
- [ ] ADR-001 written and committed to `docs/architecture/`
- [ ] Playtest report written to `prototypes/bonnie-traversal/PLAYTEST-004.md`
- [ ] No `src/` file imports from `prototypes/`
- [ ] All `.tres` files in `assets/data/` load clean headless

---

## Success Metric

**The core loop is testable when:** A playtester with zero documentation can control BONNIE, cause at least one REACTING event with Michael, perform at least one charm interaction during RECOVERING, watch the Chaos Meter UI respond to both axes, and confirm the FED condition fires — without a debugger, code explanation, or written tutorial. This is Gate 3's pre-condition.
