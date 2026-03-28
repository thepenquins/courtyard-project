@tool
extends Container


signal order_changed


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is VneResourceContainer and data.get_parent() == self


func _drop_data(at_position: Vector2, data: Variant) -> void:
	for child: Control in get_children():
		if child == data:
			continue
		var rect = child.get_rect()
		if at_position.x > rect.position.x and at_position.x < rect.size.x + rect.position.x:
			var index = child.get_index()
			move_child(data, index)
			order_changed.emit()
