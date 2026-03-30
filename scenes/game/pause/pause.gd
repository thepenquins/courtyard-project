extends Control

signal continue_pressed


func _on_continue_button_pressed() -> void:
	continue_pressed.emit()


func _on_exit_to_menu_button_pressed() -> void:
	Loader.load_scene("res://scenes/main_menu/main_menu.tscn")
