@tool extends HSlider


func _ready() -> void:
	_value_changed(value)


func _value_changed(new_value: float) -> void:
	var bus = FmodServer.get_bus("bus:/")
	if bus:
		bus.volume = new_value
