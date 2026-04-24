extends GutTest

const _BCC := preload("res://src/gameplay/camera/BonnieCameraConfig.gd")
const _E := preload("res://src/shared/enums.gd")
const _MockBonnie := preload("res://tests/unit/helpers/camera_mock_bonnie.gd")
const _BonnieCam := preload("res://src/gameplay/camera/BonnieCamera.gd")


func test_camera_config_loads() -> void:
	var cfg := load("res://assets/data/bonnie_camera_config.tres")
	assert_true(cfg != null and cfg.get_script() == _BCC)
	assert_eq(cfg.look_ahead_walking, 80.0)


func test_camera_leads_horizontally_when_walking_right() -> void:
	var floor_body := StaticBody2D.new()
	var fshape := CollisionShape2D.new()
	var frect := RectangleShape2D.new()
	frect.size = Vector2(2000, 32)
	fshape.shape = frect
	fshape.position = Vector2(0, 40)
	floor_body.add_child(fshape)
	add_child_autoqfree(floor_body)

	var scn := load("res://scenes/gameplay/BonnieController.tscn") as PackedScene
	var bonnie := scn.instantiate() as CharacterBody2D
	bonnie.global_position = Vector2(0, 0)
	add_child_autoqfree(bonnie)
	var cam := bonnie.get_node_or_null("BonnieCamera") as Camera2D
	assert_true(cam != null)
	var start_cam_x := cam.global_position.x
	Input.action_press(&"move_right")
	await wait_physics_frames(25)
	Input.action_release(&"move_right")
	assert_gt(cam.global_position.x, start_cam_x + 20.0, "camera should lerp ahead when moving right")
	assert_gt(cam.global_position.x, bonnie.global_position.x, "look-ahead should place camera ahead of BONNIE while moving right")


func test_lookahead_running_exceeds_walking_on_mock_bonnie() -> void:
	var bonnie := _MockBonnie.new()
	bonnie.global_position = Vector2(100, 0)
	bonnie.velocity = Vector2(200, 0)
	add_child_autoqfree(bonnie)
	var cam := _BonnieCam.new() as Camera2D
	bonnie.add_child(cam)
	bonnie.mock_movement_state = _E.BonnieState.WALKING
	await wait_physics_frames(2)
	var walk_ahead := cam.global_position.x - bonnie.global_position.x
	bonnie.mock_movement_state = _E.BonnieState.RUNNING
	await wait_physics_frames(2)
	var run_ahead := cam.global_position.x - bonnie.global_position.x
	assert_gt(run_ahead, walk_ahead, "RUNNING look-ahead px should exceed WALKING per state table")
