@tool extends CheckButton


func _ready() -> void:
	_set_icon()


func _toggled(toggled_on: bool) -> void:
	_set_icon()


func _set_icon() -> void:
	if button_pressed:
		icon = EditorIcons.get_icon("GuiVisibilityHidden")
	else:
		icon = EditorIcons.get_icon("GuiVisibilityVisible")
