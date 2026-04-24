extends GutTest

const _ChaosMeterScript := preload("res://src/gameplay/chaos/ChaosMeter.gd")
const _InteractiveObject := preload("res://src/gameplay/objects/InteractiveObject.gd")


func test_receive_impact_displaces_and_emits_chaos_bus() -> void:
	var obj = _InteractiveObject.new()
	obj.chaos_value = 0.02
	obj.min_impulse_to_displace = 10.0
	add_child_autoqfree(obj)
	var meter: Node = _ChaosMeterScript.new()
	add_child_autoqfree(meter)
	await wait_process_frames(2)
	var before: float = meter.get_chaos_fill_for_test() as float
	var heard: Array = [false]
	obj.object_displaced.connect(func(_v: float, _p: Vector2) -> void:
		heard[0] = true
	)
	obj.receive_impact(Vector2(500.0, 0.0))
	assert_true(heard[0] as bool)
	assert_true(obj.displaced)
	assert_gt(meter.get_chaos_fill_for_test(), before)
