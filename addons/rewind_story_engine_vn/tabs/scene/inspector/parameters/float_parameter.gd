@tool class_name VneFloatInspectorParameter extends VneSpinBoxInspectorParameter


func _set_step() -> void:
	_spin_box.step = 0.01


func _get_label_text_with_range(label_text: String, min_value: float, max_value: float) -> String:
	return "%s [%s; %s]" % [label_text, min_value, max_value]
