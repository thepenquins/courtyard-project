@tool class_name VneIntInspectorParameter extends VneSpinBoxInspectorParameter


func _set_step() -> void:
	_spin_box.step = 1


func _get_label_text_with_range(label_text: String, min_value: int, max_value: int) -> String:
	return "%s [%s; %s]" % [label_text, min_value, max_value]
