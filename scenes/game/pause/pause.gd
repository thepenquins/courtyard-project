extends Control

signal continue_pressed
signal save_pressed
signal exit_to_menu_pressed

@export var settings: MenuElement


func _on_continue_button_pressed() -> void:
	continue_pressed.emit()


func _on_save_button_pressed() -> void:
	save_pressed.emit()


func _on_exit_to_menu_button_pressed() -> void:
	exit_to_menu_pressed.emit()
	Loader.load_scene("res://scenes/main_menu/main_menu.tscn")


func _on_settings_return_pressed() -> void:
	settings.hide()


func _on_settings_button_pressed() -> void:
	settings.show()
