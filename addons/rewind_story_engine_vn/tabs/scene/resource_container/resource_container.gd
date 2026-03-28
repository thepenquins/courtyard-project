@tool
@abstract
class_name VneResourceContainer
extends PanelContainer


signal selected(resource: VneResource)
signal removed(resource: VneResource)

var _container: Container
var _rich_text_label: RichTextLabel
var _remove_button: Button

@export var text: String:
	set(value):
		text = value
		_rich_text_label.text = value

var resource: VneResource


func _init() -> void:
	add_theme_stylebox_override("panel", VnePluginController.PANEL_STYLE_BOX)
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	_add_container()
	_add_rich_text_label()
	_add_remove_button()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	


func _add_container() -> void:
	_container = HBoxContainer.new()
	add_child(_container)


func _add_rich_text_label() -> void:
	_rich_text_label = RichTextLabel.new()
	_rich_text_label.bbcode_enabled = true
	_rich_text_label.fit_content = true
	_rich_text_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_rich_text_label.add_theme_stylebox_override("normal", VnePluginController.RICH_TEXT_LABEL_STYLE_BOX)
	_rich_text_label.mouse_filter = Control.MOUSE_FILTER_PASS
	_container.add_child(_rich_text_label)
	
	_rich_text_label.gui_input.connect(_on_label_gui_input)


func _add_remove_button() -> void:
	_remove_button = Button.new()
	_remove_button.flat = true
	_remove_button.icon = EditorIcons.get_icon("Remove")
	_remove_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_remove_button.mouse_filter = Control.MOUSE_FILTER_PASS
	_container.add_child(_remove_button)
	_remove_button.hide()
	_remove_button.pressed.connect(_on_remove_button_pressed)

func _on_mouse_entered() -> void:
	_remove_button.show()


func _on_mouse_exited() -> void:
	_remove_button.hide()


func _on_remove_button_pressed() -> void:
	removed.emit(resource)
	queue_free()


func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			selected.emit(resource)


func _get_drag_data(at_position: Vector2) -> Variant:
	var rich_text_label = _rich_text_label.duplicate()
	set_drag_preview(rich_text_label)
	return self


func set_resource(resource: VneResource) -> void:
	self.resource = resource
	text = resource.name
