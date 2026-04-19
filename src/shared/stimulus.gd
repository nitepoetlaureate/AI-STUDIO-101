extends RefCounted

## Minimal NPC stimulus payload (npc-personality §3.1 `active_stimuli`).
## Not a global `class_name` — use `preload("res://src/shared/stimulus.gd")` when typing instances.

var strength: float = 0.0
var source_id: StringName = &""
