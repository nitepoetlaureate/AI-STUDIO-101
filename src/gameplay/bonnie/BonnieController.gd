extends CharacterBody2D

## Production BONNIE traversal (System 6). S1-09.
## Does not declare [code]class_name BonnieController[/code] while the prototype
## ([code]prototypes/bonnie-traversal/BonnieController.gd[/code]) still owns that global class.

const _E := preload("res://src/shared/enums.gd")
const _CONFIG_PATH := "res://assets/data/bonnie_traversal_config.tres"

signal state_changed(old_state: int, new_state: int)
signal stimulus_radius_updated(radius: float)

@export var traversal_config: BonnieTraversalConfig

@onready var _ceiling_cast: RayCast2D = $CeilingCast as RayCast2D

## Cached autoloads — avoids global identifiers for static tooling ([code]gdcli script lint[/code]).
var _level_manager: Node = null
var _input_system: Node = null

var _state: int = _E.BonnieState.IDLE
var _last_stimulus_radius: float = -1.0
var _landing_timer: float = 0.0
var _stub_timer: float = 0.0
var _recovery_timer: float = 0.0
var _airborne_start_y: float = 0.0
var _was_on_floor: bool = true
var _jump_held_frames: int = 0


func _ready() -> void:
	process_priority = -20
	if traversal_config == null:
		traversal_config = load(_CONFIG_PATH) as BonnieTraversalConfig
	if traversal_config == null:
		push_error("BonnieController: failed to load %s" % _CONFIG_PATH)
		return
	_level_manager = get_node_or_null("/root/LevelManager")
	_input_system = get_node_or_null("/root/InputSystem")
	_emit_stimulus_if_changed(_compute_stimulus_radius(), true)


func _set_state(next: int) -> void:
	if next == _state:
		return
	var old := _state
	_state = next
	state_changed.emit(old, next)
	_emit_stimulus_if_changed(_compute_stimulus_radius(), false)


func _compute_stimulus_radius() -> float:
	var cfg := traversal_config
	if cfg == null:
		return 0.0
	match _state:
		_E.BonnieState.IDLE, _E.BonnieState.DAZED, _E.BonnieState.ROUGH_LANDING:
			return cfg.idle_stimulus_radius
		_E.BonnieState.SNEAKING, _E.BonnieState.SQUEEZING, _E.BonnieState.CLIMBING:
			return cfg.sneak_stimulus_radius
		_E.BonnieState.WALKING, _E.BonnieState.LANDING, _E.BonnieState.LEDGE_PULLUP:
			return cfg.walk_stimulus_radius
		_E.BonnieState.RUNNING:
			return cfg.run_stimulus_radius
		_E.BonnieState.SLIDING:
			return cfg.run_stimulus_radius + cfg.slide_stimulus_bonus
		_E.BonnieState.JUMPING, _E.BonnieState.FALLING:
			return cfg.walk_stimulus_radius
		_:
			return cfg.walk_stimulus_radius


func _emit_stimulus_if_changed(radius: float, force: bool) -> void:
	if force or not is_equal_approx(radius, _last_stimulus_radius):
		_last_stimulus_radius = radius
		stimulus_radius_updated.emit(radius)
		_apply_npc_visibility(radius)


func _apply_npc_visibility(radius: float) -> void:
	if _level_manager == null or not _level_manager.has_method(&"foreach_registered_npc"):
		return
	var self_pos := global_position
	_level_manager.call(
		&"foreach_registered_npc",
		func(_id: StringName, node: Node2D, st: NpcState) -> void:
			if st == null:
				return
			if node == null or not is_instance_valid(node):
				st.visible_to_bonnie = false
				return
			st.visible_to_bonnie = self_pos.distance_to(node.global_position) <= radius
	)


func _physics_process(delta: float) -> void:
	var cfg := traversal_config
	if cfg == null:
		return

	var was_on_floor := is_on_floor()

	match _state:
		_E.BonnieState.DAZED, _E.BonnieState.ROUGH_LANDING:
			_physics_recovery(delta, cfg)
			_was_on_floor = is_on_floor()
			return
		_E.BonnieState.LEDGE_PULLUP:
			_physics_ledge_pullup(delta, cfg)
			move_and_slide()
			_was_on_floor = is_on_floor()
			return
		_E.BonnieState.CLIMBING:
			_physics_climbing(delta, cfg)
			move_and_slide()
			_was_on_floor = is_on_floor()
			return

	if _state == _E.BonnieState.LANDING:
		_physics_landing_skid(delta, cfg)
		var pre_vx_l := velocity.x
		move_and_slide()
		_try_wall_slide_daze(cfg, pre_vx_l)
		_was_on_floor = is_on_floor()
		return

	if _input_system == null or not _input_system.has_method(&"get_move_vector"):
		move_and_slide()
		_was_on_floor = is_on_floor()
		return
	var move_vec: Vector2 = _input_system.call(&"get_move_vector") as Vector2
	var sneak_btn := Input.is_action_pressed(&"sneak")
	var run_btn := Input.is_action_pressed(&"run")
	var auto_sneak: bool = _input_system.call(&"should_auto_sneak_from_analog", move_vec) as bool
	var sneak_on := sneak_btn or auto_sneak

	if was_on_floor:
		_physics_ground_bundle(delta, cfg, move_vec, sneak_on, run_btn)
	else:
		_physics_air(delta, cfg, move_vec, sneak_on, run_btn)

	var pre_vx := velocity.x
	move_and_slide()
	_try_wall_slide_daze(cfg, pre_vx)

	if is_on_floor() and not was_on_floor:
		_on_touch_down(cfg, move_vec, sneak_on, run_btn)
	elif not is_on_floor() and was_on_floor:
		_airborne_start_y = global_position.y

	_try_air_state_labels(cfg)
	_try_climb_entry(cfg, move_vec)
	_try_ledge_pullup_entry(cfg)
	_was_on_floor = is_on_floor()


func _physics_recovery(delta: float, cfg: BonnieTraversalConfig) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	_recovery_timer -= delta
	if _recovery_timer <= 0.0:
		_set_state(_E.BonnieState.IDLE)


func _physics_ledge_pullup(delta: float, _cfg: BonnieTraversalConfig) -> void:
	velocity = Vector2.ZERO
	_stub_timer -= delta
	if _stub_timer <= 0.0:
		_set_state(_E.BonnieState.WALKING)


func _physics_climbing(delta: float, cfg: BonnieTraversalConfig) -> void:
	velocity.x = move_toward(velocity.x, 0.0, cfg.ground_deceleration * delta)
	velocity.y = move_toward(velocity.y, -cfg.climb_speed, cfg.gravity * delta * cfg.climb_vertical_lerp_scale)
	if is_on_floor():
		_set_state(_E.BonnieState.WALKING)
	elif not is_on_wall():
		_set_state(_E.BonnieState.FALLING)


func _physics_landing_skid(delta: float, cfg: BonnieTraversalConfig) -> void:
	velocity.y = 0.0
	var skid_mul: float = 1.0 + absf(velocity.x) / maxf(cfg.skid_threshold, 1.0)
	velocity.x = move_toward(velocity.x, 0.0, cfg.ground_deceleration * skid_mul * delta)
	_landing_timer -= delta
	if _landing_timer <= 0.0:
		_set_state(_E.BonnieState.IDLE)


func _physics_air(delta: float, cfg: BonnieTraversalConfig, move_vec: Vector2, sneak_on: bool, run_btn: bool) -> void:
	velocity.y = minf(velocity.y + cfg.gravity * delta, cfg.fall_velocity_max)
	var air_force := cfg.air_control_force
	if sneak_on:
		air_force *= cfg.sneak_air_control_scale
	var target_x := velocity.x + signf(move_vec.x) * air_force * delta
	var max_x := cfg.run_max_speed if run_btn else cfg.walk_speed
	if absf(target_x) > max_x:
		target_x = signf(target_x) * max_x
	velocity.x = move_toward(velocity.x, target_x, air_force * delta)

	if Input.is_action_just_pressed(&"jump"):
		if sneak_on:
			velocity.y = -cfg.hop_velocity
		else:
			velocity.y = -cfg.jump_velocity

	if Input.is_action_pressed(&"jump"):
		_jump_held_frames = mini(_jump_held_frames + 1, cfg.jump_hold_max_frames)
		if not sneak_on and _jump_held_frames <= cfg.jump_hold_add_frames:
			velocity.y -= cfg.gravity * delta * cfg.jump_hold_gravity_scale
	else:
		_jump_held_frames = 0


func _physics_ground_bundle(delta: float, cfg: BonnieTraversalConfig, move_vec: Vector2, sneak_on: bool, run_btn: bool) -> void:
	velocity.y = 0.0
	var squeeze := _ceiling_cast != null and _ceiling_cast.is_colliding() and absf(move_vec.x) > cfg.squeeze_input_threshold
	if squeeze:
		if _state != _E.BonnieState.SQUEEZING:
			_set_state(_E.BonnieState.SQUEEZING)
		_apply_ground_move(delta, cfg, move_vec, sneak_on, run_btn, cfg.squeeze_speed)
	elif _state == _E.BonnieState.SQUEEZING:
		_set_state(_E.BonnieState.WALKING)
		_apply_ground_move(delta, cfg, move_vec, sneak_on, run_btn, null)
	elif _state == _E.BonnieState.SLIDING:
		_physics_sliding(delta, cfg, move_vec)
	else:
		_try_slide_enter(cfg, move_vec, run_btn)
		if _state == _E.BonnieState.SLIDING:
			_physics_sliding(delta, cfg, move_vec)
		else:
			_apply_ground_move(delta, cfg, move_vec, sneak_on, run_btn, null)

	var jumped := false
	if Input.is_action_just_pressed(&"jump"):
		jumped = true
		velocity.y = -cfg.hop_velocity if sneak_on else -cfg.jump_velocity
		_set_state(_E.BonnieState.JUMPING)

	if not jumped:
		_resolve_ground_locomotion_state(move_vec, sneak_on, run_btn, squeeze)


func _apply_ground_move(delta: float, cfg: BonnieTraversalConfig, move_vec: Vector2, sneak_on: bool, run_btn: bool, cap: Variant) -> void:
	var target_speed := 0.0
	var input_x := move_vec.x
	if absf(input_x) > 0.0:
		var cap_speed: float
		if cap != null:
			cap_speed = cap as float
		elif sneak_on:
			cap_speed = cfg.sneak_max_speed
		elif run_btn:
			cap_speed = cfg.run_max_speed
		else:
			cap_speed = cfg.walk_speed
		target_speed = signf(input_x) * cap_speed
	var accel := cfg.ground_acceleration if absf(target_speed) > absf(velocity.x) else cfg.ground_deceleration
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)


func _try_slide_enter(cfg: BonnieTraversalConfig, move_vec: Vector2, run_btn: bool) -> void:
	if not run_btn:
		return
	if absf(velocity.x) < cfg.slide_trigger_speed:
		return
	if signf(move_vec.x) == 0.0:
		return
	if signf(move_vec.x) != signf(velocity.x):
		_set_state(_E.BonnieState.SLIDING)


func _physics_sliding(delta: float, cfg: BonnieTraversalConfig, move_vec: Vector2) -> void:
	velocity.y = 0.0
	velocity.x = move_toward(velocity.x, 0.0, cfg.slide_friction * delta)
	var steer := signf(move_vec.x) * cfg.slide_steer_force * delta
	velocity.x += steer
	if absf(velocity.x) < cfg.walk_speed * cfg.slide_exit_speed_fraction:
		_set_state(_E.BonnieState.WALKING)


func _resolve_ground_locomotion_state(move_vec: Vector2, sneak_on: bool, run_btn: bool, squeeze: bool) -> void:
	if squeeze:
		return
	if _state == _E.BonnieState.SLIDING or _state == _E.BonnieState.LANDING:
		return
	var moving := absf(move_vec.x) > 0.0
	if not moving:
		_set_state(_E.BonnieState.IDLE)
	elif sneak_on:
		_set_state(_E.BonnieState.SNEAKING)
	elif run_btn:
		_set_state(_E.BonnieState.RUNNING)
	else:
		_set_state(_E.BonnieState.WALKING)


func _on_touch_down(cfg: BonnieTraversalConfig, move_vec: Vector2, sneak_on: bool, run_btn: bool) -> void:
	var fall_dist := global_position.y - _airborne_start_y
	if fall_dist >= cfg.rough_landing_threshold:
		_set_state(_E.BonnieState.ROUGH_LANDING)
		_recovery_timer = cfg.rough_landing_duration
		velocity = Vector2.ZERO
		return
	var hs := absf(velocity.x)
	if hs >= cfg.skid_threshold:
		_set_state(_E.BonnieState.LANDING)
		var t := remap(hs, cfg.skid_threshold, cfg.run_max_speed, cfg.landing_skid_time_min, cfg.landing_skid_time_max)
		_landing_timer = clampf(t, cfg.landing_skid_time_min, cfg.landing_skid_time_max)
	else:
		_resolve_ground_locomotion_state(move_vec, sneak_on, run_btn, false)


func _try_air_state_labels(_cfg: BonnieTraversalConfig) -> void:
	if is_on_floor():
		return
	if _state in [_E.BonnieState.DAZED, _E.BonnieState.ROUGH_LANDING, _E.BonnieState.LANDING, _E.BonnieState.LEDGE_PULLUP, _E.BonnieState.CLIMBING]:
		return
	if velocity.y < 0.0:
		_set_state(_E.BonnieState.JUMPING)
	else:
		_set_state(_E.BonnieState.FALLING)


func _try_climb_entry(cfg: BonnieTraversalConfig, move_vec: Vector2) -> void:
	if is_on_floor() or not is_on_wall():
		return
	if not Input.is_action_pressed(&"grab"):
		return
	if move_vec.y >= -cfg.climb_grab_vertical_threshold:
		return
	if _state in [_E.BonnieState.CLIMBING, _E.BonnieState.ROUGH_LANDING, _E.BonnieState.DAZED, _E.BonnieState.LANDING]:
		return
	_set_state(_E.BonnieState.CLIMBING)


func _try_ledge_pullup_entry(cfg: BonnieTraversalConfig) -> void:
	if is_on_floor():
		return
	if not is_on_wall():
		return
	if not Input.is_action_just_pressed(&"grab"):
		return
	if _state in [_E.BonnieState.CLIMBING, _E.BonnieState.LEDGE_PULLUP, _E.BonnieState.DAZED, _E.BonnieState.ROUGH_LANDING]:
		return
	_set_state(_E.BonnieState.LEDGE_PULLUP)
	_stub_timer = cfg.ledge_pullup_duration


func _try_wall_slide_daze(cfg: BonnieTraversalConfig, pre_collision_horizontal_speed: float) -> void:
	if _state != _E.BonnieState.SLIDING:
		return
	if not is_on_wall():
		return
	if absf(pre_collision_horizontal_speed) < cfg.daze_collision_threshold:
		velocity.x = 0.0
		_set_state(_E.BonnieState.IDLE)
		return
	_set_state(_E.BonnieState.DAZED)
	_recovery_timer = cfg.daze_duration


func get_movement_state() -> int:
	return _state
