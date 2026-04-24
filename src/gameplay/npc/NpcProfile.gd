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

@export_group("Receptivity / social (npc-personality §4.3)")
@export var receptivity_reacting_drop: float = 0.4
@export var receptivity_vulnerable_boost: float = 0.35
@export var receptivity_max: float = 0.9
@export var receptivity_recovery_rate: float = 0.08
@export var goodwill_decay_rate: float = 0.01
@export var chaos_goodwill_penalty: float = 0.1

@export_group("Chaos overwhelm (chaos-meter §5.2)")
## Session chaos-event count on [ChaosMeter] at which this NPC may FED via overwhelm; [code]-1[/code] disables.
@export var chaos_overwhelm_threshold: int = -1

@export_group("Line of Sight (character-local)")
@export var los_nose_bridge_local: Vector2 = Vector2(0, -18)
@export var los_chest_from_nose_local: Vector2 = Vector2(0, 24)
