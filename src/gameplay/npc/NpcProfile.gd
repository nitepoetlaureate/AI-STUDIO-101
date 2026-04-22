class_name NpcProfile
extends Resource

## Per-NPC tuning (npc-personality §7). Defaults in `assets/data/npc/*.tres`.

@export var npc_id: StringName
@export var baseline_tension: float
@export var emotion_decay_rate: float
@export var awareness_threshold: float
@export var reaction_threshold: float
@export var flee_threshold: float
@export var vulnerability_threshold: float
@export var feeding_threshold: float
@export var comfort_receptivity_floor: float
@export var comfort_receptivity_default: float
@export var can_flee: bool

@export_group("Line of Sight (character-local)")
@export var los_nose_bridge_local: Vector2 = Vector2(0, -18)
@export var los_chest_from_nose_local: Vector2 = Vector2(0, 24)
