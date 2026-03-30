extends Control

@export var main: Control
@export var extra: MenuElement
@export var settings: MenuElement
@export var developers: MenuElement

var _active_control: Control


func _ready() -> void:
	_active_control = main


func _set_active_control(control: Control) -> void:
	_active_control.hide()
	_active_control = control
	_active_control.show()


func _on_play_pressed() -> void:
	Loader.load_scene("res://scenes/game/game.tscn")


func _on_continue_pressed() -> void:
	pass # Replace with function body.


func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_extra_pressed() -> void:
	_set_active_control(extra)


func _on_settings_pressed() -> void:
	_set_active_control(settings)


func _on_developers_pressed() -> void:
	_set_active_control(developers)


func _on_exit_pressed() -> void:
	pass # Replace with function body.


func _return_to_main() -> void:
	_set_active_control(main)
