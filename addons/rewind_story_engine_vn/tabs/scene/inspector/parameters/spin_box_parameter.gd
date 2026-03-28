@tool @abstract class_name VneSpinBoxInspectorParameter extends VneInspectorParameter


var _spin_box: SpinBox


func _init(label_text: String, min_value: float, max_value: float) -> void:
	super(_get_label_text_with_range(label_text, min_value, max_value))
	_spin_box = SpinBox.new()
	_container.add_child(_spin_box)
	_spin_box.select_all_on_focus = true
	_spin_box.min_value = min_value
	_spin_box.max_value = max_value
	_spin_box.value_changed.connect(_on_spin_box_value_changed)
	_set_step()


@abstract func _get_label_text_with_range(label_text: String, min_value, max_value) -> String

@abstract func _set_step() -> void


func set_value(value: float) -> void:
	_spin_box.value = value
	value_changed.emit(value)


func get_value() -> float:
	return _spin_box.value


func _on_spin_box_value_changed(value: float) -> void:
	value_changed.emit(value)
