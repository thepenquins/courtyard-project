extends Control

@export var main: Control
@export var save_manager: Control
@export var extra: MenuElement
@export var settings: MenuElement
@export var developers: MenuElement

@export var continue_button: Button
@export var load_button: Button

var _active_control: Control


func _ready() -> void:
	_return_to_main()


func _set_active_control(control: Control) -> void:
	if _active_control:
		_active_control.hide()
	_active_control = control
	_active_control.show()


func _on_play_pressed() -> void:
	Loader.load_scene("res://scenes/game/game.tscn")


func _on_continue_pressed() -> void:
	if Settings.last_save != "":
		load_game(Save.load_from_file(Settings.last_save))
	else:
		load_game(SaveManager.saves[SaveManager.saves.size() - 1])


func load_game(save: Save) -> void:
	#_return_to_main()
	Game.save_to_load = save
	_on_play_pressed()


func _on_load_pressed() -> void:
	_set_active_control(save_manager)


func _on_extra_pressed() -> void:
	_set_active_control(extra)


func _on_settings_pressed() -> void:
	_set_active_control(settings)


func _on_developers_pressed() -> void:
	_set_active_control(developers)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _return_to_main() -> void:
	_set_active_control(main)
	
	continue_button.disabled = Settings.last_save == "" or SaveManager.saves.size() == 0
	load_button.disabled = SaveManager.saves.size() == 0


func _on_save_manager_load_save(save: Save) -> void:
	load_game(save)
