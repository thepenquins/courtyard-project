class_name RSECharacter
extends RSEBaseData


const FILE_EXTENSION: String = "rsec"


var color: Color

var name_with_color: String:
	get:
		return "[color=%s]%s[/color]" % [color.to_html(false), tr(name)]


func _init(uuid: String) -> void:
	super(uuid)
	self.color = Color.GRAY
	self._extension = FILE_EXTENSION


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(color.to_html())
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	color = Color.from_string(file.get_line(), Color.GRAY) 
