extends Node

## Autoload: bus layout + playback API (System 3 / S1-05).
## Gameplay calls AudioManager.play_sfx(&"event_id") etc.; do not spawn AudioStreamPlayer from gameplay.

const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"
const BUS_AMBIENT := &"Ambient"

const _SFX_POOL_SIZE := 8

var _music_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_cursor: int = 0
var _music_tween: Tween


func _ready() -> void:
	_ensure_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = String(BUS_MUSIC)
	add_child(_music_player)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.name = "AmbientPlayer"
	_ambient_player.bus = String(BUS_AMBIENT)
	add_child(_ambient_player)

	for i in _SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		p.bus = String(BUS_SFX)
		add_child(p)
		_sfx_pool.append(p)

	print_verbose("[AudioManager] buses and players ready")


func _ensure_buses() -> void:
	_add_bus_if_missing(BUS_MUSIC, &"Master")
	_add_bus_if_missing(BUS_SFX, &"Master")
	_add_bus_if_missing(BUS_AMBIENT, &"Master")


func _add_bus_if_missing(bus_name: StringName, send_to: StringName) -> void:
	if AudioServer.get_bus_index(String(bus_name)) >= 0:
		return
	var idx := AudioServer.get_bus_count()
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, String(bus_name))
	AudioServer.set_bus_send(idx, String(send_to))


## Linear volume 0..1 applied to bus (maps with linear_to_db).
func set_bus_volume(bus_name: StringName, volume_linear: float) -> void:
	var idx := AudioServer.get_bus_index(String(bus_name))
	if idx < 0:
		push_warning("[AudioManager] unknown bus: %s" % String(bus_name))
		return
	var t: float = clampf(volume_linear, 0.0001, 1.0)
	AudioServer.set_bus_volume_db(idx, linear_to_db(t))


## Play a catalogued SFX on the SFX bus (WAV under res://assets/audio/sfx/).
func play_sfx(event_id: StringName, volume_db: float = 0.0) -> void:
	var path := "res://assets/audio/sfx/%s.wav" % String(event_id)
	if not ResourceLoader.exists(path):
		print_verbose("[AudioManager] play_sfx missing: %s" % path)
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	var player := _next_sfx_player()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Start or crossfade into music for catalog id (OGG under res://assets/audio/music/).
func play_music(event_id: StringName, crossfade_seconds: float = 0.75) -> void:
	var path := "res://assets/audio/music/%s.ogg" % String(event_id)
	if not ResourceLoader.exists(path):
		print_verbose("[AudioManager] play_music missing: %s" % path)
		return
	var stream := load(path) as AudioStream
	if stream == null:
		return
	crossfade_music(stream, crossfade_seconds)


## Crossfade current music stream to [to_stream].
func crossfade_music(to_stream: AudioStream, duration: float = 1.0) -> void:
	if to_stream == null:
		return
	if _music_tween != null and is_instance_valid(_music_tween):
		_music_tween.kill()
	_music_tween = create_tween()
	var half: float = maxf(duration * 0.5, 0.05)
	if _music_player.playing:
		_music_tween.tween_property(_music_player, "volume_db", -80.0, half)
		_music_tween.tween_callback(func() -> void:
			_apply_music_stream(to_stream)
		)
		_music_tween.tween_property(_music_player, "volume_db", 0.0, half)
	else:
		_apply_music_stream(to_stream)
		_music_player.volume_db = -80.0
		_music_tween.tween_property(_music_player, "volume_db", 0.0, half)


func _apply_music_stream(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()


func _next_sfx_player() -> AudioStreamPlayer:
	var p := _sfx_pool[_sfx_cursor]
	_sfx_cursor = (_sfx_cursor + 1) % _sfx_pool.size()
	return p
