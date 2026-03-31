extends Node


var fmod_bank_loader: FmodBankLoader


func _enter_tree() -> void:
	_load_banks()
	_subscribe_to_signals()


func _load_banks() -> void:
	fmod_bank_loader = FmodBankLoader.new()
	fmod_bank_loader.bank_paths = [
		"res://audio/banks/Master.strings.bank",
		"res://audio/banks/Master.bank",
		]
	add_child(fmod_bank_loader)


func _subscribe_to_signals() -> void:
	Settings.master_volume_was_changed.connect(_on_master_volume_was_changed)
	Settings.sfx_volume_was_changed.connect(_on_sfx_volume_was_changed)
	Settings.music_volume_was_changed.connect(_on_music_volume_was_changed)


func _on_master_volume_was_changed() -> void:
	_set_bus_volume("bus:/", Settings.master_volume / 100.0)


func _on_sfx_volume_was_changed() -> void:
	var volume = Settings.sfx_volume / 100.0
	
	_set_bus_volume("bus:/SFX", volume)
	_set_bus_volume("bus:/UI", volume)


func _on_music_volume_was_changed() -> void:
	
	var volume = Settings.music_volume / 100.0
	_set_bus_volume("bus:/Music", volume)
	_set_bus_volume("bus:/Ambience", volume)


func _set_bus_volume(bus_path: String, volume: float) -> void:
	var bus = FmodServer.get_bus(bus_path)
	if bus:
		bus.volume = Settings.music_volume / 100.0
