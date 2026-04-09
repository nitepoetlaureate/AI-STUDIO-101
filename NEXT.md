# BONNIE! — Next Steps Handoff

**For**: The next Claude session / collaborator picking up this project
**Written by**: Hawaii Zeke (Claude) on 2026-04-08
**Context**: Session 002 complete. Six design docs exist, four system GDDs approved. GATE 0 cleared. No code exists yet.
**Immediate priority**: Traversal Prototype (NOW UNBLOCKED) + Foundation GDDs (parallel)

Read this file first. Then read the locked decisions section before touching anything.

---

## Current State

### What Is Done and Approved

| File | Status | Notes |
|------|--------|-------|
| `design/gdd/game-concept.md` | Approved | Full game bible. Do not redesign. |
| `design/gdd/systems-index.md` | Approved | 27 systems, dependency graph, design order. Updated Session 002. |
| `design/gdd/bonnie-traversal.md` | Approved | Full movement vocabulary, all mechanics locked. System #6. |
| `design/gdd/npc-personality.md` | Approved | 11-state machine, NpcState interface, Michael+Christen. Systems #9+10. |
| `design/gdd/viewport-config.md` | Approved | 720x540 viewport window (world space unbounded), nearest-neighbor, 60fps unconditional. System #2. |
| `design/gdd/camera-system.md` | Approved | State-scaled look-ahead, y=380, ledge bias, recon zoom 0.33 max, LOD sprite swap. System #4. |
| `DEVLOG.md` | Live | Sessions 001-002 documented. |
| `CHANGELOG.md` | Live | Pre-production 0.1 documented. |
| `README.md` | Updated | Active project section added. |
| Mycelium notes | Pushed | All six GDDs noted. Constraints + warnings on tree objects. |
| Engine reference | Configured | Godot 4.6 breaking changes, deprecated APIs, best practices. |

### What Does NOT Exist Yet

- `project.godot` -- Godot project file does not exist
- `src/` -- No game code whatsoever
- `assets/` -- No art assets
- `prototypes/` -- No prototype directory
- Input System GDD (`design/gdd/input-system.md`) -- Foundation, MVP. Does not exist.
- Audio Manager GDD (`design/gdd/audio-manager.md`) -- Foundation, MVP. Does not exist.
- Chaos Meter GDD (`design/gdd/chaos-meter.md`) -- Gameplay, MVP. Does not exist.
- Bidirectional Social System GDD (`design/gdd/bidirectional-social-system.md`) -- Gameplay, MVP. Does not exist.
- Sprint 1 plan -- Does not exist.
- `production/session-state/active.md` -- Does not exist (gitignored, doesn't persist).

### Known Issues to Fix

- `npc-personality.md` Section 3.4 (Christen routine) lacks arrival trigger, phase durations, departure condition. See T-NPC-FIX below.
- NPC pre-emptive stimulus removal (phone off hook, close blinds) is Vertical Slice scope, NOT MVP.
- CHASING state is Vertical Slice scope, NOT MVP.

---

## Locked Decisions -- Do Not Re-Litigate

These were settled by the developer after full design sessions. Do not propose alternatives.

### Traversal
- **Jump**: tap = hop, hold = full arc (variable height via hold). Double jump is apex-locked (available from first jump's peak, not immediately on leaving ground).
- **Post-double-jump**: air control drops to near-zero (~30 px/s2). BONNIE is committed to her arc. This is intentional -- it gives the Ledge Parry its weight.
- **Ledge Parry**: pure timing mechanic, no auto-grab, no visual telegraph. Cat reflexes or BONNIE falls. Miss it -> FALLING continues. On success: platform edge -> LEDGE_PULLUP, climbable wall -> CLIMBING.
- **Wall jump**: only on surfaces tagged `Climbable`. Climbable = carpet, fabric, curtains, rope, cat trees, door frames, shelving. NOT climbable = metal, glass, hardwood, tile, painted drywall.
- **Run input**: dedicated run button (default). Autorun buildup is an accessibility toggle only (off by default).
- **No death**: ever. Looney Tunes / Nine Lives / Felix the Cat physics. DAZED and ROUGH_LANDING are setbacks, not punishments. BONNIE always gets up.
- **The Kaneda slide**: at speed, BONNIE cannot stop instantly. High-speed direction reversal = SLIDING state. Very low friction. Objects in path get knocked over. Pop-jump available from SLIDING.

### NPC System
- **Michael**: apartment owner. Does NOT flee (his apartment). comfort_receptivity floor 0.15. Work phase lowers reaction_threshold by -0.1.
- **Christen**: Michael's partner. CAN flee (to another room). comfort_receptivity floor 0.20. Cascade bleed between them elevated by +0.2 (`relationship_cascade_bonus`).
- **NpcState** is the shared object resolving the Social System / NPC System circular dependency. Neither system calls the other directly.
- **Pre-emptive stimulus removal** (phone off hook, close blinds): Vertical Slice scope. NOT MVP.
- **CHASING state**: Vertical Slice scope (antagonist NPCs). NOT MVP.

### Art + Tech
- **720x540 = viewport WINDOW only** -- world space is unbounded. Levels can be any size. Never constrain level geometry to viewport dimensions. The 720x540 defines the camera's view into the world, not the world's size.
- **60fps locked unconditionally** through ALL view/mode changes (room transitions, mini-game cut-ins, feeding cutscenes). A dropped frame at any transition is a bug, not acceptable behavior.
- **Nearest-neighbor filtering throughout**. No bilinear or trilinear anywhere in the pipeline. Blur is forbidden.
- **Pillarbox on widescreen**: black bars (#000000). Content is never stretched or cropped.
- **Stretch mode**: Godot `viewport` + `keep`. Default window 1440x1080 (2x integer scale).
- **No discrete GPU required**: all shader effects must run on integrated graphics (Intel HD / AMD Vega iGPU).
- **Performance floor**: integrated graphics, 4GB RAM, any CPU from 2013 or later.
- **Draw calls**: <=50 per frame.

### Camera System (NEW -- Session 002)
- **Look-ahead by movement state**: IDLE 0px, SNEAKING 40px, WALKING 80px, RUNNING 180px, SLIDING 220px, JUMPING/FALLING 120px horizontal, CLIMBING 60px vertical, SQUEEZING 0px (room lock), DAZED/ROUGH_LANDING 0px, LEDGE_PULLUP 60px.
- **BONNIE vertical position in viewport**: y=380 of 540 (lower third, ~70% down). Tunable range 340-420.
- **Ledge approach bias**: activates at 80px radius from geometry (before parry_detection_radius=24px). Camera biases toward surface so player sees ledge before parry window opens.
- **Recon zoom**: analog hold on dedicated button, available in ALL movement states (not gated to IDLE). zoom_max_out=0.33 (reveals ~2160x1620 world space, potentially multiple rooms).
- **LOD sprite threshold**: zoom_lod_threshold=0.75. Below this, AnimatedSprite2D nodes swap SpriteFrames to _lod variants via `zoom_lod_changed` signal.
- **LOD sprites are Vertical Slice scope, NOT MVP.** Prototype uses colored rectangles. Each sprite gets a `_lod` suffix variant authored at reduced scale in Aseprite. T-ART-04 tracks this.
- **Zoom in all states**: recon zoom works during RUNNING, FALLING, every state. Do not gate it.
- **Godot 4.6** is beyond LLM training cutoff. ALWAYS check `docs/engine-reference/godot/` before suggesting any API call. Breaking changes in 4.4, 4.5, and 4.6 are real and documented there.

### Project Identity
- BONNIE is a real cat, found under a dumpster on Germantown Ave, Philadelphia.
- Christen is Michael's partner -- "the sun, moon, and stars of the apartment's emotional ecosystem."
- Commit co-author line: `Co-Authored-By: Hawaii Zeke <(302) 319-3895>`
- No console target. PC / Steam only.
- Do NOT add Untitled Goose Game to public-facing materials. It appears in the inspiration table inside game-concept.md (design-internal only) -- keep it there, remove from anything public-facing.

---

## Critical Path

```
T-CAM  DONE (Camera GDD approved 2026-04-08)
        |
T-PROTO <-- NOW UNBLOCKED (start immediately)
        |     (parallel)
T-FOUND (input-system + audio-manager) + T-NPC-FIX
        |
T-CHAOS + T-SOC  <-- parallel, after prototype playtest
        |
T-SPRINT (Sprint 1 Plan)
        |
T-IMPL (Sprint 1 Implementation)
```

Art pipeline and music are a fully independent parallel track at any point.

---

## Atomic Task Breakdown

### PHASE 0 -- Camera GDD (COMPLETE)

All T-CAM tasks are complete. GATE 0 is cleared.

- [x] T-CAM-01: Create camera-system.md skeleton
- [x] T-CAM-02: Write Overview + Player Fantasy
- [x] T-CAM-03: Write Detailed Rules (look-ahead per state, ledge bias, recon zoom, LOD)
- [x] T-CAM-04: Write Formulas (camera target, zoom, ledge bias, LOD signal)
- [x] T-CAM-05: Write Edge Cases
- [x] T-CAM-06: Write Dependencies + Tuning Knobs + Acceptance Criteria (8 ACs)
- [x] T-CAM-07: Mycelium notes written

---

### PHASE 1 -- Traversal Prototype (HIGHEST PRIORITY)

The highest-priority technical task in the entire project. Run `/prototype bonnie-traversal`.
Do NOT timebox this. The traversal must feel right before anything is built on top of it.

**T-PROTO-01** -- Create `project.godot`:
- Viewport: 720x540, stretch mode `viewport`, aspect `keep`
- Rendering: nearest-neighbor (Texture Filter: Nearest, no antialiasing)
- Default window: 1440x1080 (2x integer scale), resizable
- Physics: Godot Physics 2D (NOT Jolt -- Jolt is 3D-only)
- Cross-reference `docs/engine-reference/godot/current-best-practices.md`

**T-PROTO-02** -- Configure input map:
- `move_left`, `move_right` -- directional
- `run` -- dedicated button, hold to run
- `jump` -- tap detection + hold detection both needed
- `sneak` -- hold to sneak
- `slide` -- explicit slide input (also auto-triggers from opposing-run at speed)
- `grab` -- Ledge Parry input
- `drop` -- deliberate fall from climb
- `zoom` -- recon zoom, dedicated button, analog hold

**T-PROTO-03** -- Implement `BonnieController.gd` (CharacterBody2D):
- State machine enum: IDLE, SNEAKING, WALKING, RUNNING, SLIDING, JUMPING,
  FALLING, LANDING, CLIMBING, SQUEEZING, DAZED, ROUGH_LANDING, LEDGE_PULLUP
- velocity: Vector2, processed via move_and_slide()
- Cross-reference breaking-changes.md: CharacterBody2D changed between 4.3->4.6

**T-PROTO-04** -- Ground movement (SNEAKING / WALKING / RUNNING / SLIDING):
- Speed caps per state (bonnie-traversal.md Section 4.5)
- ground_acceleration=800, ground_deceleration=600
- Slide trigger: speed > slide_trigger_speed + opposing input -> SLIDING
- slide_friction: very low decel during SLIDING (~80 px/s2)
- Pop-jump from SLIDING: jump input fires with full horizontal momentum carried

**T-PROTO-05** -- Jump system:
- Tap vs. hold height differentiation (additive hold force up to ceiling)
- Coyote time: 5 frames grace after leaving ledge
- Jump buffering: 6 frames pre-land
- Double jump: apex-locked (`double_jump_window` frames from first jump peak)
- Post-double: air control = ~30 px/s2
- hop_velocity=280, jump_velocity=480, double_jump_velocity=380

**T-PROTO-06** -- Landing + skid system:
- Speed-proportional skid on landing
- skid_friction_multiplier window: 0.15x normal decel
- Hard skid above 320 px/s (longer window, brief stumble animation)
- Skid threshold: 180 px/s
- Pop-jump during skid: jump input carries full horizontal momentum

**T-PROTO-07** -- Fall tracking + ROUGH_LANDING:
- Track fall_distance from when BONNIE leaves ground non-voluntarily
- rough_landing_threshold default: 144px
- ROUGH_LANDING: flat recovery animation, limited input for 2.5s
- Cushion surface detection (soft_landing group) resets fall_distance

**T-PROTO-08** -- LEDGE PARRY:
- During FALLING/JUMPING: detect within parry_detection_radius=24px of geometry
- `grab` input within parry_window_frames=6f of ledge-plane crossing:
  - Platform edge -> LEDGE_PULLUP (snap to top, short animation, full control)
  - Climbable wall -> CLIMBING
- NO auto-grab. NO visual telegraph. Miss the window = FALLING continues.

**T-PROTO-09** -- CLIMBING + WALL JUMP:
- Climbable surfaces: nodes in `Climbable` group
- Move up/down at climb_speed=90 px/s; left/right input detaches -> FALLING/JUMPING
- Wall jump: `jump` while CLIMBING -> perpendicular launch at wall_jump_velocity=360 px/s
- Double jump resets on any Climbable contact

**T-PROTO-10** -- Camera (to camera-system.md spec, PARALLEL with T-PROTO-04):
- Look-ahead scaled by movement state (full table in camera-system.md Section 3)
- BONNIE at y=380 of 540 (lower third)
- Smooth catch-up on direction reversal (lerp coefficient in camera-system.md Section 4)
- Ledge-approach bias at 80px radius during FALLING/JUMPING
- Recon zoom: analog hold, zoom_max_out=0.33, zoom_lod_changed signal at 0.75 threshold

**T-PROTO-11** -- Test level geometry (PARALLEL with T-PROTO-02):
- Flat ground run corridor (test RUNNING + SLIDING + pop-jump)
- Platforms at varying heights: 1 hop, 1 full jump, 1 double-jump required
- Tall drop ~200px to hard surface (test ROUGH_LANDING)
- Tall drop ~200px to soft surface (test cushion interrupt -- no ROUGH_LANDING)
- Series of ledge edges for LEDGE PARRY practice
- Climbable wall sections (carpet-textured Climbable group nodes)
- Smooth wall sections (no Climbable group -- test parry FAIL behavior)
- Narrow gap ~32px height (test SQUEEZING)
- Enclosed test space for SLIDING collision (objects to knock over)
- Room wider than 720px (validates unbounded world space + camera follow)
- Room taller than 540px (validates vertical camera follow)

**T-PROTO-12** -- Playtest + validate against bonnie-traversal.md ACs:
- Run all acceptance criteria from bonnie-traversal.md Section 8
- Capture tuning notes: which default values feel wrong
- The four feel questions only YOU can answer:
  1. Does the parry window feel like cat reflexes, or an invisible wall?
  2. Is post-double-jump commitment readable as physics, or does it feel like input failure?
  3. Does the Kaneda slide feel like a consequence, or a punishment?
  4. Is the rough landing threshold right at 144px, or does it trigger too often / too rarely?
- Run `/playtest-report` to structure findings
- Lock revised tuning values back into bonnie-traversal.md Section 7

> **Agents**: `godot-specialist` + `gameplay-programmer`
> **Critical**: Cross-reference `docs/engine-reference/godot/breaking-changes.md`
>   before EVERY API call. AudioServer, AnimationPlayer, and CharacterBody2D all changed.
> **Parallelization**: After T-PROTO-01, launch T-PROTO-11 parallel. After T-PROTO-03, launch T-PROTO-10 parallel with T-PROTO-04.
> **Effort**: L (multiple sessions). The prototype is not a deliverable -- the *feel* is.

---

### PHASE 2 -- Foundation GDDs + NPC Fix (PARALLEL with prototype)

#### Subgroup A -- Fix NPC GDD

**T-NPC-FIX-01** -- Add Christen arrival trigger to `design/gdd/npc-personality.md`:
Currently Christen's routine has no timing. Add: arrival_trigger (time-based OR
event-based), phase durations in seconds of ROUTINE-state time, departure condition.
Her phases need the same specificity as Michael's 6-phase schedule.

**T-NPC-FIX-02** -- Add routine phase advancement spec:
Currently undefined: what triggers Michael from Morning -> Work phase?
Add: each phase has `phase_duration` (seconds of ROUTINE time, pauses in other states).
Add phase_duration as a tuning knob per NPC per phase in Section 7.

> **Agent**: `game-designer`
> **Effort**: XS (30 min)

#### Subgroup B -- Foundation GDDs (two remaining)

**T-FOUND-01** -- Write `design/gdd/input-system.md`:
- All button actions with semantic names (including `zoom` for recon)
- Input buffering rules (jump: 6 frames; grab/parry: NO buffer -- pure timing)
- Analog vs. digital (sneak on analog stick below sneak_threshold)
- Accessibility: full button remapping required
- Cross-reference: bonnie-traversal.md Section 3 (input triggers), camera-system.md Section 3 (zoom input)

**T-FOUND-03** -- Write `design/gdd/audio-manager.md`:
- Bus structure: Master -> Music (OGG streaming) + SFX (short uncompressed WAV)
- Volume controls: Music, SFX, Master (saved to user config)
- BONNIE audio events: footstep variants by surface, meow, chirp, thud, slide SFX,
  parry-grab SFX, rough-landing SFX, DAZED stars SFX
- NPC vocal samples: crunchy SNES/Genesis-style digitized exclamations --
  surprise, anger, delight, fear -- short, expressive, era-appropriate
- No uncompressed music in repository
- **TRAP**: AudioStreamRandomizer pitch uses semitones in Godot 4.6, NOT frequency multipliers. Route Section 4 through godot-specialist review.

> **Agent**: `game-designer` for content, `godot-specialist` review for Godot 4.6 audio API
> **Effort**: S (one session for both)

---

### PHASE 3 -- Core Gameplay GDDs (after prototype playtest validated)

Run these two in parallel -- they're independent of each other.

#### T-CHAOS -- Chaos Meter GDD

**T-CHAOS-01** -- Create `design/gdd/chaos-meter.md` skeleton

**T-CHAOS-02** -- Design contribution sources:
- NPC entering REACTING: `base_npc_contribution x emotional_level_at_entry`
- Charm during VULNERABLE (levity multiplier path): high value, earns charm meter
- Object destruction: per-object `chaos_value`
- Pest catch: `pest_chaos_value`
- Cascade events (secondary NPC triggered): reduced (x0.6 weight)

**T-CHAOS-03** -- Design the feeding threshold constraint:
> "The meter rewards creativity, not persistence."
- Pure chaos path must plateau below feeding threshold
- Charm contributions MUST be required to reach max meter
- Formula must enforce this mathematically, not just as a rule

**T-CHAOS-04** -- Design visual representation:
- Visible but not prominent -- this is not a health bar
- Consider: is it literal (food bowl filling?) or abstract?
- Must be readable in 720x540 at pixel art scale

**T-CHAOS-05** -- Write full GDD (all 8 sections, formulas, ACs)

> **Agents**: `game-designer` + `economy-designer`
> **Effort**: M

#### T-SOC -- Bidirectional Social System GDD

**T-SOC-01** -- Create `design/gdd/bidirectional-social-system.md` skeleton

**T-SOC-02** -- Define charm interaction types with NpcState write specs:
- Rub/headbutt: +goodwill, requires adjacency, NPC not in REACTING
- Sit near: ambient goodwill trickle (proximity radius, passive)
- Sit on lap: higher rate, NPC must be in ROUTINE/RECOVERING/VULNERABLE
- Meow at: small goodwill + bumps NPC toward AWARE
- Purr: while sitting on NPC, significant goodwill during VULNERABLE

**T-SOC-03** -- Spec NpcState writes per interaction:
This is the other half of the circular dependency. The Social System writes to NpcState;
the NPC System reads it. Define exactly what fields are written and under what conditions.
game-designer MUST read npc-personality.md Section 3 (full NpcState field list) before drafting.

**T-SOC-04** -- Design feedback clarity:
The player must discover the social axis exists without being told.
Goodwill gain feedback must be legible but not UI-heavy at 720x540.
Consider: what does the player see/hear when charm is working?

**T-SOC-05** -- Write full GDD (all 8 sections, formulas, ACs)

> **Agents**: `game-designer` + `ux-designer` (feedback clarity)
> **Effort**: M

---

### PHASE 4 -- Sprint 1 Plan

**T-SPRINT-01** -- Run `/sprint-plan new` once all of the following exist:
- Traversal prototype validated (T-PROTO-12 complete)
- Foundation GDDs approved (T-FOUND complete)
- Chaos Meter GDD approved (T-CHAOS complete)
- Social System GDD approved (T-SOC complete)
- NPC personality fix applied (T-NPC-FIX complete)

Sprint 1 goal recommendation: **BONNIE moves, Michael reacts, chaos meter ticks.**
No art, no audio, placeholder geometry only.

Suggested Sprint 1 scope:
- Foundation: viewport config, input map, audio bus skeleton
- BONNIE traversal code (migrate from prototype into `src/`)
- NpcState class + 11-state machine skeleton (Michael only, ROUTINE/AWARE/REACTING minimum)
- Michael routine: Morning + Work phases only
- Chaos meter: float increments correctly on REACTING event
- Verify: BONNIE runs -> Michael enters AWARE -> REACTING -> chaos meter ticks

> **Agent**: `producer`
> **Effort**: S

---

### PHASE 5 -- Art + Music (Independent Track -- Start Anytime)

**T-ART-01** -- Set up Aseprite CLI export pipeline:
```bash
aseprite -b --sheet output.png --data output.json input.aseprite
```
Target: Godot SpriteFrames resource. Output: `assets/art/sprites/`
Agent: `tools-programmer`

**T-ART-02** -- BONNIE placeholder sprite:
32x32px black cat silhouette in Aseprite. Developer draws; tools-programmer sets up import.
Purpose: validates the pipeline, gives prototype something to render.

**T-ART-03** -- Apartment mood board:
Reference images for Level 2. Color palette, tile set needs, furniture inventory, lighting tone.
Output: `design/levels/level-02-apartment-reference.md`

**T-ART-04** -- LOD sprite spec + pipeline extension (Vertical Slice scope):
- Every gameplay sprite needs `_lod` variant authored in Aseprite at reduced scale
- Godot: AnimatedSprite2D holds two SpriteFrames (full + LOD)
- Camera emits `zoom_lod_changed` signal at zoom_lod_threshold=0.75; sprites subscribe and swap
- Naming: `bonnie_run_lod.png` / `bonnie_run_lod.json` (append `_lod` suffix)
- LOD source art: separate Aseprite files at target small scale (~11x11px for BONNIE at 0.33 zoom vs ~32x32px normal)
- NOT needed for prototype -- colored rectangles suffice
- Agent: `tools-programmer` (pipeline) + `art-director` (scale targets)

**T-MUSIC-01** -- Level 2 apartment theme:
Developer composes original chiptune. No tooling needed.
Style: cozy with undercurrent of chaos potential.
Output: `assets/audio/music/level_02_apartment.ogg` when ready.

---

## Parallel Subagent Opportunities

### Set A -- After GATE 0 (NOW AVAILABLE)

Launch in one message with three parallel Agent tool calls:

**Agent 1** -- Foundation GDDs (`game-designer`)
Write input-system.md + audio-manager.md via `/design-system`.
Context: bonnie-traversal.md for input needs, camera-system.md for zoom input,
technical-preferences.md for audio specs, game-concept.md for NPC audio philosophy.
Route audio-manager.md Section 4 through `godot-specialist` for AudioStreamRandomizer trap.

**Agent 2** -- Christen Routine Fix (`game-designer`)
Edit `design/gdd/npc-personality.md` Section 3.4.
Add arrival trigger, phase timings, phase_duration tuning knobs for Christen.
Match the specificity of Michael's 6-phase routine schedule.

**Agent 3** -- Aseprite Pipeline (`tools-programmer`)
Set up CLI export pipeline (T-ART-01).
Context: technical-preferences.md for art pipeline spec.

### Set B -- After GATE 1 (prototype playtest)

Launch in one message with two parallel Agent tool calls:

**Agent 1** -- Chaos Meter GDD (`game-designer` + `economy-designer`)
Write `design/gdd/chaos-meter.md` via `/design-system`. All 8 sections.
Key constraint: charm MUST be required for full meter fill. Brute-force chaos plateaus.

**Agent 2** -- Social System GDD (`game-designer` + `ux-designer`)
Write `design/gdd/bidirectional-social-system.md` via `/design-system`. All 8 sections.
Key challenge: feedback must make the social axis discoverable without tutorial.
Must define NpcState write contract (other half of NPC circular dependency).

### Set C -- After T-PROTO-03 (controller skeleton exists)

Launch in one message with two parallel Agent tool calls:

**Agent 1** -- Ground movement (`gameplay-programmer`)
Implement T-PROTO-04 in `prototypes/bonnie-traversal/BonnieController.gd`

**Agent 2** -- Camera implementation (`godot-specialist`)
Implement T-PROTO-10 in `prototypes/bonnie-traversal/BonnieCamera.gd`

---

## Warnings for the Next Collaborator

1. **Godot 4.6 is beyond LLM training cutoff.** Check `docs/engine-reference/godot/`
   before every API suggestion. Specific traps:
   - `AnimationPlayer.play()` now uses StringName: `play(&"animation_name")`
   - AudioStreamRandomizer pitch is in semitones in 4.6, NOT frequency multipliers
   - CharacterBody2D behavior changed between 4.3 and 4.6
   - Jolt is 3D-only and completely irrelevant to BONNIE's 2D physics

2. **Prototype is unblocked.** T-CAM is complete. Start T-PROTO immediately.
   The Ledge Parry cannot be evaluated without a camera built to spec -- and it now exists.

3. **NPC + Social designed together.** They share NpcState. Cannot implement
   the NPC state machine without knowing what the Social System writes.
   Design both GDDs before implementing either.

4. **No Singleton for mutable game state.** Hard rule. Use signals or dependency
   injection. NpcState is a resource object, not a singleton.

5. **No auto-grab on ledges.** This was explicitly rejected. Pure parry only.
   Auto-grab breaks aerial sequences and hides exploration. Non-negotiable.

6. **Run button is explicit.** Not auto-run. Auto-run is accessibility toggle only.

7. **BONNIE never dies.** No HP. No game-over. DAZED and ROUGH_LANDING are max.

8. **Commit identity**: `Co-Authored-By: Hawaii Zeke <(302) 319-3895>`

9. **Prototype code is throwaway.** `prototypes/` is isolated from `src/`.
   Standards relaxed for speed. No doc comments required in prototype.

10. **Stage/commit before Mycelium-noting new files.** Unstaged files can't be
    noted by path. Stage first, then `mycelium.sh note <file> -k <kind> -m "..."`.
    For already-committed files with existing notes, use `-f` to overwrite.

11. **Christen's routine is currently underspecified** in npc-personality.md.
    She has phase names but no timings or arrival trigger. Fix this before
    attempting NPC implementation (T-NPC-FIX).

12. **720x540 is the viewport WINDOW, NOT the world/level size.** Levels are
    unbounded world space. Never constrain level geometry to viewport dimensions.
    This distinction is explicit throughout viewport-config.md -- read it.

13. **LOD sprites are required for the recon zoom system** (zoom_lod_threshold=0.75).
    Prototype does NOT need them -- colored rectangles suffice. LOD sprites are
    Vertical Slice scope (T-ART-04). Do not block MVP on them.

14. **Camera recon zoom works in ALL movement states** including RUNNING and FALLING.
    Do not gate zoom to IDLE. This was an explicit design decision in camera-system.md.

---

## Recommended Reading Order for a New Session

```bash
# 1. Start here
cat NEXT.md  # this file

# 2. Studio config and rules
cat CLAUDE.md
cat .claude/docs/technical-preferences.md

# 3. Engine warnings (before any Godot code)
cat docs/engine-reference/godot/VERSION.md
cat docs/engine-reference/godot/breaking-changes.md

# 4. Design docs (read whichever is relevant to current task)
cat design/gdd/bonnie-traversal.md   # if working on prototype
cat design/gdd/camera-system.md      # if working on prototype camera
cat design/gdd/viewport-config.md    # if working on project setup
cat design/gdd/npc-personality.md    # if working on NPC/Social

# 5. Session context
mycelium.sh find constraint
mycelium.sh find warning
mycelium/scripts/context-workflow.sh <file-you-are-working-on>
```

---

## Quick Reference: Key Formulas

**Horizontal movement** (bonnie-traversal.md Section 4.1):
```gdscript
velocity.x = move_toward(velocity.x, target_speed, accel * delta)
# accel = 800 px/s2 (moving), 600 px/s2 (stopping), 80 px/s2 (SLIDING)
```

**Jump velocities** (Section 4.2):
- Tap -> `hop_velocity` = 280 px/s
- Hold -> additive up to `jump_velocity` = 480 px/s
- Double jump -> `double_jump_velocity` = 380 px/s
- Post-double `air_control` = 30 px/s2 (near-zero, committed)

**Landing skid** (Section 4.3):
- Skid triggers above 180 px/s impact speed
- Hard skid above 320 px/s
- Skid friction multiplier: 0.15x normal deceleration

**Rough landing** (Section 4.4):
- `fall_distance >= 144px` without cushion surface -> ROUGH_LANDING

**Camera target** (camera-system.md Section 4):
```gdscript
func get_camera_target(bonnie: CharacterBody2D) -> Vector2:
    var look_ahead_distance: float = LOOK_AHEAD_BY_STATE[bonnie.current_state]
    var look_ahead_offset := Vector2(bonnie.facing_direction * look_ahead_distance, 0.0)
    var vertical_offset := Vector2(0.0, -(540.0 * 0.5 - 380.0))  # = -110px
    return bonnie.global_position + look_ahead_offset + vertical_offset
```

**Recon zoom** (camera-system.md Section 4):
```gdscript
func _process(delta: float) -> void:
    if Input.is_action_pressed(&"zoom"):
        current_zoom = max(zoom_max_out, current_zoom - zoom_out_rate * delta)
    else:
        current_zoom = min(zoom_normal, current_zoom + zoom_return_rate * delta)
    zoom = Vector2(current_zoom, current_zoom)
    var use_lod := current_zoom < zoom_lod_threshold
    emit_signal(&"zoom_lod_changed", use_lod)
```

**NPC emotional decay** (npc-personality.md Section 4.1):
```gdscript
emotional_level += (baseline_tension - emotional_level) * emotion_decay_rate * delta
```

**Goodwill** (Section 4.2):
```gdscript
goodwill = clamp(goodwill + charm_value * comfort_receptivity, 0.0, 1.0)
```

**Cascade** (Section 4.4):
```gdscript
cascade_stimulus = emotional_level_A * cascade_bleed_factor
# Michael <-> Christen: cascade_bleed_factor + 0.2 (relationship_cascade_bonus)
```

---

## Verification Gates

| Gate | Condition | Status | Unlocks |
|------|-----------|--------|---------|
| GATE 0 | Camera + Viewport GDDs approved | CLEARED | Streams A+B+C (prototype, GDDs, art) |
| GATE 1 | Prototype playtested, ACs pass, tuning locked | Pending | Phase 3 (Chaos + Social GDDs) |
| GATE 2 | All 8 system GDDs approved (4/8 done) | Pending | Phase 4 (Sprint 1 plan) |
| GATE 3 | Sprint 1 plan approved | Pending | Phase 5 (Implementation) |

---

*Hawaii Zeke -- Session 002 is complete. The design foundation now has six documents and
four approved system GDDs. The prototype is unblocked. Build BONNIE. Make her feel right
to move. Everything else follows from that.*
