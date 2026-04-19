class_name ChaosMeterConfig
extends Resource

## Chaos meter tuning (chaos-meter §3.1–3.2). Defaults in `chaos_meter_config.tres`.

@export var chaos_fill_cap: float
@export var social_fill_weight: float
@export var meter_threshold_cold: float
@export var meter_threshold_warming: float
@export var meter_threshold_hot: float
@export var meter_threshold_converging: float
@export var meter_threshold_tipping: float
@export var fill_chase_speed: float
