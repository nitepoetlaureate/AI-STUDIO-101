# Playtest Report — Session 006

## Session Info
- **Date**: 2026-04-13
- **Build**: 84fb24a (Session 005 — B01–B04 fixed, debug HUD added)
- **Duration**: ~15–20 min (exploratory + targeted re-test)
- **Tester**: m. raftery (developer/creative director)
- **Platform**: macOS / Godot 4.6 editor
- **Input Method**: Keyboard
- **Session Type**: GATE 1 re-playtest (targeted — following Session 005 bug fixes)

## Test Focus
Re-evaluate all Session 005 fixes (B01–B04), test the debug HUD, and clear GATE 1.
Also: open-form feel evaluation of newly-working mechanics.

---

## First Impressions
- **Understood the goal?** Yes — tester had specific mechanics to verify
- **Understood the controls?** Partially — slide trigger method unclear (see Pain Points)
- **Emotional response**: Positive — "very feline," specific delight moments noted
- **Notes**: Climbing feel was immediately gratifying. Parry partially working generates real excitement about the ceiling. First positive feel signal in the prototype's history.

---

## Gameplay Flow

### What worked well

- **Ground climbing (B01 fix confirmed):** Walk up to brown wall + press E → BONNIE grabs and climbs. **At the top, she pops up and over the edge with momentum.** Tester note: "That worked great!" This is a GATE 1 AC pass.

- **Ledge parry/cling (partial):** When the parry window is hit correctly, BONNIE clings to the edge. The feel is right — tester experienced the parry as intentional and cat-like. This is meaningful progress from Session 005 (where it "worked some of the time" without the temporal window).

- **Run + double jump + parry combo feel:** "I do really like the snap and response with holding RUN and hitting double jumps and parry/climb so far, it really does feel very feline." **This is the core kinetic identity confirmed by feel.** Keep it.

- **Rough landing (B04 confirmed):** Works. Tester can identify when it fires. Fine-tuning deferred to when sprites exist.

---

### Pain points

- **Squeezing still broken — Severity: HIGH** (B02 regression or incomplete fix). Zone 8 (32px gap) produced no SQUEEZING entry. The `_check_squeeze_entry()` code calls `_ceiling_cast.is_colliding()` correctly, but either (a) Zone 8 in TestLevel.tscn doesn't have ceiling geometry the RayCast2D can detect, or (b) the CeilingCast node isn't positioned/configured to reach the ceiling in that zone. Code fix is complete; scene configuration is likely the issue.

- **Slide not successfully triggered — Severity: HIGH.** Tester could not execute the full Kaneda slide + stop + pivot cycle. Root cause: without a working debug HUD display of speed (see below), it's impossible to know when the 300 px/s threshold is crossed. Slide is code-complete but untestable without feedback. Not a code bug — a discoverability and instruction gap.

- **F5 does not launch game on macOS — Severity: MEDIUM.** macOS captures F5 for system brightness controls. The debug HUD (which is inside the running game as a CanvasLayer) is therefore inaccessible because the game can't be launched via the expected shortcut. **Fix for next session: use the ▶️ Play button in the Godot toolbar (top center), or press Cmd+B.** The HUD is not a separate panel — it appears inside the running game once it's launched.

- **Ledge-mount follow-up after parry not triggering — Severity: MEDIUM.** Tester expected a second input (like a double jump) to fire the LEDGE_PULLUP pop-up after cling. Current implementation: LEDGE_PULLUP auto-triggers immediately with no position snap and no momentum carry. Player expectation does not match implementation. See Design Ideas below — tester has a strong instinct here.

- **Post-double-jump feel — Severity: LOW.** "Needs more dynamism, it feels just a little clunky." The reduced air control after double jump is intentional (GDD §3.1), but the transition may need visual/audio reinforcement to read as physics commitment rather than input lag. Probably a sprite animation problem as much as a physics one — defer to art pass.

---

### Confusion points

- **How to trigger the Kaneda slide:** Keyboard method is: Hold Shift (run) in one direction until speed exceeds 300 px/s, then either press S (down) OR input the opposite direction. Without the debug HUD showing speed, neither threshold nor trigger state is visible. This is undiscoverable on first attempt.

- **Why squeezing doesn't fire:** Zone 8 presents as a narrow gap but doesn't auto-trigger. No feedback indicates what's wrong. Tester had no path to diagnose.

- **Interactive object brown squares:** Zone 9 objects exist but produce no physics response on contact. This is B05 (known, deferred to Interactive Object System GDD — now drafted). Not a regression; correctly deferred.

---

### Moments of delight

- **Climbing pop-up:** "At the top I popped right up and over the edge with some momentum! That worked great!" — This is the emotional payoff of the climbing system working.

- **Run + parry feel:** "It really does feel very feline and we should definitely keep this up." — Traversal identity confirmed. This is the target feel.

- **Cling to ledge edge:** Successfully hitting the parry window and *clinging* to geometry was experientially meaningful — tester immediately began imagining the follow-up move chain. The mechanic is communicating correctly even in its incomplete state.

---

## Bugs Found / Confirmed

| # | Description | Severity | Reproducible | Status | Root Cause |
|---|-------------|----------|-------------|--------|------------|
| B02 | Squeezing still fails in Zone 8 | Critical | Yes | **REGRESSION / INCOMPLETE** | `_ceiling_cast.is_colliding()` check in code is correct but Zone 8 ceiling geometry may not intersect CeilingCast RayCast2D path. Scene config issue. |
| B05 | Object interaction not implemented | Minor | Yes | KNOWN — DEFERRED | No `receive_impact()` or `slide_collision_force`. Pending Interactive Object System implementation. Not a blocker for GATE 1. |
| B07 | F5 doesn't launch on macOS | Medium | Yes | NEW — PLATFORM BUG | macOS system shortcut capture. Workaround: use Play button (▶️) or Cmd+B in Godot editor. |
| B08 | LEDGE_PULLUP: no position snap, no momentum carry | Medium | Yes | KNOWN SHORTCUT — but now feel-blocking | Current: pullup fires immediately with no position snap. Player experience: expects a momentum-carry pop-up with timing window. Gap between design and feel. |

---

## Feature-Specific Feedback

### Climbing (CLIMBING state)
- **Understood purpose?** Yes
- **Working?** Yes — B01 fix confirmed
- **Feel?** Excellent. Pop-up momentum at top of climb is the target feel.

### Ledge Parry (LEDGE_PULLUP)
- **Understood purpose?** Yes
- **Working?** Partial — cling works, follow-up mount does not match player expectation
- **Feel?** Cling itself feels correct. Post-cling behavior needs redesign (see Design Ideas).

### Kaneda Slide (SLIDING)
- **Understood purpose?** Partially — knows it exists but couldn't trigger it reliably
- **Working?** Likely yes (code unchanged), but untestable without debug HUD on Mac
- **Notes**: Requires debug HUD visibility + explicit trigger instructions for next test

### Squeezing (SQUEEZING)
- **Understood purpose?** Yes
- **Working?** No — still fails
- **Likely fix**: Inspect TestLevel.tscn Zone 8 ceiling geometry, verify CeilingCast2D hits it

### Object Interaction
- **Understood purpose?** Partially (brown squares expected to react)
- **Working?** No — deferred to production, not a prototype target for GATE 1

### Post-Double-Jump Feel
- **Understood purpose?** Yes
- **Feel?** "Aight but needs more dynamism" — likely a sprite/audio reinforcement gap, not physics

### Rough Landing
- **Understood purpose?** Yes
- **Working?** Yes — confirmed
- **Feel?** Works. Calibration deferred to art pass.

---

## Design Ideas Surfaced During Playtest

These are **new or refined mechanics** the tester articulated during play. They are not bugs — they are design proposals triggered by feel response. Each needs evaluation against scope and GDD.

---

### DI-001: Ledge Pop-Up with Momentum Window (Redesign LEDGE_PULLUP)

**Tester vision:** After cling, a brief coyote-time-style window opens. BONNIE hangs with claws extended (air sprite). Player times a directional input (left or right) — if they hit it, BONNIE pops up cartoon-style and **carries the momentum into the direction pressed**, creating one long fluid motion: climb → parry → pop-up → running or sliding continuation.

**Current implementation:** LEDGE_PULLUP auto-fires immediately, no position snap, no momentum carry.

**Design delta:** Add a `pullup_window_frames` input window after cling. If player inputs a direction within the window, pop-up carries momentum. If no input, BONNIE defaults to a clean stationary pullup. The window frames could be tuned to feel like cat reflexes.

**GDD impact:** Changes LEDGE_PULLUP behavior in `bonnie-traversal.md §3.5`. Not a scope expansion — it enriches the existing state with a skill layer.

**Verdict:** STRONG — this makes the parry → pullup chain a skill expression, not an auto-execution. Recommend adding to `bonnie-traversal.md` as a GDD amendment.

---

### DI-002: Underside Platform Clinging (NEW STATE)

**Tester vision:** BONNIE can cling to the underside of platforms, shelves, counters. This is a stealth mechanic — a way to hide from NPCs or dodge the aftermath of her own chaos. "Dodge the aftermath of her own chaos" is a strong design image.

**Implications:**
- New state: HANGING (or UNDERSIDE_CLIMBING)
- New trigger: grab input while jumping into underside of tagged surface
- New NPC interaction: NPCs may not perceive BONNIE on undersides (stimulus radius reduction while HANGING)
- New traversal verb: shimmy laterally while hanging

**GDD impact:** New section in `bonnie-traversal.md`. Moderate scope expansion.

**Verdict:** COMPELLING but out of scope for GATE 1. Flag for GATE 2 consideration — this is a natural fit with the NPC perception system (System 9) and makes BONNIE's toolkit richer. Add as a **stretch goal GDD amendment** after GATE 1 clears. The narrative case is strong: a cat hiding under a shelf from the chaos she just caused is perfect.

---

### DI-003: Claw Button as Multi-Verb Input (E Key Redesign)

**Tester vision:** `E` (grab) becomes a "claw" button — context-sensitive:
- Near climbable surface: grab and climb (current behavior)
- During slide at speed: handbrake / momentum interrupt
- After parry cling: pop-up trigger (links to DI-001)
- During combo chains: staccato rhythm controller for slide deceleration

**Staccato slide control described:** "Tap opposite direction + E in a certain staccato rhythm, a little off beat, more rapid at high speed but still able to be hit with skill."

**Implications:**
- `grab` action gets new context-sensitive behaviors per-state
- Slide state: `E` pressed during slide = speed-dependent friction spike (skill expression for controlled deceleration)
- The rhythm being "off-beat" and "more rapid at high speed" = adaptive timing = high skill ceiling

**GDD impact:** Changes `input-system.md` §3.1 (grab action expanded). Changes `bonnie-traversal.md` SLIDING exit conditions.

**Verdict:** INTERESTING — the handbrake use is clearly the right instinct (it's what cats do — dig claws in to stop). The staccato rhythm is ambitious but may be too complex without analog input. Recommend: start with E-during-slide as simple speed-dependent friction spike. The rhythmic version is a feel experiment for the next prototype iteration. This is scope-adjacent — needs a design decision before implementing.

---

### DI-004: High-Skill Combo Chain (Articulation of Traversal Identity)

**Tester description:** "Running, double jump, parry ledge grab into pop-up with timed forward momentum, holding run, start to slide (maybe tap opposite direction of E in a certain staccato rhythm)."

**This is not a new mechanic — it's the target combo expression.** The tester has articulated the high-skill traversal chain as they envision it should play:

```
[RUNNING] → [double jump] → [FALLING + parry window] → [CLIMBING/cling]
→ [LEDGE_PULLUP with momentum window] → [RUNNING, full momentum]
→ [SLIDING] → [E staccato control into stop] → back to [IDLE/WALKING]
```

If the individual pieces work correctly (DI-001 ledge pop-up momentum, DI-003 claw handbrake), this chain emerges naturally. It does not require additional code — it emerges from the state machine working as designed + the two enhancements above.

**Verdict:** This is the traversal GDD's "Player Fantasy" section (§2) described by feel rather than by design. It validates the direction. Use it as a design target for the next prototype test.

---

## Quantitative Data
Not fully available — debug HUD inaccessible on macOS (B07). Qualitative feel data collected via tester narration. Coyote time, parry window frame counts, and speed threshold readings not verified this session.

---

## Acceptance Criteria Evaluation — GATE 1 Update

| AC | Description | Sess 005 | Sess 006 Early | Sess 006 Final | Notes |
|----|------------|----------|----------------|----------------|-------|
| AC-T01 | Input responsiveness ≤1 frame | UNTESTABLE | UNTESTABLE | UNTESTABLE | HUD not tested this pass |
| AC-T02 | Sneak → sprint transition | FAIL | PARTIAL | PARTIAL | Run feel confirmed; sneak not isolated |
| AC-T03 | Kaneda slide + claw brake | FAIL | UNTESTABLE | **PARTIAL** | Slide fires; claw brake ✅; rhythm needs re-test |
| AC-T04 | Jump feel (tap vs hold) | PARTIAL | PARTIAL | PARTIAL | Post-double-jump dynamism gap; defer to sprites |
| AC-T05 | Landing skid | UNTESTABLE | UNTESTABLE | UNTESTABLE | Needs HUD-verified speed reading |
| AC-T06 | Rough landing | UNTESTABLE | **PASS** ✅ | **PASS** ✅ | Confirmed both passes |
| AC-T06b | Run button model | FAIL | PARTIAL | PARTIAL | Feel confirmed; visual gap remains |
| AC-T06c | Ledge parry + directional pop | FAIL | PARTIAL | **PASS** ✅ | DI-001 implemented and confirmed working |
| AC-T06d | Double jump + parry combo | FAIL | PARTIAL | **PARTIAL** | Pop confirmed; full combo chain needs re-test |
| AC-T06e | Climbing (ground + mid-air) | FAIL | **PASS** ✅ | **PASS** ✅ | Both ground E-grab and mid-air grab confirmed |
| AC-T06f | Claw brake during SLIDING | N/A | N/A | **PASS** ✅ | DI-003 implemented; brake confirmed; needs rhythm tuning |
| AC-T07 | Squeezing | FAIL | FAIL | **PASS** ✅ | Zone flag + shape offset fix; confirmed traversable |
| AC-T08 | Camera leads movement | N/A | N/A | UNTESTED | Not yet in scope for prototype |

**Session 006 final result: 5 ACs pass. 3 partial. 3 untested. 1 out-of-scope.**

---

## GATE 1 Verdict: CONDITIONALLY NEAR-PASS

### What passed this session (new)
- AC-T06c Directional pop: PASS ✅ (DI-001 GDD + prototype implementation)
- AC-T06e Climbing (mid-air): PASS ✅ (hold E into climbable from air)
- AC-T06f Claw brake: PASS ✅ (DI-003 GDD + prototype implementation)
- AC-T07 Squeezing: PASS ✅ (Area2D flag + SqueezeShape +14px offset fix)

### Remaining before GATE 1 can be declared PASS
1. **Kaneda slide rhythm** — claw brake works but slide feel needs one more targeted test
2. **Camera leads movement** — AC-T08 not yet testable (camera system not in prototype scope yet)
3. **Stealth radius** — sneaking stimulus behavior not explicitly verified

### Design Proposals Status

| ID | Proposal | Status |
|----|----------|--------|
| DI-001 | LEDGE_PULLUP directional pop | ✅ GDD amended + implemented + confirmed |
| DI-002 | Underside platform clinging | DEFERRED — post-GATE 1 |
| DI-003 | E claw brake during SLIDING | ✅ GDD amended + implemented + confirmed (needs rhythm tuning) |
| DI-004 | High-skill combo chain | Target feel articulated — emerges from DI-001+003 working |

---

*Report updated end of Session 006. GATE 1: NEAR-PASS — slide rhythm + camera remain. 5 ACs passing, traversal identity confirmed. Ready for Session 007: slide tuning, camera test, GATE 1 final call.*
