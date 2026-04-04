class_name VneLocationResource
extends VneResource


var cgi: bool = false
var parameters: Dictionary[String, PackedStringArray]


func get_string_data() -> PackedStringArray:
	var array = super()
	for parameter in parameters:
		array.append(parameter)
		for option in parameters[parameter]:
			array.append(option)
		array.append("")
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	while file.get_position() < file.get_length():
		var parameter_key = file.get_line()
		var parameter_options: PackedStringArray
		var line = file.get_line()
		while line != "":
			parameter_options.append(line)
			line = file.get_line()
		parameters[parameter_key] = parameter_options


func _setting_type() -> void:
	_type = TYPE_LOCATION
