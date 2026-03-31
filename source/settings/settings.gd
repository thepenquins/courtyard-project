extends Node

signal locale_was_changed
signal player_name_was_changed

signal master_volume_was_changed
signal sfx_volume_was_changed
signal music_volume_was_changed

const PATH_TO_CONFIG = "user://config.ini"

enum AudioBus {
	MASTER,
	SFX,
	MUSIC,
	BLEEP,
}

var audio_bus_name: Dictionary[AudioBus, StringName] = {
	AudioBus.MASTER : &"Master",
	AudioBus.SFX : &"SFX",
	AudioBus.MUSIC : &"Music",
	AudioBus.BLEEP : &"Bleep",
}

var config: ConfigFile


var player_name: String = "":
	set(new_name):
		player_name = new_name
		player_name_was_changed.emit()
		print("Player name: %s" % player_name)


var locale: String = OS.get_locale():
	set(new_locale):
		locale = new_locale
		TranslationServer.set_locale(locale)
		locale_was_changed.emit()
		print("Locale: %s" % locale)


var screen_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
	set(mode):
		screen_mode = mode
		DisplayServer.window_set_mode(screen_mode)
		print("Screen mode: %s" % screen_mode)


var master_volume: int = 50:
	set(value):
		master_volume = value
		_set_audio_bus_volume(value, AudioBus.MASTER)
		master_volume_was_changed.emit()


var sfx_volume: int = 50:
	set(value):
		sfx_volume = value
		_set_audio_bus_volume(value, AudioBus.SFX)
		sfx_volume_was_changed.emit()


var music_volume: int = 50:
	set(value):
		music_volume = value
		_set_audio_bus_volume(value, AudioBus.MUSIC)
		music_volume_was_changed.emit()


func _set_audio_bus_volume(value: int, bus: AudioBus) -> void:
	var db: float = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name[bus]), db)
	print("%s bus volume is set to %s db." % [audio_bus_name[bus], db])


var bleep_mode: bool = true: 
	set(value):
		bleep_mode = value
		AudioServer.set_bus_mute(AudioServer.get_bus_index(audio_bus_name[AudioBus.BLEEP]), not value)
		print("Bleep mode: %s" % value)


func _enter_tree():
	load_config()


func _exit_tree():
	save_config()


func save_config() -> void:
	print("Saving settings.")
	if config == null:
		config = ConfigFile.new()
	
	config.set_value("profile", "player_name", player_name)
	
	config.set_value("general_settings", "locale", locale)
	
	config.set_value("screen_settings", "mode", int(screen_mode))
	config.set_value("screen_settings", "screen_size", get_window().size)
	
	config.set_value("audio_settings", "master_volume", master_volume)
	config.set_value("audio_settings", "sfx_volume", sfx_volume)
	config.set_value("audio_settings", "music_volume", music_volume)
	config.set_value("audio_settings", "bleep_mode", bleep_mode)
	
	config.save(PATH_TO_CONFIG)


func load_config() -> void:
	print("Loading settings.")
	if config == null:
		config = ConfigFile.new()
	
	var error = config.load(PATH_TO_CONFIG)
	if error == OK:
		player_name = config.get_value("profile", "player_name", "")
		
		locale = config.get_value("general_settings", "locale", "en")
		
		screen_mode = config.get_value("screen_settings", "mode", DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
		get_window().size = config.get_value("screen_settings", "screen_size", Vector2(1280, 720))
		get_window().move_to_center()
		
		master_volume = config.get_value("audio_settings", "master_volume", 50)
		sfx_volume = config.get_value("audio_settings", "sfx_volume", 50)
		music_volume = config.get_value("audio_settings", "music_volume", 50)
		bleep_mode = config.get_value("audio_settings", "bleep_mode", true)
		
		print("Configuration file loaded successfully!")
	else:
		print("Failed to read configuration file: %s" % error)
		load_default()


func load_default() -> void:
	print("Loading default settings.")

	locale = OS.get_locale()
	
	screen_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

	master_volume = 50
	sfx_volume = 50
	music_volume = 50


func set_audio_volume(bus: AudioBus, value: int) -> void:
	match bus:
		AudioBus.MASTER:
			master_volume = value
		AudioBus.SFX:
			sfx_volume = value
		AudioBus.MUSIC:
			music_volume = value


func get_audio_volume(bus: AudioBus) -> int:
	match bus:
		AudioBus.MASTER:
			return master_volume
		AudioBus.SFX:
			return sfx_volume
		AudioBus.MUSIC:
			return music_volume
		_:
			return 0
