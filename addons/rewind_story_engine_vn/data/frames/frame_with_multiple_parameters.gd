@abstract class_name VneFrameWithMultipleParameters extends VneBaseFrameData


var parameters: Dictionary[String, float]


func get_string_data() -> PackedStringArray:
	var array = super()
	
	for parameter in parameters:
		array.append(parameter)
		array.append(str(parameters[parameter]))
	
	array.append("")
	
	return array


func fill_data(uuid: String, file: FileAccess) -> void:
	super(uuid, file)
	var line = file.get_line()
	while line != "":
		var parameter_uuid = line
		var parameter_value = float(file.get_line())
		parameters[parameter_uuid] = parameter_value
		line = file.get_line()


func copy_from(frame: VneBaseFrameData) -> void:
	super(frame)
	parameters.clear()
	if frame is VneFrameWithMultipleParameters:
		parameters = frame.parameters.duplicate(true)
