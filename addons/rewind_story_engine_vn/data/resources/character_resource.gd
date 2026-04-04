class_name VneCharacterResource
extends VneResource


var character: RSECharacter
var emotions: PackedStringArray


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(character.uuid)
	for emotion in emotions:
		array.append(emotion)
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	var character_uuid = file.get_line()
	character = RSE.story.get_character_by_uuid(character_uuid)
	
	if character:
		name = character.name
	
	while file.get_position() < file.get_length():
		emotions.append(file.get_line())


func _setting_type() -> void:
	_type = TYPE_CHARACTER
