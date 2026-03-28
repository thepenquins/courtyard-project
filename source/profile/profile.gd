extends Node


const PATH_TO_PROFILE = "user://profile"


## Данные профиля для сохранения / загрузки.
var _data: Array[ProfileData] = [
]

## Список достижений.
var _achievements: Array[ProfileAchievement] = [
]


func _enter_tree():
	load_profile()


func _exit_tree():
	save_profile()


func load_profile() -> void:
	var file = FileAccess.open(PATH_TO_PROFILE, FileAccess.READ)   
	if file == null:
		return
	
	var base64 = file.get_as_text()
	var json_string = Marshalls.base64_to_utf8(base64)
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		_fill_data_array_from_json(json, "data", _data)
		_fill_data_array_from_json(json, "achievements", _achievements)
	
	print("Profile has been loaded.")


func _fill_data_array_from_json(json: JSON, key: String, data_array: Array) -> void:
	if json.data.has(key):
		for d: ProfileData in data_array:
			if json.data[key].has(d.key):
				d._v = json.data[key][d.key]


func save_profile() -> void:
	var data: Dictionary = {}

	_save_data_array_to_dictionary(data, "data", _data)
	_save_data_array_to_dictionary(data, "achievements", _achievements)
	
	var json_string = JSON.stringify(data, " ")
	var base64 = Marshalls.utf8_to_base64(json_string)
	
	var file = FileAccess.open(PATH_TO_PROFILE, FileAccess.WRITE)
	file.store_string(base64)
	file.close()


func _save_data_array_to_dictionary(dictionary: Dictionary, key: String, data_array: Array) -> void:
	dictionary[key] = {}
	for d: ProfileData in data_array:
		dictionary[key][d.key] = d.value


func unlock_achievement(achievement_key: String) -> bool:
	for achievement in _achievements:
		if achievement.key.to_lower() == achievement_key.to_lower():
			achievement.value = true
			print("Открыто достижение: %s" % achievement.key)
			return true

	return false
