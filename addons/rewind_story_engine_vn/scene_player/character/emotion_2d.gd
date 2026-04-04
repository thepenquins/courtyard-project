class_name VneCharacter2DEmotion extends RSEBaseData

const FILE_EXTENSION: String = "vne"

var animations: Array[VneCharacter2DAnimation]


func _init(path_to_file: String) -> void:
	var file_name = path_to_file.get_file()
	name = file_name.substr(0, file_name.length() - FILE_EXTENSION.length() - 1).capitalize()
	load_data(path_to_file)


func load_data(path_to_file: String) -> void:
	var file = FileAccess.open(path_to_file, FileAccess.READ)
	fill_data(file)
	file.close()


func fill_data(file: FileAccess) -> void:
	while file.get_position() < file.get_length():
		var animation = VneCharacter2DAnimation.new()
		animation.animated_sprite_name = file.get_line()
		animation.speed = int(file.get_line())
		var line = file.get_line()
		while line != "":
			animation.sprites.append(line)
			line = file.get_line()
		animations.append(animation)
