extends Node

## Autoload: System 1 — action map facade and [method get_move_vector] (design/gdd/input-system.md).

const CONFIG_PATH: String = "res://assets/data/input_system_config.tres"

var _config: InputSystemConfig

func _ready() -> void:
	if not ViewportConfig.validate_project_settings():
		if OS.is_debug_build():
			assert(false, "ViewportConfig validation failed — fix project settings before play")
		return

	_config = load(CONFIG_PATH) as InputSystemConfig
	if _config == null:
		push_error("InputSystem: missing %s — using built-in defaults" % CONFIG_PATH)
		_config = InputSystemConfig.new()

	_validate_action_map()
	print_verbose("[InputSystem] ready (viewport validated, config loaded)")


func _validate_action_map() -> void:
	## GDD §3.1 lists 10 actions; sprint S1-04 text says "9" — all named actions must exist.
	var required: PackedStringArray = PackedStringArray([
		"move_left", "move_right", "move_up", "move_down",
		"run", "jump", "sneak", "grab", "zoom", "interact",
	])
	for action: String in required:
		if not InputMap.has_action(action):
			push_error("InputSystem: InputMap missing required action %s" % action)
			if OS.is_debug_build():
				assert(false, "Missing InputMap action: %s" % action)


## Deadzone-normalized move intent for traversal (keyboard + analog).
func get_move_vector() -> Vector2:
	return Input.get_vector(
		&"move_left", &"move_right", &"move_up", &"move_down",
		_config.stick_deadzone
	)


func get_stick_deadzone() -> float:
	return _config.stick_deadzone


func get_sneak_threshold() -> float:
	return _config.sneak_threshold


func get_trigger_deadzone() -> float:
	return _config.trigger_deadzone


## Analog auto-sneak path: stick magnitude below [member InputSystemConfig.sneak_threshold] while moving.
func should_auto_sneak_from_analog(move_vector: Vector2) -> bool:
	var m := move_vector.length()
	return m > 0.0 and m < _config.sneak_threshold
