extends GutTest

const _ChaosMeterScript := preload("res://src/gameplay/chaos/ChaosMeter.gd")


func test_object_chaos_event_increments_chaos_fill() -> void:
	var meter: Node = _ChaosMeterScript.new()
	add_child_autoqfree(meter)
	await wait_process_frames(2)
	var before: float = meter.get_chaos_fill_for_test() as float
	var bus := get_node("/root/ChaosEventBus") as Node
	bus.emit_signal(&"object_chaos_event", 0.02)
	assert_gt(meter.get_chaos_fill_for_test(), before)
	assert_true(meter.get_chaos_fill_for_test() <= 1.0)
