# System GDD: Chaos Meter

> **Status**: Draft
> **Created**: 2026-04-17
> **System #**: 13
> **Priority**: MVP
> **Implements Pillars**: 3 (Chaos is Comedy, Not Combat), 4 (People Have Their Own
> Problems), 1 (Every Space is a Playground)

---

## 1. Overview

The Chaos Meter is BONNIE's level-progress indicator and the central design argument
of the game. It answers the question "how close am I to being fed?" — but refuses to
answer it with a single number.

The meter tracks two fundamentally different inputs: **chaos** (REACTING events on
NPCs, environmental object destruction, NPC cascade chains, pest hunting) and
**social** (goodwill built through charm interactions with NPCs). It is a composite of
two fill components. The chaos component hard-caps at 55% of the bar — no matter how
much chaos BONNIE causes, she cannot trigger a feeding on destruction alone. The social
component cannot close the gap without chaos context having been established first (at
least 2 REACTING events gate the NPC's FED condition). Neither axis works without the
other.

The meter does not count down or punish. It counts up, it is always visible, and it
waits for BONNIE. A player who spends twenty minutes exploring and hunting pests will
still have fun — the meter just won't move much. That is by design.

The meter is a **display**. The actual FED condition is the NPC-level check defined in
npc-personality.md §4.5 — `goodwill >= effective_feeding_threshold AND chaos_context_met`.
The meter approximates that condition in real time and communicates it to the player.

---

## 2. Player Fantasy

> *You are reading a room the way only a cat can.*

The chaos meter delivers the fantasy of **knowing your audience**. It is not a
demolition progress bar. It is a relationship weather gauge — a live readout of how
close BONNIE is to being understood. The player watches it not to see how much they've
broken, but to track whether the balance of chaos and warmth is tipping toward food.

### Three Beats of the Fantasy

**The Read.** Before BONNIE touches anything, the player is watching. What is Michael
doing? How wound up is he today? Is Christen about to arrive? The meter is low. It's
fine. There is time. Good chaos is not rushed.

**The Engineering.** Triggering a REACTING event and watching the chaos component
spike — then immediately seeing the opportunity. *This is the window.* Michael is
upset. In thirty seconds he will be exhausted and soft. That's when BONNIE rubs
against his leg, and the meter jumps further than any amount of pure destruction
could have moved it alone.

**The Cascade.** Using Michael's REACTING event to pull Christen into a spiral.
Watching two NPCs unravel through a Domino Rally chain. Seeing the chaos component
jump as depth bonuses apply — and then playing both VULNERABLE states simultaneously.
Two NPCs in emotional collapse, and BONNIE sitting between them, perfectly unbothered.
The meter fills not from brute force but from reading the room precisely right.

### Aligned MDA Aesthetics

| Aesthetic | Priority | How This System Delivers It |
|-----------|----------|-----------------------------|
| **Expression** | 1 | The path to FED is player-authored. Two players describing different routes to the same fed cutscene is this aesthetic working. |
| **Discovery** | 4 | The social axis is the game's central "aha" moment. Players discover that charm-after-chaos earns more than charm alone. |
| **Challenge** | 7 | Soft challenge. The puzzle is reading NPC state and acting in the right window — never punishing execution, always punishing impatience. |

---

## 3. Detailed Design

### 3.1 Core Rules

1. The meter is a float value from `0.0` to `1.0`, updated every frame. It is the
   primary visual feedback of level progress for the player.

2. The meter is composed of two additive fill components:
   - `chaos_fill`: Contributions from chaos events. **Hard cap**: `chaos_fill_cap = 0.55`.
   - `social_fill`: Live derivation from the **sum** of all active NPCs' goodwill
     progress toward their individual feeding thresholds. **Weight**:
     `social_fill_weight = 0.45`. Additive across NPCs — having multiple NPCs at
     high goodwill fills the meter faster than focusing one.
   - `meter_value = clamp(chaos_fill + social_fill, 0.0, 1.0)`

3. `chaos_fill` is **cumulative within a level session**. It does not decay. It can
   only increase or remain at its cap. **On level transition, `chaos_fill` is set to
   `level_chaos_baseline` (not zero).** Each level begins at its defined baseline
   tension — the apartment starts at 0.0, the vet's office at 0.15. There is no
   carryover from the previous level. The Notoriety System (21) handles inter-level
   reputation via `level_chaos_intensity` scoring.

4. Each level has a `level_chaos_baseline` — an ambient starting amount of
   `chaos_fill` that reflects the environment's inherent tension. The apartment
   (Level 2) starts near zero — cozy, safe, a training ground. The vet's office
   (Level 3) starts hot. The Italian Market (Level 5) is volatile from moment one.
   This baseline also shapes NPC starting relationships to BONNIE: a high-tension
   level may have NPCs who begin wary or hostile rather than neutral.

5. `social_fill` is **dynamic, reactive, and additive across NPCs**. It tracks
   the sum of all active NPCs' goodwill progress toward their individual feeding
   thresholds. It rises when goodwill rises and falls when goodwill is lost. It is
   not cumulative — it reflects the live value of NPC goodwill at every frame.

6. The meter is the player's information. NPCs do not "know" the meter value. The FED
   transition is triggered by the NPC's internal check, not by `meter_value` itself.

7. When `meter_value >= meter_threshold_tipping` (default `0.95`), the Chaos Meter UI
   (System 23) enters the FEEDING visual state. This signals FED is imminent.

8. **The meter does not count down and does not punish.** There is no "time running
   out" mechanic. The player can wander indefinitely. The meter rewards engagement
   with the bidirectional loop but never forces it.

9. ⚠️ **Invariant**: `chaos_fill_cap + social_fill_weight = 1.0` must always hold.
   If either tuning knob is changed, the other must be adjusted to maintain this sum.

### 3.2 Meter States and Visual Thresholds

The following named states are defined for the Chaos Meter UI system (System 23).
All state transitions are driven by `meter_value` crossing these thresholds:

| State | `meter_value` Range | Player Situation | Key Signal |
|-------|---------------------|-----------------|------------|
| COLD | 0.00–0.14 | Exploring, scrapping around | "Just started" |
| WARMING | 0.15–0.39 | Some REACTING events firing | "Chaos building" |
| HOT | 0.40–0.54 | Multiple REACTING cycles; nearing chaos cap | "Chaos maxed — try something different" |
| CONVERGING | 0.55–0.74 | Chaos cap reached; social fill building | "Both axes active" |
| TIPPING | 0.75–0.94 | Both axes strong; FED close on at least one NPC | "Someone's about to break" |
| FEEDING | 0.95–1.00 | FED condition met or imminent | "Get ready" |

The HOT state is the most important design signal: the chaos fill slows visibly because
it is near the cap, teaching the player that pure chaos has been exhausted. This is the
moment the social axis becomes legible without any explicit tutorial.

### 3.3 Chaos Component Sources

All sources contribute to `chaos_fill` up to `chaos_fill_cap = 0.55`. The cap is
applied on each accumulation: `chaos_fill = clamp(chaos_fill + contribution, 0.0, chaos_fill_cap)`.

#### Source A: NPC REACTING Events (Primary — MVP)

The primary and most valuable chaos source. When any NPC transitions from any state
into REACTING, the Chaos Meter receives a contribution:

```
chaos_event_contribution = emotional_level_at_entry * chaos_event_scale * cascade_depth_bonus
```

- `emotional_level_at_entry` is the NPC's `emotional_level` read from NpcState at the
  exact moment of the REACTING state transition.
- REACTING events are the **only source that increments `chaos_event_count`**, which
  is checked by `chaos_context_met` (the FED gate). All other sources contribute to
  `chaos_fill` but do not satisfy the FED gate.

#### Source B: Environmental Object Destruction (Provisional — System 8)

*The Environmental Chaos System (8) is not yet designed. Values below are provisional
and must be confirmed when System 8 is authored.*

When BONNIE interacts with or destroys an interactive object:

```
chaos_fill = clamp(chaos_fill + object_chaos_value, 0.0, chaos_fill_cap)
```

Object destruction does NOT increment `chaos_event_count` unless the destruction
event triggers an NPC REACTING event (in which case Source A applies).

Provisional values: minor objects (cup, lamp, phone) = `0.02`; major objects
(bookshelf, TV) = `0.05`; environmental cascade (chain reaction) = subject to
cascade depth bonus (see below).

#### Source C: Pest Hunting (Provisional — System 15)

*The Pest/Survival System (15) is not yet designed. Values are provisional.*

Catching mice, cockroaches, or other pests contributes a minor chaos tick:

```
chaos_fill = clamp(chaos_fill + pest_chaos_value, 0.0, chaos_fill_cap)
```

Default `pest_chaos_value = 0.015`. Pest hunting is intentionally a weak source — it
supports the "I just want to be a cat" survival loop without being a meter-dominant
strategy. See Edge Cases §5 for the worked calculation showing pest hunting alone
cannot satisfy `chaos_context_met`.

#### Source D: Cascade Chain Depth Bonus

When a Domino Rally chain resolves (NPC A triggers NPC B via cascade stimulus — see
npc-personality.md §3.3), cascade-triggered REACTING events receive a depth multiplier:

```
cascade_depth_bonus = 1.0 + (cascade_depth - 1) * cascade_bonus_per_depth
```

- Depth 1 (direct REACTING, no cascade): `bonus = 1.0` (no bonus applied)
- Depth 2 (NPC A → NPC B cascade): `bonus = 1.15` with default `cascade_bonus_per_depth = 0.15`
- Maximum depth in MVP is 2 (per npc-personality.md §3.3)

This rewards cascade engineering mechanically. A Domino Rally chain is worth more
than the equivalent number of isolated REACTING events. This reinforces Pillar 4:
understanding NPC relationships produces better outcomes than brute interaction.

### 3.4 Social Component

The social fill is a live, reactive derived value. It does not accumulate independently
— it is computed fresh every frame from current NpcState values.

```
# For each NPC i with current goodwill and effective feeding threshold:
goodwill_progress_i = npc_i.goodwill / npc_i.effective_feeding_threshold

# Additive sum of all active NPCs' progress:
total_goodwill_progress = sum(goodwill_progress_0, goodwill_progress_1, ...)

# Social fill component (clamped to weight maximum):
social_fill = clamp(total_goodwill_progress / active_npc_count_for_normalization, 0.0, 1.0) * social_fill_weight
```

**Additive model (user decision — Session 008):** Social fill sums all active NPCs'
progress rather than taking the max. This means having multiple NPCs at high goodwill
fills the meter faster than focusing one. The sum is normalized by
`active_npc_count` (number of NPCs currently in the level) so that the meter scales
correctly across varying NPC counts. When a new NPC arrives with zero goodwill, the
normalized average temporarily dips — this is intentional and correct (see the
Christen-arrival edge case in §5). The additive model rewards broader social
investment: once both NPCs are at high goodwill, the meter fills faster than
focusing one NPC alone.

Key properties:
- `social_fill = social_fill_weight` (= 0.45) when the average NPC goodwill
  progress equals 1.0.
- Two NPCs at 50% progress each produce the same social_fill as one NPC at 100%.
- If goodwill falls (chaos events during VULNERABLE, passive decay), `social_fill`
  falls with it in the same frame.
- **Post-first-feeding dynamics (Vertical Slice):** When one NPC enters FED, their
  goodwill contribution to social_fill freezes at 1.0 but the *remaining* NPCs'
  social dynamics shift — the fed NPC may talk to unfed NPCs about BONNIE, affecting
  their willingness to feed. This inter-NPC social influence is Vertical Slice scope
  (requires NPC-to-NPC dialogue, System 17). In MVP, first FED triggers level end.
- If a second NPC has higher goodwill progress than the first, the second NPC's
  progress becomes the social_fill basis automatically.
- **Post-first-feeding dynamics** are documented above (Vertical Slice scope).

### 3.5 The Levity Bridge

The levity multiplier (defined in npc-personality.md §3.5 and §4.2) is the primary
mechanism by which the chaos and social axes reinforce each other.

When BONNIE performs a charm interaction immediately following a chaos event (within
`levity_window` seconds), goodwill earned receives a 1.5× bonus:

```
# From npc-personality.md §4.2 — reproduced here for reference, NOT redefined:
goodwill += charm_value * comfort_receptivity * levity_multiplier
```

Effect on social_fill during VULNERABLE state (peak `comfort_receptivity ≈ 0.90`):
```
Levity-boosted charm:  0.10 * 0.90 * 1.5 = 0.135 goodwill per interaction
Baseline ROUTINE charm: 0.10 * 0.55 * 1.0 = 0.055 goodwill per interaction
```

The levity path is **2.45× more efficient** than baseline charm. This is the mechanical
design argument for the whole system: causing chaos first, then reading the VULNERABLE
window correctly, is dramatically more efficient than pure charm or pure chaos. The
player who learns this has learned to play BONNIE.

### 3.6 Economy Proof: Why Charm is Mathematically Required

The following worked scenarios demonstrate that neither pure chaos nor pure social play
can reach the feeding condition. This section is the mathematical expression of Design
Constraint #1.

#### Scenario A: Pure Chaos Path

```
chaos_fill accumulates toward cap:
  chaos_fill_max = chaos_fill_cap = 0.55

social_fill:
  No charm interactions → goodwill = 0.0 on all NPCs
  social_fill = 0.0

meter_value_maximum = 0.55 + 0.0 = 0.55

FED check (npc-personality.md §4.5):
  goodwill = 0.0
  feeding_threshold = 0.75 (Michael)
  0.0 >= 0.75 → FALSE → FED never triggers
```

Result: The meter **permanently plateaus at 55%** (HOT state). BONNIE can cause
unlimited REACTING events. NPCs react, exhaust, recover, and react again indefinitely.
The chaos is real, the consequences are comedic, the feeding is unavailable. The
design intent: the HOT state's visual stall tells the player something new is needed,
without any text or tutorial.

#### Scenario B: Pure Charm Path

```
Charm interactions build Michael's goodwill:
  Michael goodwill can theoretically approach 0.75

chaos_fill:
  No REACTING events → chaos_event_count = 0
  chaos_fill = 0.0 (only from passive object/pest sources if engaged)

FED check (npc-personality.md §4.5):
  goodwill = 0.75 (at threshold)
  chaos_context_met = (chaos_event_count >= min_chaos_events_for_feed)
  chaos_event_count = 0 >= 2 → FALSE → FED never triggers
```

Result: High goodwill is achievable but the FED gate is closed. The NPC recognizes
BONNIE is sweet — but a cat who has caused zero disruption to a household doesn't
create the pressure needed for someone to feed her just to make it stop. This is
narratively coherent and mechanically intentional.

#### Scenario C: Required Path — Bidirectional Play

The minimum requirements for FED to trigger (from npc-personality.md §4.5):
```
1. chaos_event_count >= min_chaos_events_for_feed (default 2)
   → At least 2 REACTING events must have occurred this session
2. npc.goodwill >= npc.effective_feeding_threshold (0.75 Michael / 0.70 Christen)
   → Goodwill must be built to threshold on at least one NPC

Both conditions must be TRUE simultaneously.
```

The optimal path:
1. Cause 2–6 REACTING events (filling chaos_fill, satisfying chaos_context_met)
2. Wait for REACTING → RECOVERING → VULNERABLE transitions
3. Charm during VULNERABLE with levity bonus (1.5× goodwill efficiency)
4. Avoid triggering CLOSED_OFF (blocks social_fill entirely)
5. When goodwill approaches threshold with chaos_context_met satisfied: FED imminent

#### Economy Summary: Sources, Sinks, and Balance Targets

**Sources (meter fill faucets):**

| Source | chaos_fill | social_fill | chaos_context_met |
|--------|------------|-------------|-------------------|
| REACTING event (avg emotional_level 0.65) | +0.078 | — | +1 event count |
| REACTING cascade depth 2 (avg 0.65) | +0.090 | — | +1 event count |
| Object destruction — minor *(provisional)* | +0.02 | — | No |
| Object destruction — major *(provisional)* | +0.05 | — | No |
| Pest catch *(provisional)* | +0.015 | — | No |
| Charm rub — ROUTINE (comfort_receptivity 0.55) | — | +0.026 social_fill | No |
| Charm — VULNERABLE + levity (receptivity 0.90, ×1.5) | — | +0.081 social_fill | No |
| Charm — VULNERABLE no levity (receptivity 0.90) | — | +0.054 social_fill | No |

*social_fill deltas computed as goodwill_delta / feeding_threshold × social_fill_weight
(e.g., 0.135 goodwill / 0.75 threshold × 0.45 = 0.081)*

**Sinks (meter fill drains):**

| Drain | chaos_fill | social_fill |
|-------|------------|-------------|
| Chaos event goodwill cost | — | Reduces goodwill → social_fill recalculates lower |
| Passive goodwill decay | — | Reduces goodwill → social_fill recalculates lower |
| CLOSED_OFF state | — | Near-zero goodwill gain; existing goodwill decays → social_fill shrinks |

chaos_fill has no drain — it is cumulative and permanent within a session.
social_fill is a derived live value with no permanent accumulation; its "drain"
is simply the current NPC goodwill falling.

**Balance Targets:**

| Metric | Target | Notes |
|--------|--------|-------|
| REACTING events to cap chaos_fill | 5–8 events | At average emotional_level 0.65 |
| Charm interactions to reach feeding_threshold (optimal path) | 5–7 interactions | VULNERABLE window + levity bonus |
| Charm interactions to reach feeding_threshold (baseline path) | 12–16 interactions | ROUTINE, no levity, low receptivity |
| Minimum time to FED (speedrun, optimal play) | 8–12 minutes | Requires reading NPC states precisely |
| Comfortable session time to FED | 15–25 minutes | Natural pacing with exploration |
| Visible chaos plateau (HOT state dwell before player adjusts) | < 5 minutes | HOT state visual stall should prompt behavior change |

---

## 4. Formulas

All float values are clamped to `[0.0, 1.0]` unless noted.

---

### 4.1 REACTING Event Chaos Contribution

```
chaos_event_contribution = emotional_level_at_entry * chaos_event_scale * cascade_depth_bonus

chaos_fill = clamp(chaos_fill + chaos_event_contribution, 0.0, chaos_fill_cap)
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `emotional_level_at_entry` | float | 0.55–1.00 | NpcState | NPC's `emotional_level` at REACTING state entry |
| `chaos_event_scale` | float | 0.06–0.20 | data file | Scale factor per REACTING event. Default: `0.12` |
| `cascade_depth_bonus` | float | 1.00–1.30 | computed | `1.0 + (depth - 1) * cascade_bonus_per_depth`. Depth 1 = 1.0 |
| `chaos_fill_cap` | float | 0.40–0.70 | data file | Hard cap on chaos component. Default: `0.55` |

**Expected output range per event**: `0.066` (min: emotional_level 0.55, no bonus) to
`0.156` (max: emotional_level 1.00, depth-2 cascade with 0.15 bonus per depth)

**Example — direct REACTING, no cascade**:
```
emotional_level_at_entry = 0.70, chaos_event_scale = 0.12, cascade_depth_bonus = 1.0
chaos_event_contribution = 0.70 * 0.12 * 1.0 = 0.084
```

After 5 such events: `chaos_fill = 5 × 0.084 = 0.42`
After ~7 events: `chaos_fill ≈ 0.55` (capped)

**Example — depth-2 cascade (Michael triggers Christen)**:
```
Christen emotional_level_at_entry = 0.68, cascade_depth_bonus = 1.15
chaos_event_contribution = 0.68 * 0.12 * 1.15 = 0.094
```

Cascade chain adds ~12% more chaos fill than the same emotional level without a chain.

---

### 4.2 Object Destruction Contribution (Provisional — System 8)

```
chaos_fill = clamp(chaos_fill + object_chaos_value, 0.0, chaos_fill_cap)
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `object_chaos_value` | float | 0.005–0.10 | per-object data | Defined on each Interactive Object resource. Provisional. |

*Interface contract (provisional)*: System 8 emits a signal `object_chaos_event(value: float)`
when BONNIE destroys or significantly disturbs an object. The Chaos Meter subscribes
to this signal and accumulates accordingly.

---

### 4.3 Pest Hunting Contribution (Provisional — System 15)

```
chaos_fill = clamp(chaos_fill + pest_chaos_value, 0.0, chaos_fill_cap)
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `pest_chaos_value` | float | 0.005–0.03 | data file | Per-catch value. Default: `0.015` |

*Interface contract (provisional)*: System 15 emits a signal `pest_caught(pest_type: PestType)`.
The Chaos Meter maps `pest_type` to `pest_chaos_value` from a lookup table.

---

### 4.4 Social Fill Derivation

```
# For each active NPC i:
effective_feeding_threshold_i = npc_i.feeding_threshold
if npc_i.bonnie_hunger_context:
    effective_feeding_threshold_i -= hunger_threshold_reduction

goodwill_progress_i = npc_i.goodwill / effective_feeding_threshold_i

# Additive progress (normalized by NPC count):
if active_npc_count == 0:
    social_fill = 0.0
    return
total_progress = sum(goodwill_progress_0, goodwill_progress_1, ...)
normalized_progress = clamp(total_progress / active_npc_count, 0.0, 1.0)

# Social fill:
social_fill = normalized_progress * social_fill_weight
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `npc_i.goodwill` | float | 0.0–1.0 | NpcState | Live goodwill value for NPC i |
| `npc_i.feeding_threshold` | float | 0.50–0.90 | npc-personality.md §7 | Michael: `0.75`, Christen: `0.70` |
| `hunger_threshold_reduction` | float | 0.05–0.20 | npc-personality.md §7 | Default: `0.10` |
| `social_fill_weight` | float | 0.30–0.60 | data file | Maximum social contribution. Default: `0.45` |

**Expected output range**: `0.0` (goodwill = 0 on all NPCs) to `0.45`
(best NPC goodwill = feeding_threshold)

**Example — Michael, goodwill = 0.60, no hunger boost**:
```
goodwill_progress = 0.60 / 0.75 = 0.800
social_fill = 0.800 * 0.45 = 0.360
```

**Example — Michael, goodwill = 0.75 (at threshold), no hunger boost**:
```
goodwill_progress = 0.75 / 0.75 = 1.000
social_fill = 1.000 * 0.45 = 0.450  ← maximum social fill
```

---

### 4.5 Combined Meter Value

```
meter_value = clamp(chaos_fill + social_fill, 0.0, 1.0)
```

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `chaos_fill` | float | 0.0–chaos_fill_cap | Cumulative chaos component |
| `social_fill` | float | 0.0–social_fill_weight | Live social component |
| `meter_value` | float | 0.0–1.0 | Combined value exposed to UI |

**Maximum achievable**: `0.55 + 0.45 = 1.0` ✓ (invariant maintained)

---

### 4.6 Hunger Boost Effect on Social Fill

When `bonnie_hunger_context = true` (set on all NpcState instances by the BONNIE
Traversal System after `hunger_threshold_time` seconds without feeding):

```
effective_feeding_threshold_i = npc_i.feeding_threshold - hunger_threshold_reduction
```

This reduces the denominator in the social_fill formula, inflating `goodwill_progress`
for the same goodwill value:

**Example — Michael, goodwill = 0.60, hunger active**:
```
effective_threshold = 0.75 - 0.10 = 0.65
goodwill_progress = 0.60 / 0.65 = 0.923
social_fill = 0.923 * 0.45 = 0.415  (vs. 0.360 without hunger)
```

The meter reads visibly higher during hunger state for the same NPC goodwill level.
No explicit UI calls attention to this — the meter movement is the signal. Attentive
players will notice the meter moving faster when BONNIE has been hungry for a while.

---

### 4.7 Meter State Resolution

The `meter_state` enum is computed each frame from `meter_value`:

```
if meter_value >= meter_threshold_tipping:    meter_state = MeterState.FEEDING
elif meter_value >= meter_threshold_converging: meter_state = MeterState.TIPPING
elif meter_value >= meter_threshold_hot:        meter_state = MeterState.CONVERGING
elif meter_value >= meter_threshold_warming:    meter_state = MeterState.HOT
elif meter_value >= meter_threshold_cold:       meter_state = MeterState.WARMING
else:                                           meter_state = MeterState.COLD
```

`MeterState` enum is exposed to System 23 (Chaos Meter UI) for animation and
audio feedback selection.

---

## 5. Edge Cases

**Q: BONNIE spams chaos forever. meter_value plateaus at 0.55. Can she ever get fed?**

A: No, and this is the intended design. The meter hard-stops at 55% (HOT state).
NPCs continue REACTING, RECOVERING, and returning to ROUTINE in an indefinite loop.
BONNIE can remain in this loop forever — it is comedic and it is the game's most
legible "try something different" signal. The social axis is the only exit. This is
not a punishment; it is Pillar 3 working (Chaos is Comedy, Not Combat).

**Q: Could chaos_fill + social_fill exceed 1.0 at extreme tuning values?**

A: No. `chaos_fill` is hard-capped at `chaos_fill_cap` on accumulation.
`social_fill` is capped at `best_goodwill_progress * social_fill_weight` where
`best_goodwill_progress` is clamped to 1.0. `meter_value` itself is also clamped
to 1.0 as a safety. The invariant `chaos_fill_cap + social_fill_weight = 1.0`
guarantees the theoretical maximum is exactly 1.0. Three independent clamps prevent
overflow; the invariant prevents the theoretical maximum from being unreachable.

**Q: Both NPCs are in CLOSED_OFF. What happens to social_fill?**

A: `social_fill` does not reset to zero immediately — it tracks current goodwill,
which continues to decay toward `goodwill_baseline` (~0.0). Over the duration of
CLOSED_OFF, goodwill decays and `social_fill` shrinks visibly. The meter retreats.
This is the penalty for over-chaos play: visible meter regression. The only exit is
waiting for CLOSED_OFF recovery (`closed_off_recovery_time` from npc-personality.md §7).
BONNIE cannot charm her way out of CLOSED_OFF — she must wait.

**Q: Two REACTING events fire in the same frame (simultaneous cascade resolve). How
is chaos_fill updated?**

A: Both contributions are accumulated in the same frame update. The accumulation
formula runs for each event in sequence; if the combined result would exceed
`chaos_fill_cap`, the final clamp applies once at the end of the frame. No ordering
dependency — the result is identical regardless of which REACTING event processes first.

**Q: BONNIE spends the entire level hunting pests. Can she fill chaos_fill through
pest catches alone?**

A: Theoretically, but extremely slowly, and it still cannot trigger FED. At
`pest_chaos_value = 0.015` and `chaos_fill_cap = 0.55`: approximately 37 pest catches
required to cap chaos_fill. Even at cap, `chaos_event_count = 0` because pest catches
do not increment it. `chaos_context_met = false`. FED is permanently blocked regardless
of goodwill. Pest hunting is a valid "be a cat" experience and contributes marginally
to the meter, but it is not a substitute for NPC engagement.

**Q: BONNIE builds Michael's goodwill to 0.74 (just under threshold) with zero
REACTING events. Is FED possible if she reaches 0.75 via one more charm?**

A: No. `chaos_context_met = (chaos_event_count >= 2)`. With zero REACTING events,
the FED gate is closed regardless of goodwill. This edge case is theoretically possible
but extremely unlikely in practice: NPCs respond to BONNIE's presence with stimuli over
time, and any significant object interaction that registers as a chaos event will likely
produce at least one REACTING transition during a normal play session.

**Q: What happens if `chaos_fill_cap + social_fill_weight` is tuned to not equal 1.0?**

A: The meter becomes either impossible to fill (if the sum is below 1.0, e.g., 0.55 +
0.40 = 0.95 — meter can never reach FEEDING state) or incompletely meaningful (if above
1.0, e.g., 0.65 + 0.45 = 1.10 — meter hits 1.0 before either axis is fully satisfied).
Both are design errors. The invariant check must be enforced before any tuning session
changes either value.

**Q: meter_value = 1.0 but the FED cutscene hasn't triggered. What is the state?**

A: `meter_value = 1.0` means `chaos_fill = chaos_fill_cap` AND `social_fill =
social_fill_weight`, which means `chaos_context_met = true` AND `goodwill >=
effective_feeding_threshold` on the best NPC. The FED check runs every frame for NPCs
in ROUTINE, RECOVERING, or VULNERABLE. If meter = 1.0 and FED hasn't fired, the target
NPC is currently in a non-checked state: REACTING, ASLEEP, GROGGY, FLEEING, CHASING,
or CLOSED_OFF. The meter correctly shows FEEDING state — the player's progress is real.
FED will fire as soon as the NPC transitions into a checked state. This is expected
behavior, not a bug.

**Q: Christen arrives mid-level with high goodwill progress already on Michael.
Does adding a second NPC change social_fill?**

A: Yes — social_fill is additive and normalized by active NPC count. When Christen
enters, `active_npc_count` increases from 1 to 2. If Michael is at goodwill 0.50
(progress = 0.67) and Christen enters at 0.0 (progress = 0.0), the normalized
progress = (0.67 + 0.0) / 2 = 0.335, which is *lower* than Michael's solo 0.67.
This momentary dip is correct: Christen's arrival dilutes the average until BONNIE
builds goodwill with her too. But once both NPCs are at high goodwill, the additive
model rewards the player's broader social investment — two NPCs at 50% progress
produce the same fill as one at 100%. This creates incentive to build relationships
with multiple NPCs rather than tunnel-visioning one.

**Q: Can the meter be gamed by repeatedly triggering minor REACTING events (high-frequency
low-intensity) instead of fewer high-intensity events?**

A: Technically yes, if `chaos_event_scale` and `emotional_level` at entry produce
small contributions. 10 events at `emotional_level = 0.61` (barely over
reaction_threshold) = `10 × 0.61 × 0.12 = 0.732` total, but capped at 0.55. There
is no mechanical difference between 5 moderate events and 10 small events — both reach
the cap. The chaos_fill_cap prevents farming small events from producing outsized results.
High-intensity events reach the cap faster (fewer events required), which is aesthetically
more satisfying and strategically equivalent. No degenerate strategy exists here.

---

### 5.2 Chaos Overwhelm FED Path and Training Level Philosophy

**User decision (Session 008):** The chaos overwhelm path exists for Michael and
Christen — but it should feel like winning by attrition, not by skill.

#### The Training Level (Level 2: The Apartment)

Michael and Christen *love BONNIE*. They will always feed her eventually. The
apartment is designed so that the charm path is the obvious, satisfying, easier win.
A player who chooses pure chaos against loving NPCs learns that it's harder, less
rewarding, and ultimately arrives at the same place — through exhaustion rather than
love. The feeding dialogue and animation should feel different: exasperated ("I just...
here. Take it. Please stop.") vs. warm ("Aww, come here baby, you hungry?").

This sets up later levels: when the player encounters NPCs who *don't* love BONNIE,
the skills learned in the apartment (reading the room, timing social interactions,
engineering VULNERABLE moments) become genuinely necessary.

#### Per-NPC Chaos Overwhelm Configuration

Not all NPCs support the chaos overwhelm path. Each NPC profile defines:

```gdscript
var chaos_overwhelm_threshold: int = -1  # -1 = no overwhelm path
```

| NPC | `chaos_overwhelm_threshold` | Rationale |
|-----|---------------------------|-----------|
| Michael | `8` | Loves BONNIE; eventually caves in exasperation. High bar. |
| Christen | `7` | Slightly more susceptible to overwhelm (lower threshold). |
| Vet (Level 3) | `-1` (disabled) | Does not love BONNIE. Must be charmed or outmaneuvered. |
| K-Mart Staff (Level 4) | `-1` (disabled) | Hostile. No overwhelm path. |

When `chaos_event_count >= chaos_overwhelm_threshold` AND the NPC is in ROUTINE,
RECOVERING, or VULNERABLE, the FED check fires with a modified condition:

```
# Standard FED check (npc-personality.md §4.5):
if goodwill >= effective_feeding_threshold AND chaos_context_met:
    transition_to(FED)

# Chaos overwhelm FED check (supplementary):
if chaos_overwhelm_threshold > 0 AND chaos_event_count >= chaos_overwhelm_threshold:
    transition_to(FED)  # FeedingPathType = CHAOS_OVERWHELM_PATH
```

The overwhelm path bypasses the goodwill requirement entirely — the NPC feeds
BONNIE not because they want to, but because they're broken. This is tracked as
`FeedingPathType.CHAOS_OVERWHELM_PATH` for System 19 (Feeding Cutscene) to use
different dialogue and animation.

**Design intent:** The overwhelm path against loving NPCs should feel *pointless*.
The player tortured someone who would have given them what they wanted if they'd
just been nice. The game doesn't punish this — the level still ends, the feeding
still happens — but it doesn't celebrate it. The charm path produces a warmer
cutscene, higher Notoriety quality score, and more goodwill-based rewards.

Against hostile NPCs (Vet, K-Mart), the overwhelm path doesn't exist. The player
*must* find the charm angle or engineer complex social situations. This is where the
skills from the training level pay off.

---

## 6. Dependencies

### This System Depends On

| System | Direction | Interface Specification |
|--------|-----------|------------------------|
| **NPC Personality System (9)** | This ← NPC reads | **Reads each frame**: `NpcState.goodwill` (computed from `NpcState.feeding_threshold` and `NpcState.bonnie_hunger_context` to derive `effective_feeding_threshold`), `NpcState.bonnie_hunger_context`. **Reads on state transition**: `NpcState.emotional_level` when `current_behavior` transitions to REACTING. **Maintains session counter**: `chaos_event_count` (session-scoped integer, owned and incremented by the Chaos Meter on each REACTING event received; exposed to NPC System for the `chaos_context_met` FED gate check). No writes back to NpcState. |
| **Bidirectional Social System (12)** | This ← Social reads | Reads `NpcState.goodwill` as updated by Social System charm interactions. Social System writes goodwill; Chaos Meter reads it on the next frame. No direct call between systems — NpcState is the shared integration layer. |
| **Environmental Chaos System (8)** | This ← signal (provisional) | **Provisional contract**: System 8 emits `object_chaos_event(value: float)` when BONNIE destroys or significantly disturbs an object. Chaos Meter subscribes and accumulates `object_chaos_value`. System 8 is not yet designed — this contract must be confirmed when System 8 is authored. |
| **Pest/Survival System (15)** | This ← signal (provisional) | **Provisional contract**: System 15 emits `pest_caught(pest_type: PestType)` when BONNIE successfully catches a pest. Chaos Meter maps `pest_type → pest_chaos_value` from a lookup table in `chaos_meter_config.tres`. System 15 is not yet designed — this contract must be confirmed when System 15 is authored. |

### Systems That Depend On This

| System | Direction | Interface Specification |
|--------|-----------|------------------------|
| **Chaos Meter UI (23)** | This → UI provides | **Provides every frame**: `meter_value: float [0.0–1.0]`, `chaos_fill: float [0.0–chaos_fill_cap]`, `social_fill: float [0.0–social_fill_weight]`, `meter_state: MeterState` (COLD / WARMING / HOT / CONVERGING / TIPPING / FEEDING). UI reads only; no writes back to Chaos Meter. |
| **Feeding Cutscene System (19)** | This → Cutscene provides | **Provides on FED trigger**: `feeding_path_type: FeedingPathType` (CHARM_PATH if goodwill was at threshold; CHAOS_OVERWHELM_PATH if overwhelm-fed via cumulative chaos_event_count exceeding a higher threshold). System 19 is Full Vision scope — this data should be tracked from MVP so it is available when System 19 is implemented. |
| **Notoriety System (21)** | This → Notoriety provides | **Provides on level complete**: `level_chaos_intensity: float` (chaos_fill at time of feeding), `level_social_quality: float` (best NPC goodwill at time of feeding), `chaos_event_count: int` (total REACTING events this session). Notoriety uses this to score the style of the run. |

### Data Flow Diagram

```
REACTING transition
    → NPC System emits event with emotional_level
    → Chaos Meter: chaos_fill += contribution
    → Chaos Meter: chaos_event_count++ (owned by Chaos Meter)

Charm interaction
    → Social System: goodwill updated on NpcState
    → Chaos Meter: reads goodwill → social_fill recalculates

Every frame:
    meter_value = chaos_fill + social_fill
    → Chaos Meter UI (23): reads meter_value, chaos_fill, social_fill, meter_state
    → Display updates

FED condition met (NPC internal check, npc-personality.md §4.5):
    → Chaos Meter: records feeding_path_type
    → Feeding Cutscene System (19): receives context
    → Notoriety System (21): receives level summary
```

No circular dependencies. The Chaos Meter is a pure reader/aggregator: it reads from
upstream systems via NpcState and signals, and provides output only to downstream
display and progression systems.

---

## 7. Tuning Knobs

All values in this section are initial MVP targets. Expect significant revision after
first playtest. All values MUST be externalized to `assets/data/chaos_meter_config.tres`.
No hardcoded values in implementation.

⚠️ **Constraint**: `chaos_fill_cap + social_fill_weight = 1.0` is a required invariant.
Any change to either value requires a corresponding adjustment to the other.

### Level Configuration

| Knob | Category | Default | Safe Range | Effect of Increase | Effect of Decrease |
|------|----------|---------|------------|-------------------|-------------------|
| `level_chaos_baseline` | curve | `0.0` (Level 2) | `0.0–0.25` | Level starts with meter partially filled; more volatile NPC starting states | Level starts calm; player builds from zero |

**Per-level defaults:**

| Level | `level_chaos_baseline` | Rationale |
|-------|----------------------|-----------|
| 1 (Germantown Ave) | `0.0` | Open air, low stakes, discovery |
| 2 (The Apartment) | `0.0` | Training level — cozy, safe, clean start |
| 3 (Vet's Office) | `0.15` | Hostile territory — tension from moment one |
| 4 (K-Mart) | `0.10` | Big energy — ambient consumer chaos |
| 5 (Italian Market) | `0.20` | Volatile — hardest level, tests everything |

### Chaos Fill Knobs

| Knob | Category | Default | Safe Range | Effect of Increase | Effect of Decrease |
|------|----------|---------|------------|-------------------|-------------------|
| `chaos_fill_cap` | curve | `0.55` | `0.40–0.70` | Pure chaos contributes more of bar; social lane narrowed; must reduce `social_fill_weight` by same delta ⚠️ | Pure chaos less dominant; social contribution larger share; must increase `social_fill_weight` ⚠️ |
| `chaos_event_scale` | feel | `0.12` | `0.06–0.20` | Each REACTING event fills more bar; fewer events to reach cap | Each event fills less; more events needed before HOT state signal |
| `cascade_bonus_per_depth` | feel | `0.15` | `0.05–0.30` | Domino Rally chains significantly better; cascade engineering strongly rewarded | Cascades barely better than solo events; less incentive for NPC chain play |
| `object_chaos_minor` *(provisional)* | curve | `0.02` | `0.005–0.05` | Object smashing is more meter-relevant | Object smashing feels inconsequential |
| `object_chaos_major` *(provisional)* | curve | `0.05` | `0.02–0.10` | Major destruction highly satisfying | Major destruction feels weak |
| `pest_chaos_value` *(provisional)* | curve | `0.015` | `0.005–0.03` | Pest hunting marginally relevant to meter | Pest hunting has near-zero meter effect |

### Social Fill Knobs

| Knob | Category | Default | Safe Range | Effect of Increase | Effect of Decrease |
|------|----------|---------|------------|-------------------|-------------------|
| `social_fill_weight` | curve | `0.45` | `0.30–0.60` | Social play fills more bar; charm more dominant; must reduce `chaos_fill_cap` ⚠️ | Social fills less; chaos becomes more dominant; must increase `chaos_fill_cap` ⚠️ |

*Note*: `charm_value`, `levity_multiplier`, `feeding_threshold`, `hunger_threshold_reduction`,
and `min_chaos_events_for_feed` are defined in npc-personality.md §7 and are the
authoritative source for those values. Do not redefine them here. Tuning them in
npc-personality.md automatically affects social_fill behavior.

### Meter State Threshold Knobs

| Knob | Category | Default | Safe Range | Notes |
|------|----------|---------|------------|-------|
| `meter_threshold_cold` | gate | `0.15` | `0.05–0.25` | Threshold to exit COLD state. Low = warm immediately; high = longer COLD |
| `meter_threshold_warming` | gate | `0.40` | `0.25–0.50` | WARMING → HOT threshold |
| `meter_threshold_hot` | gate | `0.55` | `0.45–0.65` | HOT → CONVERGING. Should align with `chaos_fill_cap` ± 0.02 |
| `meter_threshold_converging` | gate | `0.75` | `0.65–0.85` | CONVERGING → TIPPING; both axes active |
| `meter_threshold_tipping` | gate | `0.95` | `0.88–0.98` | TIPPING → FEEDING; FED imminent visual signal |

### Session Counter (owned by Chaos Meter)

| Value | Default | Notes |
|-------|---------|-------|
| `chaos_event_count` | `0` (per session) | Incremented by the Chaos Meter on each REACTING event received. Exposed to NPC System for the `chaos_context_met` FED gate check (`chaos_event_count >= min_chaos_events_for_feed`). Resets to `0` on level transition. |
| `min_chaos_events_for_feed` | `2` (source: npc-personality.md §7) | Minimum REACTING events before any NPC's FED check can pass. Not tunable here — adjust in npc-personality.md. |

---

## 8. Acceptance Criteria

All criteria must be verifiable by a QA tester running the MVP prototype with a debug
overlay showing `chaos_fill`, `social_fill`, `meter_value`, `chaos_event_count`, and
each active NPC's `goodwill` and `current_behavior`.

---

**AC-CM-01: Pure chaos path permanently plateaus below feeding threshold**
- [ ] In a test scene with Michael, trigger REACTING events exclusively — no charm
      interactions, no object destruction, no pest hunting
- [ ] Confirm: `chaos_fill` reaches `chaos_fill_cap = 0.55` and does not increase further
      after additional REACTING events
- [ ] Confirm: `social_fill = 0.0` throughout (goodwill never built)
- [ ] Confirm: `meter_value` stays at or below `0.55` permanently
- [ ] Confirm: Michael never transitions to FED state regardless of REACTING event count
- [ ] Confirm: Chaos Meter UI is in HOT state (not TIPPING or FEEDING) when plateaued

---

**AC-CM-02: Pure charm path is blocked by chaos_context_met gate**
- [ ] In a test scene, build Michael's goodwill above `0.75` using only charm interactions
      (force-suppress any REACTING events via debug)
- [ ] Confirm: `chaos_event_count = 0` throughout the session
- [ ] Confirm: `social_fill` approaches `0.45` as goodwill approaches `0.75`
- [ ] Confirm: Michael does NOT transition to FED state even when `goodwill >= 0.75`
- [ ] Confirm: Debug shows `chaos_context_met = false` as the blocking condition

---

**AC-CM-03: Combined bidirectional path successfully reaches FED**
- [ ] Trigger at least 2 REACTING events on Michael (`chaos_event_count >= 2`)
- [ ] Build Michael's goodwill above `0.75` via charm interactions after REACTING cycles
- [ ] Confirm: FED transition triggers (cutscene stub or confirmed state change)
- [ ] Confirm: `meter_value >= 0.95` at or before the FED transition fires
- [ ] Confirm: `chaos_fill > 0` AND `social_fill > 0` at time of FED trigger
- [ ] Confirm: both `chaos_context_met = true` AND `goodwill >= feeding_threshold`

---

**AC-CM-04: Levity path produces measurably more goodwill than baseline**
- [ ] Trigger REACTING event on Michael; within `levity_window` (4s), perform rub interaction
- [ ] Record `goodwill` delta. Expect: `charm_value * comfort_receptivity * levity_multiplier`
- [ ] Perform identical rub interaction after `levity_window` expires
- [ ] Record `goodwill` delta. Expect: `charm_value * comfort_receptivity` (no multiplier)
- [ ] Confirm: levity delta >= `1.5×` standard delta (within floating-point tolerance)
- [ ] Perform rub during VULNERABLE without levity window: confirm delta reflects
      elevated `comfort_receptivity` but no levity multiplier

---

**AC-CM-05: Cascade chain receives depth bonus in chaos_fill**
- [ ] Trigger Michael REACTING (depth 1, no cascade). Record `chaos_fill` delta.
      Expected: `emotional_level * 0.12 * 1.0`
- [ ] Engineer Michael REACTING → Christen REACTING (depth 2 cascade)
- [ ] Record Christen's chaos_fill contribution. Expected: `emotional_level * 0.12 * 1.15`
- [ ] Confirm: Christen's depth-2 contribution is >= 15% larger than a depth-1 REACTING
      event at the same emotional_level value
- [ ] Confirm: cascade does not loop (per AC-07 in npc-personality.md) — Michael is not
      re-triggered by Christen's cascade bleed from his own originating event

---

**AC-CM-06: social_fill dynamically reflects NPC goodwill changes**
- [ ] Build Michael's goodwill to `0.60`. Record `social_fill`. Expected: `~0.360`
- [ ] Trigger chaos event costing `0.15` goodwill. Goodwill drops to `0.45`.
- [ ] On the next frame, confirm: `social_fill` drops to `~0.270` (recalculated)
- [ ] Build goodwill back to `0.60`. Confirm: `social_fill` returns to `~0.360`
- [ ] social_fill should track goodwill continuously with no frame lag > 1

---

**AC-CM-07: Meter state transitions fire at correct thresholds**
- [ ] Force `meter_value` to each threshold boundary via debug override
- [ ] Confirm: `meter_state` enum changes at correct `meter_value` for each of the 6 states
- [ ] Confirm: System 23 (Chaos Meter UI) receives the state change signal within 1 frame
- [ ] Confirm: No intermediate states are skipped when meter_value changes rapidly

---

**AC-CM-08: Hunger boost produces visibly higher social_fill for same goodwill**
- [ ] Record `social_fill` at Michael goodwill = `0.60` with `bonnie_hunger_context = false`
      Expected: `0.60 / 0.75 * 0.45 = 0.360`
- [ ] Set `bonnie_hunger_context = true` (via debug). Confirm same goodwill produces
      higher `social_fill`. Expected: `0.60 / 0.65 * 0.45 = 0.415`
- [ ] Confirm: `effective_feeding_threshold = 0.65` when hunger active
- [ ] Confirm: FED triggers at goodwill = `0.65` (with hunger, with chaos_context_met = true)
- [ ] Confirm: FED does NOT trigger at goodwill = `0.65` when hunger is inactive (threshold 0.75)

---

**AC-CM-09: CLOSED_OFF state causes meter regression**
- [ ] Build Michael's goodwill to `0.50`; confirm `social_fill ≈ 0.300`
- [ ] Trigger chaos events until Michael enters CLOSED_OFF
- [ ] Attempt charm interactions during CLOSED_OFF; confirm near-zero goodwill gain
- [ ] Over time in CLOSED_OFF: confirm `social_fill` declines as goodwill passively decays
- [ ] Confirm: `meter_value` decreases during CLOSED_OFF (meter visibly retreats in UI)
- [ ] After `closed_off_recovery_time` with no chaos events: Michael exits CLOSED_OFF,
      charm interactions resume producing goodwill gain

---

**AC-CM-10: Pest hunting contributes to chaos_fill but cannot satisfy FED gate
(provisional — validate when System 15 is implemented)**
- [ ] Catch 10 pests without triggering any NPC REACTING events
- [ ] Confirm: `chaos_fill` increased by `10 × 0.015 = 0.15`
- [ ] Confirm: `chaos_event_count = 0` (pest catches do not increment it)
- [ ] Build goodwill above `feeding_threshold` via charm (while still no REACTING events)
- [ ] Confirm: FED does NOT trigger (`chaos_context_met = false`)
- [ ] Trigger 2 REACTING events, confirm: FED now possible (chaos_context_met = true)

---

## Open Questions for User Review

*All original open questions were resolved in Session 008.*

### Resolved Questions (Session 008)

| Question | Resolution | Date |
|----------|-----------|------|
| Max-of-N vs additive social_fill? | **Additive.** Sum of all NPCs' progress, normalized by active NPC count. Rewards building relationships with multiple NPCs. Multi-NPC social dynamics (post-first-feeding inter-NPC influence) are Vertical Slice scope. | 2026-04-17 |
| chaos_fill reset between levels? | **Yes — full reset.** Each level starts clean with a `level_chaos_baseline` that reflects the environment's ambient tension. No cumulative carryover. Notoriety System (21) handles inter-level reputation. | 2026-04-17 |
| Passive physics disturbances contribute? | **Yes — at 50% of intentional interaction value.** Define the split in System 8 GDD when authored. Rewards BONNIE's physical presence as a mechanic (Pillar 2). | 2026-04-17 |
| FeedingPathType tracking from MVP? | **Confirmed.** Track CHARM_PATH vs. CHAOS_OVERWHELM_PATH from MVP. Cheap to record, prevents backfill when System 19 (Feeding Cutscene) is implemented. | 2026-04-17 |
| Chaos overwhelm FED path? | **Per-NPC.** Michael (threshold 8) and Christen (threshold 7) support overwhelm — they love BONNIE and eventually cave in exasperation. Hostile NPCs (Vet, K-Mart) have `-1` (disabled). The overwhelm path against loving NPCs should feel pointless — the charm path is easier and more rewarding. See §5.2 for full design. | 2026-04-17 |
