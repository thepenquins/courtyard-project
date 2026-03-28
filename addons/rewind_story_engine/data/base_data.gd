## Базовый класс для всех типов данных.
class_name RSEBaseData
extends RefCounted


var _extension: String = ".rsef"

var uuid: String:
	set(value):
		uuid = value
		short_key = "%8x" % uuid.hash()
var short_key: String
var name: String


var path_to_data_file: String:
	get:
		return "%s.%s" % [uuid, _extension]

var path_to_data_file_full: String


func _init(uuid: String, name: String = "unnamed") -> void:
	self.uuid = uuid
	self.name = name


func save_data(directory: String) -> void:
	var path = directory.path_join(path_to_data_file)
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	for s in get_string_data():
		file.store_line(s)
	
	file.close()
	
	path_to_data_file_full = path


func get_string_data() -> PackedStringArray:
	var array: PackedStringArray
	array.append(uuid)
	array.append(name)
	return array


func load_data(path_to_file: String) -> void:
	var file = FileAccess.open(path_to_file, FileAccess.READ)
	fill_data(file)
	file.close()
	
	path_to_data_file_full = path_to_file


func fill_data(file: FileAccess) -> void:
	uuid = file.get_line()
	name = file.get_line()


static func sort_data_array_by_name(array) -> void:
	array.sort_custom(func(a: RSEBaseData, b: RSEBaseData): return a.name < b.name)
