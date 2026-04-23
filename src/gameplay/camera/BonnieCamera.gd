extends Camera2D

## Production follow camera (System 4 / S1-10). Reads parent [CharacterBody2D] + [code]get_movement_state[/code].

const _E := preload("res://src/shared/enums.gd")
const _CONFIG_PATH := "res://assets/data/bonnie_camera_config.tres"

@export var camera_config: Resource

var _bonnie: CharacterBody2D
var _persist_face: float = 1.0
var _last_moving_face: float = 0.0
var _zoom_hold: float = 0.0


func _ready() -> void:
	var p := get_parent()
	_bonnie = p as CharacterBody2D
	if camera_config == null:
		camera_config = load(_CONFIG_PATH) as Resource
	if camera_config == null:
		push_error("BonnieCamera: missing config at %s" % _CONFIG_PATH)
		return
	zoom = Vector2.ONE * camera_config.zoom_normal
	global_position = _bonnie.global_position if _bonnie != null else global_position


func _physics_process(delta: float) -> void:
	if camera_config == null or _bonnie == null:
		return

	_update_zoom(delta)

	var st: int = _E.BonnieState.IDLE
	if _bonnie.has_method(&"get_movement_state"):
		st = _bonnie.call(&"get_movement_state") as int

	var la: float = _lookahead_for_state(st)
	var face := signf(_bonnie.velocity.x)
	if absf(face) < 0.01:
		face = _persist_face
	else:
		_persist_face = face

	la += _ledge_bias_lookahead(st, face)

	var climb_y: float = 0.0
	if st == _E.BonnieState.CLIMBING and _bonnie.velocity.y < 0.0:
		climb_y = camera_config.climb_vertical_lookahead

	var desired := _bonnie.global_position + Vector2(la * face, camera_config.vertical_framing_offset_y + climb_y)

	var moving_face := signf(_bonnie.velocity.x)
	var reversal := false
	if absf(moving_face) > 0.01:
		if absf(_last_moving_face) > 0.01 and signf(moving_face) != signf(_last_moving_face):
			reversal = true
		_last_moving_face = moving_face

	var speed: float = camera_config.camera_catch_up_speed if reversal else camera_config.camera_lerp_speed

	var k := clampf(speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(desired, k)


func _lookahead_for_state(st: int) -> float:
	var cfg: Resource = camera_config
	match st:
		_E.BonnieState.IDLE:
			return cfg.look_ahead_idle
		_E.BonnieState.SNEAKING:
			return cfg.look_ahead_sneaking
		_E.BonnieState.WALKING:
			return cfg.look_ahead_walking
		_E.BonnieState.RUNNING:
			return cfg.look_ahead_running
		_E.BonnieState.SLIDING:
			return cfg.look_ahead_sliding
		_E.BonnieState.JUMPING, _E.BonnieState.FALLING:
			return cfg.look_ahead_jumping_falling
		_E.BonnieState.LANDING:
			return cfg.look_ahead_landing
		_E.BonnieState.CLIMBING:
			return cfg.look_ahead_climbing
		_E.BonnieState.SQUEEZING:
			return cfg.look_ahead_squeezing
		_E.BonnieState.DAZED, _E.BonnieState.ROUGH_LANDING:
			return cfg.look_ahead_dazed_rough
		_E.BonnieState.LEDGE_PULLUP:
			return cfg.look_ahead_ledge_pullup
		_:
			return cfg.look_ahead_walking


func _ledge_bias_lookahead(st: int, face: float) -> float:
	if camera_config == null:
		return 0.0
	if st != _E.BonnieState.JUMPING and st != _E.BonnieState.FALLING:
		return 0.0
	# MVP: bias when moving down (falling) — surface below is more relevant for parry read.
	if _bonnie.velocity.y <= 0.0:
		return 0.0
	if absf(_bonnie.velocity.x) > 10.0:
		return camera_config.ledge_bias_extra_lookahead * signf(face)
	return 0.0


func _update_zoom(delta: float) -> void:
	var cfg := camera_config
	if not InputMap.has_action(&"zoom"):
		return
	if Input.is_action_pressed(&"zoom"):
		_zoom_hold = clampf(_zoom_hold + cfg.zoom_out_rate * delta, 0.0, 1.0)
	else:
		_zoom_hold = maxf(0.0, _zoom_hold - cfg.zoom_return_rate * delta)
	var z := lerpf(cfg.zoom_normal, cfg.zoom_min, _zoom_hold)
	zoom = Vector2.ONE * z
