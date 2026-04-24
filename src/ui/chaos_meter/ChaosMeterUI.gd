extends CanvasLayer

## Chaos Meter bowl HUD (System 23 / S1-16). Read-only; pulls from [ChaosMeter] group.

const _E := preload("res://src/shared/enums.gd")
const _UI_CFG_PATH := "res://assets/data/chaos_meter_ui_config.tres"
const _METER_CFG_PATH := "res://assets/data/chaos_meter_config.tres"

var _ui_cfg: ChaosMeterUIConfig
var _meter_cfg: ChaosMeterConfig
var _meter: Node
var _chaos_rect: ColorRect
var _social_rect: ColorRect
var _displayed_chaos: float = -1.0
var _displayed_social: float = -1.0


func _ready() -> void:
	layer = 20
	_ui_cfg = load(_UI_CFG_PATH) as ChaosMeterUIConfig
	_meter_cfg = load(_METER_CFG_PATH) as ChaosMeterConfig
	_build_widgets()
	call_deferred(&"_resolve_meter")


func _build_widgets() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var bowl := Control.new()
	bowl.anchors_preset = Control.PRESET_BOTTOM_RIGHT
	bowl.anchor_left = 1.0
	bowl.anchor_top = 1.0
	bowl.anchor_right = 1.0
	bowl.anchor_bottom = 1.0
	bowl.offset_left = -48.0
	bowl.offset_top = -120.0
	bowl.offset_right = -8.0
	bowl.offset_bottom = -8.0
	root.add_child(bowl)
	var outline := ColorRect.new()
	outline.color = Color(0.15, 0.12, 0.2)
	outline.set_anchors_preset(Control.PRESET_FULL_RECT)
	bowl.add_child(outline)
	var inner := Control.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 4.0
	inner.offset_top = 4.0
	inner.offset_right = -4.0
	inner.offset_bottom = -4.0
	bowl.add_child(inner)
	_chaos_rect = ColorRect.new()
	_chaos_rect.color = Color(0.2, 0.15, 0.45)
	_chaos_rect.size = Vector2(float(_ui_cfg.chaos_zone_width_px), 1.0)
	_chaos_rect.position = Vector2(4.0, 0.0)
	inner.add_child(_chaos_rect)
	_social_rect = ColorRect.new()
	_social_rect.color = Color(0.85, 0.55, 0.2)
	_social_rect.size = Vector2(float(_ui_cfg.chaos_zone_width_px), 1.0)
	_social_rect.position = Vector2(4.0, 0.0)
	inner.add_child(_social_rect)


func _resolve_meter() -> void:
	var tree := get_tree()
	if tree != null:
		_meter = tree.get_first_node_in_group(&"chaos_meter")


func _process(delta: float) -> void:
	if _meter == null or _ui_cfg == null or _meter_cfg == null:
		return
	var chaos: float = _meter.get("chaos_fill") as float
	var social: float = _meter.get("social_fill") as float
	var cap: float = _meter_cfg.chaos_fill_cap
	var soc_w: float = _meter_cfg.social_fill_weight
	if _displayed_chaos < 0.0:
		_displayed_chaos = chaos
		_displayed_social = social
	var k: float = clampf(_ui_cfg.fill_chase_speed * delta, 0.0, 1.0)
	_displayed_chaos = lerpf(_displayed_chaos, chaos, k)
	_displayed_social = lerpf(_displayed_social, social, k)
	var inner_h: float = 80.0
	var chaos_h: float = inner_h * (_displayed_chaos / maxf(cap, 0.01))
	var soc_h: float = inner_h * (_displayed_social / maxf(soc_w, 0.01))
	chaos_h = floorf(chaos_h)
	soc_h = floorf(soc_h)
	var chaos_bottom := inner_h - 8.0
	_chaos_rect.size = Vector2(float(_ui_cfg.chaos_zone_width_px), chaos_h)
	_chaos_rect.position = Vector2(
		4.0,
		chaos_bottom - chaos_h
	)
	var cap_y: float = inner_h * (soc_w / maxf(cap + soc_w, 0.01))
	_social_rect.size = Vector2(float(_ui_cfg.chaos_zone_width_px), soc_h)
	_social_rect.position = Vector2(4.0, cap_y - soc_h)
