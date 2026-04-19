extends GutTest

var _audio: Node


func before_each() -> void:
	_audio = preload("res://src/core/audio/AudioManager.gd").new()
	add_child_autoqfree(_audio)


func test_buses_exist_after_ready() -> void:
	await wait_process_frames(2)
	assert_gte(AudioServer.get_bus_index("Music"), 0)
	assert_gte(AudioServer.get_bus_index("SFX"), 0)
	assert_gte(AudioServer.get_bus_index("Ambient"), 0)


func test_set_bus_volume_no_crash() -> void:
	await wait_process_frames(1)
	_audio.set_bus_volume(&"SFX", 0.5)
	# If bus missing, implementation warns; SFX must exist after _ready.
	assert_gte(AudioServer.get_bus_index("SFX"), 0)


func test_play_sfx_missing_asset_is_silent() -> void:
	await wait_process_frames(1)
	_audio.play_sfx(&"definitely_missing_event_xyz")
	pass_test("no throw")


func test_crossfade_music_headless() -> void:
	await wait_process_frames(1)
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	_audio.crossfade_music(gen, 0.15)
	await _audio.get_tree().create_timer(0.25).timeout
	var music_player: AudioStreamPlayer = _audio.get_node("MusicPlayer") as AudioStreamPlayer
	assert_true(music_player.playing, "music player should be playing after crossfade")
