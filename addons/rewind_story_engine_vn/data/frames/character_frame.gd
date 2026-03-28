class_name VneCharacterFrame extends VneBaseFrameData


var emotion: String

var character: VneCharacterResource:
	get:
		return resource


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(emotion)
	return array


func fill_data(uuid: String, file: FileAccess) -> void:
	super(uuid, file)
	emotion = file.get_line()


func copy_from(frame: VneBaseFrameData) -> void:
	super(frame)
	if frame is VneCharacterFrame:
		emotion = frame.emotion
