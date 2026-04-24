class_name InteractiveObject
extends RigidBody2D

## Physical interactive prop (System 7 / S1-13). [BonnieController] applies impulses via [method receive_impact].

signal object_displaced(chaos_value: float, object_position: Vector2)
signal object_displaced_stimulus(stimulus_strength: float, object_position: Vector2)

enum WeightClass {
	LIGHT,
	MEDIUM,
	HEAVY,
	GLASS,
	LIQUID,
}

@export var weight_class: WeightClass = WeightClass.LIGHT
@export var chaos_value: float = 0.05
@export var object_stimulus_multiplier: float = 2.0
@export var min_impulse_to_displace: float = 40.0

var displaced: bool = false
var _rest_transform: Transform2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	_rest_transform = transform
	_apply_weight_defaults()
	# MVP: reliable contact reporting if needed for object–object chains.
	contact_monitor = true
	max_contacts_reported = 8
	can_sleep = false
	lock_rotation = true


func _apply_weight_defaults() -> void:
	match weight_class:
		WeightClass.LIGHT:
			mass = 0.7
			physics_material_override = _make_material(0.35, 0.1)
		WeightClass.MEDIUM:
			mass = 1.4
			physics_material_override = _make_material(0.45, 0.12)
		WeightClass.HEAVY:
			mass = 3.5
			physics_material_override = _make_material(0.55, 0.15)
		WeightClass.GLASS:
			mass = 0.6
			physics_material_override = _make_material(0.25, 0.05)
		WeightClass.LIQUID:
			mass = 0.9
			physics_material_override = _make_material(0.3, 0.08)


func _make_material(friction: float, bounce: float) -> PhysicsMaterial:
	var m := PhysicsMaterial.new()
	m.friction = friction
	m.bounce = bounce
	return m


## Sustained shove while grab (E) is held and Bonnie is pushing into this body.
func apply_grab_push(direction_x: float, delta: float, impulse_per_sec: float) -> void:
	if direction_x == 0.0 or delta <= 0.0:
		return
	apply_central_impulse(Vector2(direction_x * impulse_per_sec * delta, 0.0))


func receive_impact(force: Vector2) -> void:
	if force.length_squared() < 0.01:
		return
	apply_central_impulse(force)
	if displaced:
		return
	if force.length() < min_impulse_to_displace:
		return
	_mark_displaced()


func _mark_displaced() -> void:
	displaced = true
	object_displaced.emit(chaos_value, global_position)
	object_displaced_stimulus.emit(chaos_value * object_stimulus_multiplier, global_position)
	var bus: Node = get_node_or_null("/root/ChaosEventBus")
	if bus != null and bus.has_signal(&"object_chaos_event"):
		bus.emit_signal(&"object_chaos_event", chaos_value)
	_apply_nearby_npc_goodwill_penalty()


func _apply_nearby_npc_goodwill_penalty() -> void:
	var lvl: Node = get_node_or_null("/root/LevelManager")
	var tree := get_tree()
	if lvl == null or tree == null:
		return
	var radius: float = 320.0
	var controllers: Array = tree.get_nodes_in_group(&"npc_controller")
	for ctrl: Variant in controllers:
		var c: Node = ctrl as Node
		if c == null or not c.has_method(&"apply_chaos_goodwill_hit"):
			continue
		var id: Variant = c.get(&"npc_id")
		if id == null:
			continue
		var st: NpcState = lvl.call(&"get_npc_state", id) as NpcState
		if st == null:
			continue
		var npc_node: Node2D = lvl.call(&"get_npc_node", id) as Node2D
		if npc_node == null:
			continue
		if npc_node.global_position.distance_to(global_position) <= radius:
			c.call(&"apply_chaos_goodwill_hit")


func reset_object() -> void:
	transform = _rest_transform
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	displaced = false
