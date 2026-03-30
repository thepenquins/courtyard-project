@tool class_name VneScenePlayer extends Node


signal scene_ended(scene: VneScene)

@export var location_container: Node
@export var characters_container: VneCharactersContainer
@export var text_box: VneTextBox

var _scene: VneScene
var _frame: VneFrame
var _index: int

var _characters: Dictionary[VneCharacterResource, VneCharacter2D]
var _location_resource: VneLocationResource
var _current_location: VneLocation

var _is_new_location: bool = true

var _ready_to_next_frame: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_frame"):
		if _ready_to_next_frame:
			next_frame()
		else:
			text_box.advance()


func _on_text_box_frame_ended() -> void:
	_ready_to_next_frame = true


func set_scene(scene: VneScene, frame_index: int = 0) -> void:
	_scene = scene
	set_frame(frame_index)


func next_frame() -> bool:
	_ready_to_next_frame = false
	set_frame(_index + 1)
	return false


func prev_frame() -> bool:
	_ready_to_next_frame = true
	set_frame(_index - 1)
	return false


func set_frame(frame_index: int) -> void:
	if _scene == null:
		return
	
	var frame_info = _scene.get_frame(frame_index)
	
	if _frame == frame_info.frame:
		return

	_frame = frame_info.frame
	_index = frame_info.index
	
	if _frame == null:
		return
	
	if frame_info.index == _scene.frames.size() - 1:
		scene_ended.emit(_scene)
	
	set_location(_frame.location)
	set_characters(_frame.characters)
	set_music(_frame.music)
	## ...
	
	text_box.set_frame(_scene.episode.get_frame_by_uuid(_frame.uuid))


func set_location(location_frame: VneLocationFrame) -> void:
	# Если локация отличается, нужно удалить старую и загрузить новую, если она не null.
	if _location_resource != location_frame.location:
		_location_resource = location_frame.location
		
		# Удаляем прошлую локацию.
		if _current_location:
			_current_location.queue_free()
			_current_location = null
			
		if location_frame.location == null:
			return
		
		# Если у ресурса не указан файл, то ничего дальше делать не нужно.
		if location_frame.location.path_to_file == "":
			return
		
		var location_scene: PackedScene = load(location_frame.location.path_to_file)
		_current_location = location_scene.instantiate()
		location_container.add_child(_current_location)
		
		_is_new_location = true
	else:
		_is_new_location = false
	
	# Нужно передать параметры в локацию.
	if _current_location:
		_current_location.set_parameters(location_frame.parameters)


func set_characters(character_frames: Array[VneCharacterFrame]) -> void:
	for character in _characters:
		var visible: bool = false
		for character_frame in character_frames:
			if character_frame.character == character:
				_characters[character].emotion = character_frame.emotion
				visible = true
				break
		_characters[character].set_visibility(visible, _is_new_location)
	
	_reorder_characters(character_frames)
	characters_container.move_characters(_is_new_location)


func _reorder_characters(character_frames: Array[VneCharacterFrame]) -> void:
	var index = 0
	for character_frame in character_frames:
		var character_resource = character_frame.character
		var character_node = _characters.get(character_resource)
		if character_node and character_node.get_parent() == characters_container:
			var current_index = character_node.get_index()
			if current_index != index:
				characters_container.move_child(character_node, index)
		index += 1


func set_music(music_frame: VneMusicFrame) -> void:
	pass


## Загрузить персонажей, если их нет.
func load_all_characters() -> void:
	if VNE.visual_novel == null:
		return
	
	for character in VNE.visual_novel.characters:
		if not _characters.has(character):
			if character.path_to_file == "":
				continue
			var character_packed_scene: PackedScene = load(character.path_to_file)
			var character_scene: VneCharacter2D = character_packed_scene.instantiate()
			characters_container.add_character(character_scene)
			_characters[character] = character_scene
