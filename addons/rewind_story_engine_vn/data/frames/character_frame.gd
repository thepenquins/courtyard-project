class_name VneCharacterFrame extends VneBaseFrameData


var emotion: String
var displayed_name: String = ""

var character: VneCharacterResource:
	get:
		return resource


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(emotion)
	array.append(displayed_name)
	return array


func fill_data(uuid: String, file: FileAccess) -> void:
	super(uuid, file)
	emotion = file.get_line()
	displayed_name = file.get_line()


func copy_from(frame: VneBaseFrameData) -> void:
	super(frame)
	if frame is VneCharacterFrame:
		emotion = frame.emotion
		displayed_name = frame.displayed_name


func get_displayed_name() -> String:
	if displayed_name == "":
		return character.name
	else:
		return displayed_name
