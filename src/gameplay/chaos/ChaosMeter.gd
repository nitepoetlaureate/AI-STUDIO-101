extends Node

## Chaos Meter (System 13 / S1-15). Aggregates chaos + social fills; exposes [member meter_state] for UI.

const _E := preload("res://src/shared/enums.gd")
const _CONFIG_PATH := "res://assets/data/chaos_meter_config.tres"
const _SOCIAL_CFG_PATH := "res://assets/data/social_system_config.tres"

@export var chaos_meter_config: ChaosMeterConfig

var chaos_fill: float = 0.0
var social_fill: float = 0.0
var meter_value: float = 0.0
var meter_state: int = _E.MeterState.COLD
var feeding_path_type: int = _E.FeedingPathType.NONE_PATH
## Count of registered NPC REACTING chaos contributions this session (FED gate + overwhelm).
var chaos_event_count: int = 0

var _cfg: ChaosMeterConfig
var _social_cfg: SocialSystemConfig
var _level: Node


func _ready() -> void:
	process_priority = 40
	add_to_group(&"chaos_meter")
	_cfg = chaos_meter_config if chaos_meter_config != null else load(_CONFIG_PATH) as ChaosMeterConfig
	if _cfg == null:
		push_error("ChaosMeter: missing config")
		return
	assert(
		is_equal_approx(_cfg.chaos_fill_cap + _cfg.social_fill_weight, 1.0),
		"chaos_fill_cap + social_fill_weight must equal 1.0"
	)
	_social_cfg = load(_SOCIAL_CFG_PATH) as SocialSystemConfig
	_level = get_node_or_null("/root/LevelManager")
	var bus: Node = get_node_or_null("/root/ChaosEventBus")
	if bus != null:
		if bus.has_signal(&"object_chaos_event"):
			bus.connect(&"object_chaos_event", Callable(self, &"_on_object_chaos_event"))
		if bus.has_signal(&"pest_caught"):
			bus.connect(&"pest_caught", Callable(self, &"_on_pest_caught"))


func _process(_delta: float) -> void:
	if _cfg == null:
		return
	_update_social_fill()
	meter_value = clampf(chaos_fill + social_fill, 0.0, 1.0)
	meter_state = _resolve_meter_state()


func register_reacting_chaos_contribution(emotional_at_entry: float, cascade_depth: int) -> void:
	if _cfg == null:
		return
	var depth_i: int = maxi(1, cascade_depth)
	var depth_bonus: float = 1.0 + float(depth_i - 1) * _cfg.cascade_bonus_per_depth
	var contrib: float = emotional_at_entry * _cfg.chaos_event_scale * depth_bonus
	chaos_fill = clampf(chaos_fill + contrib, 0.0, _cfg.chaos_fill_cap)
	chaos_event_count += 1


func chaos_context_met(min_events: int = 2) -> bool:
	return chaos_event_count >= min_events


func _update_social_fill() -> void:
	if _cfg == null or _level == null:
		return
	var n: int = _level.get_active_npc_count()
	if n == 0:
		social_fill = 0.0
		return
	var progress_acc: Array[float] = [0.0]
	_level.foreach_registered_npc(
		func(npc_id: StringName, _npc_node: Node2D, st: NpcState) -> void:
			if st == null:
				return
			var prof: NpcProfile = _level.get_npc_profile(npc_id)
			if prof == null:
				return
			var eff_thresh: float = prof.feeding_threshold
			if st.bonnie_hunger_context and _social_cfg != null:
				eff_thresh -= _social_cfg.hunger_threshold_reduction
			eff_thresh = maxf(eff_thresh, 0.05)
			var gw_prog: float = clampf(st.goodwill / eff_thresh, 0.0, 1.0)
			progress_acc[0] += gw_prog
	)
	var total_progress: float = progress_acc[0]
	var norm: float = clampf(total_progress / float(n), 0.0, 1.0)
	social_fill = norm * _cfg.social_fill_weight


func _resolve_meter_state() -> int:
	if _cfg == null:
		return _E.MeterState.COLD
	var v: float = meter_value
	if v >= _cfg.meter_threshold_tipping:
		return _E.MeterState.FEEDING
	if v >= _cfg.meter_threshold_converging:
		return _E.MeterState.TIPPING
	if v >= _cfg.meter_threshold_hot:
		return _E.MeterState.CONVERGING
	if v >= _cfg.meter_threshold_warming:
		return _E.MeterState.HOT
	if v >= _cfg.meter_threshold_cold:
		return _E.MeterState.WARMING
	return _E.MeterState.COLD


func _on_object_chaos_event(value: float) -> void:
	if _cfg == null:
		return
	chaos_fill = clampf(chaos_fill + value, 0.0, _cfg.chaos_fill_cap)


func _on_pest_caught(_pest_type: int) -> void:
	if _cfg == null:
		return
	var stub_delta: float = 0.015
	chaos_fill = clampf(chaos_fill + stub_delta, 0.0, _cfg.chaos_fill_cap)


func set_feeding_path_for_test(path: int) -> void:
	feeding_path_type = path


## Test / debug readback
func get_chaos_fill_for_test() -> float:
	return chaos_fill


func get_social_fill_for_test() -> float:
	return social_fill


func get_meter_value_for_test() -> float:
	return meter_value
