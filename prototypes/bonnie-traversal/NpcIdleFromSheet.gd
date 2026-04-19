extends AnimatedSprite2D

## Loads a horizontal Aseprite **json-hash** spritesheet (from MCP `export_spritesheet` + `include_json`)
## and plays the first [param tag_name] tag (default `idle`).

@export_file("*.json") var sheet_json_path: String = ""
@export_file("*.png") var sheet_png_path: String = ""
@export var tag_name: String = "idle"


func _ready() -> void:
	if sheet_json_path.is_empty() or sheet_png_path.is_empty():
		return
	_build_sprite_frames()
	if sprite_frames and sprite_frames.has_animation(tag_name):
		play(StringName(tag_name))


func _build_sprite_frames() -> void:
	if not FileAccess.file_exists(sheet_json_path) or not FileAccess.file_exists(sheet_png_path):
		return
	var tex: Texture2D = load(sheet_png_path) as Texture2D
	if tex == null:
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(sheet_json_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	var frames_obj: Dictionary = data.get("frames", {}) as Dictionary
	if frames_obj.is_empty():
		return
	var frame_keys: Array = frames_obj.keys()
	var meta: Dictionary = data.get("meta", {}) as Dictionary
	var tags: Array = meta.get("frameTags", []) as Array
	var sf := SpriteFrames.new()
	for tag_any in tags:
		var tag: Dictionary = tag_any as Dictionary
		var anim: String = str(tag.get("name", ""))
		if anim.is_empty() or anim != tag_name:
			continue
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		var from_i: int = int(tag.get("from", 0))
		var to_i: int = int(tag.get("to", from_i))
		for fi in range(from_i, to_i + 1):
			if fi < 0 or fi >= frame_keys.size():
				continue
			var entry: Dictionary = frames_obj[frame_keys[fi]] as Dictionary
			var fr: Dictionary = entry.get("frame", {}) as Dictionary
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(float(fr.get("x", 0)), float(fr.get("y", 0)), float(fr.get("w", 16)), float(fr.get("h", 32)))
			var dur_ms: float = float(entry.get("duration", 100))
			sf.add_frame(anim, at, dur_ms / 1000.0)
	sprite_frames = sf
