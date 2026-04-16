# System GDD: Level Manager

> **Status**: Approved
> **Author**: Michael Raftery + Hawaii Zeke
> **Last Updated**: 2026-04-13
> **System #**: 5 (Level Manager)
> **Priority**: MVP — Core Layer
> **Implements Pillar**: "Every Space is a Playground" (primary); "Chaos is Comedy, Not Combat" (supporting)

---

## 1. Overview

The Level Manager is the infrastructure node that initializes and owns the runtime context for a single level session of BONNIE!. It is not a gameplay system — it has no state machine, no scoring logic, and no player-facing UI. Its four responsibilities are: (1) define and expose the level's room topology, giving the Camera System the bounds it needs for clamping and giving the NPC System the spatial relationships it needs for cascade attenuation; (2) register all NPC instances at scene load so the Reactive NPC System can resolve cascade targets by room adjacency rather than by direct object reference; (3) fire the correct `AudioManager.play_music()` call on level entry and `stop_music()` on level exit; and (4) maintain a per-room attenuation table so that a cascade stimulus originating in one room is attenuated before it reaches NPCs in a non-adjacent or distant room. MVP scope covers Level 2 (the apartment) only. The Level Manager does not contain logic for any other environment.

---

## 2. Player Fantasy

The player never knows the Level Manager exists. That is its entire purpose.

What the player does experience is this: the apartment feels like a real place. Moving from the living room into the kitchen is not a load screen — BONNIE crosses a threshold, the camera lerps smoothly, and the music hasn't changed in register, just in texture. The apartment's emotional temperature shifts as chaos builds, but it never feels like a mechanic switching on. Michael reacting in the kitchen does not instantly send Christen into crisis in the bedroom — the chaos travels at the speed of a real apartment, and that spatial logic is what makes the cascade feel earned rather than mechanical.

When the NPC system triggers a Domino Rally, it happens because BONNIE was in the right room at the right moment, not because the code lost track of where anyone was standing. The Level Manager is the invisible stage manager — it has set every piece in its correct position before the curtain went up, and it stays out of the way while the scene plays.

---

## 3. Detailed Rules

### 3.1 Level Initialization Sequence

When the Level 2 scene loads, the Level Manager executes the following sequence in order:

1. **Register rooms.** Build the `RoomRegistry` from the scene's `Room` nodes. Each Room node declares its bounding box, its adjacency list, and its attenuation tier.
2. **Register NPCs.** Iterate all NPC nodes in the scene tree. For each NPC, record its `npc_id`, its starting room, and store a reference in the `NpcRegistry`. Emit `npc_registered(npc_id, room_id)` signal.
3. **Clamp camera bounds.** Expose `level_bounds: Rect2` (the bounding box of the full level in world-space pixels) to the Camera System via a readable property.
4. **Start music.** Call `AudioManager.play_music(&"level_02_calm", MUSIC_FADE_IN_SEC)` — apartment starts in the calm mood state.
5. **Emit `level_ready` signal.** All other systems that need post-registration state begin work after this signal.

The sequence is synchronous and completes in the same frame as scene load. No deferred calls are used in steps 1–4.

### 3.2 Room Topology

Level 2 (the apartment) is represented as a directed graph of rooms in four depth tiers. Room nodes are authored in the scene and carry their own bounding boxes and adjacency lists.

**The 7-room apartment graph:**

```
entryway ─── living_room ─── kitchen ─── studio
    │               │               │
    └── bedroom ─── bathroom ─── back_stairs
```

| Room | `room_id` | Tier | Adjacent rooms |
|------|-----------|------|----------------|
| Entryway | `&"entryway"` | 1 | `living_room`, `bedroom` |
| Living Room | `&"living_room"` | 2 | `entryway`, `bedroom`, `kitchen` |
| Bedroom | `&"bedroom"` | 2 | `entryway`, `living_room`, `bathroom` |
| Kitchen | `&"kitchen"` | 3 | `living_room`, `bathroom`, `studio` |
| Bathroom | `&"bathroom"` | 3 | `bedroom`, `kitchen`, `back_stairs` |
| Studio | `&"studio"` | 4 | `kitchen`, `back_stairs` |
| Back Stairs | `&"back_stairs"` | 4 | `bathroom`, `studio` |

Room adjacency is bidirectional — if `entryway` lists `living_room`, the registry enforces the reverse. Attenuation tiers are computed from the room graph at init via BFS — not authored manually (see Section 4.1).

Each `Room` node in the scene carries:

| Property | Type | Description |
|---|---|---|
| `room_id` | `StringName` | Unique identifier per the table above |
| `bounds` | `Rect2` | World-space bounding box. Used by Camera System for anchor positioning. |
| `adjacent_rooms` | `Array[StringName]` | Room IDs sharing a doorway or open passage with this room. |

**Level bounds:** `level_bounds` is the union of all room bounding boxes. Computed once at initialization from the authored `Room` nodes and never changes at runtime. The Camera System reads this property to clamp its position.

### 3.3 NPC Registration

All NPC instances must register with the Level Manager at `_ready()`. No NPC may query for cascade targets by node path or direct scene tree traversal — all NPC-to-NPC queries go through the Level Manager's registry.

**Registration contract:**

```gdscript
# Called by each NPC node in its _ready()
LevelManager.register_npc(npc_id: StringName, npc_node: Node2D, starting_room: StringName) -> void
```

**NPC room tracking:**

When an NPC crosses a room boundary trigger, it calls:

```gdscript
LevelManager.update_npc_room(npc_id: StringName, new_room: StringName) -> void
```

The Level Manager updates the registry and emits `npc_room_changed(npc_id, old_room, new_room)`.

**Cascade target query:**

```gdscript
# Returns all registered NPCs NOT equal to source_npc_id, with their attenuation tier
LevelManager.get_cascade_targets(source_npc_id: StringName) -> Array[CascadeTarget]
```

`CascadeTarget` is a lightweight struct:

```gdscript
class_name CascadeTarget
var npc_id: StringName
var npc_node: Node2D
var attenuation_tier: int   # 0, 1, 2, or 3
```

The NPC System receives this array and applies the cascade formula (Section 4) using the provided tier. It does not compute spatial relationships itself.

### 3.4 Room Transition Triggers

Room boundary crossings are detected by `Area2D` trigger zones at doorways placed in the scene. Each trigger carries `from_room` and `to_room` room IDs.

When BONNIE enters a trigger:
1. The trigger emits `bonnie_entered_room(new_room_id)`.
2. Level Manager receives this signal and updates `bonnie_current_room`.
3. Level Manager emits `room_transition(from_room, to_room)`.
4. Camera System listens for `room_transition` and begins lerping to the new room anchor.

When an NPC crosses a room boundary trigger, the NPC node calls `LevelManager.update_npc_room(npc_id, new_room)`.

Room boundary triggers are authored in the scene. Trigger placement must match the `adjacent_rooms` graph exactly.

### 3.5 Music Management

Level Manager is the authority for music **start** and **stop** in Level 2. Mood transitions (calm → chaotic → dangerous) are driven by the Chaos Meter (System 13), not the Level Manager. The Level Manager starts the music at the calm baseline; subsequent mood changes are dispatched by the Chaos Meter via AudioManager directly.

| Event | Level Manager action |
|---|---|
| Level loads | `AudioManager.play_music(&"level_02_calm", MUSIC_FADE_IN_SEC)` |
| Level exits (any condition) | `AudioManager.stop_music(MUSIC_FADE_OUT_SEC)` |
| Level restarts | `stop_music(0.0)` immediately, then re-init (which calls `play_music(&"level_02_calm")` again) |
| Mood shift during play | **Not Level Manager's responsibility** — Chaos Meter calls `AudioManager.play_music()` with the appropriate mood event ID |

**Music event IDs for Level 2 (mood variants):**

| Event ID | Mood | Trigger |
|---|---|---|
| `level_02_calm` | Calm, cozy — apartment at rest | Level load (initial state) |
| `level_02_chaotic` | Energetic, rising — chaos building | Chaos Meter crosses first threshold (threshold defined in Chaos Meter GDD) |
| `level_02_dangerous` | Urgent, tense — chaos near peak | Chaos Meter crosses second threshold |
| `level_02_other` | TBD — reserved for additional mood states | TBD |

> **Audio Manager dependency note:** The event IDs `level_02_calm`, `level_02_chaotic`, `level_02_dangerous`, and `level_02_other` must be added to the Audio Manager GDD music event catalogue (currently lists only `level_02_apartment`). The Audio Manager GDD must be updated before the music system is implemented.

Music is continuous across all room transitions — walking from entryway to studio does not change the track or mood. Room transitions are spatial; mood is chaos-driven. These are orthogonal axes.

### 3.6 Win Condition and Post-Win Contract

The Level Manager listens for `npc_fed` from the NPC System. On receiving it:

1. Emit `level_complete(fed_by_npc_id: StringName)`.
2. Set `level_active = false`.
3. Do nothing else. Audio, visuals, cutscene, and restart logic are the Feeding Cutscene System's (19) responsibility.

**Full post-win contract (Feeding Cutscene System must implement):**

| Responsibility | Owner |
|---|---|
| Stop music (with or without fade) | Feeding Cutscene System (19) calls `AudioManager.stop_music()` |
| Suppress further NPC audio/reactions | Feeding Cutscene System (19) — disconnects or pauses NPC nodes |
| Play feeding animation | Feeding Cutscene System (19) |
| Play `bonnie_eating` SFX | Feeding Cutscene System (19) |
| Display post-win UI / restart prompt | Feeding Cutscene System (19) |
| Level restart (if player chooses) | Feeding Cutscene System (19) signals back to Level Manager, which triggers scene reload |

Level Manager's guarantee: once `level_complete` fires and `level_active = false`, `get_cascade_targets()` returns an empty array. No further cascade computation occurs. NPC SFX may still fire from already-queued events — Feeding Cutscene System is responsible for quelling these.

### 3.7 Level Manager API Summary

```gdscript
# Signals
signal level_ready
signal npc_registered(npc_id: StringName, room_id: StringName)
signal npc_room_changed(npc_id: StringName, old_room: StringName, new_room: StringName)
signal room_transition(from_room: StringName, to_room: StringName)
signal bonnie_entered_room(room_id: StringName)
signal level_complete(fed_by_npc_id: StringName)

# Properties (read-only to external systems)
var level_bounds: Rect2
var bonnie_current_room: StringName
var level_active: bool

# Methods (called by other systems)
func register_npc(npc_id: StringName, npc_node: Node2D, starting_room: StringName) -> void
func update_npc_room(npc_id: StringName, new_room: StringName) -> void
func get_cascade_targets(source_npc_id: StringName) -> Array[CascadeTarget]
```

---

## 4. Formulas

### 4.1 Room Attenuation Tier Assignment

At initialization, the Level Manager computes the attenuation tier between every pair of rooms using breadth-first search from each room node in the graph.

```
tier(room_A, room_B) = shortest_path_length(room_A, room_B)
```

Where `shortest_path_length` is the number of edges (room-to-room hops), minimum 0 (same room). Tier 3 is the cap — any path longer than 3 hops is also tier 3.

| Tier | Room relationship | Apartment example |
|---|---|---|
| 0 | Same room | Kitchen → Kitchen |
| 1 | Directly adjacent (one doorway) | Kitchen → Living Room |
| 2 | Two hops | Kitchen → Bedroom (via Living Room or Bathroom) |
| 3 | Three+ hops | Entryway → Studio (entryway→living_room→kitchen→studio) |

### 4.2 Cross-Room Cascade Attenuation

When the NPC System calls `get_cascade_targets()`, each target receives an attenuated cascade stimulus:

```
attenuated_stimulus = cascade_stimulus_strength * attenuation_factor(tier)
```

| Tier | `attenuation_factor` | Effect |
|---|---|---|
| 0 | `1.0` | Same room — full cascade strength |
| 1 | `0.5` | Adjacent room — half strength |
| 2 | `0.2` | Two hops — 80% attenuation |
| 3 | `0.0` | Three+ hops — cascade does not cross |

The tier-1 value of `0.5` is consistent with the `room_attenuation_factor` already cited in `npc-personality.md §5`.

**Full cascade formula including attenuation:**

```gdscript
cascade_strength_A = emotional_level_A * cascade_bleed_factor_A
attenuated_strength_B = cascade_strength_A * attenuation_factor(target.attenuation_tier)
emotional_level_B = clamp(emotional_level_B + attenuated_strength_B, 0.0, 1.0)
```

**Example — Michael (kitchen, emotional_level=0.8, cascade_bleed=0.4):**
- `cascade_strength = 0.8 * 0.4 = 0.32`
- Christen in living room (tier 1): `0.32 * 0.5 = 0.16`
- Christen in bedroom (tier 2): `0.32 * 0.2 = 0.064`
- Hypothetical NPC in studio (tier 3 from kitchen → 2 hops = tier 2 actually):

  kitchen→studio = 1 hop (tier 1): `0.32 * 0.5 = 0.16`

The relationship bonus (`+0.2` to `cascade_bleed_factor` for Michael↔Christen, from `npc-personality.md §3.3`) is applied at the source before attenuation:

```
# Michael → Christen with relationship bonus (tier 1):
cascade_strength = 0.8 * (0.4 + 0.2) = 0.48
attenuated = 0.48 * 0.5 = 0.24
```

### 4.3 Level Bounds Computation

```
level_bounds = union of all Room.bounds Rect2 values
```

Computed once at initialization. The Camera System uses this to clamp:

```gdscript
camera_x_min = level_bounds.position.x + 360   # half viewport width (720/2)
camera_x_max = level_bounds.end.x - 360
camera_y_min = level_bounds.position.y + 270   # half viewport height (540/2)
camera_y_max = level_bounds.end.y - 270
```

Guard: if `level_bounds.size.x < 720` or `level_bounds.size.y < 540`, camera centers on `level_bounds` and clamping is disabled for that axis. This guard lives in the Camera System, not the Level Manager.

---

## 5. Edge Cases

**NPC registered with invalid `starting_room`.**
Log error, assign NPC to `&"living_room"` (default). NPC still registers and participates in cascade. This is a scene-authoring bug, not a crash condition.

**BONNIE crosses two room triggers in the same frame.**
First signal accepted; second ignored (BONNIE's room has already changed, trigger's `from_room` no longer matches). Room state resolves once per frame.

**`get_cascade_targets()` called before `level_ready`.**
Returns empty array. `level_active` is false until `level_ready` fires.

**NPC calls `update_npc_room()` with unknown room_id.**
Update rejected; NPC retains last valid room. Error logged.

**All NPCs in same room.**
All targets return tier 0, attenuation factor 1.0. No special case needed.

**NPC changes room mid-cascade (after `get_cascade_targets()` returns but before stimulus applied).**
The tier computed at query time is used — not re-queried. Sub-frame room changes during cascade application are too transient to re-query.

**`level_complete` fires. Further cascade queries occur.**
`level_active = false`. `get_cascade_targets()` returns empty array. Level Manager does not suppress NPC audio — that is Feeding Cutscene System's (19) responsibility per the post-win contract in §3.6.

**Level restarts.**
`AudioManager.stop_music(0.0)` — immediate, no fade. Scene reloads. All registry state clears. Re-initialization runs from §3.1. No explicit reset method needed.

**`level_bounds` smaller than 720×540 viewport.**
Camera System guard handles this (see §4.3). Level Manager reports accurate bounds regardless.

**Two NPCs both call `register_npc()` with the same `npc_id`.**
Second registration overwrites the first. Log warning. This is a scene-authoring error — two NPCs should never share an ID.

---

## 6. Dependencies

### This system depends on

- **Viewport Config (2)** — All room bounds and level bounds are in world-space pixels. Level Manager never uses viewport-relative coordinates. `design/gdd/viewport-config.md`.
- **Audio Manager (3)** — Level Manager calls `AudioManager.play_music()` and `AudioManager.stop_music()`. Never calls `AudioServer` directly. `design/gdd/audio-manager.md`. **Note: Audio Manager GDD must be updated to add mood-variant music event IDs (`level_02_calm`, `level_02_chaotic`, `level_02_dangerous`, `level_02_other`) before music implementation.**

### Systems that depend on this

- **Camera System (4)** — reads `level_bounds: Rect2`; listens to `room_transition` for anchor lerp. `design/gdd/camera-system.md`. *Bidirectional note: camera-system.md §6 should list Level Manager (5) as a dependency.*
- **Reactive NPC System (9)** — calls `register_npc()`, `update_npc_room()`, `get_cascade_targets()`. `design/gdd/npc-personality.md`.
- **Chaos Meter (13)** — calls `AudioManager.play_music()` with mood event IDs during play (Level Manager only calls it at load/exit). Chaos Meter drives mood transitions; Level Manager drives start/stop. *(T-CHAOS GDD pending.)*
- **Feeding Cutscene System (19)** — listens to `level_complete(fed_by_npc_id)`. Owns all post-win behavior per contract in §3.6. *(Not yet designed.)*
- **Interactive Object System (7)** — calls `LevelManager.reset()` (via scene reload, not a direct Level Manager method) on level restart. Level Manager's scene reload clears all object displaced flags implicitly.
- **Nine Lives System (16)**, **Notoriety System (21)**, **Save/Load System (22)** — listed in `systems-index.md` as future dependents. Interface TBD.

**No new circular dependencies introduced.** The NPC ↔ Social System loop resolves via NpcState. Level Manager is queried by NPC System but never calls into NPC System or Social System.

---

## 7. Tuning Knobs

All knobs are exported constants editable in the Godot Inspector. Numeric values live in `assets/data/level_manager_config.tres` — none hardcoded.

| Knob | Default | Safe Range | Category | What it affects | What breaks outside range |
|---|---|---|---|---|---|
| `MUSIC_FADE_IN_SEC` | `0.5` | `0.0 – 3.0` | Gate | Music fade-in duration on level entry | > 3.0: entrance feels too slow |
| `MUSIC_FADE_OUT_SEC` | `1.0` | `0.0 – 5.0` | Gate | Music fade-out on exit or win | > 5.0: silence before cutscene too long |
| `ATTENUATION_TIER_1` | `0.5` | `0.2 – 0.8` | Curve | Cascade strength to adjacent rooms | > 0.8: Domino Rally fires from any room; < 0.2: chain feels broken |
| `ATTENUATION_TIER_2` | `0.2` | `0.0 – 0.5` | Curve | Cascade strength two hops away | > 0.5: cross-apartment cascades too frequent |
| `ATTENUATION_TIER_3` | `0.0` | `0.0 – 0.1` | Curve | Cascade strength three+ hops | Treat as constraint, not tuning — raise only if playtesting shows need |
| `DEFAULT_ROOM_ID` | `&"living_room"` | Level-specific | Gate | Fallback room for invalid NPC starting rooms | Wrong room skews tier-0 cascade assignments |

**Attenuation knob guidance:** If Domino Rally feels too easy (whole apartment triggers from one event), lower `ATTENUATION_TIER_1`. If cross-room cascades feel disconnected (Christen never reacts to kitchen chaos), raise it. `ATTENUATION_TIER_3` at `0.0` is a design constraint — the 7-room apartment means studio-to-entryway cascades would feel unphysical at non-zero bleed.

---

## 8. Acceptance Criteria

**AC-LM01: Initialization completes before any other system queries Level Manager**
- [ ] `level_ready` signal fires before first `_process()` of any NPC node
- [ ] `level_bounds` is non-zero by the time `level_ready` fires
- [ ] `AudioManager.play_music(&"level_02_calm")` called exactly once per level load (verify via console log or AudioManager test hook)

**AC-LM02: NPC registration correct and complete**
- [ ] Both Michael and Christen are in `NpcRegistry` by end of initialization frame
- [ ] Each NPC's starting room matches its authored `starting_room` in the scene
- [ ] `npc_registered` signal fires once per NPC with correct `npc_id` and `room_id`

**AC-LM03: Cascade target query returns correct attenuation tiers**
- [ ] Michael in kitchen, Christen in living room → `get_cascade_targets("michael")` returns Christen with `attenuation_tier = 1`
- [ ] Michael in kitchen, Christen in bedroom → `attenuation_tier = 2`
- [ ] Michael in kitchen, Christen in studio → `attenuation_tier = 1` (kitchen ↔ studio are adjacent)
- [ ] Source NPC excluded from its own cascade target list

**AC-LM04: NPC room updates tracked correctly**
- [ ] Christen calls `update_npc_room(&"christen", &"bedroom")` — subsequent queries reflect new tier
- [ ] `npc_room_changed` fires with correct `old_room` and `new_room`

**AC-LM05: Room transition triggers camera lerp**
- [ ] BONNIE crosses a doorway trigger → `room_transition` fires
- [ ] Camera System begins lerping to new room anchor within same frame
- [ ] No frame drop during transition (60fps maintained — per AC-V04 in viewport-config.md)

**AC-LM06: Level bounds clamp camera correctly**
- [ ] Camera cannot position 720×540 viewport outside `level_bounds` at any of the 7-room boundaries
- [ ] `level_bounds` accessible via Level Manager property read — no scene tree lookup required

**AC-LM07: Win condition triggers correctly**
- [ ] Michael or Christen transitions to FED → `level_complete` fires with correct `fed_by_npc_id`
- [ ] `level_active` is `false` after `level_complete`
- [ ] `get_cascade_targets()` returns empty array after `level_complete`
- [ ] Level Manager does NOT call `AudioManager.stop_music()` — that is Feeding Cutscene System's responsibility

**AC-LM08: Music does not restart on room transitions**
- [ ] BONNIE crosses all 7 room boundaries — `play_music()` called exactly once (at level load)
- [ ] Music plays continuously without interruption across all transitions

**AC-LM09: Cascade attenuation formula validation**
- [ ] Test hook: Michael at `emotional_level=0.8`, `cascade_bleed=0.4`, Christen in adjacent room → Christen receives `+0.16` to emotional_level (±0.001 float tolerance)
- [ ] Same setup, Christen two hops away → `+0.064`
- [ ] Same setup, Christen three hops away → `+0.0`

**AC-LM10: No circular dependency introduced**
- [ ] Level Manager GDScript has no `@onready` reference to NpcPersonality, BidirectionalSocialSystem, or ChaosSystem nodes
- [ ] All Level Manager communication is via signals and defined API methods

**AC-LM11: 7-room graph produces correct BFS tiers**
- [ ] entryway → studio shortest path = 3 hops (entryway→living_room→kitchen→studio) → tier 3
- [ ] kitchen → bathroom = 1 hop → tier 1
- [ ] entryway → back_stairs = 3 hops → tier 3
- [ ] Computed at init; no manual tier authoring needed

---

*Depends on: design/gdd/viewport-config.md, design/gdd/audio-manager.md*
*Read by: design/gdd/camera-system.md, design/gdd/npc-personality.md, (T-CHAOS, System 13), (Feeding Cutscene System, System 19)*
