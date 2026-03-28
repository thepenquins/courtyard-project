class_name RSERecord
extends RSEBaseData


const FILE_EXTENSION: String = "rser"


var text: String


func _init(uuid: String) -> void:
	super(uuid)
	self._extension = FILE_EXTENSION


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(text)
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	while file.get_position() < file.get_length():
		if not text.is_empty():
			text += "\n"
		text += file.get_line()
