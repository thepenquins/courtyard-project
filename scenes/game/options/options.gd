class_name GameOptions extends Control

signal option_selected(index: int)

@export var options_container: Container
@export var option_theme: Theme


func _ready() -> void:
	_clear_container()
	hide()


func add_options(options: PackedStringArray) -> void:
	_clear_container()
	for index in options.size():
		add_option(options[index], index)
	show()


func add_option(option: String, index: int) -> void:
	var button = Button.new()
	options_container.add_child(button)
	button.text = option
	button.theme = option_theme
	button.pressed.connect(_on_option_selected.bind(index))


func _on_option_selected(index: int) -> void:
	option_selected.emit(index)
	hide()
	_clear_container()


func _clear_container() -> void:
	for child in options_container.get_children():
		child.queue_free()
