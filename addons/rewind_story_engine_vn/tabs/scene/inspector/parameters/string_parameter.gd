@tool class_name VneStringInspectorParameter extends VneInspectorParameter


var _line_edit: LineEdit


func _init(label_text: String, placeholder: String = "") -> void:
	super(label_text)
	_line_edit = LineEdit.new()
	_container.add_child(_line_edit)
	_line_edit.select_all_on_focus = true
	_line_edit.placeholder_text = placeholder
	_line_edit.text_changed.connect(_on_line_edit_text_changed)


func set_value(value: String) -> void:
	_line_edit.text = value
	value_changed.emit(value)


func get_value() -> String:
	return _line_edit.text


func _on_line_edit_text_changed(new_text: String) -> void:
	value_changed.emit(new_text)
