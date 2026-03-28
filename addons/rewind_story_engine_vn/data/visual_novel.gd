class_name VneVisualNovel
extends RefCounted


#region directories
const PATH_RESOURCES: String = "resources"
const PATH_SCENES: String = "scenes"

var _directory: String
var _directory_resources: String
var _directory_scenes: String
#endregion

const EXTENSION = ".vn"
var _path_to_vn_file: String

var story: RSEStory

#region resources
var resources: Array[VneResource]

var characters: Array[VneCharacterResource]
var locations: Array[VneLocationResource]
var music: Array[VneMusicResource]
var bgs: Array[VneBgsResource]
var sfx: Array[VneSfxResource]
var vfx: Array[VneVfxResource]
var transitions: Array[VneTransitionResource]

var scenes: Array[VneScene]
#endregion


func _init(story: RSEStory) -> void:
	self.story = story
	
	if story == null:
		return
	
	_setting_base_directories()
	_setting_path_to_vn()
	_check_directories()


func _setting_base_directories() -> void:
	_directory = story.get_directory()
	_directory_resources = _directory.path_join(PATH_RESOURCES)
	_directory_scenes = _directory.path_join(PATH_SCENES)


func _setting_path_to_vn() -> void:
	var story_file_name = story.get_filename_without_extension()
	_path_to_vn_file = _directory.path_join(story_file_name + EXTENSION)


func _check_directories() -> void:
	var dir_access = DirAccess.open(_directory)
	
	# Ресурсы.
	if not dir_access.dir_exists(_directory_resources):
		dir_access.make_dir(_directory_resources)
		
	# Сцены.
	if not dir_access.dir_exists(_directory_scenes):
		dir_access.make_dir(_directory_scenes)


#region loading
func load_vn() -> void:
	if not FileAccess.file_exists(_path_to_vn_file):
		return
	
	print_rich("[color=orange]VNE[/color]: Загрузка [b]%s[/b]." % story.name)
	
	_load_resources()
	print_rich("[color=orange]VNE[/color]: Загружено %s ресурсов." % resources.size())
	_load_scenes()
	print_rich("[color=orange]VNE[/color]: Загружено %s сцен." % scenes.size())
	
	check_character_resources()


func get_files_in_directory(directory: String, extension: String) -> PackedStringArray:
	var files: PackedStringArray
	
	var dir = DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(extension):
				files.append(file_name)
			file_name = dir.get_next()
	
	return files


func _load_resources() -> void:
	for file in get_files_in_directory(_directory_resources, VneResource.FILE_EXTENSION):
		var raw_resource = VneResource.new("")
		raw_resource.load_data(_directory_resources.path_join(file))
		var casted_resource = raw_resource.load_casted_resource()
		add_resource(casted_resource)
	RSEBaseData.sort_data_array_by_name(resources)


func _load_scenes() -> void:
	for file in get_files_in_directory(_directory_scenes, VneScene.FILE_EXTENSION):
		var scene = VneScene.new("")
		scene.load_data(_directory_scenes.path_join(file))
		scenes.append(scene)


## Создать ресурсы персонажей, если их нет.
func check_character_resources() -> void:
	for character in RSE.characters:
		if get_character_resource(character) == null:
			add_character_resource(character)
#endregion

#region saving
func save_vn() -> void:
	print_rich("[color=orange]VNE[/color]: Сохранение [b]%s[/b]." % story.name)
	
	var file = FileAccess.open(_path_to_vn_file, FileAccess.WRITE)
	file.store_line(story.name)
	file.close()
	
	_save_resources()
	_save_scenes()


func _save_resources() -> void:
	for resource in resources:
		if resource:
			resource.save_data(_directory_resources)


func _save_scenes() -> void:
	for scene in scenes:
		scene.save_data(_directory_scenes)
#endregion

#region utils
func _get_array_by_resource_type(resource: VneResource) -> Array:
	if resource is VneCharacterResource:
		return characters
	elif resource is VneLocationResource:
		return locations
	elif resource is VneMusicResource:
		return music
	elif resource is VneBgsResource:
		return bgs
	elif resource is VneSfxResource:
		return sfx
	elif resource is VneVfxResource:
		return vfx
	elif resource is VneTransitionResource:
		return transitions
	return []


func add_resource(resource: VneResource) -> void:
	resources.append(resource)
	_get_array_by_resource_type(resource).append(resource)


func remove_resource(resource: VneResource) -> void:
	resources.erase(resource)
	_get_array_by_resource_type(resource).erase(resource)
	
	if resource.path_to_data_file_full != "":
		DirAccess.remove_absolute(resource.path_to_data_file_full)


func get_resource_by_uuid(uuid: String) -> VneResource:
	for resource in resources:
		if resource.uuid == uuid:
			return resource
	return null


func get_character_by_uuid(uuid: String) -> VneCharacterResource:
	for resource in characters:
		if resource.uuid == uuid:
			return resource
	return null

func get_resource_index_in_array(resource: VneResource) -> int:
	var array = _get_array_by_resource_type(resource)
	for index in array.size():
		if array[index].uuid == resource.uuid:
			return index
	return -1


func get_scene_by_episode(episode: RSEEpisode) -> VneScene:
	for scene in scenes:
		if scene.episode == episode:
			return scene
	
	var scene = VneScene.new(RSE.story.get_uuid())
	scene.set_episode(episode)
	scenes.append(scene)
	return scene


func get_character_resource(character: RSECharacter) -> VneCharacterResource:
	for character_resource in characters:
		if character_resource.character.uuid == character.uuid:
			return character_resource
	return null 


func add_character_resource(character: RSECharacter) -> void:
	var character_resource = VneCharacterResource.new(RSE.story.get_uuid(), character.name)
	character_resource.character = character
	add_resource(character_resource)


func remove_character_resource(character: RSECharacter) -> void:
	var resource = get_character_resource(character)
	remove_resource(resource)
#endregion
