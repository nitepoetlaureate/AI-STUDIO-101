extends Node

## Autoload: scene lifecycle, NPC registry (System 5). See `design/gdd/level-manager.md`.
## Session 015: LOS pass (A+C) + `VisibilityLedger`; syncs `NpcState.visible_to_bonnie`.

signal npc_registered(npc_id: StringName, room_id: StringName)
signal npc_room_changed(npc_id: StringName, old_room: StringName, new_room: StringName)
signal level_ready

const _LOS_CONFIG_PATH := "res://assets/data/line_of_sight_config.tres"
const _LineOfSightEvaluator := preload("res://src/core/visibility/line_of_sight_evaluator.gd")
const _VisibilityLedger := preload("res://src/core/visibility/visibility_ledger.gd")

@export var level_config: LevelConfig
@export var line_of_sight_config: Resource

var _npc_states: Dictionary = {}
var _npc_nodes: Dictionary = {}
var _npc_rooms: Dictionary = {}
var _npc_profiles: Dictionary = {}
var _room_bounds: Dictionary = {}

var _visibility_ledger: RefCounted = null
var _los_physics_counter: int = 0
var _los_bonnie_stimulus_connected: bool = false
var _los_last_bonnie_pos: Vector2 = Vector2.ZERO
var _los_last_npc_pos: Dictionary = {}
var _los_force_refresh: bool = true


func _ready() -> void:
	if level_config == null:
		level_config = load("res://assets/data/level_config.tres") as LevelConfig
	if line_of_sight_config == null:
		line_of_sight_config = load(_LOS_CONFIG_PATH) as Resource
	_visibility_ledger = _VisibilityLedger.new()
	print_verbose("[LevelManager] ready")


func _physics_process(_delta: float) -> void:
	_run_los_visibility_pass()


func register_room(room_id: StringName, bounds: Rect2) -> void:
	_room_bounds[room_id] = bounds


func register_npc(
	npc_id: StringName,
	npc_node: Node2D,
	starting_room: StringName,
	state: NpcState,
	profile: NpcProfile = null,
) -> void:
	assert(state != null, "register_npc requires NpcState")
	_npc_states[npc_id] = state
	_npc_nodes[npc_id] = npc_node
	_npc_rooms[npc_id] = starting_room
	if profile != null:
		_npc_profiles[npc_id] = profile
	elif not _npc_profiles.has(npc_id):
		var loaded := _try_load_npc_profile(npc_id)
		if loaded != null:
			_npc_profiles[npc_id] = loaded
	npc_registered.emit(npc_id, starting_room)


func update_npc_room(npc_id: StringName, new_room: StringName) -> void:
	var old: StringName = _npc_rooms.get(npc_id, &"") as StringName
	_npc_rooms[npc_id] = new_room
	npc_room_changed.emit(npc_id, old, new_room)


func get_npc_state(npc_id: StringName) -> NpcState:
	return _npc_states.get(npc_id, null) as NpcState


func get_active_npc_count() -> int:
	return _npc_states.size()


func get_visibility_ledger() -> RefCounted:
	return _visibility_ledger


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
	_npc_profiles.erase(npc_id)
	_los_last_npc_pos.erase(npc_id)
	if _visibility_ledger != null:
		_visibility_ledger.set_visible(npc_id, false)


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


## Call when stimulus radius changes outside `_physics_process` if needed (Bonnie also drives via signal).
func notify_bonnie_stimulus_changed() -> void:
	_los_force_refresh = true


func _try_load_npc_profile(npc_id: StringName) -> NpcProfile:
	var path := "res://assets/data/npc/%s_profile.tres" % String(npc_id)
	if ResourceLoader.exists(path):
		return load(path) as NpcProfile
	return null


func _run_los_visibility_pass() -> void:
	var cfg: Resource = line_of_sight_config
	if cfg == null:
		return
	var bonnie := get_tree().get_first_node_in_group("bonnie") as CharacterBody2D
	if bonnie == null or not bonnie.is_inside_tree():
		return
	_ensure_bonnie_stimulus_connected(bonnie)
	var viewport := get_viewport()
	if viewport == null:
		return
	var space := viewport.world_2d.direct_space_state
	if space == null:
		return
	if not bonnie.has_method(&"get_current_stimulus_radius"):
		return
	var R: float = bonnie.call(&"get_current_stimulus_radius") as float
	if R < 0.0:
		return
	_los_physics_counter += 1
	var m: float = cfg.get("outer_band_m") as float
	var R_outer: float = R * (1.0 + m)
	var N: int = maxi(1, cfg.get("tier_b_n_frames") as int)
	var tier_b_tick: bool = (_los_physics_counter % N) == 0
	var dirty_px: float = cfg.get("tier_b_dirty_move_px") as float
	var bonnie_anchor: Vector2 = bonnie.global_position
	var bonnie_moved: bool = (
		_los_force_refresh
		or bonnie_anchor.distance_to(_los_last_bonnie_pos) >= dirty_px
	)
	_los_last_bonnie_pos = bonnie_anchor
	var exclude: Array = []
	exclude.append(bonnie.get_rid())
	for npc_id: Variant in _npc_states.keys():
		var idsn := npc_id as StringName
		var npc_node: Node2D = _npc_nodes.get(idsn, null) as Node2D
		var st: NpcState = _npc_states[idsn] as NpcState
		if st == null:
			continue
		if npc_node == null or not is_instance_valid(npc_node) or not npc_node.is_inside_tree():
			_visibility_ledger.set_visible(idsn, false)
			st.visible_to_bonnie = false
			_los_last_npc_pos.erase(idsn)
			continue
		var d_root: float = bonnie_anchor.distance_to(npc_node.global_position)
		if d_root > R_outer:
			_visibility_ledger.set_visible(idsn, false)
			st.visible_to_bonnie = false
			_los_last_npc_pos.erase(idsn)
			continue
		# Tier B: outside stimulus disc but inside outer band — A fails; no LOS casts (§5 early-out).
		if d_root > R:
			var last_np_b: Vector2 = _los_last_npc_pos.get(idsn, npc_node.global_position) as Vector2
			var npc_moved_b: bool = npc_node.global_position.distance_to(last_np_b) >= dirty_px
			if not tier_b_tick and not bonnie_moved and not npc_moved_b and not _los_force_refresh:
				if st.visible_to_bonnie or _visibility_ledger.get_visible(idsn):
					_visibility_ledger.set_visible(idsn, false)
					st.visible_to_bonnie = false
				continue
			_visibility_ledger.set_visible(idsn, false)
			st.visible_to_bonnie = false
			_los_last_npc_pos[idsn] = npc_node.global_position
			continue
		# Tier A: in radius — distance (A) + high-primary LOS (C).
		var visible: bool = _los_ray_visible(bonnie, npc_node, idsn, space, cfg, exclude)
		_visibility_ledger.set_visible(idsn, visible)
		st.visible_to_bonnie = visible
		_los_last_npc_pos[idsn] = npc_node.global_position
	_los_force_refresh = false


func _los_ray_visible(
	bonnie: CharacterBody2D,
	npc_node: Node2D,
	npc_id: StringName,
	space: PhysicsDirectSpaceState2D,
	cfg: Resource,
	exclude: Array,
) -> bool:
	if not bonnie.has_method(&"get_los_high_global"):
		return false
	var from_high: Vector2 = bonnie.call(&"get_los_high_global") as Vector2
	var chest: Vector2 = _get_npc_chest_global(npc_node, npc_id, cfg)
	return _LineOfSightEvaluator.is_segment_clear(
		space,
		from_high,
		chest,
		cfg.get("los_collision_mask") as int,
		exclude,
		cfg.get("origin_slack_px") as float,
		cfg.get("segment_end_epsilon_px") as float,
	)


func _get_npc_chest_global(npc_node: Node2D, npc_id: StringName, cfg: Resource) -> Vector2:
	var nose: Vector2 = cfg.get("default_nose_bridge_local") as Vector2
	var chest_off: Vector2 = cfg.get("default_chest_from_nose_local") as Vector2
	var prof: NpcProfile = _npc_profiles.get(npc_id, null) as NpcProfile
	if prof != null:
		nose = prof.los_nose_bridge_local
		chest_off = prof.los_chest_from_nose_local
	return npc_node.to_global(nose + chest_off)


func _ensure_bonnie_stimulus_connected(bonnie: Node) -> void:
	if _los_bonnie_stimulus_connected:
		return
	if bonnie.has_signal("stimulus_radius_updated"):
		bonnie.stimulus_radius_updated.connect(_on_bonnie_stimulus_radius_updated)
		_los_bonnie_stimulus_connected = true


func _on_bonnie_stimulus_radius_updated(_radius: float) -> void:
	_los_force_refresh = true
