@tool class_name VneOptionInspectorParameter extends VneInspectorParameter


signal value_changed_string(value: String)

var _option_button: OptionButton

var options: Dictionary[int, String]


func _init(label_text: String, params: PackedStringArray) -> void:
	super(label_text)
	_option_button = OptionButton.new()
	_container.add_child(_option_button)
	var index := 0
	for option in params:
		_option_button.add_item(option)
		options[index] = option
		index += 1
	_option_button.item_selected.connect(_on_option_button_item_selected)


func set_value(value: float) -> void:
	if value < 0:
		value = 0
	elif value > options.size() - 1:
		value = options.size() - 1
	
	_option_button.select(int(value))
	value_changed.emit(value)
	value_changed_string.emit(options[int(value)])


func set_value_string(value: String) -> void:
	var index = options.values().find(value)
	if index == -1:
		index = 0
		value = options[index]
	_option_button.select(index)
	value_changed.emit(index)
	value_changed_string.emit(value)


func get_value() -> int:
	return _option_button.selected


func _on_option_button_item_selected(index: int) -> void:
	value_changed.emit(float(index))
	value_changed_string.emit(options[index])
