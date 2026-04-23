extends Node

## Chaos Meter aggregation (System 13). S1-14: subscribes to [ChaosEventBus] for [signal object_chaos_event].

const _CONFIG_PATH := "res://assets/data/chaos_meter_config.tres"

var _cfg: ChaosMeterConfig
var _chaos_fill: float = 0.0


func _ready() -> void:
	_cfg = load(_CONFIG_PATH) as ChaosMeterConfig
	if _cfg == null:
		push_error("ChaosMeter: failed to load %s" % _CONFIG_PATH)
		return
	var bus := get_node_or_null("/root/ChaosEventBus")
	if bus != null and bus.has_signal(&"object_chaos_event"):
		bus.connect(&"object_chaos_event", Callable(self, &"_on_object_chaos_event"))


func _on_object_chaos_event(value: float) -> void:
	if _cfg == null:
		return
	_chaos_fill = clampf(_chaos_fill + value, 0.0, _cfg.chaos_fill_cap)


## Test-only readback for GUT (S1-14).
func get_chaos_fill_for_test() -> float:
	return _chaos_fill
