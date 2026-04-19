# BONNIE! — Development Log

Design decisions, session notes, and milestone progress for BONNIE! —
a sandbox chaos puzzle game developed with Claude Code Game Studios.

---

## [2026-04-05] Session 001 — Pre-Production Sprint 0

**Developer**: m. raftery
**Studio**: Claude Code Game Studios (Godot 4.6)
**Focus**: Foundation — game concept, systems architecture, core design GDDs

---

### Studio Infrastructure

Configured the full Claude Code Game Studios environment for BONNIE! development:

- Engine reference docs populated for Godot 4.6 (breaking changes 4.4→4.5→4.6,
  deprecated APIs, current best practices, version-pinned at 2026-02-12)
- Mycelium knowledge layer initialized — session hooks wired (session-start,
  session-stop, pre-compact), departure protocol active
- `/setup-engine godot 4.6` confirmed ready
- `.mycelium/repo-id` + zone initialized; notes push/fetch wired to remote

---

### Game Concept Locked

**File**: `design/gdd/game-concept.md` — **Approved**

BONNIE! is a sandbox chaos / puzzle game. You are BONNIE — a big black cat
(a real cat, found under a dumpster on Germantown Ave in Philadelphia) with
an unshakeable belief that she deserves tuna. Engineer cascading chaos until
somebody feeds you. Play it completely cool while everything burns.

**Core fantasy**: *You are a cat. You are not sorry about any of it.*

**Comparable titles**: Haunting Starring Polterguy × Maniac Mansion.
The replayability model is variable-stuffed systems,
not scripted linearity — no two runs feel identical.

**Key decisions locked this session:**
- Bidirectional social system: charm AND chaos both fill the chaos meter
- NPCs speak: SNES-style text boxes + crunchy Genesis/SNES vocal samples
- Mini-games discovered organically mid-play (Yo! Noid / Nightshade model)
- End-of-level feeding cutscenes unique per level, hand-crafted
- Five levels: Germantown Ave → Apartment → Vet → K-Mart → Italian Market
- Performance target: "most beloved cult classic 2D game ever made for the
  Sega Dreamcast" — 720×540, nearest-neighbor, ≤50 draw calls, integrated
  graphics capable

**MVP definition**: BONNIE movement + one environment (Level 2: apartment) +
two NPCs + chaos meter + fed animation. 4–6 weeks.

---

### Systems Architecture

**File**: `design/gdd/systems-index.md` — **Approved**

27 systems identified and mapped with full dependency graph, design order,
effort estimates, and priority tiers.

**MVP systems (11)**: Input, Viewport/Rendering Config, Audio Manager, BONNIE
Traversal, Camera, Level Manager, Interactive Object System, Reactive NPC,
Bidirectional Social System, Chaos Meter, Chaos Meter UI.

**Highest-risk systems flagged:**
- BONNIE Traversal — prototype immediately, physics feel is make-or-break
- Reactive NPC — most complex system, scope-balloon risk, design with strict limits
- Bidirectional Social — novel mechanic, feedback must make the social axis visible
- Chaos Meter — balance-sensitive, tuning only knowable through playtesting

**Key architectural decision**: NPC System / Social System circular dependency
resolved via shared `NpcState` data object. Neither system calls the other directly.

---

### NPC Personality System

**File**: `design/gdd/npc-personality.md` — **Approved**

Full design for the most complex system in the game. Maniac Mansion-depth NPC
simulation built on a continuous emotional state model.

**State machine — 11 states:**

| State | What It Means |
|-------|---------------|
| ASLEEP | Sleeping. Below wake threshold, stimulus is ignored. |
| GROGGY | Just woken. Confused, low reactivity, comedy target. |
| ROUTINE | Going about their day. Following schedule. |
| AWARE | Noticed something. "What was that?" Not yet reacting. |
| REACTING | Active emotional response. Loud, visible, cascades to others. |
| RECOVERING | Cooling down. Hair-trigger window. Comfort starts landing. |
| VULNERABLE | Post-stress exhaustion. Max comfort_receptivity. Jackpot state. |
| CLOSED_OFF | Social shutdown. Won't engage. Too much chaos without goodwill recovery. |
| FLEEING | Running away (Christen can flee; Michael does not — his apartment). |
| CHASING | Antagonist pursuit. Vertical Slice scope. |
| FED | Terminal. Level complete. |

**NpcState interface (8 fields):**
```
emotional_level: float       — 0.0 (calm) → 1.0 (max stress)
goodwill: float              — 0.0 (hostile) → 1.0 (loves BONNIE)
current_behavior: NpcBehavior
comfort_receptivity: float   — floor is per-NPC
active_stimuli: Array[Stimulus]
visible_to_bonnie: bool
last_interaction_type: InteractionType
bonnie_hunger_context: bool
```

**MVP NPCs:**
- **Michael** — apartment owner, works from home. Moderate patience. Work phase
  lowers reaction threshold (-0.1). Does not flee. comfort_receptivity floor 0.15.
- **Christen** — Michael's partner (the sun, moon, and stars of the apartment's
  emotional ecosystem, and BONNIE knows this). More easily startled. Can flee
  to another room. comfort_receptivity floor 0.20.

**Domino Rally cascade**: When NPC A enters REACTING, it emits a cascade
stimulus weighted by emotional_level × cascade_bleed_factor to nearby NPCs.
Michael ↔ Christen mutual cascade is elevated by relationship_cascade_bonus (0.2).
Chain depth: max 2 (MVP). Loops prevented via cascade_source_id.

**New mechanics surfaced:**
- **Levity multiplier** (1.5×): charm interaction within 4s of a chaos event earns bonus goodwill
- **Hunger boost** (ambient): BONNIE unfed >300s → increased clumsiness + NPC feeding_threshold -0.1
- **VULNERABLE state**: post-REACTING crash — emotional_level below threshold, max comfort_receptivity
- **Pre-emptive stimulus removal** (phone off hook, close blinds): Vertical Slice scope

---

### BONNIE Traversal System

**File**: `design/gdd/bonnie-traversal.md` — **Approved**

Full physics and movement design. Core principle: **controls are snappy, physics
consequences are real.** Input registers instantly; the challenge is managing what
happens after you commit.

Reference: *clumsy feline Ryu Hayabusa.*

**Complete movement vocabulary:**

| State | Description |
|-------|-------------|
| SNEAKING | Slow, quiet, minimal stimulus radius. NPCs don't notice. |
| WALKING | Default ground move. |
| RUNNING | Full speed. Dedicated run button (autorun as accessibility toggle). |
| SLIDING | The Kaneda. Can't stop. Objects in path get knocked over. Pop-jump available. |
| JUMPING | Tap = hop. Hold = full arc. Coyote time + jump buffering. |
| DOUBLE JUMP | Apex-locked. Post-double air control near zero — BONNIE commits to arc. |
| LEDGE PARRY | Pure timing. No auto-grab. No telegraph. Cat reflexes or you fall. |
| WALL JUMP | On climbable surfaces (carpet/fabric) only. Metal/glass/hardwood: no grab. |
| CLIMBING | On designated Climbable nodes. Hunger-boost adds slip chance. |
| SQUEEZING | Narrow passages. Hidden from NPCs. |
| DAZED | Brief stun. Comic. Time cost only — no health damage. |
| ROUGH_LANDING | ~18ft+ fall. Extended recovery. Nine Lives trigger candidate. |
| LEDGE_PULLUP | Post-parry. BONNIE scrambles up. Short animation, full control restored. |

**Key design decisions:**
- Run button is default; autorun is an accessibility toggle
- Double jump available from first jump's apex (not immediately on leaving ground)
- Post-double-jump air control: ~30 px/s² (near zero). BONNIE is twisted and committed.
- The intended high-skill combo: run → jump → double jump at apex → committed arc
  → LEDGE PARRY at the right moment → stick it. The reduced post-double control
  is what gives the parry its weight.
- No auto-grab on ledges. BONNIE goes flying off and stays flying off unless the
  player executes the parry. Auto-grab would break aerial sequences and hide exploration.
- No death. Ever. Looney Tunes / Nine Lives / Felix the Cat logic. BONNIE always
  gets up. DAZED and ROUGH_LANDING are setbacks, not punishments.
- Camera is co-equal with traversal. Bad camera = bad game. Camera must be
  prototyped alongside traversal.

---

### What's Next

- **`/prototype bonnie-traversal`** — create Godot project, BONNIE moves for the
  first time. Validate physics feel. This is the most critical risk in the project.
- **Foundation GDDs** — `input-system.md`, `viewport-config.md`, `audio-manager.md`
  (small, ~30 min each, unblock everything)
- **`/sprint-plan new`** — Sprint 1 after traversal prototype validated
- **Art pipeline** — BONNIE placeholder sprite in Aseprite; starts the toolchain
- **Music** — first original track (apartment theme); no tooling needed, just start

---

---

## [2026-04-08] Session 002 — Foundation Systems

**Developer**: m. raftery
**Focus**: Viewport configuration + Camera system GDDs — unblock prototype

### Completed
- **Viewport Config GDD** (System #2) — Approved. 720×540 internal resolution, nearest-neighbor filtering, 4:3 locked, stretch mode "viewport", integer scaling (2× default, 4× supported).
- **Camera System GDD** (System #4) — Approved. Look-ahead, ledge bias, recon zoom, per-state camera values.

### GATE Status
- GATE 0: CLEARED — Camera + Viewport GDDs approved. Prototype stream unblocked.

### What Happened
Two foundation GDDs that were blocking the traversal prototype. Both small, both approved in a single session. GATE 0 cleared, enabling parallel work streams: prototype implementation (Set A), Phase 3 GDDs (Set B, after GATE 1), and Level Manager / Interactive Object / Chaos Meter UI GDDs (Set C, anytime).

---

---

## [2026-04-11] Session 003 — Foundation GDDs + Traversal Prototype

**Focus**: Foundation GDDs complete + Traversal Prototype implemented

### Completed
- **Input System GDD** (System #1) — Approved. 10 actions, buffering rules (jump buffered, grab frame-exact), analog thresholds, accessibility remapping.
- **Audio Manager GDD** (System #3) — Approved. Bus hierarchy, full event catalogue (17 traversal SFX, 6 BONNIE vocal, 8 NPC vocal, 4 env, 1 music), playback API, Godot 4.6 semitone trap documented.
- **T-NPC-FIX** — Christen routine fully specified: arrival trigger (Michael Afternoon→Evening transition), 6 phases with durations, flee behavior with stress carry stacking.
- **T-PROTO-01/02/03** — `project.godot` (720×540, nearest-neighbor, GodotPhysics2D), input map (10 actions), BonnieController.gd skeleton (13-state enum).
- **T-PROTO-04 through T-PROTO-09** — Full BonnieController.gd implementation: all 13 state handlers, ledge parry via ShapeCast2D, coyote time, jump buffer, apex-locked double jump, pop-jump from slide/skid.
- **T-PROTO-11** — TestLevel.tscn: 10 test zones (run corridor, platform steps, hard/soft drop, ledge parry practice, climbable/smooth walls, squeeze gap, collision objects, end wall).

### Systems Index
- 6/11 MVP systems approved: Input (1), Viewport (2), Audio Manager (3), Camera (4), Traversal (6), NPC (9)

### GATE Status
- GATE 0: CLEARED
- GATE 1: PENDING — prototype ready, awaiting playtest

### Next Session Opens With
Playtest feedback → GATE 1 evaluation → T-CHAOS + T-SOC GDDs (parallel)

---

---

## [2026-04-15] Session 006 — GATE 1 Re-Playtest + Prototype Sprint + GDD Sprint

**Developer**: m. raftery
**Focus**: GATE 1 re-playtest → prototype fixes → DI-001/DI-003 design + implementation → T-FOUND-04/05 GDDs → infrastructure (Mycelium hooks)

---

### Playtest Results

Conducted Session 006 GATE 1 re-playtest (targeted, ~15–20 min). Four bugs from Session 005 carried over or emerged:

- **B02 (SQUEEZING)** — fully broken; traced to three compounding causes: wrong groups syntax in .tscn, approach ramp geometry blocking entry, and shape-swap floating causing rapid SQUEEZING↔FALLING state cycle. All three fixed this session.
- **B07 (F5 on macOS)** — system shortcut capture; workaround documented (Cmd+B or Play button)
- **B08 (LEDGE_PULLUP)** — auto-fire with no position snap didn't match player expectation; triggered DI-001 design proposal and full redesign

**Feel signals confirmed:**
- Climbing pop-up at wall top: "That worked great!" — target feel, GATE 1 AC pass
- Run + double jump + parry combo: "It really does feel very feline" — traversal identity confirmed
- Rough landing: confirmed working, calibration deferred to art pass
- Post-double-jump: "needs more dynamism" — likely a sprite/audio gap, not physics

**GATE 1 result: CONDITIONALLY NEAR-PASS** — see `prototypes/bonnie-traversal/PLAYTEST-002.md`

---

### Design Ideas Approved and Implemented

**DI-001 — LEDGE_PULLUP Directional Pop**

Tester vision: after cling, a brief input window. If directional input → BONNIE pops up and carries momentum. If no input → clean stationary pullup.

- GDD amended: `bonnie-traversal.md §3.5` rewritten as two-phase state
- Prototype implemented: `_pullup_direction` captured during cling phase; `_handle_ledge_pullup()` resolves momentum launch vs. stationary pop at window end
- Confirmed working on Session 006 re-test
- New tuning knobs: `pullup_window_frames` (10f), `pullup_pop_velocity` (260 px/s), `pullup_pop_vertical` (200 px/s)

**DI-003 — Claw Brake During SLIDING**

Tester vision: E key as context-sensitive "claw" button — handbrake during SLIDING that allows skill-based deceleration.

- GDD amended: `bonnie-traversal.md` SLIDING section, formula: `claw_brake_force = abs(velocity.x) * claw_brake_multiplier`
- `input-system.md` updated: E grab action expanded as context-sensitive across FALLING/JUMPING/SLIDING states
- Prototype implemented: E-during-SLIDING removes `abs(velocity.x) * 0.30` per tap (~3 taps from full speed)
- Confirmed working; rhythm tuning deferred to Session 007

---

### Additional Prototype Improvements

- **Mid-air climbing**: E-press while touching Climbable during JUMPING/FALLING → immediate CLIMBING entry. Player can hit the wall at full speed and climb from the moment of contact.
- **E-scramble burst**: Pressing E during CLIMBING fires a velocity impulse for `climb_claw_burst_frames` (default 4). More cat-like than smooth surface ascent.
- **Auto-clamber**: CLIMBING auto-exits to JUMPING at wall top via `is_on_ceiling()` — no UP input required. Confirmed delivering the "pop over the edge with momentum" feel.

---

### GDD Sprint — T-FOUND-04 and T-FOUND-05

**T-FOUND-04: Level Manager GDD** — `design/gdd/level-manager.md` — Approved

System #5. 7-room apartment topology: entryway → living_room/bedroom → kitchen/bathroom → studio/back_stairs. Key decisions:
- BFS cascade attenuation: 4 tiers (0–3), stimulus attenuated ×0.5 per tier crossing, floor at tier 3
- Music: starts `level_02_calm`; Chaos Meter drives `level_02_chaotic`/`dangerous` transitions
- Post-win signal: `level_complete(fed_by_npc_id: StringName)` → Feeding Cutscene System (19)
- Room deactivation: rooms outside radius 1 from BONNIE deactivate (physics + visibility)

**T-FOUND-05: Interactive Object System GDD** — `design/gdd/interactive-object-system.md` — Approved

System #7. Five weight classes (Light/Medium/Heavy/Glass/Liquid Container). Key decisions:
- Slide force formula: `slide_force = abs(bonnie_velocity.x) * slide_force_multiplier * object_mass_factor`
- Liquid: two-signal pattern (knock → spill delay → displaced stimulus with 2× weight)
- `receive_impact(force: Vector2)` — the only entry point into the system from BONNIE
- `object_displaced` + `object_displaced_stimulus` signals

**systems-index.md** updated: Systems 5 and 7 → Approved. Progress: **8/11 MVP GDDs approved**.

---

### Infrastructure — Mycelium Pre/Post Tool-Use Hooks

Identified critical gap: `Write` and `Edit` tool calls were not triggering Mycelium context-workflow or departure tracking. Two hooks created:

- **`.claude/hooks/pre-tool-use-mycelium.sh`** — fires before any Write/Edit; runs `context-workflow.sh` for file-specific notes. Guards: `git rev-parse --verify HEAD:<path>` exits cleanly for uncommitted files (avoids exit 128 on new files).
- **`.claude/hooks/post-tool-use-mycelium.sh`** — appends file paths to `.mycelium-touched` for session-stop departure reminder.
- **`.claude/settings.json`** — PreToolUse and PostToolUse matchers for `Write|Edit` wired to both new hooks.

---

### GATE Status
- GATE 0: CLEARED
- GATE 1: **CONDITIONALLY NEAR-PASS** — 5/12 ACs pass, traversal identity confirmed; slide rhythm + camera/stealth remain before final PASS call

---

## [2026-04-13] Session 005 — GATE 1 Playtest + Prototype Fixes + Infrastructure Cleanup

**Developer**: m. raftery
**Focus**: First GATE 1 playtest → prototype bug audit → fixes → infrastructure cleanup

### Playtest Results
Conducted first GATE 1 playtest of traversal prototype. Found 4 critical bugs preventing full AC evaluation:

- **B01** — CLIMBING state had no ground-based entry. Only enterable via airborne parry. GDD specified ground approach should work.
- **B02** — SQUEEZING state completely unreachable. State handler existed but nothing called `_change_state(State.SQUEEZING)`. Auto-trigger never implemented.
- **B03** — `parry_window_frames` tuning knob existed but `_check_ledge_parry()` was proximity-only. No temporal window around ledge-plane crossing.
- **B04** — CircleShape2D ParryCast detected floor/ceiling geometry as valid parry targets. Intermittent false positives.

Additionally: no debug feedback layer made playtesting guesswork. User could not distinguish states, speed thresholds, or timer states.

**GATE 1 result: NEEDS WORK** — see `prototypes/bonnie-traversal/PLAYTEST-001.md`

### Prototype Fixes Applied
- Ground climbing: grab button near Climbable surface → CLIMBING from all ground states
- Slide auto-climb: SLIDING collision with Climbable auto-grabs without input
- SQUEEZING: CeilingCast RayCast2D (pointing up, 22px range) added to scene; ground handlers check it
- Parry: temporal window opened on proximity zone entry, active for `parry_window_frames`; floor contact filtered by contact-point Y offset heuristic
- Debug HUD: CanvasLayer layer 128, RichTextLabel with BBCode state colors, shows all tuning-relevant runtime data

### Infrastructure Cleanup
Three areas addressed following comprehensive infrastructure audit:

**Mycelium seeded** — 6 live notes written that didn't exist before:
- Renderer constraint (project.godot)
- Audio pitch semitone trap (audio-manager.md)
- Traversal constraints (bonnie-traversal.md)
- Performance budget (project root)
- Prototype warning with 5 known shortcuts (BonnieController.gd)
- NPC scope warning + NPC↔Social circular dependency (npc-personality.md, design/gdd/)

**Documentation fixes:**
- `quick-start.md` — stripped Unity/Unreal references, scoped to BONNIE!/Godot
- `npc-personality.md` — scope note added: Systems 10+11 are VS not MVP
- `input-system.md` — stale cross-ref resolved

**Pending (user action needed):**
- `! rm -rf docs/engine-reference/unity docs/engine-reference/unreal` (~7K LOC)
- Remove 13 Unity/Unreal/post-launch agent files from `.claude/agents/`

### GATE Status
- GATE 0: CLEARED
- GATE 1: **NEEDS WORK** — re-playtest after fixes (Session 006)

---

## [2026-04-13] Session 004 — Playtest Unblock + Infrastructure Hardening

**Developer**: m. raftery
**Focus**: Fix critical playtest blockers, harden hooks/infrastructure, fill documentation gaps

### Critical Fixes
- **BONNIE invisible** — PlaceholderSprite was `Color(0,0,0,1)` (black) on black background. Changed to warm orange `Color(1, 0.4, 0.2, 1)`.
- **Wrong renderer** — `project.godot` had no `renderer/rendering_method` set. Godot defaulted to Forward+ (3D), compiling 60+ 3D shader caches (SSAO, SSR, VoxelGI, volumetric fog) for a pure 2D game. Switched to `gl_compatibility`.

### Infrastructure Improvements
- **detect-gaps.sh** — Added caching. Saves 5-10k tokens per session start by skipping filesystem scans when `design/`, `src/`, `prototypes/` are unchanged. `--force` flag bypasses cache.
- **session-start.sh** — Added renderer guard. Warns if `project.godot` has no renderer set or uses Forward+ for a 2D-only project.
- **validate-commit.sh** — Enhanced GDD section check to validate all 8 required sections by name with a missing count. Fixed silent Python failure (now surfaces as visible warning).

### Documentation Gaps Filled
- Added missing Session 002 entry to DEVLOG.md (viewport-config + camera-system, 2026-04-08)
- Added [Pre-Production 0.2] to CHANGELOG.md
- Created `production/session-state/active.md` (living session checkpoint)

### GATE Status
- GATE 0: CLEARED
- GATE 1: **READY FOR PLAYTEST** — blockers resolved

### Next Session Opens With
Delete `.godot/shader_cache/` → Open Godot → Playtest → Answer feel questions → GATE 1 evaluation

---

---

## [2026-04-16] Session 008 — GATE 1 Closure

**Developer**: m. raftery
**Focus**: GATE 1 final assessment — slide re-test, deferral decisions, formal closure

---

### Pre-Flight Validation

All green:
- `gdcli doctor` — environment OK
- `gdcli project info` — project.godot valid
- `gdcli project scene-list` — all scenes enumerated
- `gdcli script lint` — BonnieController.gd clean (0 errors)
- `gdcli scene validate` × 2 — BonnieController.tscn + TestLevel.tscn valid
- `gdcli project uid-fix` — no UID issues

---

### gdcli MCP Issue

`CallMcpTool` (Cursor transport layer) hangs when invoking gdcli MCP tools. Diagnosed as a Cursor-side transport issue, not a gdcli problem. All gdcli operations routed via Shell (`npx -y gdcli-godot ...`) — works perfectly. `mcp.json` env override reverted since Shell fallback is reliable.

---

### PLAYTEST-003 Produced

Code analysis + headless validation of Kaneda slide rhythm (AC-T03). Findings:
- Slide trigger: correct (speed > 300 px/s + opposing input or S key)
- Claw brake formula: `abs(velocity.x) * 0.30` per E tap — mathematically verified (~3 taps from full speed)
- Slide → brake → stop → pivot cycle: code-complete, all exit paths correct
- Linting: 0 errors. Scene validation: 0 issues. Headless run: no crashes.

**Result**: AC-T03 upgraded from PARTIAL to CODE VERIFIED.

---

### GATE 1 Assessment

Formal assessment produced: `prototypes/bonnie-traversal/GATE-1-AC-ASSESSMENT.md`

| Category | Count |
|----------|-------|
| PASS | 5 (T06, T06c, T06e, T06f, T07) |
| CODE VERIFIED | 1 (T03) |
| PARTIAL | 4 (T02, T04, T06b, T06d — asset-dependent) |
| UNTESTABLE | 2 (T01, T05 — need production tooling) |
| DEFERRED | 2 (T08 → GATE 2, Stealth → post-T-SOC) |

**User deferrals:**
- AC-T08 (camera leads movement) → GATE 2 — polish concern, not traversal-feel
- Stealth radius → post-T-SOC — no NPCs exist yet

**Verdict**: **CONDITIONAL PASS** — traversal feel validated sufficiently to proceed to T-CHAOS + T-SOC GDD authoring. Conditions: feel tuning of slide rhythm during early production; PARTIAL ACs require sprites/audio (production polish, not design gaps).

---

### GATE Status
- GATE 0: CLEARED
- GATE 1: **CONDITIONAL PASS** ✅ — Session 008
- GATE 2: Pending (8/11 MVP GDDs approved; T-CHAOS + T-SOC now unblocked)

---

### T-CHAOS + T-SOC GDD Authoring (continued, same session)

Both GDDs authored in parallel via game-designer + economy-designer (T-CHAOS) and game-designer + ux-designer (T-SOC) subagents.

**T-CHAOS (Chaos Meter, System 13):**
- Composite meter: `chaos_fill` (cap 0.55) + `social_fill` (weight 0.45)
- Additive social_fill model across all active NPCs (user decision)
- Per-level `level_chaos_baseline` with full reset between levels
- Chaos overwhelm FED path: per-NPC thresholds (Michael 8, Christen 7, hostile -1)
- `chaos_event_count` owned by Chaos Meter (resolved ownership ambiguity)
- Economy proof: neither pure chaos nor pure charm can reach FED alone
- All 5 open questions resolved with user

**T-SOC (Bidirectional Social System, System 12):**
- 5-interaction charm catalog: Proximity, Rub, Lap Sit, Purr, Meow
- 4-tier visual goodwill legibility without UI (COLD/NEUTRAL/SOFTENED/WARM)
- RECOVERING extended levity + comfort acceleration mechanic (layered design)
- Passive play formally documented as valid aesthetic choice with equilibrium analysis
- NpcState extensions: `last_interaction_timestamp` + `recovering_comfort_stacks`
- 4 of 5 open questions resolved; 1 remaining (Chaos Meter signal format)

**NpcState Contract Mediation (Opus-tier):**
Both GDDs' NpcState assumptions verified compatible. T-SOC adds `last_interaction_timestamp`
and `recovering_comfort_stacks`; T-CHAOS is a pure reader. No conflicts.

---

### Design Review

Formal design-review dispatched for both GDDs in parallel. Results:

**T-CHAOS**: NEEDS REVISION — 6 required changes:
1. Removed stale "best-of-N" paragraph contradicting additive decision
2. Fixed dead §4.2.1 reference → §4.4 + §5 Christen edge case
3. Corrected normalization language re: Christen-arrival dip
4. Explicit level-transition reset target (`level_chaos_baseline`, not zero)
5. Resolved `chaos_event_count` ownership (Chaos Meter owns it)
6. Fixed arithmetic error in Sources table (0.028 → 0.026)
Plus: added division-by-zero guard, unified variable naming

**T-SOC**: NEEDS REVISION — 4 required changes:
1. Corrected §4.1 expected output ranges (math didn't match equilibrium analysis)
2. Defined `recovering_comfort_stacks` data channel in NpcState
3. Enforced `recovering_comfort_acceleration_cap` in pseudocode
4. Added LEDGE_PULLUP and LANDING to BONNIE Movement State Gates
Plus: added passive_accumulator initialization spec, fixed systems-index.md typo (System 13→12 in circular deps)

All required changes applied. Both GDDs now pass review criteria.

---

### GATE Status
- GATE 0: CLEARED
- GATE 1: **CONDITIONAL PASS** ✅ — Session 008
- GATE 2: Pending (10/11 MVP GDDs designed; 8 approved, 2 pending user approval; Chaos Meter UI remaining)

### Next Session Opens With
Approve T-CHAOS + T-SOC GDDs → Author Chaos Meter UI (System 23) → GATE 2 evaluation.

---

## [2026-04-17] Session 009 — Design Phase Closure

**Developer**: m. raftery
**Focus**: Close design phase — approve final GDDs, pass GATE 2, draft and approve Sprint 1 plan

---

### Mission: Close the Design Phase

Session 009 operational directive: clear all remaining design work, evaluate GATE 2, produce Sprint 1 plan. Executed as Studio Director/Orchestrator with 8 working groups (A–H).

---

### GDD Approvals

**T-CHAOS (Chaos Meter, System 13)**: Approved. Composite meter with chaos_fill (cap 0.55) + social_fill (weight 0.45). Per-level baseline. Chaos overwhelm FED path.

**T-SOC (Bidirectional Social System, System 12)**: Approved. 5-interaction charm catalog, 4-tier visual goodwill legibility, RECOVERING comfort acceleration, passive play validated.

**T-FOUND-06 (Chaos Meter UI, System 23)**: Authored, design-reviewed (NEEDS REVISION — 7 issues), revised, approved. Cat food bowl metaphor with dual fill layers. HUD corner bowl for MVP, diegetic world bowls post-MVP. HOT plateau UX solved via accelerated noise + pulse rhythm.

---

### GATE 2 Evaluation

**Verdict**: PASS ✅

All 11 MVP GDDs approved:
| System | Status |
|--------|--------|
| 1 (Input), 2 (Viewport), 3 (Audio), 4 (Camera), 5 (Level Manager) | Approved (Sessions 001–006) |
| 6 (Traversal), 7 (Interactive Objects), 9 (NPC Personality) | Approved (Sessions 004–007) |
| 12 (Social), 13 (Chaos Meter) | Approved (Session 009) |
| 23 (Chaos Meter UI) | Approved (Session 009) |

Cross-system consistency verified: NpcState contract (System 9 writes, Systems 12/13 read, System 23 displays), signal flow, boundary definitions.

---

### Sprint 1 Plan

Drafted by lead-programmer subagent, then refined through comprehensive pre-sprint Q&A with user. 30 decisions locked covering process (branching, commits, testing), gameplay (NPC routines, physics, audio), and architecture (NpcState as RefCounted, Custom Resources + .cfg overrides, TileMap surface detection).

**Key architecture decisions**:
- `src/` structure: `core/`, `gameplay/`, `ui/`, `shared/` with one-way dependency
- 4 autoloads: InputSystem, AudioManager, LevelManager, ChaosEventBus
- Interface/contract tests first, implementation second, unit tests third
- Feature branches per system, orchestrator reviews and commits
- Full RigidBody2D physics for interactive objects (not stubs)
- 3-room test level (kitchen, living room, bedroom) with TileMap surface metadata

**Scope**: 18 Must Have tasks (~35 agent-sessions), 6 Should Have, 3 Nice to Have.

---

### Infrastructure

- `godot-mcp/SKILL.md` rewritten: placeholder → full gdcli v0.2.3 command reference
- `CallMcpTool` transport hang: confirmed persists (Cursor-side issue)
- `.gitignore` updated: added `.gdcli/`

---

### GATE Status
- GATE 0: CLEARED ✅
- GATE 1: CONDITIONAL PASS ✅ — Session 008
- GATE 2: **PASS** ✅ — Session 009
- GATE 3: **PASS** ✅ — Session 009

### Next Session Opens With
Sprint 1 implementation: S1-01 (src/ scaffold) → S1-02 (ADR-001) → parallel system streams.

---

## [2026-04-17] Session 010 — Sprint 1 scaffold + ADR-001

**Developer**: m. raftery  
**Focus**: S1-01 infrastructure scaffold, GUT install, autoload wiring; S1-02 production architecture ADR; NEXT handoff corrections

---

### S1-01

- Created full `src/` tree per `production/sprints/sprint-1.md` (stub scripts only; `NpcState` / `enums.gd` shells for S1-06).
- Registered four autoloads in `project.godot`. Left `run/main_scene` on prototype `TestLevel.tscn` (user decision 1A).
- Installed **GUT 9.6.0** under `addons/gut/` (Godot 4.6.x; sprint “GUT 7.x” wording superseded — 7.x is Godot 3.x line).
- Added `tests/unit/test_sanity.gd`; headless run: `godot --headless --import --path .` then `gut_cmdln.gd` with `-gdir=res://tests/unit -gexit` — all tests passed.
- `npx -y gdcli-godot script lint` — 0 errors.
- Production `BonnieController.gd` intentionally **without** `class_name` until prototype archived (ADR-001).

### S1-02

- Authored `docs/architecture/ADR-001-production-architecture.md` (layout, autoloads, NpcState, ChaosEventBus seam, GUT 9.x + import prerequisite, `class_name` conflict note).

### Handoff docs

- `NEXT.md`: Session 011 header; Stream A order S1-03 Viewport → S1-04 Input; condensed stale Session 007 GATE block.
- `CHANGELOG.md`: Pre-Production 0.9 entry.
- Git branch: `feat/s1-01-scaffold`.

### Next Session Opens With

Merge `feat/s1-01-scaffold` after review → **S1-03** Viewport (`ViewportConfig.gd` boot validation) → **S1-04** Input System.

---

## [2026-04-17] Session 010 (continued) — S1-03 Viewport + S1-04 Input

**Developer**: m. raftery  
**Branch**: `feat/s1-03-s1-04-viewport-input`

### S1-03

- `ViewportConfig` refactored to `RefCounted` with `validate_project_settings()` (720×540, `viewport` + `keep` stretch, GL Compatibility, nearest canvas filter, `Engine.max_fps = 60`).
- `project.godot`: `window/stretch/aspect=keep`; `default_texture_filter=1` (Godot 4.6 nearest enum).

### S1-04

- `InputSystem` loads `assets/data/input_system_config.tres`; public `get_move_vector()`, accessors, `should_auto_sneak_from_analog()`, InputMap guard for all 10 GDD actions.
- GUT: viewport validate, config defaults, move vector idle, auto-sneak threshold behavior.

### Next

Merge `feat/s1-01-scaffold` + `feat/s1-03-s1-04-viewport-input` → **S1-05** Audio Manager.

---

## [2026-04-17] Session 011 — Prototype squeeze, level fixes, handoff docs

**Developer**: m. raftery  
**Focus**: Geometry-driven squeeze + documentation; guard viewport settings; agent handoff for Session 012

### Delivered (on `main`, commit `89b4074` and follow-up doc commit)

- **BonnieController**: Squeeze from low ceiling (`CeilingCast`) and/or `SqueezeTrigger`; slide and landing can enter squeeze with horizontal momentum; crawl uses run cap; exit when ceiling ray clears (default `squeeze_use_ceiling_ray`).
- **TestLevel**: Squeeze trigger width 200; rigid box collision 20×20 (re-assert if editor clears sub_resource size).
- **project.godot**: Gamepad InputMap; autoloads; GUT plugin — **stretch `keep`** and **nearest filter** must remain for `ViewportConfig`.
- **Tracked**: `SESSION-010-PROMPT.md`, `design/gdd/chaos-meter-ui.md`, GUT test `.uid` sidecars, `icon.svg.import`.
- **Session 012 prep**: `NEXT.md` retargeted to S1-05; `CHANGELOG` 0.9.1; `docs/CURSOR-AGENTS-WINDOW-HANDOFF.md` for parallel Cursor Agents.

### Next Session Opens With

**S1-05** Audio Manager; optional parallel **TestLevel** validation grid per handoff doc. Run `mycelium/scripts/compost-workflow.sh` if stale notes accumulate.

---

## [2026-04-17] Session 013 (closure) — Bonnie traversal integration + NPC LOD exports

**Developer**: m. raftery  
**Focus**: `SESSION-013-PROMPT.md` Phase B/E — TileMap **`surface`/`terrain`** + semisolid one-way row, Bonnie **`collision_mask`** vs layer 2, env **`Sprite2D`** fills (single **SoftLandingPad** greybox), **Aseprite MCP** NPC sources + **16 / 24 / 32** px export folders, **`IMPORT-GODOT.md`** + **`PLAYTEST-004.md`**, **`verification-013/`** export-pixel composites + optional in-editor **`capture_verification_013.gd`** path.

### Delivered

- Runtime **TileSet** second atlas (**platform top**) on physics layer **2** with **one-way** polygon; demo cells **x 15–25, y −1**; `project.godot` physics **layer names**.
- **Michael / Christen**: `AnimatedSprite2D` + `NpcIdleFromSheet.gd`; scaled exports under `art/export/npc/michael-{16,24,32}px/` and `christen-{16,24,32}px/`.
- **CHANGELOG** Session 013 items finalized; `.gitignore` for `_scale_work*.aseprite`.

### Next

**Merged to `main` (2026-04-19)** after fast-forward to tip **`d3d2247`** (`art/bonnie-mvp-1` + **`chore: ignore and untrack AI-STUDIO-101.code-workspace`**). Re-verified: **`npx -y gdcli-godot doctor`**, **`scene validate`** on **`TestLevel.tscn`** / **`BonnieController.tscn`**, **GUT** `res://tests/unit` **9/9**. **Mycelium**: `mycelium/scripts/compost-workflow.sh --dry-run` (33 stale notes listed); interactive compost still optional — run when ready to review removals. Continue Sprint 1 from **S1-06**; human playtest pass on semisolid feel when convenient.
