extends GutTest

var _bonnie: CharacterBody2D
var _npc_node: Node2D
var _lm: Node


func before_each() -> void:
	_lm = get_node("/root/LevelManager")
	_lm.unregister_npc(&"gut_bonnie_npc")
	_npc_node = Node2D.new()
	_npc_node.global_position = Vector2(80, 0)
	add_child_autoqfree(_npc_node)
	_lm.register_npc(&"gut_bonnie_npc", _npc_node, &"kitchen", NpcState.create_michael_default())


func after_each() -> void:
	_lm.unregister_npc(&"gut_bonnie_npc")


func test_bonnie_traversal_config_loads_from_tres() -> void:
	var cfg := load("res://assets/data/bonnie_traversal_config.tres") as BonnieTraversalConfig
	assert_true(cfg != null)
	assert_eq(cfg.walk_speed, 180.0)
	assert_eq(cfg.run_stimulus_radius, 220.0)


func test_production_bonnie_scene_physics_smoke() -> void:
	var scn := load("res://scenes/gameplay/BonnieController.tscn") as PackedScene
	_bonnie = scn.instantiate() as CharacterBody2D
	add_child_autoqfree(_bonnie)
	await wait_process_frames(5)
	var script_obj: Object = _bonnie
	assert_true(script_obj.has_method("get_movement_state"))
	var st_id: int = script_obj.call("get_movement_state") as int
	assert_true(st_id >= 0 and st_id < 13, "BonnieState must stay within enum range without floor collision")


func test_idle_stimulus_sets_visible_to_bonnie_within_radius() -> void:
	var scn := load("res://scenes/gameplay/BonnieController.tscn") as PackedScene
	_bonnie = scn.instantiate() as CharacterBody2D
	_bonnie.global_position = Vector2.ZERO
	add_child_autoqfree(_bonnie)
	await wait_process_frames(3)
	var st: NpcState = _lm.get_npc_state(&"gut_bonnie_npc") as NpcState
	assert_true(st.visible_to_bonnie)


func test_idle_stimulus_clears_visibility_beyond_radius() -> void:
	_npc_node.global_position = Vector2(5000, 0)
	var scn := load("res://scenes/gameplay/BonnieController.tscn") as PackedScene
	_bonnie = scn.instantiate() as CharacterBody2D
	_bonnie.global_position = Vector2.ZERO
	add_child_autoqfree(_bonnie)
	await wait_process_frames(3)
	var st: NpcState = _lm.get_npc_state(&"gut_bonnie_npc") as NpcState
	assert_false(st.visible_to_bonnie)


func test_state_changed_emits_on_transition() -> void:
	var scn := load("res://scenes/gameplay/BonnieController.tscn") as PackedScene
	_bonnie = scn.instantiate() as CharacterBody2D
	add_child_autoqfree(_bonnie)
	var log: Array = []
	_bonnie.state_changed.connect(func(old_s: int, new_s: int) -> void:
		log.append([old_s, new_s])
	)
	Input.action_press(&"move_right")
	await wait_process_frames(4)
	Input.action_release(&"move_right")
	assert_gt(log.size(), 0)
