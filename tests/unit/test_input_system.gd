extends GutTest

var _input_system: Node

func before_each() -> void:
	_input_system = preload("res://src/core/input/InputSystem.gd").new()
	add_child_autoqfree(_input_system)


func test_get_move_vector_no_hardware_is_zero() -> void:
	await wait_process_frames(2)
	assert_eq(_input_system.get_move_vector(), Vector2.ZERO)


func test_auto_sneak_below_threshold() -> void:
	await wait_process_frames(1)
	assert_true(
		_input_system.should_auto_sneak_from_analog(Vector2(0.1, 0.0)),
		"stick magnitude below sneak_threshold should request auto-sneak path"
	)
	assert_false(
		_input_system.should_auto_sneak_from_analog(Vector2.ZERO),
		"no movement must not auto-sneak"
	)
