# System GDD: Bidirectional Social System

> **Status**: Draft
> **Author**: game-designer
> **Created**: 2026-04-17
> **Last Updated**: 2026-04-17
> **System #**: 12
> **Priority**: MVP
> **Implements Pillars**: 2 (BONNIE Moves Like She Means It), 3 (Chaos is Comedy, Not Combat), 4 (People Have Their Own Problems)

---

## 1. Overview

The Bidirectional Social System governs every interaction where BONNIE's physical
presence directly shapes an NPC's relational capital — **goodwill**. It is the
mechanic that makes charming NPCs a real path to fed, not just flavor. BONNIE can
build goodwill through proximity, rubbing, lap-sitting, purring, and meowing; she
loses it through chaos. The system reads from and writes to **NpcState** — the
shared data object defined in `design/gdd/npc-personality.md §3.1` — and is
responsible for computing goodwill changes, recording interaction type, tracking
the levity window, and gating which interactions are available based on both NPC
behavioral state and BONNIE's current movement state.

It is called *bidirectional* because both charm and chaos flow through the same
relational model. Charm accumulates goodwill; chaos burns it. A goodwill-high NPC
reaches FED differently than a chaos-broken NPC — and both paths are real. The
system is also bidirectional in the player-skill sense: BONNIE's movement states
determine what social interactions are possible, and the NPC's behavioral state
determines how effective they are. This mutual dependence makes reading the room —
Pillar 4 — the core skill expression.

This system does **not** define NpcState, the NPC behavioral state machine, or
goodwill decay mechanics. Those are the Reactive NPC System's (9) domain.
This system consumes them. See `design/gdd/npc-personality.md` for all upstream
definitions — especially §3.1 (NpcState interface), §4.2 (goodwill accumulation
and decay), §4.3 (comfort_receptivity), §3.5 (levity multiplier and hunger boost),
and §4.5 (feeding threshold check).

---

## 2. Player Fantasy

> You are reading a room the way only a cat can.

This system delivers three interlocking pleasures:

**The warm approach.** BONNIE walks into a room. She doesn't touch anything. She
just sits near Michael on the couch. His body language softens — no UI prompt, no
goodwill bar ticking up. Just him. Glancing down. The warmth is real before any
interaction fires.

**The timing play.** Michael reacts to something. He's hot. BONNIE immediately
jumps in his lap and purrs. It costs him nothing. He didn't want her there. He
*absolutely* settles anyway. The levity window mechanic turns "caused chaos,
immediately did comfort" into the game's comedic engine — and the player
discovers it not through a tooltip but through the joy of watching it work.

**The de-escalation.** Michael notices something. His posture shifts. He's about
to react. BONNIE rubs his leg. *Right there.* The AWARE state collapses back into
ROUTINE. The player did that. The player read the moment and used charm to diffuse
it. That is cat genius, and it earns more than a close call — it earns goodwill,
and it earns the satisfaction of a system behaving exactly as intended.

The skill ceiling of this system is knowing who to charm, when to charm them, and
when to let chaos run instead. An NPC in VULNERABLE who the player has been
building goodwill with since ROUTINE is a completely different feeding scenario
from an NPC driven to CLOSED_OFF. Both paths are valid. Both feel earned. Both
are the player's to engineer.

---

## 3. Detailed Design

### 3.1 NpcState Contract — Read/Write Interface

Neither the Social System nor the NPC System calls the other directly. The shared
contract is NpcState. Execution order per frame: NPC System processes stimuli and
updates all state → **Social System reads updated state → Social System writes
interaction results** → NPC System reads updated state on next frame.

#### Fields the Social System READS

| Field | Written By | How the Social System Uses It |
|-------|------------|-------------------------------|
| `emotional_level` | NPC System | Context for interaction risk and meow resolution |
| `current_behavior` | NPC System | Primary gate for which interactions are available |
| `comfort_receptivity` | NPC System | Multiplier applied to all goodwill calculations |
| `visible_to_bonnie` | Traversal System | Precondition: NPC must be in range before any interaction is evaluated |
| `last_interaction_type` | Social System | Levity multiplier eligibility check |
| `bonnie_hunger_context` | NPC System | Informational — confirms hunger-boost state; Social System does not modify feeding thresholds |

#### Fields the Social System WRITES

| Field | When Written | Value |
|-------|-------------|-------|
| `goodwill` | After any charm interaction or chaos recording event | Clamped `[0.0, 1.0]` — see §4 for formulas |
| `last_interaction_type` | After any charm interaction | `InteractionType.CHARM` |
| `last_interaction_type` | When a chaos event is recorded | `InteractionType.CHAOS` |
| `last_interaction_timestamp` | Any time `last_interaction_type` changes | Current game time in seconds — see §3.1.1 |
| `recovering_comfort_stacks` | On discrete charm interaction during RECOVERING | Incremented (0 → max stacks); reset to 0 when NPC exits RECOVERING — see §3.1.1 |

#### 3.1.1 NpcState Extension: `last_interaction_timestamp`

The levity multiplier formula (`npc-personality.md §4.2`, `§3.5`) requires knowing
*when* the last chaos interaction occurred. NpcState as defined in §3.1 of
`npc-personality.md` does not include a timestamp field. The Social System requires
this addition:

```gdscript
var last_interaction_timestamp: float  # game time in seconds at last interaction type change
```

Written by the Social System every time `last_interaction_type` changes. Read only
by the Social System to compute levity window eligibility. No other system reads
this field.

**Second extension: `recovering_comfort_stacks`**

```gdscript
var recovering_comfort_stacks: int = 0  # comfort acceleration stacks during RECOVERING
```

Written by the Social System on each discrete charm interaction during RECOVERING
(see §3.7). Read by the NPC System to modify `effective_receptivity_recovery_rate`
on the next frame. Resets to zero when the NPC exits RECOVERING (transitions to
ROUTINE or VULNERABLE). The NPC System detects the state change and clears the
field — no signal required, consistent with the data-object-only integration
pattern.

These are the **two extensions** to NpcState required by the Social System:
`last_interaction_timestamp` and `recovering_comfort_stacks`.

---

### 3.2 Interaction Availability Matrix

Social interactions are gated on both NPC behavioral state (which NPC system owns)
and BONNIE's current movement state (which the Traversal System owns).

#### NPC Behavioral State Gates

| NPC State | Proximity | Rub | Lap Sit | Purr | Meow | Notes |
|-----------|:---------:|:---:|:-------:|:----:|:----:|-------|
| ASLEEP | — | — | — | — | — | `comfort_receptivity = 0.0` |
| GROGGY | — | — | — | — | — | `comfort_receptivity = 0.1` — effectively zero gain; blocked |
| ROUTINE | ✓ | ✓ | ✓ (seated) | ✓ | ✓ | Standard window |
| AWARE | ✓ | ✓ | — | ✓ | ✓* | *Meow is risk-sensitive — see §3.5 |
| REACTING | — | — | — | — | — | `comfort_receptivity ≈ 0.0` — all interactions blocked |
| RECOVERING | ✓ | ✓ | — | ✓ | ✓ (reduced) | **Extended levity window** — see §3.7. Hair-trigger caution; gains accelerate with persistence |
| VULNERABLE | ✓ | ✓ | ✓ (any) | ✓ (boosted) | ✓ (boosted) | Maximum goodwill window |
| CLOSED_OFF | — | — | — | — | — | All interactions blocked; NPC ignores BONNIE |
| FLEEING | — | — | — | — | — | NPC physically unavailable |
| FED | — | — | — | — | — | Level complete state |

**Design rationale — REACTING blocks vs. "plays but does nothing":**
During REACTING, the interaction is blocked entirely (not accepted). An alternative
design allows the rub animation to play with zero gain. Blocking is preferred:
playing the animation with no result teaches the player the system is broken.
Blocking teaches the player the timing. *If playtesting reveals this feels too
harsh, revisit — the animation-plays-but-does-nothing version is a valid fallback.*

**Design rationale — CLOSED_OFF blocks vs. REACTING blocks:**
Both block all interactions. The difference is expressed in NPC body language only:
during REACTING the NPC is expressive and loud; during CLOSED_OFF the NPC is still
and avoidant. The NPC takes a small step away if BONNIE approaches in CLOSED_OFF.
Neither acknowledges her socially.

#### BONNIE Movement State Gates

Physical presence IS the social mechanic. Charm requires BONNIE to slow down.

| BONNIE State | Available Interactions |
|--------------|------------------------|
| IDLE | All (Proximity, Rub, Lap Sit, Purr, Meow) |
| SNEAKING | Proximity, Rub, Purr, Meow |
| WALKING | Proximity only (passive tick — no discrete interaction) |
| RUNNING | None |
| SLIDING | None |
| JUMPING / FALLING | None |
| CLIMBING | None |
| SQUEEZING | None |
| LEDGE_PULLUP | None |
| LANDING | Proximity only (brief post-airborne grounded state; 2–4 frames) |
| DAZED / ROUGH_LANDING | None |

**Why WALKING allows Proximity only:** Walking past an NPC generates a low passive
goodwill tick. BONNIE's casual movement through the space always does something.
But active charm (rub, lap sit) requires BONNIE to commit and stop — presence at
speed is noticed, warmth requires stillness.

---

### 3.3 Charm Interaction Catalog

#### PROXIMITY — Passive Ambient Goodwill

BONNIE's physical presence within `proximity_charm_radius` ticks goodwill
continuously. The lowest yield but most consistent charm source. Rewards players
who inhabit the space rather than rush through it.

- **Rate:** `charm_value_proximity` goodwill per second (framerate-normalized)
- **Active while:** BONNIE within `proximity_charm_radius`, NPC state allows (matrix above), BONNIE in IDLE/SNEAKING/WALKING
- **Input required:** None — entirely ambient
- **Stacking:** Purr stacks additively on top of Proximity when BONNIE is in IDLE
- **Interaction log throttle:** Does NOT write `last_interaction_type = CHARM` each
  frame. Writes only when cumulative passive gain crosses `proximity_interaction_threshold`.
  This prevents passive ticks from resetting the levity window — see §4.3.

**NPC visual feedback:**
- Low goodwill (COLD): brief glance down at BONNIE, no activity change
- Mid goodwill (SOFTENED): NPC pauses current activity, looks at BONNIE with a soft expression
- High goodwill (WARM): NPC smiles, reaches a hand down toward BONNIE

---

#### RUBBING — Active De-escalation and Goodwill

BONNIE rubs against the NPC's legs. Requires BONNIE within `rub_distance` of the
NPC, on the ground (IDLE or SNEAKING). Triggered by the contextual E-input — see
`bonnie-traversal.md §3.2` for the complete E-key context map. Rub is the social
E-context when BONNIE is on the ground adjacent to an NPC.

- **Goodwill:** `charm_value_rub` per successful interaction (flat, not per-second)
- **Cooldown:** `rub_cooldown` seconds per NPC before the same NPC can be rubbed again
- **Available states:** ROUTINE, AWARE, RECOVERING, VULNERABLE
- **AWARE conversion:** Rubbing during AWARE state can de-escalate NPC to ROUTINE — see §3.6
- **RECOVERING caution:** BONNIE's physical approach during RECOVERING may itself register
  as a low-level stimulus if `emotional_level` is still elevated. The rub earns
  goodwill but does not guarantee safety. This is intentional — reading the recovery
  window is the skill expression.

**NPC visual feedback:**
- ROUTINE: looks down, soft smile, may reach to scratch BONNIE's head
- AWARE (conversion success): alert expression dissolves into warmth mid-rub; NPC resumes activity
- AWARE (no conversion): NPC glances down, tension doesn't fully release
- RECOVERING: tense warmth — expression mixes relief and exhaustion
- VULNERABLE: NPC fully opens; may pull BONNIE close, cry softly. The emotional payoff.

---

#### LAP SITTING — Sustained High-Yield Goodwill

BONNIE jumps onto an NPC's lap and stays. The highest single-session goodwill
source per unit of investment. Duration-based: goodwill ticks continuously
while maintained.

**Availability requirements:**
1. BONNIE must physically navigate to the NPC and jump onto the lap position
   (traversal handles physics — this is not an auto-teleport)
2. NPC must be in ROUTINE during a **seated phase**, OR in VULNERABLE (any position)
3. Seated phases: Michael's Evening phase; Christen's Socializing and Relaxing phases
4. In VULNERABLE, NPC does not need to be seated — BONNIE can sit beside them anywhere
5. BONNIE must be in IDLE to maintain the sit (movement input exits the lap)

**Interaction flow:**
1. BONNIE reaches lap position via traversal and enters IDLE
2. Lap Sit sub-state activates: movement input is dampened, BONNIE stays in place
3. Goodwill ticks at `charm_value_lap_per_second` per second while maintained
4. Player exits lap with directional input — BONNIE hops off
5. NPC entering REACTING or FLEEING during Lap Sit: BONNIE is ejected (physics
   impulse away from NPC), enters DAZED or LANDING depending on distance

**Ejection and goodwill:** All goodwill earned during the lap sit is kept on
ejection. There is no cancellation penalty. BONNIE was there for as long as she
was there.

**NPC visual feedback:**
- On BONNIE landing in lap: NPC's expression shifts immediately. Arms lower.
  Activity pauses. Dialogue: "...okay, fine."
- Sustained: NPC may stroke BONNIE. Posture settles.
- VULNERABLE lap sit: deepest warmth. NPC may hold BONNIE close, bury face in
  fur, sigh with relief. The relationship is real here.

---

#### PURRING — Idle Comfort Aura

When BONNIE is in IDLE near an NPC, she purrs. Passive ambient aura that stacks
additively with Proximity. The lowest per-second yield of any interaction, but
uniquely boosted in VULNERABLE where it becomes mechanically meaningful.

- **Rate:** `charm_value_purring` per second (stacks with Proximity — both apply
  simultaneously when BONNIE is in IDLE within range)
- **Requires:** BONNIE in IDLE (any movement exits purr state)
- **VULNERABLE boost:** `comfort_receptivity` is at its peak AND `purr_vulnerable_multiplier`
  applies — purring during VULNERABLE is the most efficient passive goodwill source
- **Input required:** None
- **Audio-driven confirmation:** The purring SFX is the player's only feedback that
  this is active. No UI indicator.

**NPC visual feedback:**
- Subtle shoulder drop; a soft exhale. Calmer because BONNIE is present.
- In VULNERABLE: slumped posture softens further. NPC may close their eyes briefly.
  The purr is doing something.

---

#### MEOWING — Context-Sensitive Social Bid

BONNIE meows at the NPC. A discrete player-input interaction (dedicated meow
button, independent of E). The most complex interaction because its outcome
depends on NPC state AND proximity to `reaction_threshold`. A meow can be charm,
de-escalation, or inadvertent chaos — the player learns which from context.

See §4.5 for the complete meow resolution formula. Behavioral summary:

| NPC State | `emotional_level` | Outcome | Effect |
|-----------|-------------------|---------|--------|
| ROUTINE | Below `meow_routine_safe_threshold` | **Charm** | Small goodwill; positive attention |
| ROUTINE | Above `meow_routine_safe_threshold` | **Risk** | Small stimulus; may push toward AWARE |
| AWARE | Below `reaction_threshold - meow_safe_margin` | **Charm + signal** | Goodwill; helps NPC settle |
| AWARE | Above `reaction_threshold - meow_safe_margin` | **Chaos** | Tips NPC to REACTING; goodwill cost |
| RECOVERING | Any | **Charm (reduced)** | Small goodwill at reduced multiplier |
| VULNERABLE | Any | **Charm (boosted)** | Highest goodwill; NPC responds emotionally |
| REACTING | — | **Blocked** | No effect |
| CLOSED_OFF | — | **Blocked** | No effect |

- **Cooldown:** `meow_cooldown` seconds (BONNIE-level — applies globally, not per-NPC)

**NPC visual feedback:**
- Positive (ROUTINE low stress): NPC looks down, responds vocally, smiles
- Risky (AWARE near threshold): NPC's posture snaps sharper. Eyes narrow. "I'm deciding."
- VULNERABLE: soft eye contact, NPC responds emotionally — may reach out, speak softly
- Backfire (tips to REACTING): NPC visibly startles; the meow was the last straw

---

### 3.4 Chaos Recording

Chaos events are **caused by other systems** (Environmental Chaos System, Interactive
Object System, BONNIE's slide collision force from the Traversal System). When a
chaos event affects a specific NPC, the Social System receives a notification,
records the relational consequence, and updates NpcState.

**Chaos recording process:**
1. Source system emits chaos event: `(npc_id, chaos_severity: ChaosSeverity)`
2. Social System resolves `NpcState` for `npc_id`
3. Social System applies goodwill cost (see §4.1 formula)
4. Social System writes `last_interaction_type = CHAOS` to NpcState
5. Social System writes `last_interaction_timestamp` to NpcState
6. Chaos Meter (System 13) receives the **same chaos event independently** via a
   separate notification channel — not through the Social System

**Chaos severity tiers and goodwill cost:**

| Severity | Example | `chaos_goodwill_cost` |
|----------|---------|----------------------|
| MINOR | Proximity nudge, small object jostled | `0.05` |
| MODERATE | Object knocked from surface, loud noise near NPC | `0.10` |
| MAJOR | Direct NPC collision (slide), large object destruction | `0.20` |
| CRITICAL | Multi-object chain event, room-scale chaos | `0.30` |

Severity classification is the Environmental Chaos System's (8) responsibility.
The Social System receives the severity tag and applies the corresponding cost.

**MVP simplification:** Environmental Chaos System (8) is Vertical Slice scope.
For MVP, chaos events are emitted by simplified triggers: BONNIE's slide collision
into an NPC emits MAJOR; knocking an object the NPC is using emits MODERATE.
Full severity taxonomy is Vertical Slice scope.

---

### 3.5 AWARE Conversion Mechanic

Rubbing an NPC during AWARE state, when their `emotional_level` is below the
conversion threshold, de-escalates the NPC from AWARE back to ROUTINE. This is the
Social System's skill-expression peak moment — reading the window and spending
goodwill to prevent a reaction.

**Conversion conditions:**
```
emotional_level < (reaction_threshold - aware_conversion_margin)
```

`aware_conversion_margin` default: `0.12`. At `reaction_threshold = 0.60`,
conversion is possible when `emotional_level < 0.48` — the NPC is AWARE
(above `awareness_threshold`) but has not yet tipped toward REACTING.

**When conversion triggers:**
- Goodwill is earned at the standard rub rate (including levity multiplier if eligible)
- Social System emits `deescalation_event(npc_id)` signal
- NPC System receives this signal and resets the `awareness_window` timer on next frame
- NPC transitions AWARE → ROUTINE via its own decay logic (the Social System does
  NOT directly change `current_behavior` — the NPC System owns state transitions)

**When rub fires in AWARE without conversion:**
- `emotional_level >= (reaction_threshold - aware_conversion_margin)`: NPC is too
  close to tipping. Goodwill is still earned (small amount — `comfort_receptivity`
  is low near threshold), but no de-escalation signal fires. NPC remains AWARE.

**AWARE conversion example:**
- Michael in AWARE, `emotional_level = 0.42`, `reaction_threshold = 0.60`
- Margin check: `0.42 < (0.60 - 0.12 = 0.48)` → conversion eligible ✓
- Rub fires: goodwill += `0.08 * comfort_receptivity`; `deescalation_event` emits
- Next frame: Michael returns to ROUTINE

**No conversion example:**
- Michael in AWARE, `emotional_level = 0.52`, `reaction_threshold = 0.60`
- Margin check: `0.52 < 0.48` → false — conversion ineligible
- Rub still fires: small goodwill gain. Michael stays AWARE.

---

### 3.6 Visual Legibility System

**There is no goodwill meter visible to the player.** Social state is communicated
entirely through NPC body language, posture, animation, and audio. This section
defines the complete visual communication contract for implementers and animators.

#### Goodwill Visual Tiers

The Social System drives NPC visual tier state based on `goodwill` thresholds.
These are animation layers applied *on top of* behavioral state animations.
Transitions between tiers blend over `goodwill_visual_blend_time` — no hard snaps.

| Goodwill Range | Visual Tier | Posture | Expression | Audio Cue |
|---------------|-------------|---------|------------|-----------|
| `0.0 – 0.25` | **COLD** | Stiff, rigid; keeps body angled away from BONNIE | Minimal eye contact; flat affect | Clipped tones; no warmth; "hmm" |
| `0.25 – 0.50` | **NEUTRAL** | Default ROUTINE posture | Occasional glance at BONNIE | Standard ambient dialogue |
| `0.50 – 0.75` | **SOFTENED** | Relaxed; shoulders down; pauses activity when BONNIE enters view | Smiles at BONNIE's approach; soft glances | Warm ambient sounds; softer vocal tone |
| `0.75 – 1.0` | **WARM** | Open posture; actively faces BONNIE; reaches toward her | Brightens when she enters the room; sustained eye contact | "Aww", "hey baby", direct warm address |

Behavioral state animations (REACTING, VULNERABLE, CLOSED_OFF) override goodwill
tier visuals while active. The goodwill tier reasserts when the NPC returns to
ROUTINE or RECOVERING.

#### Behavioral State Visual Language (Social Context)

Supplementary visual cues that communicate social-relevant states without UI:

**AWARE** (NPC noticed something):
- Body halts current activity
- Posture stiffens regardless of goodwill tier — AWARE overrides the tier
- Eyes widen or narrow (alert); angles slightly toward stimulus source
- Expression: "I'm watching you"

**RECOVERING** (cooling down after reaction):
- Shoulders lower than ROUTINE — the after-tense release
- Arms may cross loosely (self-soothing; distinct from CLOSED_OFF's firm cross)
- Slower head movements; tired, unfocused eyes
- BONNIE's approach: eyes track BONNIE warily — warmth is possible but cautious

**VULNERABLE** (the jackpot state — post-stress emotional exhaustion):
- Full slump: rounded spine, dropped shoulders, head forward or looking at floor
- Seated or moving slowly; arms at sides or holding self
- BONNIE's presence: eyes soften immediately; posture opens; hand reaches down
- This state must be **visually unambiguous** — players must read it without instruction

**CLOSED_OFF** (social shutdown):
- Arms crossed firmly (harder set than RECOVERING's loose self-soothing)
- Explicitly averts gaze when BONNIE approaches; body turns away
- If BONNIE comes very close: NPC takes a small deliberate step back or turns further
- Active avoidance without FLEEING — the NPC is done, not afraid

#### Per-Interaction NPC Visual Response

| Interaction | NPC Response — Lands | NPC Response — Blocked |
|-------------|----------------------|------------------------|
| Proximity (NEUTRAL) | Brief glance down; no activity change | — |
| Proximity (SOFTENED/WARM) | Pauses activity; soft expression | — |
| Rub (ROUTINE) | Looks down; smiles; may reach hand | — |
| Rub (AWARE, conversion) | Alert expression dissolves; NPC resumes activity | Eyes narrow; stays alert |
| Rub (RECOVERING) | Tense warmth; mixed expression | — |
| Rub (VULNERABLE) | NPC opens fully; reaches for BONNIE; may cry | — |
| Lap Sit | Arms lower; activity pauses; settles | N/A (state gate blocks) |
| Lap Sit (VULNERABLE) | Holds BONNIE; closes eyes; audible sigh | — |
| Purr (standard) | Shoulder drop; soft exhale | No visible change |
| Purr (VULNERABLE) | Eyes close briefly; visible tension release | — |
| Meow (positive) | Looks down; responds vocally; smiles | — |
| Meow (risky, AWARE near threshold) | Posture snaps rigid; eyes narrow sharply | — |
| Meow (VULNERABLE) | Soft eye contact; emotional vocal response | — |
| Meow (backfire → REACTING) | Visible startle; expression breaks — the last straw | — |

---

### 3.7 RECOVERING State — Extended Levity and Comfort Acceleration

RECOVERING is the aftermath of chaos. The NPC just came out of REACTING — which
was caused by chaos. Therefore, charm during RECOVERING is *inherently*
charm-after-chaos. This section defines the layered mechanic that makes
RECOVERING the most strategically interesting state for social play.

**Layer 1 — Extended Levity Window:**
The entire RECOVERING state is treated as levity-eligible regardless of the
standard `levity_window` timer. The levity multiplier (1.5×) applies to all
charm interactions during RECOVERING because the NPC's REACTING event was a
chaos event by definition. The standard 4-second `levity_window` only governs
levity eligibility in ROUTINE, AWARE, and VULNERABLE states.

```gdscript
func is_levity_eligible(npc_state: NpcState) -> bool:
    # RECOVERING is always levity-eligible (the entire state IS the aftermath of chaos)
    if npc_state.current_behavior == NpcBehavior.RECOVERING:
        return true
    # Standard levity window check for all other states
    if npc_state.last_interaction_type != InteractionType.CHAOS:
        return false
    return (current_time - npc_state.last_interaction_timestamp) < levity_window
```

**Layer 2 — Comfort Acceleration:**
Each discrete charm interaction (rub, meow — not passive ticks) during
RECOVERING temporarily boosts `receptivity_recovery_rate` by
`recovering_comfort_acceleration`. This stacks up to
`recovering_comfort_acceleration_max_stacks` times, capping at
`recovering_comfort_acceleration_cap`.

```gdscript
# On discrete charm interaction during RECOVERING:
recovering_comfort_stacks[npc_id] = min(
    recovering_comfort_stacks[npc_id] + 1,
    recovering_comfort_acceleration_max_stacks
)
# NPC System reads this modifier on next frame:
var acceleration_multiplier: float = min(
    1.0 + recovering_comfort_stacks[npc_id] * (recovering_comfort_acceleration - 1.0),
    recovering_comfort_acceleration_cap
)
effective_receptivity_recovery_rate = receptivity_recovery_rate * acceleration_multiplier
```

The acceleration decays: stacks reset to zero when the NPC exits RECOVERING
(transitions to ROUTINE or VULNERABLE). The stacks are per-NPC.

**Combined effect — the emotional arc:**
1. BONNIE causes chaos → NPC enters REACTING
2. NPC transitions to RECOVERING → `comfort_receptivity` is low
3. BONNIE sits nearby. First rub: weak base goodwill BUT levity multiplier
   (1.5×) partially compensates → it feels meaningful. Stack 1 applied.
4. `comfort_receptivity` starts climbing faster (accelerated recovery)
5. Second rub: better base AND levity → noticeably more. Stack 2 applied.
6. Third rub: comfort_receptivity now substantially recovered; each rub is
   landing harder. The NPC is visibly warming.
7. If `emotional_level` drops below `vulnerability_threshold`: NPC enters
   VULNERABLE — the jackpot state. The player earned this by staying through
   the storm.

This teaches the player the complete chaos-to-comfort loop without
tutorializing it. The correct instinct — "comfort the upset person" — is
rewarded immediately (via levity) and increasingly (via acceleration).

**NPC visual feedback during RECOVERING comfort acceleration:**
- First rub: tense warmth — expression mixes relief and exhaustion
- Second rub: shoulders drop slightly; the guarded posture softens
- Third rub: NPC's expression shifts toward gratitude; posture opens noticeably
- The visual progression matches the mechanical acceleration — the player sees
  it working before they understand the math

---

### 3.8 Passive Play as Valid Expression

**Design principle:** A player who chooses to exist in the space without pursuing
the chaos meter objective is making a valid aesthetic choice. BONNIE sitting on a
windowsill, watching Michael go through his entire day, listening to the
soundtrack, observing the routines — this is not a degenerate strategy. It is an
expression of Pillar 1 ("Every Space is a Playground") and the anti-pillar
("NOT a speedrun — wandering is the game").

**Mechanical guardrails ensure passive play doesn't accidentally trigger feeding:**
- `min_chaos_events_for_feed` (default 2) gates the FED check — a player who
  never causes chaos can never trigger feeding regardless of goodwill level
- Goodwill decay equilibrium caps passive-only goodwill well below
  `feeding_threshold` under normal conditions (see §4.6)
- The player must actively choose to engage the chaos system at some point

**What passive play DOES earn:**
- Goodwill accumulation (slow, via proximity and purr)
- Visual tier progression (NPC body language softens over time)
- Environmental storytelling moments (NPC routines, dialogue, ambient events)
- The satisfaction of being a cat who is just *there*

**Future enrichment (post-MVP):** As music, environmental audio, NPC ambient
animations, and full art assets come online, passive play becomes richer. The
game should reward the patient observer with details invisible to the rushing
player — NPC micro-behaviors, ambient sound design shifts, environmental
storytelling that unfolds only when BONNIE is still. This is a design direction,
not a current implementation requirement.

---

## 4. Formulas

All float values clamped to `[0.0, 1.0]` unless noted. `delta` is frame delta in
seconds. All goodwill formulas are **extensions of `npc-personality.md §4.2`** —
the accumulation and decay model defined there is authoritative. This section
supplies the correct inputs and extends with the levity, passive tick, and context
resolution logic.

---

### 4.1 Goodwill Calculation — Charm and Chaos

The core accumulation formula from `npc-personality.md §4.2`:
```
goodwill = clamp(goodwill + charm_value * comfort_receptivity, 0.0, 1.0)
```

The Social System's job: supply the correct `charm_value` per interaction type,
apply the levity multiplier when eligible, then execute the above formula.

**Full charm application (single discrete interaction):**
```gdscript
# Step 1: Get base charm_value for this interaction
charm_value = get_base_charm_value(interaction_type, npc_state)

# Step 2: Apply levity multiplier if eligible (see §4.2)
if is_levity_eligible(npc_state):
    effective_charm_value = charm_value * levity_multiplier
else:
    effective_charm_value = charm_value

# Step 3: Apply goodwill formula (npc-personality.md §4.2)
npc_state.goodwill = clamp(
    npc_state.goodwill + effective_charm_value * npc_state.comfort_receptivity,
    0.0, 1.0
)

# Step 4: Update interaction record
npc_state.last_interaction_type = InteractionType.CHARM
npc_state.last_interaction_timestamp = current_time
```

**Base `charm_value` by interaction type:**

| Interaction | Base `charm_value` | Delivery |
|-------------|-------------------|---------|
| Proximity | `0.008 / s` | Continuous; framerate-normalized |
| Rub | `0.08` | Flat per interaction; cooldown gated |
| Lap Sit | `0.06 / s` | Continuous while maintained |
| Purr (standard) | `0.004 / s` | Continuous; stacks with Proximity in IDLE |
| Purr (VULNERABLE) | `0.004 * purr_vulnerable_multiplier / s` | See §4.3 |
| Meow (ROUTINE safe) | `0.05` | Flat per interaction |
| Meow (AWARE positive) | `0.05 * meow_aware_multiplier` | Elevated for successful AWARE bid |
| Meow (RECOVERING) | `0.05 * meow_recovering_multiplier` | Reduced; fragile window |
| Meow (VULNERABLE) | `0.05 * meow_vulnerable_multiplier` | Highest meow yield |

**Chaos goodwill cost (also `npc-personality.md §4.2`):**
```gdscript
npc_state.goodwill = clamp(npc_state.goodwill - chaos_goodwill_cost, 0.0, 1.0)
npc_state.last_interaction_type = InteractionType.CHAOS
npc_state.last_interaction_timestamp = current_time
```

**Expected goodwill output ranges (verified against §4.4 equilibrium math):**
- Passive only (proximity + purr, ~35 seconds in ROUTINE, `comfort_receptivity = 0.55`):
  `0.0 → ~0.15–0.25`. After 2 full minutes: `~0.45–0.50` (approaching equilibrium
  ceiling of ~0.66 — see §4.4 for derivation)
- Active charm session (2 rubs, 1 meow, ongoing proximity, 2 minutes):
  `0.0 → ~0.50–0.65`
- VULNERABLE lap sit (15–20 seconds, `comfort_receptivity = 0.90`):
  `0.0 → ~0.65–0.80` — primary path to FED in a charm-focused run. Lap sit rate
  at VULNERABLE receptivity (0.054/s effective) reaches feeding threshold rapidly;
  equilibrium is well above 1.0 (clamped)
- Two rubs with levity multiplier after a MAJOR chaos event:
  approximately `+0.05–0.10` additional over unmodified rubs

---

### 4.2 Levity Multiplier Application

Extends `npc-personality.md §3.5` and `§4.2`. The levity multiplier activates
when BONNIE performs charm immediately after chaos, within `levity_window` seconds.

```gdscript
func is_levity_eligible(npc_state: NpcState) -> bool:
    # RECOVERING is always levity-eligible (see §3.7 — extended levity window)
    if npc_state.current_behavior == NpcBehavior.RECOVERING:
        return true
    # Standard levity window check for all other states
    if npc_state.last_interaction_type != InteractionType.CHAOS:
        return false
    var time_since_chaos: float = current_time - npc_state.last_interaction_timestamp
    return time_since_chaos < levity_window
```

When eligible, `charm_value` is multiplied before applying the goodwill formula:
```
effective_charm_value = charm_value * levity_multiplier
```

**Knob source:** `levity_multiplier = 1.5` and `levity_window = 4.0s` are defined
in `npc-personality.md §7` (global tuning knobs). **Do not redefine here** —
the Social System references them. Update the source document to change them.

**Levity is per-NPC:** tracked in each NpcState independently. A chaos event
against Michael does not activate levity for Christen.

**Levity example — rub after coffee knock:**
1. BONNIE knocks Michael's coffee (MAJOR): `goodwill -= 0.20`, `last_interaction_type = CHAOS`, timestamp recorded
2. 2.0 seconds later, BONNIE rubs Michael (`comfort_receptivity = 0.65` in RECOVERING):
   - Without levity: `0.08 * 0.65 = 0.052` goodwill gained
   - With levity: `0.08 * 1.5 * 0.65 = 0.078` goodwill gained
   - Net from the chaos + levity rub: `-0.20 + 0.078 = -0.122` total delta
3. After 4.0 seconds without charm: next rub earns standard `0.052`

---

### 4.3 Proximity and Purr — Passive Continuous Tick

These interactions accumulate per frame. They do not invoke the full goodwill
formula 60× per second — they apply per-second rates via delta.

```gdscript
# Called from Social System update, every frame
func tick_passive_social(npc_id: int, npc_state: NpcState, delta: float) -> void:
    if not is_passive_charm_available(npc_state):
        return

    var passive_rate: float = 0.0

    # Proximity contribution
    if bonnie_within_radius(npc_state, proximity_charm_radius):
        passive_rate += charm_value_proximity  # per second

    # Purr stacks if BONNIE is IDLE
    if bonnie_state == BonnieState.IDLE and bonnie_within_radius(npc_state, purr_radius):
        var purr_rate: float = charm_value_purring
        if npc_state.current_behavior == NpcBehavior.VULNERABLE:
            purr_rate *= purr_vulnerable_multiplier
        passive_rate += purr_rate

    if passive_rate <= 0.0:
        return

    # Apply delta (no levity multiplier on passive ticks — only discrete interactions)
    var gain: float = passive_rate * npc_state.comfort_receptivity * delta
    npc_state.goodwill = clamp(npc_state.goodwill + gain, 0.0, 1.0)

    # Log interaction type only when accumulator crosses threshold
    # (prevents passive ticks from resetting the levity window each frame)
    passive_accumulator[npc_id] += gain
    if passive_accumulator[npc_id] >= proximity_interaction_threshold:
        npc_state.last_interaction_type = InteractionType.CHARM
        npc_state.last_interaction_timestamp = current_time
        passive_accumulator[npc_id] = 0.0
```

**Accumulator initialization:** `passive_accumulator[npc_id]` is initialized to `0.0`
when the Social System first processes an NPC (system init or NPC arrival). The
accumulator is NOT reset on CHAOS events — this preserves the levity window
protection. A partial accumulator that crosses the threshold after a chaos event
will log CHARM at that moment, which is correct since the gain is from pre-chaos
proximity ticks.

**Why the accumulator threshold matters:** Writing `last_interaction_type = CHARM`
every frame would immediately reset the levity window — passive proximity ticks
near an NPC after a chaos event would constantly overwrite the CHAOS timestamp
before the player could capitalize on it. The accumulator prevents this: passive
charm only logs an interaction record when enough goodwill has accumulated to be
meaningful (`proximity_interaction_threshold = 0.02`, roughly 2.5 seconds of
proximity at base rate).

---

### 4.4 Passive Play Equilibrium Analysis

The goodwill decay formula (`npc-personality.md §4.2`) creates a natural
equilibrium ceiling for passive-only play. Goodwill earned through proximity
and purring is continuously counteracted by decay toward `goodwill_baseline`.

**Equilibrium formula:**
```
At equilibrium: earn_rate = decay_rate
passive_rate * comfort_receptivity = goodwill * goodwill_decay_rate
→ equilibrium_goodwill = (passive_rate * comfort_receptivity) / goodwill_decay_rate
```

**Worked examples (no active charm, proximity + purr only, BONNIE in IDLE):**

| Scenario | earn/s | comfort_receptivity | decay_rate | equilibrium | feeding_threshold | Feeds? |
|----------|--------|--------------------:|-----------|-------------|-------------------|--------|
| ROUTINE Michael | 0.012 | 0.55 | 0.01 | ~0.66 | 0.75 | No |
| VULNERABLE Michael | 0.012 | 0.90 | 0.01 | ~1.08 (clamped to 1.0) | 0.75 | **Gated** |
| VULNERABLE + Hunger | 0.012 | 0.90 | 0.01 | ~1.0 | 0.65 | **Gated** |

In the VULNERABLE + Hunger case, goodwill *could* exceed the reduced feeding
threshold — but `min_chaos_events_for_feed` (default 2) prevents FED from
triggering without at least 2 REACTING events. A player who never caused chaos
cannot have REACTING events, so this path is blocked by design.

**This is intentional.** A player who engineers the emotional arc (causes chaos,
creates VULNERABLE) and then waits patiently is using the system as designed.
The `min_chaos_events_for_feed` gate ensures they participated actively at some
point. The long wait time (~3+ minutes of uninterrupted proximity during
VULNERABLE) is the time cost of the patient approach — active charm reaches
the same threshold in a fraction of the time.

See §3.8 for the design principle governing passive play.

---

### 4.5 AWARE Conversion Check

```gdscript
func check_aware_conversion(npc_state: NpcState) -> bool:
    if npc_state.current_behavior != NpcBehavior.AWARE:
        return false
    return npc_state.emotional_level < (npc_state.reaction_threshold - aware_conversion_margin)

# During rub interaction in AWARE state:
var converted: bool = check_aware_conversion(npc_state)
if converted:
    emit_signal("deescalation_event", npc_id)
    # NPC System receives on next frame, resets awareness_window timer → AWARE→ROUTINE
    # Social System does NOT directly set current_behavior — NPC System owns transitions
# Goodwill is earned regardless of conversion (standard rub formula, including levity)
```

**AWARE conversion example:**
- Michael in AWARE: `emotional_level = 0.42`, `reaction_threshold = 0.60`
- `aware_conversion_margin = 0.12` → threshold = `0.48`
- `0.42 < 0.48` ✓ — eligible
- Rub fires: goodwill += `0.08 * comfort_receptivity`; `deescalation_event` emits
- Next frame: NPC System receives signal, awareness timer resets → ROUTINE

---

### 4.6 Meow Context Resolution

```gdscript
func resolve_meow(npc_state: NpcState) -> MeowResult:
    var result: MeowResult = MeowResult.new()

    match npc_state.current_behavior:
        NpcBehavior.VULNERABLE:
            result.goodwill_delta = charm_value_meow_base * meow_vulnerable_multiplier \
                                    * npc_state.comfort_receptivity
            result.interaction_type = InteractionType.CHARM

        NpcBehavior.RECOVERING:
            result.goodwill_delta = charm_value_meow_base * meow_recovering_multiplier \
                                    * npc_state.comfort_receptivity
            result.interaction_type = InteractionType.CHARM

        NpcBehavior.AWARE:
            var safe_threshold: float = npc_state.reaction_threshold - meow_safe_margin
            if npc_state.emotional_level < safe_threshold:
                result.goodwill_delta = charm_value_meow_base * meow_aware_multiplier \
                                        * npc_state.comfort_receptivity
                result.interaction_type = InteractionType.CHARM
            else:
                # Risky: meow adds stimulus; could tip to REACTING
                result.stimulus_bump = meow_threshold_stimulus  # emitted to NPC System
                result.goodwill_delta = 0.0
                result.interaction_type = InteractionType.CHAOS

        NpcBehavior.ROUTINE:
            if npc_state.emotional_level < meow_routine_safe_threshold:
                result.goodwill_delta = charm_value_meow_base * npc_state.comfort_receptivity
                result.interaction_type = InteractionType.CHARM
            else:
                # Near threshold even in ROUTINE — meow adds minor stress
                result.stimulus_bump = meow_routine_stimulus  # small; may push to AWARE
                result.goodwill_delta = 0.0
                result.interaction_type = InteractionType.CHAOS

        _:
            result.blocked = true

    return result
```

**Meow example — VULNERABLE Christen:**
- `comfort_receptivity = 0.95`, `charm_value_meow_base = 0.05`, `meow_vulnerable_multiplier = 1.8`
- Goodwill delta: `0.05 * 1.8 * 0.95 = 0.0855`
- If levity eligible (just caused chaos): `0.0855 * 1.5 = 0.128`

**Meow example — risky AWARE Michael:**
- `emotional_level = 0.55`, `reaction_threshold = 0.60`, `meow_safe_margin = 0.15`
- Safe threshold: `0.60 - 0.15 = 0.45`
- `0.55 > 0.45` → risky path
- `meow_threshold_stimulus = 0.08` emitted to NPC System
- `0.55 + 0.08 = 0.63 > 0.60` → Michael enters REACTING
- Social System records: `chaos_goodwill_cost = 0.05` (MINOR tier), `last_interaction_type = CHAOS`

---

## 5. Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| BONNIE attempts rub during REACTING | Interaction blocked entirely. No animation, no goodwill, no feedback. | Zero-gain animation teaches players the system is broken. Blocking teaches timing. Player learns: not now. |
| BONNIE attempts any charm during CLOSED_OFF | All interactions blocked. NPC does not acknowledge BONNIE. NPC takes a small step back if BONNIE comes very close. | CLOSED_OFF is the penalty state. The way out is time, not charm. No response reinforces: done. |
| BONNIE in range of both Michael AND Christen simultaneously | Social System processes each NpcState independently. Proximity and purr tick for each in-range NPC simultaneously. Goodwill updates are per-NpcState. | Social System iterates all NPCs within range. No priority queue. Both receive independent goodwill gains. |
| Levity window active for Michael; BONNIE charms Christen instead | Levity is per-NpcState. Christen's `last_interaction_type` and `last_interaction_timestamp` are her own. Rubbing Christen uses Christen's levity state only. | The levity window is relational, not global. Chaos with Michael does not create levity opportunity with Christen. |
| NPC enters REACTING during active Lap Sit | BONNIE is ejected (physics impulse). Goodwill accumulated during the sit is retained — no cancellation penalty. BONNIE enters DAZED or LANDING depending on distance from floor. | Earned goodwill is non-refundable. The ejection is a physics consequence, not a punishment. Comedic: you were wrong to be on that lap. |
| Meow at exactly `reaction_threshold - meow_safe_margin` | Uses `<` comparison — at exactly the boundary, falls into the risky path. Meow emits stimulus; potential REACTING trigger. | At the boundary, err toward risk. Meow is always dangerous when the NPC is this close to tipping. |
| Proximity + Purr + Rub all in same frame | Passive tick formula and discrete rub formula are separate code paths that both write to `goodwill`. All three apply correctly. GDScript clamp prevents overflow. | No interaction between passive and discrete paths. Both accumulate to the same `goodwill` field. |
| Rub cooldown active; player attempts rub again | Interaction blocked. No animation, no goodwill, no response. BONNIE's idle animation continues. | Cooldown prevents degenerate spam-rub. BONNIE simply isn't rubbing right now. |
| NPC transitions from RECOVERING to VULNERABLE while BONNIE is already in proximity | Social System detects state change on next frame (state is read fresh every frame). VULNERABLE gates open immediately. Purr and proximity start earning VULNERABLE-boosted rates. | The frame-based read model handles state transitions naturally. No mid-frame edge case. |
| BONNIE meows during GROGGY | GROGGY is blocked for all interactions. BONNIE's meow animation plays (she meowed), but NPC produces no response — no goodwill, no stimulus. | GROGGY NPCs are not receptive. Playing BONNIE's animation with no NPC response is consistent with the GROGGY "barely there" character. The asymmetry (BONNIE acts, NPC doesn't respond) is correct. |
| `last_interaction_timestamp` on a freshly initialized NpcState | Default value `0.0`. `time_since_chaos = current_time - 0.0 = current_time` (many seconds). `current_time < levity_window` is false. No levity on first interaction. | Correct: no levity on the very first interaction since no chaos has qualified it. |
| Passive proximity ticks immediately after a chaos event | Passive ticks accumulate against `passive_accumulator`. The accumulator must reach `proximity_interaction_threshold` before logging `CHARM` and potentially resetting the levity window. At default rates (~2.5 seconds), the levity window (4.0 seconds) can still activate before the log fires. | This is the point of the accumulator threshold. A patient player who hangs near the NPC immediately after chaos can still capitalize on the levity window — passive ticks don't instantly overwrite it. |
| NPC in VULNERABLE; BONNIE triggers a chaos event (see npc-personality.md §5) | Chaos event is recorded: `goodwill -= chaos_goodwill_cost`, `last_interaction_type = CHAOS`. NPC behavioral state is governed by npc-personality.md §5 (VULNERABLE → REACTING if stimulus exceeds reaction_threshold; CLOSED_OFF path if chaos_event_count threshold exceeded). Social System records the goodwill penalty; NPC System handles behavioral state change. | Separation of concerns: Social System owns goodwill, NPC System owns behavioral state. |
| FED triggers during an active Lap Sit | FED transition fires (feeding cutscene triggers). The level completes. The Lap Sit contributed to the goodwill that triggered FED; the cutscene can reference the current interaction state for emotional context. | FED is terminal. It overrides everything. The warmth of the moment is preserved in the cutscene. |

---

## 6. Dependencies

### This System Depends On

| System | # | Direction | Dependency Nature |
|--------|---|-----------|-------------------|
| BONNIE Traversal System | 6 | Social reads Traversal | BONNIE's movement state gates available interactions (§3.2). Proximity radius (from stimulus radius system) feeds `visible_to_bonnie` and determines whether BONNIE is in range. The E-key contextual rub is defined in `bonnie-traversal.md §3.2` E-key context map — Social System is one of those E-key contexts. |
| Reactive NPC System | 9 | Social reads and writes NpcState | NpcState is the shared data object. NPC System must complete stimulus processing before Social System writes results back. Execution order: NPC System → Social System → next frame NPC System read. Neither system calls the other directly. |

### Systems That Depend On This

| System | # | Direction | What They Need |
|--------|---|-----------|----------------|
| Chaos Meter | 13 | Reads goodwill and charm events | `goodwill` in NpcState is this system's primary output. Social System will emit `SocialInteractionEvent(npc_id, interaction_type, goodwill_delta, was_levity_active)` — Chaos Meter listens to this signal. Exact Chaos Meter usage of charm events is the Chaos Meter GDD's specification. |
| Dialogue System | 17 (VS) | Reads NpcState | `last_interaction_type`, `goodwill` inform dialogue pool selection. Reads directly from NpcState — no direct calls to Social System. Vertical Slice scope. |

### Circular Dependency Resolution

**Social System (12) ↔ NPC System (9)** — documented in `npc-personality.md §6`
and `systems-index.md`.

Resolution: NpcState as shared data object. Neither system calls the other.

**Frame execution order:**
1. Input System processes player input
2. BONNIE Traversal System updates movement state, stimulus radii, writes `visible_to_bonnie`
3. Reactive NPC System processes all active stimuli → updates `emotional_level`,
   `current_behavior`, `comfort_receptivity`
4. **Bidirectional Social System reads updated NpcState → resolves BONNIE's active
   social interactions → writes `goodwill`, `last_interaction_type`,
   `last_interaction_timestamp`**
5. Chaos Meter reads NpcState goodwill changes, REACTING events
6. NPC System reads updated NpcState on next frame

### Provisional Contracts with Undesigned Systems

| System | Status | Provisional Contract |
|--------|--------|---------------------|
| Environmental Chaos System (8) | Vertical Slice — not started | Must emit: `ChaosEvent(npc_id: int, severity: ChaosSeverity)`. The `ChaosSeverity` enum (MINOR, MODERATE, MAJOR, CRITICAL) is defined in this GDD (§3.4) and is the interface contract. Environmental Chaos System must use these tier labels. |
| Chaos Meter (13) | MVP — not started | Social System emits: `SocialInteractionEvent(npc_id, interaction_type, goodwill_delta, was_levity_active: bool)`. Exact Chaos Meter API TBD — signal format is provisional; coordinate before implementation. |
| Dialogue System (17) | Vertical Slice — not started | Reads `last_interaction_type` and `goodwill` directly from NpcState. No direct Social System calls required. |

---

## 7. Tuning Knobs

All values are MVP prototype starting points. Social balance requires playtesting
to calibrate — these are initial targets with wide safe ranges.

### Charm Values

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `charm_value_proximity` | `0.008/s` | `0.003–0.020/s` | feel | Passive goodwill builds faster; passive strategy more viable |
| `charm_value_rub` | `0.08` | `0.04–0.15` | feel | Each rub is worth more; reaching FED faster from rubs |
| `charm_value_lap_per_second` | `0.06/s` | `0.03–0.12/s` | feel | Lap sit path to FED requires less time |
| `charm_value_purring` | `0.004/s` | `0.001–0.010/s` | feel | Idle purr contributes more to passive goodwill |
| `charm_value_meow_base` | `0.05` | `0.02–0.10` | feel | Meow earns more on positive resolutions |
| `purr_vulnerable_multiplier` | `2.0` | `1.2–3.0` | feel | Purring during VULNERABLE more effective |
| `meow_vulnerable_multiplier` | `1.8` | `1.2–2.5` | feel | Meow at jackpot state earns more |
| `meow_aware_multiplier` | `1.2` | `0.8–1.8` | feel | Reward for successful AWARE meow bid |
| `meow_recovering_multiplier` | `0.7` | `0.4–1.0` | feel | Meow during fragile state earns less |

### Proximity and Radii

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `proximity_charm_radius` | `80 px` | `48–120 px` | feel | Larger zone; passive goodwill activates from further away |
| `purr_radius` | `60 px` | `40–90 px` | feel | Purr activates from further; must be ≤ `proximity_charm_radius` |
| `rub_distance` | `32 px` | `20–48 px` | feel | Rub available from further away; less precision required |
| `proximity_interaction_threshold` | `0.02` | `0.01–0.05` | gate | How much passive goodwill must accumulate before CHARM is logged (levity window protection) |

### Cooldowns

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `rub_cooldown` | `4.0s` | `2.0–8.0s` | gate | Longer wait between rubs; spam-rub strategy less viable |
| `meow_cooldown` | `3.0s` | `1.5–6.0s` | gate | BONNIE can meow less frequently; meow feels more deliberate |

### AWARE Conversion

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `aware_conversion_margin` | `0.12` | `0.05–0.25` | gate | Wider buffer → conversion available even when NPC is closer to tipping; easier de-escalation skill |

### RECOVERING Comfort Acceleration

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `recovering_comfort_acceleration` | `1.8` | `1.2–3.0` | feel | Each charm interaction during RECOVERING boosts receptivity recovery rate more |
| `recovering_comfort_acceleration_max_stacks` | `2` | `1–4` | gate | More stacks available; more rubs needed to reach full acceleration |
| `recovering_comfort_acceleration_cap` | `3.0` | `2.0–4.0` | gate | Maximum total multiplier on receptivity_recovery_rate during RECOVERING |

### Meow Risk Parameters

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `meow_safe_margin` | `0.15` | `0.08–0.25` | gate | Larger buffer → risky meow zone in AWARE is smaller; meow is safer |
| `meow_routine_safe_threshold` | `0.35` | `0.20–0.50` | gate | Higher → meow safe in ROUTINE even when NPC is more stressed |
| `meow_threshold_stimulus` | `0.08` | `0.04–0.15` | feel | Larger stimulus → risky AWARE meow more likely to trigger REACTING |
| `meow_routine_stimulus` | `0.05` | `0.02–0.10` | feel | Larger → risky ROUTINE meow more likely to push to AWARE |

### Visual Legibility

| Knob | Default | Safe Range | Category | Effect of Increase |
|------|---------|------------|----------|--------------------|
| `goodwill_visual_blend_time` | `2.0s` | `0.5–4.0s` | feel | Smoother/slower visual tier transitions; less snappy feedback |
| `goodwill_cold_threshold` | `0.25` | `0.10–0.35` | feel | COLD tier covers more of the goodwill range; NPC stays cold longer |
| `goodwill_softened_threshold` | `0.50` | `0.35–0.65` | feel | Softened tier starts earlier/later |
| `goodwill_warm_threshold` | `0.75` | `0.60–0.90` | feel | WARM tier requires more/less goodwill to reach |

### Levity Window (reference — source: `npc-personality.md §7`)

These are defined in `npc-personality.md §7`. Listed here for reference. **Update
the source document** — do not create duplicate definitions.

| Knob | Source | Default |
|------|--------|---------|
| `levity_window` | npc-personality.md §7 | `4.0s` |
| `levity_multiplier` | npc-personality.md §7 | `1.5` |

---

## 8. Acceptance Criteria

All criteria verifiable by a QA tester in the MVP prototype. Goodwill values
confirmed via debug output — no goodwill UI required.

---

**AC-S01: Proximity charm ticks passively**
- [ ] BONNIE in IDLE within `proximity_charm_radius` of Michael in ROUTINE:
      `goodwill` increases over time (confirm in debug output)
- [ ] BONNIE moves outside `proximity_charm_radius`: goodwill ticks stop
- [ ] BONNIE in WALKING within radius: goodwill ticks at proximity rate
      (passive only — no rub input available from WALKING state)
- [ ] BONNIE in RUNNING within same radius: goodwill does NOT tick

**AC-S02: Rub interaction fires and cooldowns correctly**
- [ ] BONNIE in IDLE within `rub_distance` of Michael in ROUTINE: rub triggers
      on E input; `goodwill` increases by `charm_value_rub * comfort_receptivity`
- [ ] Rub: `last_interaction_type = CHARM` written to NpcState (confirm in debug)
- [ ] Second rub within `rub_cooldown` seconds: blocked — no goodwill delta,
      no rub animation
- [ ] After `rub_cooldown` expires: rub available again; fires correctly

**AC-S03: Levity multiplier activates on charm-after-chaos**
- [ ] Trigger MODERATE chaos against Michael: `last_interaction_type = CHAOS`
      confirmed; `goodwill` decremented by `0.10`
- [ ] Within `levity_window` (4.0s): perform rub; goodwill delta =
      `charm_value_rub * levity_multiplier * comfort_receptivity` (within tolerance)
- [ ] After `levity_window` expires: same rub earns `charm_value_rub * comfort_receptivity`
      (no multiplier)
- [ ] Levity window for Michael does NOT activate for Christen: cause MODERATE
      chaos against Michael only; rub Christen; Christen earns standard rub rate

**AC-S04: Lap sit earns sustained goodwill**
- [ ] Michael in ROUTINE during Evening phase (seated): lap sit available;
      `goodwill` increases continuously at `charm_value_lap_per_second` rate
- [ ] BONNIE exits lap voluntarily: goodwill earned during sit is retained
- [ ] Michael enters REACTING during lap sit: BONNIE is ejected; goodwill
      earned before ejection is retained; BONNIE enters DAZED or LANDING
- [ ] Lap sit NOT available during Michael Work phase (not a seated lap position)

**AC-S05: Purr stacks with proximity in IDLE**
- [ ] BONNIE in IDLE within `purr_radius` (inside `proximity_charm_radius`):
      goodwill tick rate is higher than BONNIE in IDLE between `purr_radius`
      and `proximity_charm_radius` (proximity only, no purr)
- [ ] BONNIE moves from IDLE to WALKING: purr stops; proximity rate only
- [ ] In NPC VULNERABLE: IDLE purr + proximity combined rate is measurably higher
      than same configuration in ROUTINE at same `comfort_receptivity`

**AC-S06: AWARE conversion via rub**
- [ ] Drive Michael to AWARE; confirm `emotional_level < (reaction_threshold - aware_conversion_margin)`
- [ ] Rub fires: goodwill increases; `deescalation_event` emits (confirm in debug log)
- [ ] Next frame: Michael returns to ROUTINE
- [ ] Drive Michael to AWARE near threshold (`emotional_level > conversion margin`):
      rub fires (small goodwill gained) but `deescalation_event` does NOT emit;
      Michael remains AWARE

**AC-S07: Meow context-sensitivity**
- [ ] Michael ROUTINE, `emotional_level = 0.15`: meow earns goodwill;
      `last_interaction_type = CHARM`
- [ ] Michael ROUTINE, `emotional_level = 0.45` (above `meow_routine_safe_threshold`):
      meow emits stimulus; no goodwill; `last_interaction_type = CHAOS`
- [ ] Michael VULNERABLE: meow earns goodwill at `meow_vulnerable_multiplier` rate
      (higher than ROUTINE equivalent)
- [ ] Michael AWARE near threshold: meow emits `meow_threshold_stimulus`; if
      `emotional_level + meow_threshold_stimulus >= reaction_threshold`, Michael
      enters REACTING (confirm state transition in debug)
- [ ] Michael REACTING: meow blocked entirely — no NPC response, no delta

**AC-S08: RECOVERING extended levity and comfort acceleration**
- [ ] BONNIE rubs Michael during RECOVERING: goodwill delta includes levity
      multiplier (1.5×) confirmed via debug — even if `levity_window` timer from
      the original chaos event has expired
- [ ] First rub during RECOVERING: comfort_receptivity is low; goodwill gain is
      small but non-zero (levity compensates)
- [ ] Second rub during RECOVERING (after cooldown): goodwill gain is measurably
      higher than first rub (receptivity_recovery_rate has been accelerated by
      `recovering_comfort_acceleration`)
- [ ] Third rub: gain higher still — visible in debug as progressive increase
- [ ] NPC exits RECOVERING (to ROUTINE or VULNERABLE): comfort acceleration
      stacks reset to zero (confirm `recovering_comfort_stacks` cleared in debug)
- [ ] NPC visual progression during RECOVERING comfort: first rub produces tense
      warmth; second rub shows shoulders dropping; third rub shows expression
      shifting toward gratitude

**AC-S09: CLOSED_OFF blocks all charm**
- [ ] Drive Michael to CLOSED_OFF state
- [ ] BONNIE attempts proximity, rub, meow: all blocked; `goodwill` delta is
      `0.0` for all (confirm in debug); no positive NPC visual response
- [ ] BONNIE approaches very close: Michael takes a small step back or turns
      further away (active avoidance animation confirmed)
- [ ] After `closed_off_recovery_time` with no chaos events: Michael returns
      to ROUTINE; charm interactions become available again

**AC-S10: Visual legibility — goodwill tiers distinguishable without UI**
- [ ] Michael at `goodwill = 0.10` (COLD): posture stiff; no warmth toward
      BONNIE during ROUTINE
- [ ] Michael at `goodwill = 0.60` (SOFTENED): posture relaxed; occasional warm
      glances at BONNIE
- [ ] Michael at `goodwill = 0.85` (WARM): actively brightens when BONNIE enters
      view; reaches toward her
- [ ] Visual transition between tiers is smooth — no hard posture snap on threshold
- [ ] Independent playtester (no instruction on the system) can identify that one
      session went "better" than another based on NPC body language alone

**AC-S11: VULNERABLE visual legibility**
- [ ] Michael in VULNERABLE: slumped posture, rounded shoulders, unfocused gaze —
      visually distinct from RECOVERING (RECOVERING is tense but upright;
      VULNERABLE is depleted)
- [ ] BONNIE approaches Michael in VULNERABLE: Michael reaches toward BONNIE
      (distinct from ROUTINE approach response)
- [ ] Rub during VULNERABLE: NPC response is visibly more emotionally open than
      rub during ROUTINE (animation + audio difference confirmed)

**AC-S12: Chaos recording correct**
- [ ] MODERATE chaos event received: `goodwill -= 0.10`; `last_interaction_type = CHAOS`;
      `last_interaction_timestamp` written (confirm all three in debug)
- [ ] CRITICAL chaos event: `goodwill -= 0.30`
- [ ] Multiple chaos events in sequence: goodwill decrements each time, clamped at `0.0`

**AC-S13: Two NPCs processed independently**
- [ ] BONNIE simultaneously in range of both Michael and Christen:
      both NPCs receive goodwill ticks (confirm both `goodwill` fields increasing)
- [ ] MODERATE chaos event against Michael only: only Michael's goodwill decrements;
      Christen's `goodwill` is unchanged
- [ ] Levity active for Michael (CHAOS timestamp set): rubbing Christen does NOT
      use levity multiplier for Christen's calculation

---

## Open Questions

| Question | Priority | Notes |
|----------|----------|-------|
| Chaos Meter (13) signal format: what exactly does it need from Social System events? | High | Provisional `SocialInteractionEvent` defined in §6. Chaos Meter GDD will specify — coordinate on exact event schema before implementation begins. |

### Resolved Questions (Session 008)

| Question | Resolution | Date |
|----------|-----------|------|
| Lap sit: physical navigation or snap? | **Physical navigation.** BONNIE must physically traverse and jump to the NPC's lap. Consistent with Pillar 2. NPCs require defined lap-accessible jump targets in level design. | 2026-04-17 |
| MVP visual legibility: 4-tier or 2-tier? | **4-tier from the start.** Design and code target full COLD/NEUTRAL/SOFTENED/WARM system. If art pipeline pressure forces a temporary reduction, fall back to 2-tier — but the design spec builds for 4. | 2026-04-17 |
| Rub during RECOVERING: blocked or available with reduced gain? | **Available with extended levity + comfort acceleration.** See §3.7. RECOVERING charm interactions get the levity multiplier (1.5×) AND accelerate receptivity recovery. First rub is weak but meaningful; subsequent rubs land progressively harder. The correct instinct is rewarded. | 2026-04-17 |
| Passive proximity dominant strategy risk? | **Passive play is a valid expression, not a degenerate strategy.** See §3.8. `min_chaos_events_for_feed` gates feeding — pure passive play cannot trigger FED. Passive play earns goodwill, visual tier progression, and environmental storytelling. Future enrichment will make patient observation increasingly rewarding. The game honors this aesthetic choice. | 2026-04-17 |
