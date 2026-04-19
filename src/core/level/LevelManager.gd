extends Node

## Autoload: scene lifecycle, NPC registry (System 5). See `design/gdd/level-manager.md`.

signal npc_registered(npc_id: StringName, room_id: StringName)
signal npc_room_changed(npc_id: StringName, old_room: StringName, new_room: StringName)
signal level_ready

@export var level_config: LevelConfig

var _npc_states: Dictionary = {}
var _npc_nodes: Dictionary = {}
var _npc_rooms: Dictionary = {}
var _room_bounds: Dictionary = {}


func _ready() -> void:
	if level_config == null:
		level_config = load("res://assets/data/level_config.tres") as LevelConfig
	print_verbose("[LevelManager] ready")


func register_room(room_id: StringName, bounds: Rect2) -> void:
	_room_bounds[room_id] = bounds


func register_npc(npc_id: StringName, npc_node: Node2D, starting_room: StringName, state: NpcState) -> void:
	assert(state != null, "register_npc requires NpcState")
	_npc_states[npc_id] = state
	_npc_nodes[npc_id] = npc_node
	_npc_rooms[npc_id] = starting_room
	npc_registered.emit(npc_id, starting_room)


func update_npc_room(npc_id: StringName, new_room: StringName) -> void:
	var old: StringName = _npc_rooms.get(npc_id, &"") as StringName
	_npc_rooms[npc_id] = new_room
	npc_room_changed.emit(npc_id, old, new_room)


func get_npc_state(npc_id: StringName) -> NpcState:
	return _npc_states.get(npc_id, null) as NpcState


func get_active_npc_count() -> int:
	return _npc_states.size()


## Iterates registered NPCs for traversal / awareness (System 6). Callable receives `(npc_id: StringName, npc_node: Node2D, state: NpcState)`.
func foreach_registered_npc(callback: Callable) -> void:
	for npc_id: Variant in _npc_states.keys():
		var st: NpcState = _npc_states[npc_id] as NpcState
		var n: Node2D = _npc_nodes.get(npc_id, null) as Node2D
		callback.call(npc_id as StringName, n, st)


func unregister_npc(npc_id: StringName) -> void:
	_npc_states.erase(npc_id)
	_npc_nodes.erase(npc_id)
	_npc_rooms.erase(npc_id)


func get_room_id_at(world_pos: Vector2) -> StringName:
	for rid: Variant in _room_bounds.keys():
		var rect: Rect2 = _room_bounds[rid] as Rect2
		if rect.has_point(world_pos):
			return rid as StringName
	return &""


func get_level_chaos_baseline() -> float:
	if level_config == null:
		return 0.0
	return level_config.level_chaos_baseline


func notify_level_ready() -> void:
	level_ready.emit()
