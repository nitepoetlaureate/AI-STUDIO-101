class_name BonnieTraversalConfig
extends Resource

## Traversal tuning ([code]bonnie-traversal.md[/code] §4). Defaults live in [code]bonnie_traversal_config.tres[/code].

@export_group("Movement Speeds")
@export var walk_speed: float
@export var run_max_speed: float
@export var sneak_max_speed: float
@export var climb_speed: float
@export var climb_grab_vertical_threshold: float
@export var squeeze_speed: float

@export_group("Ground / Air")
@export var slide_trigger_speed: float
@export var slide_friction: float
@export var slide_steer_force: float
@export var ground_acceleration: float
@export var ground_deceleration: float
@export var air_control_force: float
@export var gravity: float
@export var fall_velocity_max: float

@export_group("Jump")
@export var hop_velocity: float
@export var jump_velocity: float
@export var jump_hold_add_frames: int
@export var jump_hold_max_frames: int
@export var jump_hold_gravity_scale: float
@export var sneak_air_control_scale: float

@export_group("Landing / Recovery")
@export var clean_land_threshold: float
@export var skid_threshold: float
@export var landing_skid_time_min: float
@export var landing_skid_time_max: float
@export var rough_landing_threshold: float
@export var rough_landing_duration: float
@export var daze_duration: float
@export var daze_collision_threshold: float
@export var climb_vertical_lerp_scale: float
@export var ledge_pullup_duration: float
@export var squeeze_input_threshold: float
@export var slide_exit_speed_fraction: float

@export_group("Stimulus Radii (px)")
@export var idle_stimulus_radius: float
@export var sneak_stimulus_radius: float
@export var walk_stimulus_radius: float
@export var run_stimulus_radius: float
@export var slide_stimulus_bonus: float

@export_group("Interactive objects (Godot 4 impulse bridge)")
## Scale for [method InteractiveObject.receive_impact] from slide/run collisions.
@export var interactive_object_impulse_scale: float = 1.15
## Minimum horizontal speed for RUNNING to displace objects on contact ([code]interactive-object-system.md[/code] §3.3).
@export var run_object_interaction_min_speed: float = 200.0
## Minimum horizontal speed for WALKING/SNEAKING to apply [method InteractiveObject.receive_impact] (lower than run; bumping while walking).
@export var walk_object_interaction_min_speed: float = 55.0
## Floor for [method InteractiveObject.receive_impact] speed term while SLIDING (Godot may zero lateral velocity on rigid contact).
@export var slide_object_impulse_min_speed: float = 260.0
## Per-second impulse scale while grab is held and moving into a prop ([method InteractiveObject.apply_grab_push]).
@export var grab_object_push_impulse_per_sec: float = 140.0
