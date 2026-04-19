# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Pre-Production 0.9.1] — 2026-04-17

### Added — Session 014 (S1-09 slice)

- `SESSION-014-PROMPT.md` — handoff brief (Track A default defer + Track B phases B1–B5, AC-T priority subset, verification).
- `scenes/gameplay/BonnieController.tscn` — production **CharacterBody2D** shell (`CeilingCast` + capsule collision).
- **S1-09** — `src/gameplay/bonnie/BonnieController.gd`: 13-state traversal spine, `state_changed` / `stimulus_radius_updated`, `NpcState.visible_to_bonnie` via `LevelManager.foreach_registered_npc`; ground/air/slide/landing/rough/daze/squeeze/climb/ledge-pullup paths; gameplay tuning from `bonnie_traversal_config.tres` only (expanded `BonnieTraversalConfig.gd`: jump-hold, air-sneak scale, climb/ledge/squeeze/slide-exit shape fields).
- `LevelManager` — `foreach_registered_npc`, `unregister_npc`.
- `tests/unit/test_bonnie_controller_production.gd` — config load, physics smoke, stimulus visibility, `state_changed` under input; `test_level_manager.gd` — foreach + unregister.

### Changed — Session 013 optional polish (docs)

- `PLAYTEST-004.md` — GUT row **18/18** (post–S1-08) with Session 013 baseline note; **Optional polish** subsection for framebuffer vs composite, feel pass, IMPORT-GODOT drift, hygiene
- `SESSION-013-PROMPT.md` — **Optional polish (post-closure)** pointer to PLAYTEST-004
- `tools/capture_verification_013.gd` — run-mode comments (**headless** vs **visible** window)

### Added — Sprint 1 (S1-06–S1-08)

- `src/shared/enums.gd` — `NpcBehavior`, `InteractionType`, `MeterState`, `ChaosSeverity`, `FeedingPathType`, `BonnieState` (preload from gameplay; avoids global class parse order issues)
- `src/shared/stimulus.gd` — minimal stimulus payload for `NpcState.active_stimuli`
- `NpcState` factory defaults — `create_michael_default()` / `create_christen_default()` per npc-personality §7
- `LevelManager` — `register_npc`, `register_room`, `update_npc_room`, `get_npc_state`, `get_active_npc_count`, `get_room_id_at`, `get_level_chaos_baseline`, signals + `level_config` default load
- `assets/data/level_config.tres`, `bonnie_traversal_config.tres`, `chaos_meter_config.tres`, `social_system_config.tres`, `npc/michael_profile.tres`, `npc/christen_profile.tres` — GDD-aligned tuning (seven data files including existing `input_system_config.tres`)
- `tests/unit/test_npc_state.gd`, `tests/unit/test_level_manager.gd` — GUT coverage

### Added — Session 013

- `SESSION-013-PROMPT.md` — integration + audio + Cursor bridge handoff
- `.cursor/hooks.json` + hooks calling `.claude` mycelium/validate paths; `.cursor/skills` → `.claude/skills` symlinks; `docs/CREDITS.md`; `prototypes/bonnie-traversal/art/README.md`
- `NpcIdleFromSheet.gd` — NPC `AnimatedSprite2D` loader for Aseprite **json-hash** sheets
- `prototypes/bonnie-traversal/art/npc/source/{michael,christen}-npc-v01.aseprite` + multi-scale **`art/export/npc/*-{16,24,32}px/`** exports (Aseprite MCP `user-aseprite`)
- `prototypes/bonnie-traversal/art/_critique/verification-013/*.png` — five 1× **720×540** composites from **`art/export/**`** (Pillow); `tools/composite_verification_013.py` (CI-safe). `tools/capture_verification_013.gd` — SubViewport grab for visible-Godot runs (dummy GL headless still null)

### Changed — Session 013

- `NEXT.md`, `SESSION-013-PROMPT.md`, `PLAYTEST-004.md`, `DEVLOG.md` — merge dates (**2026-04-19**), **mycelium** backlog cleared, verification rows aligned with **`main`**
- **Mycelium** — stale notes on pre-merge blobs **composted** (`mycelium/scripts/compost-workflow.sh <path-prefix> --compost`); `compost-workflow.sh --report`: **0 stale**
- `tools/composite_verification_013.py` — closure re-run; **`verification-013/*.png`** unchanged in git
- `IMPORT-GODOT.md` — §3.5 **NPC** strips + multi-scale table; §4.3 locomotion **implemented**; §6 **TestLevel** TileMap **`surface`/`terrain`** + semisolid + scene sprite pass; §7 checklist updated
- `PLAYTEST-004.md` — Session 013 integration gate (composite verification stills + automated check results)
- `project.godot` — **`2d_physics` layer names** `world` / `semisolid`; `default_texture_filter=1` (matches `ViewportConfig` / GUT headless)
- `TestLevel.gd` / `TestLevel.tscn` — runtime TileSet **solid + one-way semisolid** row; **Sprite2D** fills for platforms/walls/crates; **one** `ColorRect` greybox (**SoftLandingPad**); **AnimatedSprite2D** NPCs
- `BonnieController.gd` / `.tscn` — **`LocomotionSprite`** strip + **semisolid** `collision_mask` rule; `collision_layer`/`collision_mask` explicit
- `verification-013/` — dropped duplicate legacy filenames (`03_03_*`, `04_04_*`, `05_05_*`); tree matches `composite_verification_013.py` outputs only
- `src/core/audio/AudioManager.gd` — **S1-05**: buses Master/Music/SFX/Ambient, `play_sfx`, `play_music`, `crossfade_music`, `set_bus_volume`; pooled SFX players
- `tests/unit/test_audio_manager.gd` — GUT coverage for audio API headless
- `.gitignore` — ignore `art/npc/source/_scale_work*.aseprite` MCP scale scratch files; **`AI-STUDIO-101.code-workspace`** (local editor; not tracked)

### Added — Session 011
- `docs/CURSOR-AGENTS-WINDOW-HANDOFF.md` — how to run parallel Cursor Agents for Sprint 1 + prototype follow-up

### Changed — Session 011
- `NEXT.md` — Session 012 handoff; `main` merged; immediate work **S1-05** Audio Manager
- `DEVLOG.md` — Session 011 summary (geometry squeeze commit, docs, agent handoff)

### Notes — Session 011 (editor pitfall)
- `project.godot` — if the Godot editor **removes** `window/stretch/aspect="keep"` or `default_texture_filter=1`, restore them; `InputSystem` / `ViewportConfig` assert on boot.
- `prototypes/bonnie-traversal/TestLevel.tscn` — if `Shape_RigidBox` **loses** its `size` line, restore `Vector2(20, 20)` for valid RigidBody2D collision.

---

## [Pre-Production 0.9] — 2026-04-17

### Added — Session 010
- `src/` production scaffold (`core/`, `gameplay/`, `ui/`, `shared/`) per Sprint 1 architecture tree
- Autoloads: `InputSystem`, `AudioManager`, `LevelManager`, `ChaosEventBus`
- `addons/gut/` — GUT **9.6.0** (bitwes/Gut) for Godot 4.6.x; `tests/unit/test_sanity.gd`
- `docs/architecture/ADR-001-production-architecture.md` — production architecture ADR

### Changed — Session 010
- `project.godot`: autoload section + Gut editor plugin enabled
- `NEXT.md`: Session 007 block replaced with Session 008 GATE 1 pointer; Stream A order matches sprint (Viewport → Input)

### Notes — Session 010
- First-time / CI headless GUT: run `godot --headless --import --path .` before `gut_cmdln.gd` (global class registration).

### Added — Session 010 (viewport + input follow-up)
- `assets/data/input_system_config.tres` — `InputSystemConfig` defaults for autoload
- `tests/unit/test_viewport_config.gd`, `test_input_system_config.gd`, `test_input_system.gd`

### Changed — Session 010 (viewport + input follow-up)
- `ViewportConfig.gd`: project-setting validation + `Engine.max_fps = 60` on boot (invoked from `InputSystem`)
- `InputSystem.gd`: loads config, `get_move_vector()`, `should_auto_sneak_from_analog()`, InputMap presence checks
- `project.godot`: `window/stretch/aspect="keep"`; `default_texture_filter=1` (Godot 4.6 `TEXTURE_FILTER_NEAREST`, not legacy `0`)

### GATE Status
- Unchanged from 0.8 (GATE 1 CONDITIONAL PASS, GATE 2/3 PASS)

---

## [Pre-Production 0.8] — 2026-04-17

### Added — Session 009
- `design/gdd/chaos-meter-ui.md` — Chaos Meter UI GDD (System 23), approved
- `production/sprints/sprint-1.md` — Sprint 1 plan with 30 pre-sprint decisions locked
- `.claude/skills/godot-mcp/SKILL.md` — rewritten to match gdcli v0.2.3 command surface

### Changed — Session 009
- GATE 2 status: **Pending** → **PASS** ✅ — all 11 MVP GDDs approved
- GATE 3 status: **Pending** → **PASS** ✅ — Sprint 1 plan approved
- Systems 12, 13 status: "Draft (review-passed)" → **Approved**
- System 23 added and moved through Draft → Draft (review-passed) → **Approved**
- `systems-index.md`: progress tracker 10→11/11 designed, 8→11/11 approved
- `NEXT.md`: rewritten for Session 010 handoff (implementation phase)
- `.gitignore`: added `.gdcli/`

### Fixed — Session 009
- Chaos Meter UI GDD design review: 7 issues (1 critical, 4 moderate, 2 minor) — HOT/CONVERGING visual triggers re-architected, diegetic bowl scope expanded
- gdcli SKILL.md: replaced placeholder content with verified command inventory

### GATE Status
- GATE 0: CLEARED ✅
- GATE 1: **CONDITIONAL PASS** ✅ — Session 008
- GATE 2: **PASS** ✅ — Session 009 (11/11 MVP GDDs approved)
- GATE 3: **PASS** ✅ — Session 009 (Sprint 1 plan approved)

---

## [Pre-Production 0.7] — 2026-04-16

### Added — Session 008
- `design/gdd/chaos-meter.md` — Chaos Meter GDD (System 13), draft, review-passed
- `design/gdd/bidirectional-social-system.md` — Bidirectional Social System GDD (System 12), draft, review-passed
- `prototypes/bonnie-traversal/PLAYTEST-003.md` — Kaneda slide rhythm re-test (code analysis + headless validation)
- `prototypes/bonnie-traversal/GATE-1-AC-ASSESSMENT.md` — formal GATE 1 closure document

### Changed — Session 008
- GATE 1 status: **NEAR-PASS** → **CONDITIONAL PASS** ✅ — traversal feel validated for dependent system GDD authoring
- `systems-index.md`: Systems 12 + 13 status updated to "Draft (review-passed)"; progress tracker 8→10 started/reviewed; fixed circular dependency typo (13→12)
- `NEXT.md`: Updated for Session 009 handoff — T-CHAOS/T-SOC pending approval, Chaos Meter UI unblocked
- `mcp.json` reverted to remove env override (gdcli routed via Shell)

### Fixed — Session 008
- gdcli MCP connectivity — diagnosed as Cursor transport layer issue (`CallMcpTool` hangs); all gdcli operations now use Shell fallback (`npx -y gdcli-godot ...`)
- Design review findings: stale best-of-N paragraph, dead §4.2.1 ref, arithmetic error in Sources table, missing cap enforcement in comfort acceleration, missing BONNIE states in interaction matrix, unclear reset target, ambiguous counter ownership

### GATE Status
- GATE 1: **CONDITIONAL PASS** ✅ — 5 ACs PASS, 1 CODE VERIFIED, 2 DEFERRED (user decision), 4 PARTIAL (asset-dependent)
- GATE 2: Pending — 10/11 MVP GDDs designed (8 approved + 2 review-passed pending approval; Chaos Meter UI remaining)

---

## [Pre-Production 0.6] — 2026-04-15

### Fixed — Prototype (Session 006)
- B02 (regression/incomplete): SQUEEZING fully fixed — three-layer fix:
  (1) `groups=["SqueezeTrigger"]` moved to node header (was silently ignored as body property)
  (2) SqueezeApproachLeft/Right removed (tops at y=468 = zero clearance, physically blocked entry)
  (3) `CollisionShape2D` position `Vector2(0,0)` → `Vector2(0,14)` — squeeze shape now floor-aligned; eliminates float→fall→squeeze cycle
- B07: F5 macOS shortcut — documented workaround: use Play button (▶️) or Cmd+B in Godot editor
- B08: LEDGE_PULLUP redesigned — replaced auto-fire with two-phase directional pop system (DI-001)

### Added — Prototype (Session 006)
- DI-001: LEDGE_PULLUP directional pop — Phase 1 cling reads directional input; Phase 2 resolves as momentum-carry launch or stationary pullup
- DI-003: Claw brake during SLIDING — E key removes `abs(velocity.x) * claw_brake_multiplier` per tap; ~3 taps from full speed to stop
- Mid-air climbing: E-press during JUMPING/FALLING while touching Climbable → instant CLIMBING entry
- E-scramble burst: pressing E during CLIMBING fires `climb_claw_impulse` for `climb_claw_burst_frames` — more cat-like than smooth surface slide
- Auto-clamber: CLIMBING state exits to JUMPING without player UP input when `is_on_ceiling()` or slide normal y > 0.5
- `_squeeze_zone_active` flag-based SQUEEZING trigger — safe from physics flushing errors; replaces CeilingCast-based entry

### Added — GDDs (Session 006)
- `design/gdd/level-manager.md` — Level Manager GDD approved (System #5): 7-room apartment topology, BFS cascade attenuation, mood-based music transitions, post-win contract
- `design/gdd/interactive-object-system.md` — Interactive Object System GDD approved (System #7): 5 weight classes, `receive_impact()` contract, liquid two-signal pattern, object_displaced stimulus

### Changed — GDDs (Session 006)
- `design/gdd/bonnie-traversal.md` — DI-001 + DI-003 amendments: LEDGE_PULLUP two-phase redesign, SLIDING claw brake formula, 4 new tuning knobs, 2 new ACs (AC-T06c2, AC-T06f)
- `design/gdd/input-system.md` — E key `grab` action expanded: context-sensitive across FALLING/JUMPING (ledge parry), SLIDING (claw brake); CLIMBING excluded from claw brake
- `design/gdd/audio-manager.md` — Level 2 apartment music: single track → 4 mood variants (calm/chaotic/dangerous/other)
- `design/gdd/systems-index.md` — Systems 5 and 7 status → Approved; progress 6/11 → 8/11 MVP

### Added — Infrastructure (Session 006)
- `.claude/hooks/pre-tool-use-mycelium.sh` — runs `context-workflow.sh` before Write/Edit; guards uncommitted files via `git rev-parse --verify`
- `.claude/hooks/post-tool-use-mycelium.sh` — tracks touched file paths to `.mycelium-touched` for departure reminder
- `.claude/settings.json` — PreToolUse `Write|Edit` → mycelium hook; PostToolUse `Write|Edit` → mycelium hook

### GATE Status
- GATE 1: **CONDITIONALLY NEAR-PASS** — 5 ACs passing. Slide rhythm + camera lead remain before final call.

---

## [Pre-Production 0.5] — 2026-04-13

### Fixed — Prototype Bugs
- B01: CLIMBING state had no ground-based entry — added grab-near-Climbable from IDLE/WALK/RUN/SNEAK
- B02: SQUEEZING state was completely unreachable — added CeilingCast RayCast2D auto-trigger
- B03: `parry_window_frames` tuning knob existed but had no effect — temporal window now implemented
- B04: ParryCast circle detected floor geometry as valid parry targets — directional filter added

### Added — Prototype
- Debug HUD (CanvasLayer/RichTextLabel) — shows state, velocity, all timer states, fall distance, proximity flags
- `prototypes/bonnie-traversal/PLAYTEST-001.md` — Session 005 playtest report documenting GATE 1 NEEDS WORK status

### Added — Infrastructure
- Mycelium seeded with 6 live notes: renderer constraint, audio pitch semitone constraint, traversal constraints (no auto-grab, skid multiplier, no death), performance budget constraint, prototype warning (5 known shortcuts), NPC scope warning, NPC↔Social circular dependency constraint

### Changed — Documentation
- `quick-start.md` — removed Unity/Unreal-specific agent references; scoped to Godot/BONNIE!
- `npc-personality.md` — added scope clarification note: Systems 10+11 are Vertical Slice, not MVP
- `input-system.md` — resolved stale cross-ref note (CLIMBING exit was already correct in traversal GDD)
- `NEXT.md` — updated for Session 006 handoff (GATE 1 NEEDS WORK, re-playtest protocol)

### GATE Status
- GATE 1: **NEEDS WORK** — re-playtest required after prototype fixes

---

## [Pre-Production 0.4] — 2026-04-13

### Fixed
- BONNIE invisible — PlaceholderSprite changed from black to warm orange for playtesting
- Wrong renderer — Forward+ (3D) switched to GL Compatibility (2D), eliminating 60+ stale 3D shader caches

### Changed
- `detect-gaps.sh` — cached output, skips expensive scans if design/src/prototypes unchanged
- `session-start.sh` — renderer guard warns if wrong renderer for project type
- `validate-commit.sh` — all 8 GDD sections checked by name, Python absence now surfaces as visible warning

### Added
- Session 002 entries in DEVLOG.md + CHANGELOG.md (were missing)
- `production/session-state/active.md` — live session checkpoint file

### Design Decisions Locked
- GL Compatibility renderer — Forward+ forbidden for this 2D project

---

## [Pre-Production 0.2] — 2026-04-08

### Added
- Viewport Config GDD (`design/gdd/viewport-config.md`) — 720×540, nearest-neighbor, 4:3 locked, integer scaling
- Camera System GDD (`design/gdd/camera-system.md`) — look-ahead, ledge bias, recon zoom, per-state values

### Changed
- GATE 0 cleared — prototype stream unblocked

---

## [Pre-Production 0.1] — 2026-04-05

### Added — BONNIE! Design Sprint 0

**Game Design Documents:**
- `design/gdd/game-concept.md` — Complete game bible: concept, player fantasy, MDA analysis,
  mechanics overview, NPC dialogue/audio spec, mini-games, end-of-level payoff structure,
  game pillars + anti-pillars, inspiration references, player profile, technical considerations,
  full 5-level arc, replayability architecture, risks, MVP definition, scope tiers
- `design/gdd/systems-index.md` — 27-system dependency map with full dependency graph,
  priority tier breakdown (MVP/VS/Alpha/Full Vision), design order, effort estimates,
  high-risk system flags, and progress tracker
- `design/gdd/npc-personality.md` — NPC Personality System GDD (Systems 9+10):
  11-state behavioral machine, NpcState interface (8 fields), Michael+Christen MVP profiles,
  Domino Rally cascade rules, all formulas (emotional decay, goodwill, comfort_receptivity,
  cascade, feeding threshold), 8 edge cases, dependency map, tuning knobs, 8 acceptance criteria
- `design/gdd/bonnie-traversal.md` — BONNIE Traversal System GDD (System 6):
  13-state movement vocabulary, Ledge Parry mechanic, Kaneda slide, double jump (apex-locked),
  wall jump (climbable surfaces only), Nine Lives / no-death physics contract,
  complete formulas, 12 edge cases, tuning knob table, 12 acceptance criteria

**Studio Infrastructure:**
- Mycelium knowledge layer — structured git notes with session hooks (session-start,
  session-stop, pre-compact), mandatory departure protocol, notes push/fetch wired to remote
- Godot 4.6 engine reference — breaking changes (4.4→4.5→4.6), deprecated APIs,
  current best practices, verified sources (engine pinned 2026-02-12)

**Documentation:**
- `DEVLOG.md` — development log, session-by-session record of decisions and progress
- `CHANGELOG.md` — this file

---

## [0.3.0] — 2026-04-04

### Added — Claude Code Game Studios Framework

- `/design-system` skill — guided, section-by-section GDD authoring for a single game system
- `/map-systems` skill — decompose a game concept into individual systems with dependency mapping
- Status line integration — session context breadcrumb (Epic > Feature > Task)
- `UPGRADING.md` — step-by-step migration guide for template updates between versions

---

## [0.2.0] — 2026-04-04

### Added — Claude Code Game Studios Framework

- Context resilience system — `production/session-state/active.md` as living checkpoint,
  incremental file-writing protocol, recovery-after-crash workflow
- `AskUserQuestion` tool integration for structured clarification requests
- `/design-systems` skill (precursor to `/design-system`)
- `.claude/docs/context-management.md` — context budget guidance and compaction instructions

---

## [0.1.0] — 2026-04-04

### Added — Claude Code Game Studios Framework

Initial public release of the Claude Code Game Studios template:

- **48 specialized agents** across design, programming, art, audio, narrative, QA, and production
- **37 slash command skills** (`/start`, `/sprint-plan`, `/prototype`, `/playtest-report`, etc.)
- **8 automated hooks** — commit validation, push validation, asset validation, session
  lifecycle (start/stop), context compaction, agent audit trail, documentation gap detection
- **11 path-scoped coding rules** — standards auto-enforced by file location
- **29 document templates** — GDDs, ADRs, sprint plans, economy models, faction design, etc.
- **Engine specialist agent sets**: Godot 4 (GDScript + Shaders + GDExtension),
  Unity (DOTS/ECS + Shaders + Addressables + UI Toolkit),
  Unreal Engine 5 (GAS + Blueprints + Replication + UMG/CommonUI)
- Studio hierarchy: 3-tier delegation (Directors → Leads → Specialists)
- Collaborative protocol: Question → Options → Decision → Draft → Approval

## [Pre-Production 0.3] — 2026-04-11

### Added
- Input System GDD (`design/gdd/input-system.md`) — 10 actions, buffering rules, analog thresholds
- Audio Manager GDD (`design/gdd/audio-manager.md`) — full event catalogue, bus hierarchy, playback API
- Traversal prototype: `project.godot`, `BonnieController.gd` (full 13-state implementation), `BonnieController.tscn`, `TestLevel.tscn` (10 test zones), `README.md`

### Changed
- `design/gdd/npc-personality.md` — Christen routine fully specified (arrival trigger, phase durations, flee/stress-carry)
- `design/gdd/bonnie-traversal.md` — CLIMBING exit corrected: IDLE → LEDGE_PULLUP
- `design/gdd/systems-index.md` — 6/11 MVP systems approved, Audio Manager linked

### Design Decisions Locked
- AudioStreamRandomizer pitch in semitones (Godot 4.6) — not frequency multipliers
- Ledge parry = frame-exact, no auto-grab, no buffer. Non-negotiable.
- skid_friction_multiplier = 0.15 (not 0.85)
- AudioManager as Autoload (infrastructure exception to singleton rule)
