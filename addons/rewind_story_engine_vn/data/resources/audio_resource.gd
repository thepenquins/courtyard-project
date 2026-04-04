@abstract
class_name VneAudioResource
extends VneResource

enum AudioType {
	Regular,
	FMOD,
} 

var audio_type: AudioType


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(str(audio_type))
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	audio_type = int(file.get_line())
