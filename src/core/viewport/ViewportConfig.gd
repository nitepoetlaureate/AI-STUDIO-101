extends RefCounted
class_name ViewportConfig

## System 2 — viewport / rendering invariants (see design/gdd/viewport-config.md).
## Call [method validate_project_settings] once at startup (from [InputSystem]).

const INTERNAL_WIDTH: int = 720
const INTERNAL_HEIGHT: int = 540

## Verifies project settings match the approved 720×540, nearest-neighbor, GL Compatibility stack.
## Returns [code]false[/code] if any check fails ([code]push_error[/code] carries detail).
static func validate_project_settings() -> bool:
	var ok := true
	var vw: int = int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	var vh: int = int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
	if vw != INTERNAL_WIDTH or vh != INTERNAL_HEIGHT:
		push_error("ViewportConfig: expected display/window/viewport %d×%d, got %d×%d" % [INTERNAL_WIDTH, INTERNAL_HEIGHT, vw, vh])
		ok = false

	var stretch_mode: String = str(ProjectSettings.get_setting("display/window/stretch/mode", ""))
	if stretch_mode != "viewport":
		push_error('ViewportConfig: display/window/stretch/mode must be "viewport" (got %s)' % stretch_mode)
		ok = false

	var stretch_aspect: String = str(ProjectSettings.get_setting("display/window/stretch/aspect", ""))
	if stretch_aspect != "keep":
		push_error('ViewportConfig: display/window/stretch/aspect must be "keep" for 4:3 pillarbox (got %s)' % stretch_aspect)
		ok = false

	var filter: int = int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1))
	if filter != CanvasItem.TEXTURE_FILTER_NEAREST:
		push_error("ViewportConfig: canvas default_texture_filter must be NEAREST (%d)" % CanvasItem.TEXTURE_FILTER_NEAREST)
		ok = false

	var rendering_method: String = str(ProjectSettings.get_setting("rendering/renderer/rendering_method", ""))
	if rendering_method != "gl_compatibility":
		push_error('ViewportConfig: rendering_method must be "gl_compatibility" (got %s)' % rendering_method)
		ok = false

	Engine.max_fps = 60
	return ok
