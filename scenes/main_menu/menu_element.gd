class_name MenuElement extends Control

signal return_pressed

@export var return_button: Button


func _ready() -> void:
	return_button.pressed.connect(_on_return_button_pressed)


func _on_return_button_pressed() -> void:
	return_pressed.emit()
