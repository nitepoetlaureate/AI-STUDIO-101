# Line of sight — portals, doors, vents (phased)

**Status:** Stub — full behavior is **not** MVP-blocking for `visible_to_bonnie` **A+C** with static geometry. Aligned with Session 014/015 LOS plan.

## Phase 1 (binary physics)

- **Closed** door / vent cover = solid on blocking layers (`world` / `semisolid` / future `door` layers as configured).
- **Open** = collider removed, gap in physics, or sensor-only — LOS follows physics truth.
- **Ajar:** best-effort via **animation-driven collision** or **secondary shape** until Phase 2.

## Phase 2 (typed LOS)

- Component or node type (working name **`LosDoor`**): opening angle, gap width, optional **multi-sample** rays through opening, **vent louvers**.
- Level tooling integration; mask bits **`door_los`**, **`vent_slats`**, etc., **data-driven** from project config.

## References

- `SESSION-015-PROMPT.md` — MVP mask + extensibility.
- `design/gdd/bonnie-traversal.md` — stimulus and NPC awareness.
- `project.godot` — physics layer names and collision matrix.
