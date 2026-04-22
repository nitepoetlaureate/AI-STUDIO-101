extends GutTest

const _Eval := preload("res://src/core/visibility/line_of_sight_evaluator.gd")


func test_segment_clear_in_open_space() -> void:
	var root := Node2D.new()
	add_child_autoqfree(root)
	await wait_physics_frames(3)
	var space: PhysicsDirectSpaceState2D = root.get_world_2d().direct_space_state
	var ok: bool = _Eval.is_segment_clear(
		space,
		Vector2(0, 0),
		Vector2(256, 0),
		7,
		[],
		2.0,
		0.75,
	)
	assert_true(ok)


func test_wall_blocks_segment() -> void:
	var root := Node2D.new()
	add_child_autoqfree(root)
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.position = Vector2(96, 0)
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 200)
	cs.shape = rect
	wall.add_child(cs)
	root.add_child(wall)
	await wait_physics_frames(3)
	var space: PhysicsDirectSpaceState2D = root.get_world_2d().direct_space_state
	var blocked: bool = not _Eval.is_segment_clear(
		space,
		Vector2(0, 0),
		Vector2(256, 0),
		7,
		[],
		2.0,
		0.75,
	)
	assert_true(blocked)


func test_exclude_body_skips_self_hit() -> void:
	var root := Node2D.new()
	add_child_autoqfree(root)
	var body := CharacterBody2D.new()
	body.collision_layer = 1
	var cs := CollisionShape2D.new()
	var cap := CapsuleShape2D.new()
	cap.radius = 8.0
	cap.height = 24.0
	cs.shape = cap
	body.add_child(cs)
	body.position = Vector2(0, 0)
	root.add_child(body)
	await wait_physics_frames(3)
	var space: PhysicsDirectSpaceState2D = root.get_world_2d().direct_space_state
	var ex: Array = [body.get_rid()]
	var ok: bool = _Eval.is_segment_clear(
		space,
		Vector2(0, 0),
		Vector2(400, 0),
		7,
		ex,
		2.0,
		0.75,
	)
	assert_true(ok)
