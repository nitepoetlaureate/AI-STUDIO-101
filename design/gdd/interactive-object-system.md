# System GDD: Interactive Object System

> **Status**: Approved
> **Author**: Michael Raftery + Hawaii Zeke
> **Last Updated**: 2026-04-13
> **System #**: 7 (Interactive Object System)
> **Priority**: MVP — Core Layer
> **Implements Pillar**: "Chaos is Comedy, Not Combat" (primary); "BONNIE Moves Like She Means It" (supporting)

---

## 1. Overview

The Interactive Object System defines every physical object in BONNIE!'s world that can be knocked over, pushed, or disturbed through BONNIE's movement. These objects are the apartment's destructible landscape — dishes, cups, books, plants, picture frames — and their primary purpose is to generate chaos as a mechanical output. When BONNIE slides into a stack of dishes at full speed, each dish that moves contributes a `chaos_value` to the Chaos Meter (System 13). When a book falls off a shelf, it emits a stimulus that the Reactive NPC System (9) can read. The system manages object physics state, collision detection from BONNIE, impulse application (CharacterBody2D does not automatically push RigidBody2D in Godot 4 — this is handled explicitly), audio event selection, and the signal interface downstream systems consume. MVP scope covers pushable and knockable objects only. Breakable sprites and destructible geometry are Vertical Slice.

---

## 2. Player Fantasy

> You have been sneaking across the apartment for thirty seconds. Perfectly. Then you commit. Full run. The kitchen counter is right there. You slide in and five things go off the edge in a cascade. Each one a small catastrophe. Each one completely your fault. It is the best thing that has ever happened.

The Interactive Object System delivers the physical comedy that underpins BONNIE!'s entire chaos loop.

**The accidental catastrophe.** BONNIE was running to the other side of the room and didn't fully account for the stack of books on the coffee table. The slide carried her into them. Three books fell. One domino'd into the plant. The plant is on the floor now. Michael is going to have thoughts about this.

**The engineered chaos.** The player has done this enough to know the kitchen counter has six objects and BONNIE, sliding from the hallway, can reach all of them. The run is intentional. The slide is intentional. The cleanup Michael has to do afterward is entirely intentional. This is mastery.

**The single satisfying knock.** Sometimes one object is right at the edge of a table. BONNIE barely clips it walking by. It falls. There is a specific pitch of crash sound. Michael looks up from across the room. That's the whole thing. It was perfect.

All three depend on the same underlying truth: objects must feel physically real in how they move. A push that feels weightless undermines the comedy. The audio is load-bearing — the crash sound IS the punchline. The chaos value is the score.

---

## 3. Detailed Rules

### 3.1 Object Classification

Every interactive object belongs to exactly one weight class. Weight class determines physics behavior, audio event selection, and chaos value range.

| Weight Class | Examples | `chaos_value` range | Audio Event |
|---|---|---|---|
| Light | Cups, pens, small figurines, paperback books | 0.03 – 0.08 | `env_object_knock_light` |
| Medium | Plates, hardback books, small potted plants, picture frames | 0.08 – 0.14 | `env_object_knock_heavy` |
| Heavy | Large plants, heavy vase, stacked book groups | 0.14 – 0.20 | `env_object_knock_heavy` |
| Glass | Glass/ceramic objects — cups, vases, figurines | 0.10 – 0.18 | `env_glass_break` |
| Liquid Container | Glasses of water, open cups, watering can | (inherits weight class value) + `liquid_chaos_bonus` | `env_object_knock_*` + delayed `env_liquid_spill` |

**Glass objects:** `env_glass_break` overrides the weight-class audio. A glass cup is Glass class (audio) and Light class (chaos_value range and physics). Audio: `env_glass_break`. Chaos value: Glass range (0.10 – 0.18).

**Liquid containers:** Play their weight-class knock sound immediately on displacement, then play `env_liquid_spill` after `liquid_spill_delay` (default 0.3s) to simulate liquid spreading. A liquid container emits **two signals**: one for physical displacement, one for the spill bonus. This keeps the knock and spill mechanically and audibly distinct. Each signal carries its own chaos_value contribution.

**Stacked objects:** Modeled as individual RigidBody2D nodes. The code does not treat stacks as a single unit. Chaos value for a full stack is the sum of individual object values — the higher the stack, the higher the chaos potential. When the bottom object is pushed, upper objects fall via normal Godot physics.

### 3.2 Object Node Structure

```
InteractiveObject (RigidBody2D, class: interactive_object.gd)
├── CollisionShape2D          — physics shape
├── Sprite2D                  — visual (AnimatedSprite2D for Vertical Slice breakables)
```

The `interactive_object.gd` script handles:
- Weight class (exported enum, set per instance)
- Per-instance `chaos_value` (exported float, editable in Inspector)
- Displacement detection and `displaced` flag (bool, prevents double-counting)
- Signal emission on first displacement
- Audio event selection and `AudioManager.play_sfx()` call
- Liquid spill scheduling (Timer per object, cancelled on `reset()`)

### 3.3 Interaction Trigger Conditions

An object is displaced when it satisfies ANY of:

**Condition A — Slide Collision:** BONNIE is in SLIDING state AND `get_slide_collision_count() > 0` AND the collider is an `InteractiveObject`. Uses slide force formula (§4.1). Primary chaos trigger.

**Condition B — Run Collision at Speed:** BONNIE is in RUNNING state AND `get_slide_collision_count() > 0` AND the collider is an `InteractiveObject` AND `abs(velocity.x) >= run_interaction_threshold`. Below threshold, BONNIE nudges but does not displace. Above threshold, uses run force formula (§4.2).

**Condition C — Physics Contact (Object to Object):** An already-moving `InteractiveObject` contacts a stationary one. Handled by Godot RigidBody2D physics — no explicit code. Second object's chaos signal fires only on its first displacement (`displaced` flag).

**Condition D — Landing Impact:** BONNIE enters ROUGH_LANDING state AND an `InteractiveObject` is within `landing_displacement_radius`. Objects within range receive a radial impulse (§4.3).

**Grab-and-throw:** Future Vertical Slice verb. Interface contract only: `InteractiveObject.receive_impact(direction: Vector2, force: float)` — object treats this as any other impulse.

### 3.4 Impulse Application — The CharacterBody2D / RigidBody2D Problem

**CharacterBody2D does NOT push RigidBody2D automatically in Godot 4.** `move_and_slide()` generates slide collisions but applies no forces to rigid bodies. Without explicit impulse code, BONNIE stops at objects without moving them.

The production implementation MUST apply impulses explicitly. Recommended approach:

- `RigidBody2D.apply_central_impulse(force: Vector2)` — for direct center hits
- `RigidBody2D.apply_impulse(impulse: Vector2, position: Vector2)` — for off-center hits

**Division of responsibility:**
- `BonnieController` detects collisions via `get_slide_collision_count()` / `get_slide_collision(i)` and calls `InteractiveObject.receive_impact(force: Vector2)` on the struck object
- `InteractiveObject.receive_impact()` applies the impulse to its own RigidBody2D

This keeps coupling one-directional. BonnieController does not know object weight. InteractiveObject does not know BONNIE's state. The only contract is `receive_impact(force: Vector2)`.

> **Implementation note on `RigidBody2D.mass`:** Whether `RigidBody2D.mass` is set per weight class (e.g., Light = 1.0kg, Heavy = 4.0kg) or held constant at 1.0 with `object_mass_factor` as the sole differentiator is an implementation decision. Both approaches achieve the designed outcome — tune via playtest after implementation.

> **Cross-reference `docs/engine-reference/godot/` before implementing impulse API calls.** Godot 4.4/4.5/4.6 may have changes beyond LLM training data.

### 3.5 Chaos Signal Interface

The Interactive Object System does not write directly to the Chaos Meter (System 13). The Chaos Meter GDD is pending — the interface is designed as a signal contract so both systems can be implemented and connected independently.

On first displacement (`displaced == false`), an `InteractiveObject`:

1. Sets `displaced = true`
2. Emits: `object_displaced(chaos_value: float, object_position: Vector2)`
3. Calls `AudioManager.play_sfx(audio_event_id)`
4. If liquid container: schedules `AudioManager.play_sfx(&"env_liquid_spill")` after `liquid_spill_delay` seconds, then emits a **second** `object_displaced(liquid_chaos_bonus, global_position)` after the same delay

Signal shape:
```gdscript
signal object_displaced(chaos_value: float, object_position: Vector2)
```

`chaos_value` is the per-instance exported float. `object_position` is `global_position` at moment of displacement — passed so downstream systems can do spatial calculations if needed. The Interactive Object System fires and forgets.

### 3.6 NPC Stimulus Interface

On displacement, `InteractiveObject` also emits a secondary signal for the NPC System:

```gdscript
signal object_displaced_stimulus(stimulus_strength: float, object_position: Vector2)
```

Where `stimulus_strength = chaos_value * object_stimulus_multiplier`.

This is separate from `object_displaced` so Chaos Meter and NPC System evolve independently. The NPC System connects to `object_displaced_stimulus`; the Chaos Meter connects to `object_displaced`. Neither needs to know what the other does with the event.

### 3.7 Rest State and Reset

Objects begin each level session at their scene-authored rest position. Once `displaced = true`, an object does not reset during normal play — the apartment remembers what BONNIE did.

On level restart, Level Manager triggers a scene reload. Before reload, or via explicit `reset()` call:

```gdscript
func reset() -> void:
    transform = rest_transform   # captured in _ready()
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    displaced = false
    # cancel any pending liquid spill timer
    if _liquid_spill_timer != null and not _liquid_spill_timer.is_stopped():
        _liquid_spill_timer.stop()
```

### 3.8 MVP Object Roster — Level 2 Apartment

All pushable/knockable. Breakable sprite variants are Vertical Slice.

| Object | Weight Class | Default `chaos_value` | Notes |
|---|---|---|---|
| Coffee mug (full) | Liquid Container / Light | 0.05 + liquid bonus | Kitchen, desk |
| Coffee mug (empty) | Light | 0.05 | Kitchen |
| Dinner plate | Medium | 0.10 | Kitchen, dining area |
| Paperback book | Light | 0.04 | Coffee table, shelves |
| Hardback book | Medium | 0.09 | Shelves |
| Small potted plant | Medium | 0.12 | Windowsills, counter |
| Large potted plant | Heavy | 0.18 | Floor corners |
| Picture frame (small) | Light | 0.06 | Knocked off surface |
| Picture frame (large) | Medium | 0.11 | Walls |
| Glass of water | Glass / Liquid Container | 0.13 + liquid bonus | Tables, desk |
| Glass figurine | Glass | 0.14 | Shelves |
| Pen / pencil | Light | 0.03 | Desk |

Default `chaos_value` figures are starting points for level design. Final values require playtest calibration against the Chaos Meter thresholds (pending T-CHAOS GDD). The relative ordering (Heavy plant > Glass > Medium plate > Light book > pen) is the design intent.

---

## 4. Formulas

All pixel values assume 720×540 internal render resolution (world-space pixels, per `viewport-config.md §3`).

### 4.1 Slide Collision Force

```
slide_force = abs(bonnie_velocity.x) * slide_force_multiplier * object_mass_factor
impulse = Vector2(
    slide_force * sign(bonnie_velocity.x),
    -slide_force * slide_vertical_kick
)
```

| Weight Class | `object_mass_factor` |
|---|---|
| Light | 1.0 |
| Medium | 0.75 |
| Heavy | 0.5 |
| Glass | 1.0 (fragile — moves easily) |

`slide_vertical_kick` (default: `0.3`) adds a small upward component so objects arc rather than move purely horizontally.

**Example — BONNIE slides at 380 px/s into a coffee mug (Light):**
- `slide_force = 380 * 2.8 * 1.0 = 1064`
- `impulse = Vector2(1064, -319)` — mug moves sideways with slight upward arc

**Example — BONNIE slides at 310 px/s into a large plant (Heavy):**
- `slide_force = 310 * 2.8 * 0.5 = 434`
- `impulse = Vector2(434, -130)` — plant moves noticeably, feels weighted

### 4.2 Run Collision Force

```
run_force = (abs(bonnie_velocity.x) - run_interaction_threshold) * run_force_multiplier * object_mass_factor
impulse = Vector2(run_force * sign(bonnie_velocity.x), 0)
```

Below `run_interaction_threshold`, `run_force = 0` — no displacement. This is the intentional gate: walking-speed run does not knock objects, near-max-speed run does.

Run force is intentionally less than slide force — running into something should feel smaller than a full committed slide. Players learn that sliding is the high-chaos verb.

**Example — BONNIE runs at 340 px/s into a paperback book:**
- `run_force = (340 - 220) * 1.5 * 1.0 = 180`
- Modest impulse. Book slides. It does not fly.

### 4.3 Landing Displacement (ROUGH_LANDING)

```
distance = (object_position - bonnie_position).length()
radial_force = landing_base_force * (1.0 - distance / landing_displacement_radius)
impulse = (object_position - bonnie_position).normalized() * radial_force * object_mass_factor
```

Force falls off linearly from center to edge of radius. Objects at exact radius edge receive zero force.

**Example — BONNIE lands 20px from a coffee mug (`radius = 48`):**
- `radial_force = 900 * (1.0 - 20/48) = 900 * 0.583 = 525`
- Mug receives 525-magnitude impulse directed away from BONNIE

### 4.4 Chaos Value per Object

`chaos_value` is an exported float set per-instance in the Godot Inspector. It is not calculated at runtime — it is authored by the level designer.

```
chaos_value ∈ [0.0, 1.0]
```

A `chaos_value` of `0.0` is valid (purely visual objects that should not contribute chaos). The system still plays audio and sets `displaced = true`; it simply emits `chaos_value = 0.0`.

**Liquid bonus — two-signal approach:**
```
# Signal 1: physical displacement
emit_signal("object_displaced", chaos_value, global_position)

# After liquid_spill_delay seconds:
# Signal 2: spill
emit_signal("object_displaced", liquid_chaos_bonus, global_position)
AudioManager.play_sfx(&"env_liquid_spill")
```

Two signals keep the knock and spill mechanically distinct. The Chaos Meter receives two separate contributions, making liquid containers meaningfully more chaotic than equivalent-weight dry objects.

### 4.5 NPC Stimulus Strength

```
stimulus_strength = chaos_value * object_stimulus_multiplier
```

A Light object (chaos_value 0.05): `0.05 * 0.6 = 0.03` — noticeable but minor NPC stimulus.
A Heavy plant (chaos_value 0.18): `0.18 * 0.6 = 0.108` — significant stimulus, can push an NPC toward REACTING from ROUTINE on its own.

Small objects build pressure gradually. Large objects can tip an NPC alone. This scales NPC sensitivity directly with object weight — intentional.

---

## 5. Edge Cases

**Multiple simultaneous collisions (BONNIE slides through a cluster).**
`get_slide_collision_count()` can return multiple contacts per physics frame. Each `InteractiveObject` is processed independently. `displaced` flag is checked before signal emission — duplicate contacts on the same object (possible in Godot physics) do not double-fire the signal.

**Object already in motion when BONNIE hits it.**
`displaced = true`: no new chaos signal. Object still receives the impulse — a moving object can change direction or accelerate. This prevents a cup from contributing chaos_value repeatedly as BONNIE chases it across the floor.

**Object at map edge.**
Level design places invisible boundary StaticBody2D walls at scene edges. The Interactive Object System does not handle bounds clamping. An off-screen object is unreachable and generates no error.

**BONNIE runs at exactly `run_interaction_threshold`.**
Condition is `>=`. At exactly the threshold: `(velocity - threshold) * multiplier = 0`. Zero impulse applied, no displacement, no signal. Invisible to the player.

**BONNIE in LANDING/skid state contacts an object.**
LANDING uses `move_and_slide()` and produces slide collision data. The **RUN formula** (§4.2) applies with BONNIE's current landing velocity. If `abs(velocity.x) >= run_interaction_threshold`, object is displaced. This matches the landing skid being treated as a fast-but-decelerating run, not a committed slide.

**BONNIE is DAZED near objects.**
BONNIE is effectively stationary. She cannot displace objects via active collision. A moving RigidBody2D may deflect off her collision shape — this is valid Godot physics and requires no handling. Object's `displaced` flag is already true; no additional chaos signal fires.

**ROUGH_LANDING with no objects within radius.**
Zero iterations. No signals, no impulses. No error.

**Two BONNIE contacts on same object in same physics frame.**
`receive_impact()` still applies the impulse (physics is applied regardless) but `displaced` flag skips the signal on the second call. Object moves; chaos signal fires once.

**Liquid spill timer fires after level restart.**
`reset()` cancels pending liquid spill timers via per-object Timer node. Timers are scoped to the object — scene-global timers are not used for liquid spills.

---

## 6. Dependencies

### This system depends on

| System | Type | What we need |
|---|---|---|
| Viewport Config (2) | Hard | All pixel distances assume 720×540 world-space pixels |
| Audio Manager (3) | Hard | `AudioManager.play_sfx()` for all displacement audio. Uses only existing `env_*` event IDs: `env_object_knock_light`, `env_object_knock_heavy`, `env_glass_break`, `env_liquid_spill`. No new event IDs defined here. |
| BONNIE Traversal (6) | Hard | BONNIE's `velocity`, current `State`, and `get_slide_collision_count()` / `get_slide_collision(i)`. BonnieController calls `InteractiveObject.receive_impact(force: Vector2)` on collision. |

### Systems that depend on this

| System | Type | What they get |
|---|---|---|
| Chaos Meter (13) | Hard (pending) | `object_displaced(chaos_value: float, object_position: Vector2)` — connects at scene load |
| Reactive NPC System (9) | Hard | `object_displaced_stimulus(stimulus_strength: float, object_position: Vector2)` — processes as environmental stimulus |
| Level Manager (5) | Hard | `reset()` called on level restart |
| Environmental Chaos System (8) | Soft (Vertical Slice) | Will extend object interaction model — interface TBD when System 8 is designed |

**Bidirectional consistency notes:**
- Audio Manager (3) lists "Environmental Chaos System (8)" as the env_* audio caller. This GDD clarifies that System 7 is the direct env_* caller for object displacement audio. Audio Manager §6 should note System 7 as the primary env_* caller.
- BONNIE Traversal (6) GDD lists System 7 as a dependent that "reads BONNIE's velocity and collision events." This GDD confirms: BonnieController calls `InteractiveObject.receive_impact(force: Vector2)`.
- NPC Personality (9) references `NpcState.active_stimuli`. System 7 feeds into that array via `object_displaced_stimulus`.

---

## 7. Tuning Knobs

Global knobs live in `assets/data/interactive_object_config.tres`. Per-instance knobs are set in the Godot Inspector.

### Global Knobs

| Knob | Default | Safe Range | Category | Too High | Too Low |
|---|---|---|---|---|---|
| `slide_force_multiplier` | `2.8` | `1.5 – 5.0` | Feel | Objects fly off-screen | Objects barely move; unsatisfying |
| `slide_vertical_kick` | `0.3` | `0.0 – 0.6` | Feel | Objects arc comically high | Objects move only horizontally |
| `run_interaction_threshold` | `220 px/s` | `150 – 320` | Gate | Objects never knocked while running | Objects displaced by walking; loses clarity |
| `run_force_multiplier` | `1.5` | `0.8 – 3.0` | Feel | Run feels as chaotic as slide | Run interactions feel inert |
| `landing_displacement_radius` | `48 px` | `24 – 96` | Gate | Distant objects disrupted by landing | Landing has no environmental impact |
| `landing_base_force` | `900` | `400 – 1600` | Feel | Objects launched from under BONNIE | Landing barely disturbs anything |
| `liquid_spill_delay` | `0.3s` | `0.1 – 0.8` | Feel | Spill sound disconnected from knock | Sounds simultaneous; spill loses comedic beat |
| `liquid_chaos_bonus` | `0.04` | `0.0 – 0.10` | Curve | Liquid containers over-valued | Liquid spill has no added chaos meaning |
| `object_stimulus_multiplier` | `0.6` | `0.2 – 1.5` | Curve | Object falls constantly trigger REACTING | Object falls barely register as NPC stimuli |

### Per-Instance Knobs (Inspector)

| Knob | Default | Range | Notes |
|---|---|---|---|
| `weight_class` | (set per object) | Light / Medium / Heavy / Glass | Drives audio selection and mass factor |
| `chaos_value` | (set per object) | `0.0 – 1.0` | Primary design lever; see §3.8 roster |
| `is_liquid_container` | `false` | bool | Enables liquid spill event + bonus chaos_value |
| `rest_transform` | (scene-authored) | Transform2D | Captured in `_ready()` for reset |

---

## 8. Acceptance Criteria

| ID | Criterion | Pass Condition |
|---|---|---|
| AC-O01 | Objects exist in scene | Zone 9 of TestLevel.tscn contains ≥ 3 InteractiveObject instances |
| AC-O02 | Slide displaces objects | BONNIE in SLIDING contacts InteractiveObject at full slide speed — object visibly moves |
| AC-O03 | Sub-threshold run does not displace | BONNIE at walk_speed (180 px/s) contacts InteractiveObject — object does NOT move |
| AC-O04 | Above-threshold run displaces | BONNIE at run_max_speed (420 px/s) contacts InteractiveObject — object visibly moves |
| AC-O05 | chaos_value signal fires exactly once | Light object knocked over — `object_displaced` emits exactly once, even with further BONNIE contact |
| AC-O06 | Correct audio event plays | Light/Medium knock → `env_object_knock_light` or `env_object_knock_heavy`. Glass knock → `env_glass_break` (not a knock event) |
| AC-O07 | Liquid spill audio fires on delay | Liquid container knocked → knock SFX immediately. `env_liquid_spill` plays ≈ `liquid_spill_delay` seconds later (±0.05s) |
| AC-O08 | Liquid emits two chaos signals | Liquid container knocked → first `object_displaced(chaos_value, ...)` on knock, second `object_displaced(liquid_chaos_bonus, ...)` after `liquid_spill_delay` |
| AC-O09 | ROUGH_LANDING displaces nearby objects | BONNIE triggers ROUGH_LANDING within `landing_displacement_radius` of an object — object receives radial impulse and moves. Object outside radius does not move. |
| AC-O10 | Object cascade works | Object A knocked into Object B (both InteractiveObject RigidBody2D) — Object B moves and emits `object_displaced` |
| AC-O11 | Level reset restores objects | Objects knocked. `reset()` called. All return to rest transform, `displaced` flags false |
| AC-O12 | NPC stimulus received | NPC System connected to `object_displaced_stimulus`. Heavy object knocked near Michael → Michael's `NpcState.active_stimuli` contains entry within one physics frame |
| AC-O13 | No crash with empty landing area | BONNIE ROUGH_LANDING in empty area — no objects within radius — no error, game continues |
| AC-O14 | Landing skid uses RUN formula | Fast landing skid contacts object — force calculated from RUN formula (§4.2), not SLIDE formula (§4.1). Verify by checking force magnitude is smaller than a comparable full-speed slide. |
| AC-O15 | CharacterBody2D explicitly pushes RigidBody2D | Confirmed: without `receive_impact()` call, object does NOT move (default Godot behavior). With the call, it does. The explicit code is the entire mechanism. |

---

## Implementation Notes

**Highest-risk item:** The CharacterBody2D / RigidBody2D push problem (§3.4 and AC-O15). The prototype in `prototypes/bonnie-traversal/` does not yet implement explicit impulse application. Zone 9 objects in TestLevel.tscn are present but do not respond to BONNIE correctly. Production requires:

1. In `BonnieController._handle_sliding()` and `_handle_running()`: after `move_and_slide()`, iterate `get_slide_collision_count()`. For each collision where the collider is an `InteractiveObject`, calculate impulse (§4) and call `collider.receive_impact(impulse)`.

2. `InteractiveObject.receive_impact(force: Vector2)` applies `apply_central_impulse(force)` to its own RigidBody2D body, checks `displaced`, emits signals if first impact, plays audio.

Cross-reference `docs/engine-reference/godot/` before implementation — verify the correct `RigidBody2D` impulse API for Godot 4.6.

---

*Depends on: design/gdd/viewport-config.md, design/gdd/audio-manager.md, design/gdd/bonnie-traversal.md*
*Read by: Chaos Meter (System 13, T-CHAOS pending), design/gdd/npc-personality.md (System 9), design/gdd/level-manager.md (System 5)*
