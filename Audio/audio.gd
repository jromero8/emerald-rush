extends Node

var music_player : AudioStreamPlayer = null

var music_on : bool = true:
	set = set_music,
	get = get_music

var sound_on := true

var audio_files := {}

func _ready() -> void:
	music_player = get_stream_player("music")

func set_music(on : bool) -> void:
	music_on = on
	if music_on:
		music_player.play()
	else:
		music_player.stop()

func get_music() -> bool:
	return music_on

func play_sound(sound_name: String, volume_db: float = 0, from_pitch: float = 1, to_pitch: float = 1, channel : String = "") -> void:
	var sound := get_sound_by_name(sound_name)
	if sound:
		var rng : = RandomNumberGenerator.new()
		var pitch := rng.randf_range(from_pitch, to_pitch)
		var a : AudioStreamPlayer = get_stream_player(channel, true)
		if a != null:
			a.stream = sound
			a.pitch_scale = pitch
			a.volume_db = volume_db
			if sound_on:
				a.play()
			else:
				a.stop()

func stop_music() -> void:
	music_player.stop()

func play_music(music_name: String, volume_db: float = 0, pitch: float = 1) -> void:
	var music := get_sound_by_name(music_name)
	if music or music_name == "":
		if music_player.stream != music:
			music_player.stream = music
			music_player.pitch_scale = pitch
			music_player.volume_db = volume_db
			if music_on:
				music_player.play()
			else:
				music_player.stop()
	

func get_stream_player(channel : String = "", wait_for_channel_to_end : bool = false) -> AudioStreamPlayer:
	if channel != "":
		for c : AudioStreamPlayer in get_children():
			if c.has_meta("channel"):
				var _channel : String = c.get_meta("channel")
				if _channel == channel:
					if c.playing:
						if wait_for_channel_to_end:
							return null
						else:
							return c
					else:
						return c
	for c : AudioStreamPlayer in get_children():
		var _channel := ""
		if c.has_meta("channel"):
			_channel = c.get_meta("channel")
		if _channel == "" and !c.playing and c != music_player:
			c.set_meta("channel", channel)
			return c
	var a := AudioStreamPlayer.new()
	a.set_meta("channel", channel)
	add_child(a)
	return a

func is_channel_playing(_channel : String) -> bool:
	var sp := get_stream_player(_channel)
	if sp == null:
		return false
	else:
		return sp.playing

func set_sound(on : bool) -> void:
	sound_on = on
	if !sound_on:
		for c : AudioStreamPlayer in get_children():
			if c.playing and c != music_player:
				c.stop()

func stop_channel(channel : String) -> void:
	for c : AudioStreamPlayer in get_children():
		if c.has_meta("channel"):
			if c.playing and c != music_player:
				var _channel : String = c.get_meta("channel")
				if channel == _channel:
					c.stop()

func get_sound_by_name(sound_name : String) -> Resource:
	if audio_files.has(sound_name):
		return audio_files.get(sound_name)
	else:
		var path : String = "res://Audio/" + sound_name + ".wav"
		if !ResourceLoader.exists(path):
			path = "res://Audio/" + sound_name + ".mp3"
		if !ResourceLoader.exists(path):
			printerr("Audio file not found:" + sound_name)
			return
		var res := load(path)
		audio_files.set(sound_name, res)
		return res
		
func stop_all_sounds() -> void:
	for c : AudioStreamPlayer in get_children():
		if c != music_player:
			c.stop()
