# Prototype: BONNIE Traversal

**Hypothesis**: BONNIE's 13-state movement system feels like controlling a cat — momentum, clumsiness, commitment to direction, and the Ledge Parry timing window produce the intended "cat physics" fantasy.

**Status**: In Progress

## How to Run

Open `project.godot` in Godot 4.6. The main scene is not yet set — run `TestLevel.tscn` directly (once created) or `BonnieController.tscn` for isolated testing.

## What This Tests

- Ground movement: IDLE, SNEAKING, WALKING, RUNNING speed caps and transitions
- SLIDING: opposing input at speed triggers slide, low friction, pop-jump exit
- Jump system: tap hop vs hold full jump, double jump (apex-locked), coyote time, jump buffer
- Fall tracking: ROUGH_LANDING triggers above 144px fall distance, cushion surfaces reset
- Ledge Parry: frame-exact grab timing near geometry, no auto-grab, no buffer
- CLIMBING: vertical movement on Climbable surfaces, wall jump, auto-clamber at top
- Landing skid: speed-proportional skid at 180px/s threshold, hard skid at 320px/s

## Key Design References

- `design/gdd/bonnie-traversal.md` — canonical movement spec (all tuning values)
- `design/gdd/input-system.md` — action map, buffering rules, analog thresholds
- `design/gdd/camera-system.md` — look-ahead distances per state

## Findings

(Updated when prototype concludes)
