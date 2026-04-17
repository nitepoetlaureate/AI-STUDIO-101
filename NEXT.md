# BONNIE! — Next Steps Handoff

**For**: Session 011
**Written by**: Hawaii Zeke (Claude) on 2026-04-17
**Context**: S1-01/S1-02 on `feat/s1-01-scaffold`; S1-03 + S1-04 landed on `feat/s1-03-s1-04-viewport-input` (viewport validation, `InputSystem` + `assets/data/input_system_config.tres`, GUT). `run/main_scene` still prototype `TestLevel.tscn` until S1-17.
**Immediate priority**: Merge viewport/input branch, then **S1-05** Audio Manager (depends on S1-03).

Read this file first. Then read the locked decisions section before touching anything.

---

## Session 007 snapshot (historical)

Session 007 infrastructure work (Mycelium sync-init, hooks, prototype P0 fixes, `icon.svg`, `.gdignore`, systems-index tracker) is complete. **GATE 1** was later closed **CONDITIONAL PASS** in Session 008 — see `prototypes/bonnie-traversal/GATE-1-AC-ASSESSMENT.md` and `PLAYTEST-003.md`; deferrals (AC-T08 camera polish, stealth post–T-SOC) remain as documented there.

---

## Current State

### What Is Done and Approved

| File | Status | Notes |
|------|--------|-------|
| `design/gdd/game-concept.md` | Approved | Do not redesign. |
| `design/gdd/systems-index.md` | Approved | 11/11 MVP designed; tracker updated through Session 009. |
| `design/gdd/input-system.md` | Approved | E key updated for DI-003 context-sensitivity. |
| `design/gdd/viewport-config.md` | Approved | 720x540, nearest-neighbor, 60fps. |
| `design/gdd/audio-manager.md` | Approved | 4 apartment mood variants added Session 006. |
| `design/gdd/camera-system.md` | Approved | Look-ahead, ledge bias, recon zoom. |
| `design/gdd/bonnie-traversal.md` | Approved | DI-001 + DI-003 amendments applied. |
| `design/gdd/npc-personality.md` | Approved | Systems 9 vs 10/11 scope note. |
| `design/gdd/level-manager.md` | Approved | System #5 — 7-room apartment, BFS attenuation. |
| `design/gdd/interactive-object-system.md` | Approved | System #7 — 5 weight classes, receive_impact contract. |
| `project.godot` | Configured | 720x540, input map, GodotPhysics2D, nearest-neighbor, gl_compatibility. |
| `prototypes/bonnie-traversal/BonnieController.gd` | Updated S007 | soft_landing, dead vars removed, _try_airborne_climb extracted. |
| `prototypes/bonnie-traversal/BonnieController.tscn` | Updated | SqueezeShape position=(0,14). |
| `prototypes/bonnie-traversal/TestLevel.tscn` | Updated | SqueezeTrigger groups header fixed, ramp geometry removed. |
| `prototypes/bonnie-traversal/PLAYTEST-002.md` | Written | Session 006 report (superseded for GATE 1 by PLAYTEST-003 + GATE-1-AC-ASSESSMENT). |
| `icon.svg` | Created S007 | Placeholder cat silhouette. Eliminates editor warning. |

### What Does NOT Exist Yet

- Chaos Meter GDD — **APPROVED** — `design/gdd/chaos-meter.md`
- Bidirectional Social System GDD — **APPROVED** — `design/gdd/bidirectional-social-system.md`
- Chaos Meter UI GDD — **APPROVED** — `design/gdd/chaos-meter-ui.md`
- Sprint 1 plan — **APPROVED** — `production/sprints/sprint-1.md` (30 pre-sprint decisions locked)
- Production gameplay in `src/` — **S1-01 scaffold + autoloads landed**; systems implemented per Sprint 1 tasks S1-03+.
- Any art assets in `assets/` — **Placeholder pixel art via pixel-plugin**

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
Sprint 1 Implementation — Session 010+
     |
S1-01: src/ scaffold + autoloads + scene architecture   ← START HERE
S1-02: ADR-001 (architecture decisions document)
     |
S1-03 through S1-08: Core systems (Viewport, Input, Audio, NpcState, Level Manager, Config) — order per `production/sprints/sprint-1.md`
     |
S1-09 through S1-16: Gameplay systems (Traversal, Camera, NPC, Social, Objects, Chaos, UI)
     |
S1-17: Test Apartment level assembly (TileMap + 3 rooms)
     |
S1-18: Core Loop Playtest → GATE 3
```

---

## Session 010 Opening Protocol

**Operational directive for new agents:** `./SESSION-010-PROMPT.md`

### Priority 0: Sprint 1 Implementation Begins

Sprint 1 plan is approved with 30 pre-sprint decisions locked. See `production/sprints/sprint-1.md`.

**Completed Session 010:** S1-01 scaffold + GUT 9.6; S1-02 ADR-001.

**Completed (branch `feat/s1-03-s1-04-viewport-input`):** S1-03 ViewportConfig project validation + stretch `keep` + NEAREST filter fix; S1-04 `InputSystem.get_move_vector()` + config `.tres` + GUT.

**Next tasks** (sequential):
1. **S1-05**: Audio Manager (four buses, API stubs filled in)

**Then parallel streams open**:
- Stream A (Core): S1-03 Viewport → S1-04 Input → S1-05 Audio → S1-06 NpcState → S1-07 Level Manager → S1-08 Config
- Stream B (Gameplay, after S1-06): S1-09 Traversal → S1-10 Camera → S1-11 NPC → S1-12 Social → S1-13 Objects → S1-14 Stubs → S1-15 Chaos → S1-16 UI
- Stream C (Level, after all): S1-17 Test Apartment → S1-18 Playtest

### Priority 1: Stale Mycelium Notes (deferred from Session 009)

21 stale notes on old blob versions. Run `mycelium/scripts/compost-workflow.sh` interactively.

### Priority 2: Opportunistic Art via pixel-plugin (if bandwidth permits)

- Replace `icon.svg` placeholder with real BONNIE pixel icon (32×32)
- Create minimal placeholder sprites for BONNIE (16×16 color-coded blobs per decision B7)
- Prerequisite: Aseprite installed and `/pixel-setup` run.

---

## Known Prototype Shortcuts (Do NOT Fix in `prototypes/`)

Address in production rewrite in `src/` only:

1. **CLIMBING top-edge detect**: `is_on_ceiling()` approximation. Production needs Area2D or raycast top-edge detect.
2. **LEDGE_PULLUP position snap**: no ledge-top snap in prototype. Production needs snap.
3. **SQUEEZING exit**: `_squeeze_zone_active` flag (improved but still approximate). Production needs proper overlap test.
4. **Surface detection for footsteps**: not implemented.
5. **Parry directional filter**: contact-point Y offset heuristic. Production needs proper raycasts.

---

## Warnings for Session 009

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
| GATE 1 | Prototype playtested, ACs pass, tuning locked | **CONDITIONAL PASS** ✅ — Session 008 | Phase 3 GDDs |
| GATE 2 | All 11 MVP GDDs approved (11/11) | **PASS** ✅ — Session 009 | Sprint 1 plan |
| GATE 3 | Sprint 1 plan approved | **PASS** ✅ — Session 009 | Implementation |

### GATE 1 Closure (Session 008)
- **Verdict**: CONDITIONAL PASS
- **Date**: 2026-04-16
- **5 ACs PASS**: T06, T06c, T06e, T06f, T07
- **1 AC CODE VERIFIED**: T03 (slide rhythm — mechanically correct)
- **2 ACs DEFERRED**: T08 (camera → GATE 2), Stealth (→ post-T-SOC)
- **Conditions**: Feel tuning of slide rhythm during early production; PARTIAL ACs require sprites/audio
- **Unlocks**: T-CHAOS (System 13) + T-SOC (System 12) GDD authoring

---

## DI-002 — Deferred Design Idea (Post-GATE 1)

**Underside Platform Clinging (HANGING state)**

Tester vision: BONNIE can cling to the underside of platforms, shelves, counters.
Stealth mechanic — dodge the aftermath of her own chaos. "Dodge the aftermath of
her own chaos" is the design image.

Deferred scope: GATE 2+. Natural fit with NPC perception system (System 9).
Flag when NPC GDD enters implementation phase.

---

### GATE 2 Closure (Session 009)
- **Verdict**: PASS
- **Date**: 2026-04-17
- **11/11 MVP GDDs approved**: Systems 1–7, 9, 12, 13, 23
- **Unlocks**: Sprint 1 plan

### GATE 3 Closure (Session 009)
- **Verdict**: PASS
- **Date**: 2026-04-17
- **Sprint 1 plan approved**: `production/sprints/sprint-1.md`
- **30 pre-sprint decisions locked**: See Sprint 1 "Pre-Sprint Decisions" section
- **Unlocks**: Sprint 1 implementation

---

*Hawaii Zeke — Session 009 complete. Design phase CLOSED. GATE 2 PASS (11/11 MVP GDDs approved). GATE 3 PASS (Sprint 1 plan approved, 30 decisions locked). Implementation begins Session 010.*
