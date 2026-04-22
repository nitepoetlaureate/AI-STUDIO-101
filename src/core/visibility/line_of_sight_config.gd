extends Resource

## LOS tuning for Session 015 (`SESSION-015-PROMPT.md`). Defaults in `line_of_sight_config.tres`.

@export_group("Query")
## Physics layers the LOS ray collides with (bitmask). Typically world + semisolid + npc.
@export var los_collision_mask: int = 7
@export var origin_slack_px: float = 2.0
@export var segment_end_epsilon_px: float = 0.75

@export_group("Tier B (outer band)")
## R_outer = R * (1 + m).
@export var outer_band_m: float = 0.75
@export var tier_b_n_frames: int = 2
@export var tier_b_dirty_move_px: float = 4.0

@export_group("Fallback anatomy (no NpcProfile)")
@export var default_nose_bridge_local: Vector2 = Vector2(0, -18)
@export var default_chest_from_nose_local: Vector2 = Vector2(0, 24)
