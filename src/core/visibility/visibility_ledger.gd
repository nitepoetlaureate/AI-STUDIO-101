extends RefCounted

## Canonical visibility snapshot keyed by [param npc_id]. Single writer: LevelManager LOS pass.

var _visible: Dictionary = {} ## StringName -> bool
var revision: int = 0

func get_visible(npc_id: StringName) -> bool:
	return _visible.get(npc_id, false) as bool


func set_visible(npc_id: StringName, value: bool) -> void:
	var prev: bool = _visible.get(npc_id, false) as bool
	if prev == value:
		return
	_visible[npc_id] = value
	revision += 1


func clear_all_to_false(keys: Array) -> void:
	for k: Variant in keys:
		var id := k as StringName
		set_visible(id, false)
