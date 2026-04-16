# BONNIE! — Comprehensive Project Audit & Remediation Plan

**Auditor**: Your second-in-command
**Date**: 2026-04-15
**Repo**: `nitepoetlaureate/bonnie-game` @ commit `817e6df`
**Scope**: Full repository — every file, every line, every claim

---

## PART 0: CLAUDE CODE CLI CREDENTIALS

Before anything else. You asked about making sure your credentials are right in the terminal. Here's the exact sequence:

```bash
# 1. Check which account Claude Code is using
claude config list

# 2. If you need to see your auth status specifically
claude auth status

# 3. If you need to re-authenticate or switch accounts
claude auth login

# 4. Verify the model being used (your agents specify "sonnet" — make sure
#    the account has access to the models your agent definitions reference)
claude config get model

# 5. Verify your git identity matches what NEXT.md specifies for commits
git config user.name
git config user.email
```

Your `NEXT.md` line 193 specifies:
`Co-Authored-By: Hawaii Zeke <(302) 319-3895>`

Make sure your local git config produces this correctly on commits. If Claude Code is making commits on your behalf, this identity is what the `validate-commit.sh` hook should be checking.

---

## PART 1: PROJECT STATE SUMMARY

### What This Project IS (right now)

| Metric | Value |
|--------|-------|
| Game code files | **1** (`BonnieController.gd`, 968 lines) |
| Scene files | **2** (`BonnieController.tscn`, `TestLevel.tscn`) |
| GDD documents | **10** (8 approved, game-concept + systems-index) |
| Agent definitions | **40** (5,436 lines total) |
| Skill definitions | **37** |
| Templates | **26** |
| Hook scripts | **10** |
| Rule files | **12** |
| Docs/guides | **~30** files across `.claude/docs/`, `docs/` |
| Production source code (`src/`) | **0 files — directory does not exist** |
| Test files | **0** |
| Art assets | **0** |
| Total infrastructure-to-game-code ratio | **~200:1 by file count** |

### What the Project Claims to Be vs. What It Is

The `CLAUDE.md` header says: *"Indie game development managed through 48 coordinated Claude Code subagents."*

The reality: You have ONE GDScript file with a well-built 13-state character controller prototype, a thoughtfully designed 10-zone test level, 10 GDD documents (8 approved), and an *enormous* scaffolding layer that is partially functional, partially phantom.

This is not a criticism of ambition. This is a statement of fact so we can plan correctly.

---

## PART 2: CRITICAL FINDINGS

### CRITICAL-01: Mycelium Is a Phantom Limb

**Severity**: CRITICAL — the entire knowledge persistence layer is non-functional

The `mycelium/` directory is **empty**. Zero scripts. Zero files.

Every reference to mycelium in the project is a dead letter:

| Reference Location | What It Claims | Reality |
|---|---|---|
| `CLAUDE.md` lines 57-63 | `mycelium.sh find constraint`, `mycelium.sh note HEAD`, `mycelium.sh prime` | **Command does not exist** |
| `.claude/rules/mycelium.md` | Full arrival/departure protocol | **Cannot be executed** |
| `.claude/hooks/session-start.sh` lines 86-97 | Surfaces constraints and warnings on session start | **Silently fails** (guarded by `command -v mycelium.sh`) |
| `.claude/hooks/pre-tool-use-mycelium.sh` | Runs `mycelium/scripts/context-workflow.sh` before file edits | **Script does not exist** — exits 0 silently |
| `.claude/hooks/post-tool-use-mycelium.sh` | Tracks edited files for departure annotation | **Works** (just appends paths to a file) — but the departure step that reads it cannot function |
| `.claude/hooks/pre-compact.sh` | References mycelium for context preservation | Needs verification |
| `.claude/hooks/session-stop.sh` | References mycelium for departure notes | Needs verification |

The `.mycelium/zone` (value: `80`) and `.mycelium/repo-id` (value: `29543e197ca3fc6afa584f224a1afb9c`) exist as config stubs but have no operational system to serve.

**Impact**: Every session that follows the documented arrival protocol gets zero institutional memory. Constraints, warnings, file-level annotations — none of it persists. The hooks fail open, so nothing crashes, but every agent starts every session blind to prior context except what's in NEXT.md and DEVLOG.md.

**Root cause**: Mycelium was likely installed as a git-notes-based system (`mycelium installed` commit `5fcbdc0`) but the actual script bundle was either never committed, was in a submodule that wasn't initialized, or was removed at some point. The config files survived but the runtime did not.

---

### CRITICAL-02: `soft_landing` Group — Dead Mechanic in Test Level

**Severity**: CRITICAL for test validity — a test zone gives false results

`TestLevel.tscn` Zone 4 has a `SoftLandingPad` node in group `"soft_landing"` (line 199). The zone comments (lines 180-183) state:

> *"fall distance reset → LANDING not ROUGH_LANDING"*

**`BonnieController.gd` never checks for the `"soft_landing"` group. Anywhere.** Zero references.

The `_on_landed()` function (line 621) checks ONLY `fall_distance >= rough_landing_threshold`. It does not inspect what surface BONNIE landed on.

**Impact**: Zone 4 and Zone 3 produce identical ROUGH_LANDING results. Any playtest evaluation of "soft landing vs. hard landing" mechanics is invalid. The test level's own documentation claims a behavior that the code does not implement.

---

### CRITICAL-03: Missing `icon.svg`

**Severity**: LOW-CRITICAL — project won't crash but generates warnings on every Godot launch

`project.godot` line 16: `config/icon="res://icon.svg"`

The file does not exist in the repo. Godot will log a warning on every editor launch and every export attempt.

---

## PART 3: SERIOUS FINDINGS

### SERIOUS-01: Duplicated Mid-Air Climb Logic

`_handle_jumping()` lines 552-562 and `_handle_falling()` lines 603-613 contain nearly identical code blocks:

```gdscript
# In _handle_jumping (lines 552-562):
if Input.is_action_pressed(&"grab"):
    for i: int in get_slide_collision_count():
        var col: KinematicCollision2D = get_slide_collision(i)
        var collider: Object = col.get_collider()
        if collider and collider.is_in_group(&"Climbable"):
            double_jump_available = true
            _post_double_jumped = false
            velocity.x = 0.0
            _change_state(State.CLIMBING)
            return

# In _handle_falling (lines 603-613):
if Input.is_action_pressed(&"grab"):
    for i: int in get_slide_collision_count():
        var col: KinematicCollision2D = get_slide_collision(i)
        var collider: Object = col.get_collider()
        if collider and collider.is_in_group(&"Climbable"):
            double_jump_available = true
            _post_double_jumped = false
            velocity.x = 0.0
            _change_state(State.CLIMBING)
            return
```

This is a textbook extract-to-function candidate: `_try_airborne_climb() -> bool`. Identical logic, identical reset sequence, identical return pattern. Divergence risk is real — if one gets patched and the other doesn't, you get asymmetric grab behavior between jumping and falling.

---

### SERIOUS-02: Legacy Variable Duplication

Two pairs of variables exist that serve overlapping purposes:

**Pair 1 — skid_timer:**
- Line 144: `var skid_timer: float = 0.0` — comment says *"legacy public — use _skid_timer internally"*
- Line 162: `var _skid_timer: float = 0.0` — the actual working variable

`skid_timer` (public) is NEVER read or written anywhere in the code. It's dead weight that will confuse any agent or developer who encounters it.

**Pair 2 — jump_hold_timer:**
- Line 147: `var jump_hold_timer: float = 0.0` — float
- Line 161: `var _jump_hold_timer: int = 0` — int, comment says *"frame counter for hold (distinct from legacy float above)"*

`jump_hold_timer` (float, public) is written in `_change_state()` line 307 (`jump_hold_timer = 0.0`) but never read functionally. `_jump_hold_timer` (int, private) is the one actually used in `_handle_jumping()`.

Both pairs create traps for future agents who see the public variables and assume they're the authoritative state.

---

### SERIOUS-03: Empty PHYSICS HELPERS Section

Lines 787-793:
```gdscript
# =============================================================================
# PHYSICS HELPERS
# =============================================================================

# =============================================================================
# GROUND-BASED CLIMBING + SQUEEZING DETECTION
# =============================================================================
```

The PHYSICS HELPERS section header exists but contains zero functions. The `_apply_gravity()` function (line 856) is the only physics helper and it's placed 60 lines later, AFTER the climbing/squeezing section. Code organization implies there should be more helpers here — at minimum, `_apply_gravity` should live under this header.

---

### SERIOUS-04: RigidBody2D Boxes Are Non-Functional

Zone 9 has three `RigidBody2D` collision boxes. In Godot 4.x, `CharacterBody2D.move_and_slide()` does NOT automatically apply impulses to `RigidBody2D` objects. Without explicit code like:

```gdscript
for i in get_slide_collision_count():
    var collision = get_slide_collision(i)
    var collider = collision.get_collider()
    if collider is RigidBody2D:
        collider.apply_central_impulse(-collision.get_normal() * push_force)
```

...BONNIE either stops dead against the boxes or clips through them depending on collision layer setup. PLAYTEST-002.md acknowledges this (B05, deferred), but the boxes give a broken first impression to anyone testing.

---

### SERIOUS-05: Terminal Velocity Clamp Direction in Jumping

`_handle_jumping()` line 517:
```gdscript
velocity.y = max(velocity.y, -fall_velocity_max)
```

This clamps UPWARD velocity (prevents BONNIE from going up faster than 900 px/s). This is mathematically correct but semantically misleading — `fall_velocity_max` as a variable name implies it governs falling, not ascending. The comment on line 516 says *"Clamp to terminal velocity"* which reinforces the confusion.

Meanwhile in `_handle_falling()` line 574:
```gdscript
velocity.y = min(velocity.y, fall_velocity_max)
```

This correctly clamps downward terminal velocity.

The jumping clamp is not wrong — it prevents physics exploits from stacking jump forces. But it should use a dedicated constant like `ascent_velocity_max` or at minimum have a comment explaining why `fall_velocity_max` is reused for upward clamping.

---

### SERIOUS-06: `LOOK_AHEAD_BY_STATE` Dictionary — Dead Code

Lines 36-50 define a `LOOK_AHEAD_BY_STATE` constant mapping every state to a camera look-ahead distance. This dictionary is NEVER referenced anywhere in the codebase. It exists in anticipation of the camera system (AC-T08), but right now it's dead code that will not be validated against the camera-system.md GDD until someone explicitly connects them.

---

### SERIOUS-07: Infrastructure Dormancy

The following infrastructure components are defined but currently inert because there is no production code:

| Component | Count | Status |
|-----------|-------|--------|
| Agent definitions in `.claude/agents/` | 40 | Cannot do meaningful work — no `src/` exists |
| Skills in `.claude/skills/` | 37 | Most trigger on production workflows that don't exist yet |
| Templates in `.claude/docs/templates/` | 26 | Unused — no sprint plans, no architecture decisions recorded |
| Hooks scanning `src/` | 3+ | Scan empty/nonexistent directories |
| Rules for network-code, shader-code, ai-code | 3 | No code in these categories exists |

This isn't wrong — it's pre-investment. But it means every session start loads context about 40 agents, none of whom have work to do until `src/` exists. Token overhead is real.

---

## PART 4: MODERATE FINDINGS

### MOD-01: CeilingCast Is Vestigial

`_ceiling_cast` (`$CeilingCast`) is `@onready` referenced on line 119 and displayed in the debug HUD (line 943-945), but performs no functional role. Squeeze detection was migrated to the `_squeeze_zone_active` Area2D flag system. The RayCast2D node remains in the scene and the script. Not broken, but misleading — a future agent might think squeeze detection depends on it.

### MOD-02: Systems Index Numbering Is Inconsistent

The systems-index.md table numbers systems 1-27. The "Dependency Map" section renumbers them in a different order. The "Recommended Design Order" uses yet another numbering. Cross-referencing between sections requires mental mapping.

### MOD-03: Progress Tracker Is Stale

`systems-index.md` bottom section:
```
Design docs started: 0
Design docs reviewed: 0
Design docs approved: 8
```

"Started: 0" and "reviewed: 0" are wrong — 8 docs went through both stages to reach approved. The tracker was likely written before any docs were approved and never updated.

### MOD-04: No `.gdignore` Files

The `mycelium/`, `production/`, `docs/`, and `.claude/` directories contain only markdown and shell scripts. Without `.gdignore` files, Godot's import system scans all of these on every editor launch, generating unnecessary import metadata.

### MOD-05: Workspace File Has Space in Name

`Claude Code Game Studios.code-workspace` — spaces in filenames are a known source of shell escaping bugs. Any hook or script that references this file without quoting will fail on the space.

### MOD-06: One TODO in Prototype Code

Line 757: `# TODO: Nine Lives system hook fires here (see bonnie-traversal §8 AC-T06c).`

Acceptable in prototype code. Flag for production rewrite.

---

## PART 5: POSITIVE FINDINGS (Credit Where Due)

This section matters. The problems above are fixable. The following things are genuinely well-done and should be preserved:

1. **BonnieController.gd is well-written prototype code.** The state machine is clean, every handler follows a consistent pattern, comments reference GDD sections by number, and the physics math is correct. The exported tuning knobs are properly documented with units and source references. For a prototype that's explicitly marked throwaway, this is high quality.

2. **TestLevel.tscn is an excellent test harness.** 10 zones, each testing a specific mechanic with documented measurements. Platform heights are mathematically derived from physics constants. The zone comments are thorough enough to serve as a test plan.

3. **The GDD documents are thorough.** 8 approved system designs with clear acceptance criteria, dependency tracking, and scope boundaries. The game-concept.md is genuinely compelling — the MDA framework analysis is rigorous.

4. **The playtest reports are exemplary.** PLAYTEST-002.md captures bugs, design ideas, acceptance criteria evaluations, and emotional responses. The DI-001 through DI-004 design proposals emerged from actual play testing and were fed back into the GDD correctly.

5. **The gate system works.** GATE 0 → GATE 1 → GATE 2 → GATE 3 progression is clearly defined and honestly evaluated. GATE 1 is "NEAR-PASS" not "PASS" because the team is being honest about remaining work.

6. **The hook system is thoughtful.** Session-start context loading, renderer guards, gap detection, mycelium integration points (even if mycelium itself is missing) — the architecture is sound. The hooks fail-open, which is correct.

7. **The locked decisions are documented.** DI-001, DI-003, Zone 8 squeeze fix — each has a "do not re-litigate" marker with technical rationale. This prevents agent churn.

8. **BONNIE never dies. Non-negotiable.** Good design instinct. This constraint shapes everything downstream correctly.

---

## PART 6: REMEDIATION PLAN — PHASED, ATOMIC, SWARM-READY

### Philosophy

Every task below is sized for a single subagent session. Tasks are tagged with the agent persona best suited to execute them and the model tier appropriate for the complexity.

**Model assignments:**
- **Opus**: Complex design synthesis, architecture decisions, multi-system analysis
- **Sonnet**: Code implementation, document writing, refactoring, GDD drafting
- **Haiku**: Mechanical tasks — file creation, config changes, search-and-replace, validation

---

### PHASE 0: TRIAGE (Do Before Anything Else)

These are blockers or false-signal generators. Fix them before any further development work.

| Task ID | Description | Agent | Model | Depends On | Est. |
|---------|-------------|-------|-------|------------|------|
| P0-01 | **Resolve mycelium**: Determine whether mycelium should be (a) installed from its source, (b) replaced with a simpler git-notes wrapper, or (c) stripped from the project entirely. The current state is the worst option — infrastructure that references a nonexistent system. **Decision required from Ed before executing.** | lead-programmer | Opus | — | Decision |
| P0-02 | **Implement `soft_landing` check in `_on_landed()`**: Add group check before ROUGH_LANDING evaluation so Zone 4 works as documented. ~5 lines of code. | gameplay-programmer | Sonnet | — | 10 min |
| P0-03 | **Add placeholder `icon.svg`**: Create a simple BONNIE cat silhouette SVG or use Godot's default icon. Eliminates editor warning. | technical-artist | Haiku | — | 5 min |
| P0-04 | **Remove dead variables**: Delete `skid_timer` (line 144) and `jump_hold_timer` (line 147). Verify no external references. | gameplay-programmer | Haiku | — | 5 min |
| P0-05 | **Extract `_try_airborne_climb()`**: Deduplicate the mid-air climb logic from `_handle_jumping()` and `_handle_falling()` into a single helper function. | gameplay-programmer | Sonnet | — | 15 min |
| P0-06 | **Add `.gdignore` files**: Place in `mycelium/`, `production/`, `docs/`, `.claude/`, `.github/` to prevent Godot import scanning. | devops-engineer | Haiku | — | 5 min |
| P0-07 | **Fix systems-index.md progress tracker**: Update "started" and "reviewed" counts to reflect reality. | producer | Haiku | — | 5 min |

---

### PHASE 1: GATE 1 CLOSURE (Complete the Prototype Evaluation)

GATE 1 has 3 remaining items per NEXT.md. Close them.

| Task ID | Description | Agent | Model | Depends On | Est. |
|---------|-------------|-------|-------|------------|------|
| P1-01 | **Slide rhythm re-test**: Launch prototype, execute the Kaneda slide → claw brake → stop → pivot cycle. Document findings. Tune `claw_brake_multiplier` if needed. Write PLAYTEST-003.md. | qa-tester | Sonnet | P0-02, P0-05 | 30 min |
| P1-02 | **Camera AC-T08 disposition**: Decide whether camera-leads-movement is a GATE 1 blocker or deferrable. The camera GDD is approved; the prototype has the `LOOK_AHEAD_BY_STATE` data ready. Implementation is a separate task. **Recommend: defer to GATE 2 — camera is not a traversal-feel question, it's a polish question.** | creative-director | Opus | — | Decision |
| P1-03 | **Stealth radius disposition**: AC for sneaking stimulus reduction. No NPC system exists yet. **Recommend: defer to post-T-SOC — stealth radius is meaningless without NPCs to perceive it.** | game-designer | Opus | — | Decision |
| P1-04 | **GATE 1 final call**: With P1-01 through P1-03 resolved, write the GATE 1 PASS/FAIL verdict. Update NEXT.md and CHANGELOG.md. | producer | Sonnet | P1-01, P1-02, P1-03 | 15 min |

---

### PHASE 2: REMAINING MVP GDDs (Unblock GATE 2)

GATE 2 requires 11/11 MVP GDDs. Currently 8/11. Missing: Chaos Meter, Bidirectional Social System, Chaos Meter UI.

| Task ID | Description | Agent | Model | Depends On | Est. |
|---------|-------------|-------|-------|------------|------|
| P2-01 | **Design Chaos Meter (T-CHAOS)**: `design/gdd/chaos-meter.md`. Key constraints from NEXT.md: pure chaos plateaus below feeding threshold, charm MUST be mathematically required, no HP/death, max chaos = reacting-on-all-NPCs not game-over. | game-designer + economy-designer | Opus | GATE 1 PASS | 2-3 hours |
| P2-02 | **Design Bidirectional Social System (T-SOC)**: `design/gdd/bidirectional-social-system.md`. Must read `npc-personality.md` §3 first. Define NpcState write contract. Social axis must be visually legible without UI. Resolve NPC↔Social circular dependency via shared NpcState object. | game-designer + ux-designer | Opus | GATE 1 PASS | 2-3 hours |
| P2-03 | **Design Chaos Meter UI (T-FOUND-06)**: `design/gdd/chaos-meter-ui.md`. Depends on T-CHAOS skeleton being defined. | ui-programmer + ux-designer | Sonnet | P2-01 | 1-2 hours |
| P2-04 | **GATE 2 evaluation**: All 11 MVP GDDs reviewed and approved. Run `/gate-check pre-production`. | producer | Sonnet | P2-01, P2-02, P2-03 | 30 min |

---

### PHASE 3: PRODUCTION FOUNDATION (Build the `src/` Directory)

This is where the game starts being built for real. The prototype has served its purpose.

| Task ID | Description | Agent | Model | Depends On | Est. |
|---------|-------------|-------|-------|------------|------|
| P3-01 | **Sprint 1 plan (T-SPRINT-01)**: Define the first implementation sprint. Scope: Input System (1), Viewport Config (2), and BONNIE Traversal (6) — the foundation layer. Use `/sprint-plan`. | producer + lead-programmer | Opus | GATE 2 PASS | 1-2 hours |
| P3-02 | **Create `src/` directory structure**: Build the production directory layout per `.claude/docs/directory-structure.md`. Create `.gd` stub files with proper class_name, extends, and signal declarations ONLY — no implementation yet. This is the skeleton. | lead-programmer | Sonnet | P3-01 | 1 hour |
| P3-03 | **Implement Input System (`src/core/input/`)**: Production-quality input manager. Port relevant logic from prototype, add action validation, deadzone config, input remapping support. Reference `input-system.md`. | godot-gdscript-specialist | Sonnet | P3-02 | 2-3 hours |
| P3-04 | **Implement Viewport Config (`src/core/rendering/`)**: Production viewport setup. Window management, resolution scaling, pixel-perfect rendering. Reference `viewport-config.md`. | engine-programmer | Sonnet | P3-02 | 1-2 hours |
| P3-05 | **Implement Camera System (`src/core/camera/`)**: Full camera with look-ahead per state, ledge bias, smooth transitions, recon zoom. Wire up `LOOK_AHEAD_BY_STATE`. Reference `camera-system.md`. | gameplay-programmer | Sonnet | P3-03, P3-04 | 2-3 hours |
| P3-06 | **Implement Audio Manager (`src/core/audio/`)**: Bus layout, spatial audio, music crossfade, SFX pooling. Reference `audio-manager.md`. NOTE: Godot 4.6 uses semitones for AudioStreamRandomizer pitch, not frequency multipliers. | godot-specialist | Sonnet | P3-04 | 2-3 hours |
| P3-07 | **Production BONNIE Traversal (`src/gameplay/bonnie/`)**: Full rewrite of BonnieController. Decompose the 968-line monolith into flat, callable components: state machine, physics helpers, collision queries, input buffer, debug overlay. Port all 13 states. Fix known prototype shortcuts (NEXT.md lines 174-178). | gameplay-programmer | Sonnet | P3-03, P3-05 | 4-6 hours |
| P3-08 | **Write GDScript unit tests**: Test each state handler independently. Verify state transitions, physics values, buffer timers. Use GUT (Godot Unit Testing) or GdUnit4. | qa-lead | Sonnet | P3-07 | 2-3 hours |

---

### PHASE 4: INFRASTRUCTURE CLEANUP (Parallel Track)

These can run alongside Phase 2 and 3. They don't block gameplay work.

| Task ID | Description | Agent | Model | Depends On | Est. |
|---------|-------------|-------|-------|------------|------|
| P4-01 | **Mycelium resolution** (depends on P0-01 decision): Install, replace, or strip. If installing: verify `mycelium.sh` is on PATH, all hooks function, arrival/departure protocol works end-to-end. If stripping: remove all mycelium references from CLAUDE.md, rules, hooks. | devops-engineer | Sonnet | P0-01 decision | 1-2 hours |
| P4-02 | **Prune irrelevant agents**: Archive (don't delete) agents that have no work for 6+ months: `analytics-engineer`, `community-manager`, `live-ops-designer`, `localization-lead`, `release-manager`, `security-engineer`, `sound-designer`. Move to `.claude/agents/archived/`. Reduces session-start cognitive load. | producer | Haiku | — | 30 min |
| P4-03 | **Rename workspace file**: `Claude Code Game Studios.code-workspace` → `bonnie-game.code-workspace`. Eliminate the space. | devops-engineer | Haiku | — | 5 min |
| P4-04 | **Clean up empty PHYSICS HELPERS section**: Move `_apply_gravity()` under the PHYSICS HELPERS header. Add `_try_airborne_climb()` (from P0-05) there too. | gameplay-programmer | Haiku | P0-05 | 10 min |
| P4-05 | **Add upward velocity clamp comment**: In `_handle_jumping()` line 517, add a comment explaining why `fall_velocity_max` is reused for upward clamping, or introduce `ascent_velocity_max` constant. | gameplay-programmer | Haiku | — | 5 min |
| P4-06 | **Document CeilingCast status**: Add a comment to `_ceiling_cast` declaration noting it's vestigial (replaced by Area2D flag for squeeze detection) and retained only for debug HUD display. | gameplay-programmer | Haiku | — | 5 min |
| P4-07 | **Godot MCP integration**: Per NEXT.md Session 007 Priority 0. Verify MCP is configured, create/update `.claude/skills/godot-mcp/SKILL.md`, test that `godot --headless` works from agent tool calls. | devops-engineer + godot-specialist | Sonnet | — | 1-2 hours |

---

### PHASE 5: VERTICAL SLICE PREPARATION (After Sprint 1)

Not actionable yet. Documented here so the dependency chain is visible.

| Task ID | Description | Agent | Model | Depends On |
|---------|-------------|-------|-------|------------|
| P5-01 | Environmental Chaos System GDD | game-designer | Opus | P2-01 |
| P5-02 | NPC Behavior/Routine System GDD | game-designer + ai-programmer | Opus | P2-02 |
| P5-03 | NPC Relationship Graph GDD | game-designer | Opus | P2-02 |
| P5-04 | Antagonist/Trap System GDD | game-designer | Opus | P5-01 |
| P5-05 | Dialogue System GDD | game-designer + writer | Opus | P5-02 |
| P5-06 | Aseprite Export Pipeline | tools-programmer | Sonnet | P3-04 |
| P5-07 | Level Manager implementation | gameplay-programmer | Sonnet | P3-04, P3-06 |
| P5-08 | Interactive Object System implementation | gameplay-programmer | Sonnet | P3-07 |
| P5-09 | DI-002: Underside Platform Clinging (HANGING state) | game-designer + gameplay-programmer | Sonnet | P3-07 |

---

## PART 7: SWARM EXECUTION MAP

For Claude Code subagent orchestration, here's how the phases map to parallel execution:

```
TIME ──────────────────────────────────────────────────────────►

PHASE 0 (TRIAGE) — all tasks can run in parallel
  ├── P0-01 (mycelium decision) ← REQUIRES ED INPUT
  ├── P0-02 (soft_landing fix)
  ├── P0-03 (icon.svg)
  ├── P0-04 (dead variables)
  ├── P0-05 (extract _try_airborne_climb)
  ├── P0-06 (.gdignore files)
  └── P0-07 (progress tracker fix)

PHASE 1 (GATE 1) — sequential, decision-gated
  P1-01 (slide retest) → P1-02 + P1-03 (dispositions) → P1-04 (GATE 1 call)

PHASE 2 (MVP GDDs) — P2-01 and P2-02 run in parallel
  ├── P2-01 (Chaos Meter GDD) ──────┐
  └── P2-02 (Social System GDD) ────┼── P2-03 (Chaos UI GDD) → P2-04 (GATE 2)
                                     │
PHASE 4 (INFRASTRUCTURE) — runs alongside Phases 1-3
  ├── P4-01 (mycelium) ← after P0-01 decision
  ├── P4-02 (prune agents)
  ├── P4-03 (rename workspace)
  ├── P4-04 (physics helpers section)
  ├── P4-05 (velocity clamp comment)
  ├── P4-06 (CeilingCast comment)
  └── P4-07 (Godot MCP)

PHASE 3 (PRODUCTION) — after GATE 2, partially parallelizable
  P3-01 (sprint plan) → P3-02 (src/ skeleton)
                           ├── P3-03 (Input) ──────┐
                           ├── P3-04 (Viewport) ───┤
                           └── P3-06 (Audio) ──────┤
                                                    ├── P3-05 (Camera)
                                                    └── P3-07 (BONNIE rewrite) → P3-08 (tests)
```

---

## PART 8: DECISION POINTS FOR ED

I need your call on these before the swarm can execute:

1. **Mycelium (P0-01)**: Install it properly, replace it with something simpler, or strip it? My recommendation: if the original mycelium source is available and works with git-notes as described, install it. If not, a 50-line bash wrapper around `git notes` that supports `read`, `note`, `find`, and `list` would cover 90% of the described protocol. Don't leave it phantom.

2. **Camera for GATE 1 (P1-02)**: Defer to GATE 2? Camera is approved in GDD, data structure exists in code, but it's a polish concern not a traversal-feel concern. I recommend deferral.

3. **Stealth radius for GATE 1 (P1-03)**: Defer to post-T-SOC? There are no NPCs to perceive BONNIE. Stealth radius is meaningless without a perception system. I recommend deferral.

4. **Agent pruning (P4-02)**: Archive the irrelevant agents or keep the full roster? My recommendation: archive. They're adding cognitive load with zero utility for the next 3-6 months minimum.

5. **Prototype vs. production priority**: Do you want to keep iterating the prototype (add camera, add soft_landing, etc.) or do you want to close GATE 1, bang out the remaining GDDs, and move to production code in `src/`? My recommendation: close GATE 1 with deferrals, write the remaining 3 GDDs, and get to production code. The prototype has taught us what it needed to teach us.

---

*End of audit. Every finding is backed by file paths and line numbers. Every recommendation has a task ID, an agent assignment, a model tier, and a dependency chain. No bullshit. No placeholders. Ready when you are.*
