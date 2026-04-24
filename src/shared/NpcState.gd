class_name NpcState
extends RefCounted

const _E := preload("res://src/shared/enums.gd")

## Shared NPC read/write surface (Systems 9, 12, 13). Fields per
## `design/gdd/npc-personality.md` §3.1 + `bidirectional-social-system.md` §3.1 extensions.

var emotional_level: float = 0.0
var goodwill: float = 0.0
var current_behavior: int = _E.NpcBehavior.ROUTINE
var comfort_receptivity: float = 0.0
## Stimulus instances from `res://src/shared/stimulus.gd` (untyped until global order is stable).
var active_stimuli: Array = []
var visible_to_bonnie: bool = false
var last_interaction_type: int = _E.InteractionType.NONE
var bonnie_hunger_context: bool = false
var last_interaction_timestamp: float = -1.0
var recovering_comfort_stacks: int = 0
## Prevents cascade ping-pong (npc-personality §4.4) — last propagator in chain.
var cascade_source_id: StringName = &""
var last_chaos_timestamp: float = -1000.0


static func create_michael_default() -> NpcState:
	var s := NpcState.new()
	s.emotional_level = 0.20
	s.goodwill = 0.0
	s.current_behavior = _E.NpcBehavior.ROUTINE
	s.comfort_receptivity = 0.55
	s.active_stimuli = []
	s.visible_to_bonnie = false
	s.last_interaction_type = _E.InteractionType.NONE
	s.bonnie_hunger_context = false
	s.last_interaction_timestamp = -1.0
	s.recovering_comfort_stacks = 0
	return s


static func create_christen_default() -> NpcState:
	var s := NpcState.new()
	s.emotional_level = 0.25
	s.goodwill = 0.0
	s.current_behavior = _E.NpcBehavior.ROUTINE
	s.comfort_receptivity = 0.65
	s.active_stimuli = []
	s.visible_to_bonnie = false
	s.last_interaction_type = _E.InteractionType.NONE
	s.bonnie_hunger_context = false
	s.last_interaction_timestamp = -1.0
	s.recovering_comfort_stacks = 0
	return s
