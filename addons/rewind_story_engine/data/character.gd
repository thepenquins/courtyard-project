class_name RSECharacter
extends RSEBaseData


const FILE_EXTENSION: String = "rsec"


var color: Color
var path_to_scene_file: String

var name_with_color: String:
	get:
		return "[color=%s]%s" % [color.to_html(false), tr(name)]


func _init(uuid: String) -> void:
	super(uuid)
	self.color = Color.GRAY
	self.path_to_scene_file = ""
	self._extension = FILE_EXTENSION


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(color.to_html())
	array.append(path_to_scene_file)
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	color = Color.from_string(file.get_line(), Color.GRAY) 
	path_to_scene_file = file.get_line()
