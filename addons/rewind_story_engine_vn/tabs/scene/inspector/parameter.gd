@tool @abstract class_name VneInspectorParameter extends HBoxContainer

signal value_changed(value: float)

const MINIMUM_SIZE: int = 120

var _container: PanelContainer
var _value


func _init(label_text: String) -> void:
	_add_label(label_text)
	_add_container()


func _add_label(label_text: String) -> void:
	var label = Label.new()
	add_child(label)
	label.text = label_text
	label.custom_minimum_size.x = MINIMUM_SIZE


func _add_container() -> void:
	_container = PanelContainer.new()
	add_child(_container)
	_container.add_theme_stylebox_override("panel", VnePluginController.PANEL_STYLE_BOX)
	_container.custom_minimum_size.x = MINIMUM_SIZE
	_container.size_flags_horizontal = Control.SIZE_SHRINK_END | SIZE_EXPAND


@abstract func set_value(value) -> void
@abstract func get_value()
