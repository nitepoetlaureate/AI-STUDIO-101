# BONNIE! — Next Steps Handoff

**For**: Session 009
**Written by**: Hawaii Zeke (Claude) on 2026-04-16
**Context**: Session 008 complete. GATE 1 CONDITIONAL PASS. T-CHAOS (System 13) and T-SOC (System 12) GDDs drafted, design-reviewed, and revision-fixed. 10/11 MVP GDDs designed. Only Chaos Meter UI (System 23) remains before GATE 2.
**Immediate priority**: Approve T-CHAOS + T-SOC GDDs → Author T-FOUND-06 (Chaos Meter UI) → GATE 2

Read this file first. Then read the locked decisions section before touching anything.

---

## Session 007 Summary

### What Was Done

| Area | Result |
|------|--------|
| Mycelium audit | CONFIRMED WORKING — audit CRITICAL-01 was wrong; 51 notes, 4 slots |
| Mycelium sync-init | DONE — notes now travel with `git push`/`git fetch` |
| Mycelium git hooks | INSTALLED — post-commit (doctor), post-checkout (awareness), pre-push (gitleaks), reference-transaction (export gating) |
| Git config cleanup | DONE — deduplicated 4x refspecs, 2x displayref, 2x branch sections |
| Session hooks enhanced | session-start shows stale count; session-stop runs departure protocol |
| P0-02: soft_landing | DONE — `_on_landed()` now checks floor group, Zone 4 works as documented |
| P0-03: icon.svg | DONE — placeholder cat silhouette eliminates editor warning |
| P0-04: dead variables | DONE — removed legacy `skid_timer` and `jump_hold_timer` |
| P0-05: _try_airborne_climb | DONE — extracted from duplicate blocks, placed under PHYSICS HELPERS |
| P0-06: .gdignore files | DONE — mycelium/, production/, docs/, .claude/, .github/ |
| P0-07: progress tracker | DONE — systems-index.md updated from 0/0 to 8/8 started/reviewed |

### GATE 1 Status — CONDITIONALLY NEAR-PASS (unchanged)

**5 ACs passing:**
- AC-T06 Rough landing ✅
- AC-T06c Directional pop ✅
- AC-T06e Climbing (ground + mid-air) ✅
- AC-T06f Claw brake ✅
- AC-T07 Squeezing ✅

**Remaining before GATE 1 PASS:**
1. **Slide rhythm** — claw brake works; slide → brake → stop → pivot cycle needs one targeted re-test
2. **Camera leads movement (AC-T08)** — audit recommends defer to GATE 2 (polish, not traversal-feel)
3. **Stealth radius** — audit recommends defer to post-T-SOC (no NPCs to perceive BONNIE)

---

## Current State

### What Is Done and Approved

| File | Status | Notes |
|------|--------|-------|
| `design/gdd/game-concept.md` | Approved | Do not redesign. |
| `design/gdd/systems-index.md` | Approved | 8/11 MVP approved. Progress tracker fixed Session 007. |
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
| `prototypes/bonnie-traversal/PLAYTEST-002.md` | Written | Session 006 report. GATE 1 NEAR-PASS. |
| `icon.svg` | Created S007 | Placeholder cat silhouette. Eliminates editor warning. |

### What Does NOT Exist Yet

- Chaos Meter GDD — **DRAFTED, REVIEW-PASSED** — `design/gdd/chaos-meter.md` (pending user approval)
- Bidirectional Social System GDD — **DRAFTED, REVIEW-PASSED** — `design/gdd/bidirectional-social-system.md` (pending user approval)
- Chaos Meter UI GDD — **UNBLOCKED** — last MVP GDD before GATE 2
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
Session 009 Priority A: Approve T-CHAOS + T-SOC GDDs (review-passed, pending approval)
     |
T-FOUND-06 (Chaos Meter UI — System 23, last MVP GDD)
     |
GATE 2 (all 11 MVP GDDs approved — currently 10/11 designed)
     |
T-SPRINT-01 (Sprint 1 plan)
     |
T-IMPL (Sprint 1 Implementation)
```

---

## Session 009 Opening Protocol

### Priority 0: Approve T-CHAOS + T-SOC GDDs

Both GDDs have passed design review with all required revisions applied.

**`design/gdd/chaos-meter.md`** (System 13):
- Composite meter: chaos_fill (cap 0.55) + social_fill (weight 0.45, additive across NPCs)
- Per-level chaos baseline; full reset between levels
- Chaos overwhelm FED path (per-NPC, Michael 8 / Christen 7 / hostile NPCs disabled)
- `chaos_event_count` owned by Chaos Meter
- All 5 original open questions resolved

**`design/gdd/bidirectional-social-system.md`** (System 12):
- 5-interaction charm catalog (Proximity, Rub, Lap Sit, Purr, Meow)
- 4-tier visual goodwill legibility (COLD/NEUTRAL/SOFTENED/WARM)
- RECOVERING extended levity + comfort acceleration mechanic
- Passive play formally validated as acceptable aesthetic choice
- NpcState extensions: `last_interaction_timestamp` + `recovering_comfort_stacks`
- 4 of 5 original open questions resolved; 1 remaining (Chaos Meter signal format)

**Review outcome**: Both NEEDS REVISION → all required changes applied.
**Action**: Read both GDDs, approve or request further changes.

### Priority 1: T-FOUND-06 (Chaos Meter UI, System 23)

Last MVP GDD. Depends on T-CHAOS (now designed). Author via `game-designer` + `ux-designer`.

### Priority 2: GATE 2 Evaluation

Once all 11 MVP GDDs are approved, trigger GATE 2 to unlock Sprint 1 planning.

### Priority 3: Stale Mycelium Notes

21 stale notes on old blob versions. Run `! mycelium/scripts/compost-workflow.sh` interactively
to renew valid notes and compost outdated ones.

### Priority 4: Infrastructure Health Triage (deferred from Session 008)

- **browser-server MCP**: FAILED. Diagnose — is it fixable or redundant with `playwright`?
- **gdcli skill reference**: May be stale vs. gdcli v0.2.3 command surface. Validate and update `godot-mcp/SKILL.md`.
- **CallMcpTool gdcli re-test**: Check if Cursor update resolved the transport hang. Single test at session start.

### Priority 5: Opportunistic Art via pixel-plugin (if bandwidth permits)

- Replace `icon.svg` placeholder with real BONNIE pixel icon (32×32)
- Replace `PlaceholderSprite` ColorRect with actual sprite frames
- Prerequisite: Aseprite installed and `/pixel-setup` run. If not configured, skip entirely.

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
| GATE 2 | All 11 MVP GDDs approved (10/11 designed, 8 approved, 2 pending approval) | Pending | Sprint 1 plan |
| GATE 3 | Sprint 1 plan approved | Pending | Implementation |

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

*Hawaii Zeke — Session 008 complete. GATE 1 CONDITIONAL PASS. T-CHAOS + T-SOC GDDs drafted, design-reviewed, and revision-fixed. 10/11 MVP GDDs designed. One GDD to go before GATE 2.*
