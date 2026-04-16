# BONNIE! — Next Steps Handoff

**For**: Session 007
**Written by**: Hawaii Zeke (Claude) on 2026-04-15
**Context**: Session 006 complete. GATE 1 CONDITIONALLY NEAR-PASS. DI-001 + DI-003 implemented and confirmed. T-FOUND-04 + T-FOUND-05 approved (8/11 MVP GDDs). Mycelium pre/post-tool-use hooks wired. Godot CLI MCP to be integrated this session.
**Immediate priority**: Godot MCP integration → slide rhythm tuning re-test → GATE 1 final call → T-CHAOS + T-SOC GDDs

Read this file first. Then read the locked decisions section before touching anything.

---

## Session 006 Summary

### What Was Done

| Area | Result |
|------|--------|
| Squeezing (B02) | FULLY FIXED — 3-layer fix (groups syntax, ramp removal, shape position offset) |
| Ledge pullup | REDESIGNED — DI-001 directional pop, confirmed working |
| Claw brake | IMPLEMENTED — DI-003 E-during-SLIDING, confirmed working |
| Mid-air climbing | IMPLEMENTED — E during JUMPING/FALLING near Climbable |
| Auto-clamber | IMPLEMENTED — wall top exits CLIMBING without UP input |
| T-FOUND-04 | APPROVED — `design/gdd/level-manager.md` |
| T-FOUND-05 | APPROVED — `design/gdd/interactive-object-system.md` |
| Mycelium hooks | WIRED — pre/post tool-use hooks for Write/Edit |
| Systems approved | **8/11 MVP** |

### GATE 1 Status — CONDITIONALLY NEAR-PASS

**5 ACs passing:**
- AC-T06 Rough landing ✅
- AC-T06c Directional pop ✅
- AC-T06e Climbing (ground + mid-air) ✅
- AC-T06f Claw brake ✅
- AC-T07 Squeezing ✅

**Remaining before GATE 1 PASS:**
1. **Slide rhythm** — claw brake works; slide → brake → stop → pivot cycle needs one targeted re-test
2. **Camera leads movement** — AC-T08 not yet testable (camera system not yet in prototype)
3. **Stealth radius** — sneaking stimulus reduction not explicitly verified

---

## Current State

### What Is Done and Approved

| File | Status | Notes |
|------|--------|-------|
| `design/gdd/game-concept.md` | Approved | Do not redesign. |
| `design/gdd/systems-index.md` | Approved | 8/11 MVP approved. |
| `design/gdd/input-system.md` | Approved | E key updated for DI-003 context-sensitivity. |
| `design/gdd/viewport-config.md` | Approved | 720x540, nearest-neighbor, 60fps. |
| `design/gdd/audio-manager.md` | Approved | 4 apartment mood variants added Session 006. |
| `design/gdd/camera-system.md` | Approved | Look-ahead, ledge bias, recon zoom. |
| `design/gdd/bonnie-traversal.md` | Approved | DI-001 + DI-003 amendments applied. |
| `design/gdd/npc-personality.md` | Approved | Systems 9 vs 10/11 scope note. |
| `design/gdd/level-manager.md` | Approved | System #5 — 7-room apartment, BFS attenuation. |
| `design/gdd/interactive-object-system.md` | Approved | System #7 — 5 weight classes, receive_impact contract. |
| `project.godot` | Configured | 720x540, input map, GodotPhysics2D, nearest-neighbor, gl_compatibility. |
| `prototypes/bonnie-traversal/BonnieController.gd` | Fixed | DI-001, DI-003, mid-air climb, auto-clamber, squeeze flag-based. |
| `prototypes/bonnie-traversal/BonnieController.tscn` | Updated | SqueezeShape position=(0,14). |
| `prototypes/bonnie-traversal/TestLevel.tscn` | Updated | SqueezeTrigger groups header fixed, ramp geometry removed. |
| `prototypes/bonnie-traversal/PLAYTEST-002.md` | Written | Session 006 report. GATE 1 NEAR-PASS. |

### What Does NOT Exist Yet

- Chaos Meter GDD — **BLOCKED on GATE 1**
- Bidirectional Social System GDD — **BLOCKED on GATE 1**
- Chaos Meter UI GDD — **BLOCKED on T-CHAOS**
- Sprint 1 plan — **BLOCKED on GATE 2**
- Any production code in `src/`
- Any art assets in `assets/`

---

## Locked Decisions — Do Not Re-Litigate

All decisions from Sessions 001-005 still apply. Session 006 additions:

### DI-001 — LEDGE_PULLUP Directional Pop (LOCKED)
- Phase 1 (cling): `pullup_window_frames` (default 10) — reads directional input
- Phase 2 (pop): directional input → `pullup_pop_velocity` launch + `pullup_pop_vertical` arc; no input → stationary clean pullup
- This is a skill-expression layer, not a QoL auto-feature. Keep the timing window honest.

### DI-003 — E Claw Brake during SLIDING (LOCKED, rhythm TBD)
- E during SLIDING removes `abs(velocity.x) * claw_brake_multiplier` per tap
- Default multiplier: 0.30. ~3 taps from full speed to stop. Tunable.
- The "staccato rhythm" at high speed is a design aspiration — Session 007 determines if `claw_brake_multiplier` alone achieves it or if adaptive timing is needed.

### Zone 8 SQUEEZING (LOCKED implementation)
- SqueezeShape position=(0,14) MUST NOT change — this offset is load-bearing
- SqueezeTrigger groups=["SqueezeTrigger"] is in node header — do not move to body
- _squeeze_zone_active flag replaces CeilingCast for entry/exit — do not revert

---

## Critical Path

```
Session 007 Priority A: Godot MCP integration (new this session)
Session 007 Priority B: Slide rhythm re-test → GATE 1 final call
     |
T-CHAOS + T-SOC  ← parallel GDDs, immediately after GATE 1 PASS
     |
T-FOUND-06 (Chaos Meter UI — after T-CHAOS skeleton)
     |
GATE 2 (all 11 MVP GDDs approved — currently 8/11)
     |
T-SPRINT-01 (Sprint 1 plan)
     |
T-IMPL (Sprint 1 Implementation)
```

---

## Session 007 Opening Protocol

### Priority 0: Godot CLI MCP Integration

The user will be setting up a Godot CLI MCP this session. All agents will have access to
the Godot CLI from within Claude Code tool calls. Steps:

1. User installs / configures MCP (on their end)
2. Create `.claude/skills/godot-mcp.md` — Godot MCP skill reference for the team
3. Update hooks as needed for MCP-aware workflows
4. Verify: any agent can call `godot --headless` or the MCP equivalent to run builds/checks

### Priority 1: Slide Rhythm Re-Test

Reopen `prototypes/bonnie-traversal/TestLevel.tscn` (Play button / Cmd+B, NOT F5 on macOS).

**How to trigger the Kaneda slide:**
1. Hold Shift (run) in any direction
2. Run until speed > 300 px/s (debug HUD speed counter confirms this)
3. Then: press S (down) OR press the opposite direction key
4. SLIDING state fires

**What to evaluate:**
- Does pressing E during SLIDING feel like a handbrake or a full-stop?
- Can you execute: run → slide → 2-3 E taps → controlled stop → immediate pivot?
- Does the rhythm feel "cat-like" or "mechanical"?
- Try tuning `claw_brake_multiplier` in the Inspector (default 0.30): lower = softer stops

**Report back:** slide feel verdict → GATE 1 final call

### Priority 2: GATE 1 Final Evaluation

Once slide feel is confirmed:
- Review AC table in PLAYTEST-002.md
- Determine: camera and stealth — are these blockers or deferrable?
- Call GATE 1: PASS or still NEEDS WORK

### Priority 3 (Post-GATE 1): T-CHAOS + T-SOC

**Agent 1** → `game-designer` + `economy-designer`: `/design-system chaos-meter`
Key constraints:
- Pure chaos plateaus below the feeding threshold — charm MUST be mathematically required
- No HP/death. Chaos Meter is social/environmental pressure, not a kill condition.
- Max chaos level should feel like REACTING-on-all-NPCs, not game-over warning

**Agent 2** → `game-designer` + `ux-designer`: `/design-system bidirectional-social-system`
Key constraints:
- Read `npc-personality.md` Section 3 first — define NpcState write contract carefully
- Social axis must be visually legible without a UI (NPC body language, reactions)
- NPC↔Social circular dependency is resolved via NpcState shared object (mycelium constraint)

---

## Known Prototype Shortcuts (Do NOT Fix in `prototypes/`)

Address in production rewrite in `src/` only:

1. **CLIMBING top-edge detect**: `is_on_ceiling()` approximation. Production needs Area2D or raycast top-edge detect.
2. **LEDGE_PULLUP position snap**: no ledge-top snap in prototype. Production needs snap.
3. **SQUEEZING exit**: `_squeeze_zone_active` flag (improved but still approximate). Production needs proper overlap test.
4. **Surface detection for footsteps**: not implemented.
5. **Parry directional filter**: contact-point Y offset heuristic. Production needs proper raycasts.

---

## Warnings for Session 007

1. **F5 does NOT launch on macOS** — use Play button (▶️) or Cmd+B in Godot editor
2. **SqueezeShape position=(0,14) is load-bearing** — changing it causes BONNIE to float and state-cycle
3. **GL Compatibility renderer** — `gl_compatibility` only. Session-start.sh guards.
4. **AudioStreamRandomizer pitch in semitones** — Godot 4.6. NOT frequency multipliers.
5. **Prototype is throwaway** — BonnieController.gd is not production code. Rewrite in src/.
6. **Systems 10+11 are Vertical Slice** — System 9 only for MVP NPC work.
7. **Both T-CHAOS + T-SOC must be designed before implementing either NPC or Social System.**
8. **BONNIE never dies.** Non-negotiable.
9. **No auto-grab on ledges.** Pure parry only. Non-negotiable.
10. **Commit identity**: `Co-Authored-By: Hawaii Zeke <(302) 319-3895>`

---

## Verification Gates

| Gate | Condition | Status | Unlocks |
|------|-----------|--------|---------|
| GATE 0 | Camera + Viewport GDDs approved | CLEARED ✅ | Streams A+B+C |
| GATE 1 | Prototype playtested, ACs pass, tuning locked | **NEAR-PASS** — slide + camera remain | Phase 3 GDDs |
| GATE 2 | All 11 MVP GDDs approved (8/11 done) | Pending | Sprint 1 plan |
| GATE 3 | Sprint 1 plan approved | Pending | Implementation |

---

## DI-002 — Deferred Design Idea (Post-GATE 1)

**Underside Platform Clinging (HANGING state)**

Tester vision: BONNIE can cling to the underside of platforms, shelves, counters.
Stealth mechanic — dodge the aftermath of her own chaos. "Dodge the aftermath of
her own chaos" is the design image.

Deferred scope: GATE 2+. Natural fit with NPC perception system (System 9).
Flag when NPC GDD enters implementation phase.

---

*Hawaii Zeke — Session 006 complete. Traversal identity confirmed. 8/11 MVP GDDs done.
GATE 1 near. MCP next. Let's finish the slide and call it.*
