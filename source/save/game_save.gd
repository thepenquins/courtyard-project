class_name GameSave extends RefCounted


var _data: Array[ASaveData]


func add_save_data(save_data: ASaveData) -> void:
	_data.append(save_data)


func clear() -> void:
	_data.clear()


func write(path_to_file: String) -> void:
	var data: Dictionary = {}

	for d in _data:
		d.add_data_to_dictionary(data)

	var json_string = JSON.stringify(data, " ")
	var base64 = Marshalls.utf8_to_base64(json_string)

	var file = FileAccess.open(path_to_file, FileAccess.WRITE)
	file.store_string(base64)
	file.close()


func read(path_to_file: String) -> void:
	clear()

	var file = FileAccess.open(path_to_file, FileAccess.READ)   
	if file == null:
		return

	var base64 = file.get_as_text()
	var json_string = Marshalls.base64_to_utf8(base64)
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		for key in json.data:
			var type = json.data[key]["type"]
			var value = json.data[key]["value"]
			var save_data = get_save_data(type, key, value)
			add_save_data(save_data)


func get_save_data(type: String, key: String, value) -> ASaveData:
	match type:
		_:
			return ASaveData.new(key, value)
