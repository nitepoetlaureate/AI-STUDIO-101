extends SceneTree

## Session 013: five 1× PNG captures (720×540) into `art/_critique/verification-013/`.
## Reads the framebuffer from a **SubViewport**. Under **`--headless`** + **dummy** GL,
## `ViewportTexture.get_image()` usually fails — use **`python3 tools/composite_verification_013.py`**
## for CI-safe stills built from **`art/export/**` PNGs**.
##
## Uses **Timer** chains (no `await`) — `await process_frame` on a `SceneTree` `-s` script can stall.
##
## Run modes:
## - **CI / regression (expect capture to fail):** `godot --headless --path . -s res://tools/capture_verification_013.gd` — use the Python composite script for green stills instead.
## - **Optional true framebuffer (visible GL):** `godot --path . -s res://tools/capture_verification_013.gd` (omit `--headless`). Then diff `verification-013/*.png` against composite outputs or commit intentionally.

const OUT := "res://prototypes/bonnie-traversal/art/_critique/verification-013/"
const LEVEL := "res://prototypes/bonnie-traversal/TestLevel.tscn"

var _vp: SubViewport
var _inst: Node2D
var _bonnie: BonnieController

var _names: PackedStringArray = PackedStringArray(
	["01_idle_floor.png", "02_run_moving.png", "03_jump_rising.png", "04_near_npcs.png", "05_semisolid_strip.png"]
)


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	call_deferred("_setup")


func _setup() -> void:
	_vp = SubViewport.new()
	_vp.name = &"VerificationViewport"
	_vp.size = Vector2i(720, 540)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_vp.transparent_bg = false
	_vp.handle_input_locally = false
	(root as Window).add_child(_vp)

	_inst = (load(LEVEL) as PackedScene).instantiate() as Node2D
	_vp.add_child(_inst)
	_bonnie = _inst.get_node("BonnieController") as BonnieController

	_after_delay(0.12, _warmup_tick.bind(10))


func _after_delay(sec: float, callable: Callable) -> void:
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = sec
	root.add_child(t)
	t.timeout.connect(
		func() -> void:
			t.queue_free()
			callable.call()
	,
		CONNECT_ONE_SHOT
	)
	t.start()


func _warmup_tick(remaining: int) -> void:
	if remaining > 0:
		_after_delay(0.02, _warmup_tick.bind(remaining - 1))
	else:
		_capture_phase(0)


func _capture_phase(phase: int) -> void:
	if phase >= _names.size():
		_vp.queue_free()
		quit(0)
		return

	_apply_pose(phase)
	_after_delay(0.14, func() -> void: _snap_png(phase))


func _snap_png(phase: int) -> void:
	var tex: ViewportTexture = _vp.get_texture()
	if tex == null:
		push_error("capture_verification_013: SubViewport texture null at phase %d" % phase)
		_vp.queue_free()
		quit(1)
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		push_error("capture_verification_013: Image null/empty at phase %d" % phase)
		_vp.queue_free()
		quit(1)
		return
	var path: String = OUT + _names[phase]
	var err: Error = img.save_png(ProjectSettings.globalize_path(path))
	if err != OK:
		push_error("capture_verification_013: save_png failed %s err=%d" % [path, err])
		_vp.queue_free()
		quit(1)
		return
	_after_delay(0.02, _capture_phase.bind(phase + 1))


func _apply_pose(phase: int) -> void:
	match phase:
		0:
			_bonnie.global_position = Vector2(120, 452)
			_bonnie.velocity = Vector2.ZERO
			_bonnie._change_state(BonnieController.State.IDLE)
		1:
			_bonnie.global_position = Vector2(260, 452)
			_bonnie._change_state(BonnieController.State.RUNNING)
			_bonnie.velocity = Vector2(280, 0)
		2:
			_bonnie.global_position = Vector2(180, 380)
			_bonnie._change_state(BonnieController.State.JUMPING)
			_bonnie.velocity = Vector2(80, -220)
		3:
			_bonnie.global_position = Vector2(400, 452)
			_bonnie.velocity = Vector2.ZERO
			_bonnie._change_state(BonnieController.State.IDLE)
		4:
			_bonnie.global_position = Vector2(360, 455)
			_bonnie.velocity = Vector2.ZERO
			_bonnie._change_state(BonnieController.State.IDLE)
