extends RefCounted

## Stateless ray LOS helper. Uses real [PhysicsDirectSpaceState2D] only — no mocked hits.

static func is_segment_clear(
	space: PhysicsDirectSpaceState2D,
	from: Vector2,
	to: Vector2,
	collision_mask: int,
	exclude: Array,
	origin_slack_px: float,
	segment_end_epsilon_px: float,
) -> bool:
	if space == null:
		return false
	var seg: Vector2 = to - from
	var seg_len: float = seg.length()
	if seg_len < 0.0001:
		return true
	var dir: Vector2 = seg / seg_len
	var slack: float = clampf(origin_slack_px, 0.0, seg_len * 0.5)
	var start: Vector2 = from + dir * slack
	var ray_len: float = seg_len - slack
	if ray_len <= 0.0001:
		return true
	var ray_end: Vector2 = start + dir * ray_len
	var q := PhysicsRayQueryParameters2D.create(start, ray_end)
	q.collision_mask = collision_mask
	q.collide_with_areas = false
	q.collide_with_bodies = true
	if exclude.size() > 0:
		q.exclude = exclude
	var hit: Dictionary = space.intersect_ray(q)
	if hit.is_empty():
		return true
	var hit_pos: Vector2 = hit.get("position", Vector2.ZERO) as Vector2
	var hit_along: float = (hit_pos - start).length()
	if hit_along >= ray_len - segment_end_epsilon_px:
		return true
	return false
