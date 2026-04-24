extends GutTest

const _ChaosMeterScript := preload("res://src/gameplay/chaos/ChaosMeter.gd")


func test_config_invariant_still_holds() -> void:
	var cfg := load("res://assets/data/chaos_meter_config.tres")
	assert_true(is_equal_approx(cfg.chaos_fill_cap + cfg.social_fill_weight, 1.0))


func test_pure_chaos_hits_cap_before_meter_one() -> void:
	var meter: Node = _ChaosMeterScript.new()
	add_child_autoqfree(meter)
	await wait_process_frames(2)
	var bus: Node = get_node("/root/ChaosEventBus") as Node
	for _i in 40:
		bus.emit_signal(&"object_chaos_event", 0.06)
	var cap: float = load("res://assets/data/chaos_meter_config.tres").chaos_fill_cap
	assert_true(is_equal_approx(meter.get_chaos_fill_for_test(), cap))
	await wait_process_frames(1)
	var v: float = meter.get("meter_value") as float
	assert_lt(v, 0.95, "chaos-only should stay below full meter without social axis")


func test_reacting_contribution_increments_chaos_and_counter() -> void:
	var meter: Node = _ChaosMeterScript.new()
	add_child_autoqfree(meter)
	await wait_process_frames(2)
	var before_fill: float = meter.get_chaos_fill_for_test()
	var before_n: int = meter.get("chaos_event_count") as int
	meter.call(&"register_reacting_chaos_contribution", 0.8, 1)
	assert_gt(meter.get_chaos_fill_for_test(), before_fill)
	assert_eq(meter.get("chaos_event_count") as int, before_n + 1)
