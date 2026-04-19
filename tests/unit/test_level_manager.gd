extends GutTest

var _lm: Node


func before_each() -> void:
	_lm = preload("res://src/core/level/LevelManager.gd").new()
	add_child_autoqfree(_lm)
	_lm.level_config = load("res://assets/data/level_config.tres") as LevelConfig


func test_get_level_chaos_baseline_from_config() -> void:
	assert_eq(_lm.get_level_chaos_baseline(), 0.0)


func test_register_npc_round_trip() -> void:
	var dummy := Node2D.new()
	add_child_autoqfree(dummy)
	var state := NpcState.create_michael_default()
	_lm.register_room(&"kitchen", Rect2(0, 0, 500, 400))
	_lm.register_npc(&"michael", dummy, &"kitchen", state)
	assert_eq(_lm.get_active_npc_count(), 1)
	assert_same(_lm.get_npc_state(&"michael"), state)


func test_get_room_id_at() -> void:
	_lm.register_room(&"kitchen", Rect2(0, 0, 100, 100))
	_lm.register_room(&"living_room", Rect2(200, 0, 100, 100))
	assert_eq(_lm.get_room_id_at(Vector2(50, 50)), &"kitchen")
	assert_eq(_lm.get_room_id_at(Vector2(250, 50)), &"living_room")
	assert_eq(_lm.get_room_id_at(Vector2(999, 999)), &"")


func test_foreach_registered_npc() -> void:
	var n := Node2D.new()
	add_child_autoqfree(n)
	var st := NpcState.create_michael_default()
	_lm.register_npc(&"loop", n, &"kitchen", st)
	var seen: Array = []
	_lm.foreach_registered_npc(func(id: StringName, node: Node2D, s: NpcState) -> void:
		seen.append([id, node, s])
	)
	assert_eq(seen.size(), 1)
	assert_eq(seen[0][0], &"loop")
	assert_same(seen[0][2], st)


func test_unregister_npc_removes_registry() -> void:
	var n := Node2D.new()
	add_child_autoqfree(n)
	_lm.register_npc(&"gone", n, &"kitchen", NpcState.create_michael_default())
	assert_eq(_lm.get_active_npc_count(), 1)
	_lm.unregister_npc(&"gone")
	assert_eq(_lm.get_active_npc_count(), 0)


func test_update_npc_room_signal() -> void:
	var fired: Array = []
	_lm.npc_room_changed.connect(func(id: StringName, old_r: StringName, new_r: StringName) -> void:
		fired.append([id, old_r, new_r])
	)
	var n := Node2D.new()
	add_child_autoqfree(n)
	_lm.register_npc(&"christen", n, &"kitchen", NpcState.create_christen_default())
	_lm.update_npc_room(&"christen", &"living_room")
	assert_eq(fired.size(), 1)
	assert_eq(fired[0][0], &"christen")
	assert_eq(fired[0][2], &"living_room")
