class_name NpcController
extends Node

## Reactive NPC state machine (System 9 / S1-11). One instance per NPC; reads [NpcProfile] from [LevelManager].

const _E := preload("res://src/shared/enums.gd")

@export var npc_id: StringName = &"michael"

const REACTING_DURATION: float = 1.6
const RECOVERING_DURATION: float = 2.0
const CASCADE_BLEED: float = 0.35
const MIN_FEED_CHAOS_EVENTS: int = 2

var _level: Node
var _meter: Node
var _reacting_timer: float = 0.0
var _recovering_timer: float = 0.0
var _emotion_at_reacting_entry: float = 0.0


func _ready() -> void:
	process_priority = 20
	add_to_group(&"npc_controller")
	_level = get_node_or_null("/root/LevelManager")
	call_deferred(&"_resolve_meter")


func _resolve_meter() -> void:
	var tree := get_tree()
	if tree != null:
		_meter = tree.get_first_node_in_group(&"chaos_meter")


func _physics_process(delta: float) -> void:
	if _level == null:
		return
	var st: NpcState = _level.get_npc_state(npc_id)
	var prof: NpcProfile = _level.get_npc_profile(npc_id)
	if st == null or prof == null:
		return

	_tick_emotional_decay(st, prof, delta)
	_tick_goodwill_decay(st, prof, delta)
	_tick_comfort_receptivity(st, prof, delta)
	_tick_timers(st, prof, delta)
	_try_fed_and_overwhelm(st, prof)


## External: emotional spike (stimulus, cascade from another NPC, object chaos).
func apply_emotional_spike(amount: float, _source_id: StringName, react_cascade_depth: int = 1) -> void:
	if _level == null:
		return
	var st: NpcState = _level.get_npc_state(npc_id)
	if st == null:
		return
	st.emotional_level = clampf(st.emotional_level + amount, 0.0, 1.0)
	var prof: NpcProfile = _level.get_npc_profile(npc_id)
	if prof == null:
		return
	var skip_react: Array = [
		_E.NpcBehavior.REACTING,
		_E.NpcBehavior.FED,
		_E.NpcBehavior.ASLEEP,
		_E.NpcBehavior.FLEEING,
	]
	if st.emotional_level >= prof.reaction_threshold and not skip_react.has(st.current_behavior):
		_enter_reacting(st, prof, react_cascade_depth)


func apply_cascade_from(origin_id: StringName, origin_emotional: float) -> void:
	if origin_id == npc_id:
		return
	var st: NpcState = _level.get_npc_state(npc_id) if _level != null else null
	if st == null:
		return
	var bleed: float = clampf(origin_emotional * CASCADE_BLEED, 0.0, 0.85)
	apply_emotional_spike(bleed, origin_id, 2)
	if _level != null:
		var st2: NpcState = _level.get_npc_state(npc_id)
		if st2 != null:
			st2.cascade_source_id = origin_id


func apply_chaos_goodwill_hit() -> void:
	var st: NpcState = _level.get_npc_state(npc_id) if _level != null else null
	var prof: NpcProfile = _level.get_npc_profile(npc_id) if _level != null else null
	if st == null or prof == null:
		return
	st.goodwill = clampf(st.goodwill - prof.chaos_goodwill_penalty, 0.0, 1.0)
	st.last_interaction_type = _E.InteractionType.CHAOS
	if _level != null:
		st.last_chaos_timestamp = _level.level_elapsed_time


func _enter_reacting(st: NpcState, prof: NpcProfile, cascade_depth: int = 1) -> void:
	st.current_behavior = _E.NpcBehavior.REACTING
	_emotion_at_reacting_entry = st.emotional_level
	st.comfort_receptivity = maxf(
		st.comfort_receptivity - prof.receptivity_reacting_drop,
		prof.comfort_receptivity_floor
	)
	_reacting_timer = REACTING_DURATION
	if _meter != null and _meter.has_method(&"register_reacting_chaos_contribution"):
		_meter.call(&"register_reacting_chaos_contribution", _emotion_at_reacting_entry, cascade_depth)
	_propagate_cascade(st)


func _propagate_cascade(st: NpcState) -> void:
	if npc_id != &"michael":
		return
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var christen_ctrl: NpcController = _find_npc_controller_in_subtree(scene, &"christen")
	if christen_ctrl != null:
		christen_ctrl.apply_cascade_from(npc_id, st.emotional_level)


func _find_npc_controller_in_subtree(n: Node, target_id: StringName) -> NpcController:
	if n is NpcController:
		var self_c: NpcController = n as NpcController
		if self_c.npc_id == target_id:
			return self_c
	for ch: Node in n.get_children():
		var found: NpcController = _find_npc_controller_in_subtree(ch, target_id)
		if found != null:
			return found
	return null


func _tick_emotional_decay(st: NpcState, prof: NpcProfile, delta: float) -> void:
	if st.current_behavior in [_E.NpcBehavior.FED, _E.NpcBehavior.ASLEEP]:
		return
	var rate: float = prof.emotion_decay_rate
	if st.current_behavior == _E.NpcBehavior.RECOVERING:
		rate *= 1.5
	st.emotional_level += (prof.baseline_tension - st.emotional_level) * rate * delta
	st.emotional_level = clampf(st.emotional_level, 0.0, 1.0)


func _tick_goodwill_decay(st: NpcState, prof: NpcProfile, delta: float) -> void:
	var baseline: float = 0.0
	st.goodwill += (baseline - st.goodwill) * prof.goodwill_decay_rate * delta
	st.goodwill = clampf(st.goodwill, 0.0, 1.0)


func _tick_comfort_receptivity(st: NpcState, prof: NpcProfile, delta: float) -> void:
	if st.current_behavior == _E.NpcBehavior.REACTING:
		return
	var target: float = prof.comfort_receptivity_default
	st.comfort_receptivity += (target - st.comfort_receptivity) * prof.receptivity_recovery_rate * delta
	st.comfort_receptivity = clampf(
		st.comfort_receptivity,
		prof.comfort_receptivity_floor,
		prof.receptivity_max
	)


func _tick_timers(st: NpcState, prof: NpcProfile, delta: float) -> void:
	match st.current_behavior:
		_E.NpcBehavior.REACTING:
			_reacting_timer -= delta
			if _reacting_timer <= 0.0:
				st.current_behavior = _E.NpcBehavior.RECOVERING
				st.cascade_source_id = &""
				_recovering_timer = RECOVERING_DURATION
		_E.NpcBehavior.RECOVERING:
			_recovering_timer -= delta
			if _recovering_timer <= 0.0:
				if st.emotional_level <= prof.vulnerability_threshold:
					st.current_behavior = _E.NpcBehavior.VULNERABLE
					st.comfort_receptivity = minf(
						st.comfort_receptivity + prof.receptivity_vulnerable_boost,
						prof.receptivity_max
					)
				else:
					st.current_behavior = _E.NpcBehavior.ROUTINE


func _try_fed_and_overwhelm(st: NpcState, prof: NpcProfile) -> void:
	if st.current_behavior == _E.NpcBehavior.FED:
		return
	var fed_ok_states: Array = [
		_E.NpcBehavior.ROUTINE,
		_E.NpcBehavior.RECOVERING,
		_E.NpcBehavior.VULNERABLE,
	]
	if not fed_ok_states.has(st.current_behavior):
		return
	if _meter == null:
		return
	var chaos_ok: bool = _meter.call(&"chaos_context_met", MIN_FEED_CHAOS_EVENTS) as bool
	var eff_feed: float = prof.feeding_threshold
	if st.bonnie_hunger_context:
		eff_feed -= 0.1
	if chaos_ok and st.goodwill >= eff_feed:
		st.current_behavior = _E.NpcBehavior.FED
		if _meter.has_method(&"set_feeding_path_for_test"):
			_meter.call(&"set_feeding_path_for_test", _E.FeedingPathType.CHARM_PATH)
		return
	if prof.chaos_overwhelm_threshold > 0:
		var ev: int = _meter.get("chaos_event_count") as int
		if ev >= prof.chaos_overwhelm_threshold:
			st.current_behavior = _E.NpcBehavior.FED
			if _meter.has_method(&"set_feeding_path_for_test"):
				_meter.call(
					&"set_feeding_path_for_test",
					_E.FeedingPathType.CHAOS_OVERWHELM_PATH
				)
