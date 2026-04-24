extends Node

## Bidirectional social resolution (System 12 / S1-12). process_priority 30 — after NPC tick.

const _E := preload("res://src/shared/enums.gd")
const _CFG_PATH := "res://assets/data/social_system_config.tres"

var _level: Node
var _cfg: SocialSystemConfig


func _ready() -> void:
	process_priority = 30
	add_to_group(&"social_system")
	_level = get_node_or_null("/root/LevelManager")
	_cfg = load(_CFG_PATH) as SocialSystemConfig


func _physics_process(delta: float) -> void:
	if _level == null or _cfg == null:
		return
	var bonnie: CharacterBody2D = get_tree().get_first_node_in_group(&"bonnie") as CharacterBody2D
	if bonnie == null:
		return
	_level.foreach_registered_npc(
		func(npc_id: StringName, npc_node: Node2D, st: NpcState) -> void:
			if st == null or npc_node == null:
				return
			if not st.visible_to_bonnie:
				return
			_tick_proximity_charm(st, delta)
			_try_charm_interactions(bonnie, npc_id, npc_node, st)
	)


func _tick_proximity_charm(st: NpcState, delta: float) -> void:
	if st.current_behavior == _E.NpcBehavior.CLOSED_OFF:
		return
	var charm_rate: float = 0.02
	if st.current_behavior == _E.NpcBehavior.REACTING:
		charm_rate *= 0.05
	st.goodwill = clampf(
		st.goodwill + charm_rate * st.comfort_receptivity * delta,
		0.0,
		1.0
	)


func _try_charm_interactions(
	bonnie: CharacterBody2D,
	_npc_id: StringName,
	npc_node: Node2D,
	st: NpcState
) -> void:
	if not Input.is_action_just_pressed(&"interact"):
		return
	var dist: float = bonnie.global_position.distance_to(npc_node.global_position)
	if dist > 64.0:
		return
	var _bonnie_state: int = _E.BonnieState.IDLE
	if bonnie.has_method(&"get_movement_state"):
		_bonnie_state = bonnie.call(&"get_movement_state") as int
	if st.current_behavior == _E.NpcBehavior.CLOSED_OFF:
		return
	var charm: float = 0.08
	if _within_levity_window(st):
		charm *= _cfg.levity_multiplier
	st.goodwill = clampf(st.goodwill + charm * st.comfort_receptivity, 0.0, 1.0)
	st.last_interaction_type = _E.InteractionType.CHARM
	if _level != null:
		st.last_interaction_timestamp = _level.level_elapsed_time


func _within_levity_window(st: NpcState) -> bool:
	if _level == null:
		return false
	return (_level.level_elapsed_time - st.last_chaos_timestamp) <= _cfg.levity_window
