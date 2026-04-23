extends Resource

## Camera tuning per `design/gdd/camera-system.md` §3 / §7. All look-ahead values in pixels.

@export_group("Lerp")
@export var camera_lerp_speed: float = 6.0
@export var camera_catch_up_speed: float = 4.0

@export_group("Framing")
## Camera world Y offset from BONNIE (negative = camera above player → player lower on screen).
@export var vertical_framing_offset_y: float = -110.0

@export_group("Look-ahead by BonnieState (px, horizontal unless noted)")
@export var look_ahead_idle: float = 0.0
@export var look_ahead_sneaking: float = 40.0
@export var look_ahead_walking: float = 80.0
@export var look_ahead_running: float = 180.0
@export var look_ahead_sliding: float = 220.0
@export var look_ahead_jumping_falling: float = 120.0
@export var look_ahead_climbing: float = 60.0
@export var look_ahead_squeezing: float = 0.0
@export var look_ahead_dazed_rough: float = 0.0
@export var look_ahead_ledge_pullup: float = 60.0
@export var look_ahead_landing: float = 80.0

@export_group("Ledge bias (MVP hook)")
@export var ledge_bias_activation_radius: float = 80.0
@export var ledge_bias_extra_lookahead: float = 40.0

@export_group("Climbing")
## Extra world-space Y offset toward climb direction (negative = up in Godot 2D).
@export var climb_vertical_lookahead: float = -60.0

@export_group("Zoom skeleton (hold `zoom` action)")
@export var zoom_normal: float = 1.0
@export var zoom_min: float = 0.65
@export var zoom_out_rate: float = 0.4
@export var zoom_return_rate: float = 0.8
