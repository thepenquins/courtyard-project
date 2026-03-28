class_name RSEFrame
extends RSEBaseData


const SPECIAL_SEPARATOR: String = " >>> "


var speaker: String:
	set(value):
		speaker = value
		_character = _story.get_character_by_name(value)
	get:
		if _character != null:
			return _character.name
		return speaker
var speaker_with_color: String:
	get:
		if _character != null:
			return _character.name_with_color
		return speaker
var text: String

var text_with_speaker: String:
	get:
		if speaker == "":
			return text
		else:
			return "%s: %s" % [speaker_with_color, text]

var _story
var _character: RSECharacter

var is_commentary: bool:
	get:
		return text.begins_with("#")


func _init(story: RSEStory, uuid: String = "", speaker: String = "", text: String = "") -> void:
	self._story = story
	self.uuid = uuid
	self.speaker = speaker
	self.text = text


func get_string_data() -> PackedStringArray:
	var array: PackedStringArray
	if is_commentary:
		array.append(text)
		return array

	array.append(uuid)
	if speaker == "":
		array.append(text)
	else:
		array.append("%s%s%s" % [speaker, SPECIAL_SEPARATOR, text])
	return array


func fill_data(file: FileAccess) -> void:
	var first_line = file.get_line()

	if first_line.begins_with("#"):
		text = first_line
		return

	uuid = first_line
	var data = file.get_line()
	
	if data.contains(SPECIAL_SEPARATOR):
		var s = data.split(SPECIAL_SEPARATOR)
		speaker = s[0]
		text = s[1]
	else:
		text = data
