extends Node2D

## Sprint 1 production test apartment (S1-17). Built in code so headless CI can load one scene.

#region agent log
const _AGENT_LOG_PATHS: Array[String] = [
	"/Users/michaelraftery/AI-STUDIO-101/.cursor/debug-1bb634.log",
	"user://debug_1bb634.log",
]


func _agent_log(loc: String, msg: String, data: Dictionary, hypothesis_id: String) -> void:
	var payload: Dictionary = {
		"sessionId": "1bb634",
		"timestamp": Time.get_ticks_msec(),
		"location": loc,
		"message": msg,
		"data": data,
		"hypothesisId": hypothesis_id,
	}
	var line: String = JSON.stringify(payload) + "\n"
	for p: String in _AGENT_LOG_PATHS:
		var f: FileAccess = FileAccess.open(p, FileAccess.READ_WRITE)
		if f == null:
			f = FileAccess.open(p, FileAccess.WRITE)
		if f == null:
			continue
		f.seek(f.get_length())
		f.store_string(line)
		f.close()


#endregion agent log

const _BonnieScn := preload("res://scenes/gameplay/BonnieController.tscn")
const _ChaosMeter := preload("res://src/gameplay/chaos/ChaosMeter.gd")
const _SocialSystem := preload("res://src/gameplay/social/SocialSystem.gd")
const _ChaosMeterUI := preload("res://src/ui/chaos_meter/ChaosMeterUI.gd")
const _NpcController := preload("res://src/gameplay/npc/NpcController.gd")
const _InteractiveObject := preload("res://src/gameplay/objects/InteractiveObject.gd")

const CHRISTEN_ARRIVAL_SEC := 120.0
## Top Y of walkable surface (matches `_add_floor(Rect2(0, 332, ...))`).
const _FLOOR_TOP_Y := 332.0
## Wide strip so run/slide into props is testable.
const _FLOOR_WIDTH := 3000.0

var _christen_root: Node2D
var _christen_timer: float = 0.0
var _playtest_bonnie: CharacterBody2D
const _PLAYTEST_OOB_Y := 460.0
const _PLAYTEST_OOB_X_MARGIN := 120.0


func _ready() -> void:
	var editor_preview: Node = get_node_or_null("_EditorPreview")
	if editor_preview != null:
		editor_preview.queue_free()
	# region agent log
	_agent_log(
		"test_apartment_root.gd:_ready",
		"enter",
		{"get_child_count": get_child_count()},
		"H4"
	)
	# endregion
	_build_core_systems()
	_add_floor(Rect2(0, 332, _FLOOR_WIDTH, 48))
	_build_npcs()
	var bonnie: CharacterBody2D = _BonnieScn.instantiate() as CharacterBody2D
	# region agent log
	_agent_log(
		"test_apartment_root.gd:_ready",
		"after_instantiate",
		{
			"bonnie_is_null": bonnie == null,
			"bonnie_name": "" if bonnie == null else String(bonnie.name),
		},
		"H1"
	)
	# endregion
	bonnie.position = Vector2(120, 280)
	add_child(bonnie)
	_playtest_bonnie = bonnie
	_add_bonnie_placeholder_visual(bonnie)
	# region agent log
	var cam: Camera2D = bonnie.get_node_or_null("BonnieCamera") as Camera2D
	_agent_log(
		"test_apartment_root.gd:_ready",
		"after_add_bonnie",
		{
			"bonnie_global": bonnie.global_position,
			"cam_is_null": cam == null,
			"cam_enabled": cam.enabled if cam != null else false,
			"child_count": get_child_count(),
		},
		"H1_H2_H3"
	)
	# endregion
	# 20×20 props: bottom edge on floor top → center Y = floor top + half height (was wrongly minus: boxes floated).
	var prop_y: float = _FLOOR_TOP_Y + 10.0
	_add_object(Vector2(520, prop_y), 0, 0.05)
	_add_object(Vector2(1600, prop_y), 1, 0.1)
	var lm: Node = get_node("/root/LevelManager")
	if lm.has_method(&"notify_level_ready"):
		lm.call(&"notify_level_ready")
	call_deferred(&"_agent_deferred_snapshot")


func _agent_deferred_snapshot() -> void:
	var vp: Viewport = get_viewport()
	var active: Camera2D = vp.get_camera_2d() if vp != null else null
	var bonnie: Node = find_child("BonnieController", true, false)
	# region agent log
	_agent_log(
		"test_apartment_root.gd:_agent_deferred_snapshot",
		"deferred_viewport",
		{
			"viewport_size": vp.get_visible_rect().size if vp != null else Vector2.ZERO,
			"active_cam_is_null": active == null,
			"active_cam_global": active.global_position if active != null else Vector2.ZERO,
			"bonnie_found": bonnie != null,
			"bonnie_global": bonnie.global_position if bonnie is Node2D else Vector2.ZERO,
		},
		"H2_H3"
	)
	# endregion


func _physics_process(delta: float) -> void:
	_christen_timer += delta
	if _christen_timer >= CHRISTEN_ARRIVAL_SEC and _christen_root != null:
		if _christen_root.process_mode == PROCESS_MODE_DISABLED:
			_christen_root.process_mode = Node.PROCESS_MODE_INHERIT
			_christen_root.visible = true
	_playtest_bounds_respawn_if_needed()


func _build_core_systems() -> void:
	var meter: Node = _ChaosMeter.new()
	meter.name = &"ChaosMeter"
	add_child(meter)
	add_child(_SocialSystem.new())
	add_child(_ChaosMeterUI.new())


func _add_floor(rect: Rect2) -> void:
	var sb := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = rect.size
	cs.position = rect.get_center()
	cs.shape = sh
	sb.add_child(cs)
	add_child(sb)
	_add_floor_placeholder_visual(rect)


func _add_floor_placeholder_visual(rect: Rect2) -> void:
	var poly := Polygon2D.new()
	poly.color = Color(0.42, 0.35, 0.28)
	var x: float = rect.position.x
	var y: float = rect.position.y
	var w: float = rect.size.x
	var h: float = rect.size.y
	poly.polygon = PackedVector2Array(
		[Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)]
	)
	add_child(poly)


func _add_bonnie_placeholder_visual(bonnie: Node2D) -> void:
	var poly := Polygon2D.new()
	poly.color = Color(0.92, 0.55, 0.18)
	poly.polygon = PackedVector2Array(
		[Vector2(-10, -18), Vector2(10, -18), Vector2(10, 18), Vector2(-10, 18)]
	)
	poly.z_index = 1
	bonnie.add_child(poly)


func _build_npcs() -> void:
	var lm: Node = get_node("/root/LevelManager")
	lm.call(&"register_room", &"kitchen", Rect2(0, 0, 420, 400))
	lm.call(&"register_room", &"living_room", Rect2(420, 0, 520, 400))
	lm.call(&"register_room", &"bedroom", Rect2(940, 0, 460, 400))

	var michael := Node2D.new()
	michael.position = Vector2(220, 280)
	add_child(michael)
	var mc := _NpcController.new()
	mc.npc_id = &"michael"
	michael.add_child(mc)
	var st_m := NpcState.create_michael_default()
	var pm: NpcProfile = load("res://assets/data/npc/michael_profile.tres") as NpcProfile
	lm.call(&"register_npc", &"michael", michael, &"kitchen", st_m, pm)

	_christen_root = Node2D.new()
	_christen_root.position = Vector2(720, 280)
	_christen_root.process_mode = Node.PROCESS_MODE_DISABLED
	_christen_root.visible = false
	add_child(_christen_root)
	var cc := _NpcController.new()
	cc.npc_id = &"christen"
	_christen_root.add_child(cc)
	var st_c := NpcState.create_christen_default()
	var pc: NpcProfile = load("res://assets/data/npc/christen_profile.tres") as NpcProfile
	lm.call(&"register_npc", &"christen", _christen_root, &"living_room", st_c, pc)


func _playtest_bounds_respawn_if_needed() -> void:
	if _playtest_bonnie == null or not is_instance_valid(_playtest_bonnie):
		return
	var p: Vector2 = _playtest_bonnie.global_position
	var floor_w: float = _FLOOR_WIDTH
	if p.y <= _PLAYTEST_OOB_Y and p.x >= -_PLAYTEST_OOB_X_MARGIN and p.x <= floor_w + _PLAYTEST_OOB_X_MARGIN:
		return
	if _playtest_bonnie.has_method(&"soft_respawn_at"):
		_playtest_bonnie.call(&"soft_respawn_at", Vector2(120, 280))
	else:
		_playtest_bonnie.global_position = Vector2(120, 280)
		_playtest_bonnie.velocity = Vector2.ZERO
	# region agent log
	_agent_log(
		"test_apartment_root.gd:_playtest_bounds_respawn_if_needed",
		"respawn",
		{"reason_oob": true, "last_pos": p},
		"H7"
	)
	# endregion


func _add_object(pos: Vector2, wclass: int, chaos: float) -> void:
	var io = _InteractiveObject.new()
	io.position = pos
	io.weight_class = wclass
	io.chaos_value = chaos
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(20, 20)
	cs.shape = sh
	io.add_child(cs)
	var vis := Polygon2D.new()
	vis.color = Color(0.35, 0.55, 0.85)
	vis.polygon = PackedVector2Array(
		[Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)]
	)
	io.add_child(vis)
	add_child(io)
