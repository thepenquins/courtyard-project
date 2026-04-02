@tool class_name VneScenePlayer extends Node


signal frame_setting(rse_frame: RSEFrame, vn_frame: VneFrame)
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
var _current_music: VneMusicResource
var _music_player: FmodEventEmitter2D
var _current_bgs: VneBgsResource
var _bgs_player: FmodEventEmitter2D

var _is_new_location: bool = true

var _ready_to_next_frame: bool = false

const REWIND_RELOAD_TIME: float = 0.05
var _current_rewind_reload: float = 0.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_frame"):
		if Engine.is_editor_hint():
			text_box.advance()
		else:
			if _ready_to_next_frame:
				next_frame()
			else:
				text_box.advance()
	if event.is_action_pressed("prev_frame"):
		if not Engine.is_editor_hint():
			if _ready_to_next_frame:
				prev_frame()
			else:
				text_box.skip()


func _process(delta: float) -> void:
	if _current_rewind_reload > 0:
		_current_rewind_reload -= delta
	
	if Input.is_action_pressed("rewind"):
		if not Engine.is_editor_hint() and _current_rewind_reload <= 0:
			_current_rewind_reload = REWIND_RELOAD_TIME
			next_frame(true)


func _on_text_box_frame_ended() -> void:
	_ready_to_next_frame = true


func set_scene(scene: VneScene, frame_index: int = 0) -> void:
	_scene = scene
	set_frame(frame_index)


func next_frame(instantly: bool = false) -> bool:
	var new_index = _index + 1
	if new_index >= _scene.episode.frames_without_commentary.size():
		return false
	
	_ready_to_next_frame = false
	set_frame(new_index, instantly)
	return true


func prev_frame() -> bool:
	var new_index = _index - 1
	if new_index < 0:
		return false
	
	_ready_to_next_frame = true
	set_frame(new_index, true)
	return true


func set_frame(frame_index: int, instantly: bool = false) -> void:
	if _scene == null:
		return
	
	var frame_info = _scene.get_frame(frame_index, true)
	
	if _frame == frame_info.frame:
		return

	_frame = frame_info.frame
	_index = frame_info.index
	
	if _frame == null:
		return
	
	if frame_info.index == _scene.frames.size() - 1:
		scene_ended.emit(_scene)
	
	set_location(_frame.location)
	set_characters(_frame.characters, instantly)
	set_music(_frame.music)
	set_bgs(_frame.bgs)
	set_sfx(_frame.sfx)
	## ...
	
	var rse_frame = _scene.episode.get_frame_by_uuid(_frame.uuid)
	
	set_text(rse_frame, instantly)
	
	frame_setting.emit(rse_frame, _frame)


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


func set_characters(character_frames: Array[VneCharacterFrame], instantly: bool = false) -> void:
	for character in _characters:
		var visible: bool = false
		for character_frame in character_frames:
			if character_frame.character == character:
				_characters[character].emotion = character_frame.emotion
				visible = true
				break
		_characters[character].set_visibility(visible, _is_new_location or instantly)
	
	_reorder_characters(character_frames)
	characters_container.move_characters(_is_new_location or instantly)


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
	_music_player = set_audio(_music_player, _current_music, music_frame)
	_current_music = music_frame.music


func set_bgs(bgs_frame: VneBgsFrame) -> void:
	_bgs_player = set_audio(_bgs_player, _current_bgs, bgs_frame)
	_current_bgs = bgs_frame.bgs


func set_sfx(sfx_array: Array[VneSfxFrame]) -> void:
	for sfx in sfx_array:
		var emitter = set_audio(null, null, sfx)


func set_audio(player: FmodEventEmitter2D, current_audio: VneAudioResource, audio_frame: VneFrameWithMultipleParameters) -> FmodEventEmitter2D:
	#if Engine.is_editor_hint(): ## TODO: Починить воспроизведение в редакторе.
		#return
		
	if audio_frame.resource == null:
		if player:
			player.stop()
		return null
	
	if current_audio == audio_frame.resource:
		if player:
			_set_fmod_event_emitter_2D_parameters(player, audio_frame.parameters)
		return player
	
	player = _create_fmod_event_emitter_2D(audio_frame.resource.path_to_file)
	_set_fmod_event_emitter_2D_parameters(player, audio_frame.parameters)
	
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if Engine.is_editor_hint(): ## TODO: Починить воспроизведение в редакторе.
		player.play()
		#var event_instance = FmodServer.create_event_instance(audio_frame.resource.path_to_file)
		#event_instance.position
		#var desc = FmodServer.get_event(audio_frame.resource.path_to_file)
		#if desc.is_valid():
			#print(desc.get_instance_count()) 
			#print(desc.get_instance_list()) 
	
	return player


func set_text(rse_frame: RSEFrame = null, instantly: bool = false) -> void:
	if not rse_frame:
		rse_frame = _scene.episode.get_frame_by_uuid(_frame.uuid)
	text_box.set_frame(rse_frame, _frame, instantly)


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


func _create_fmod_event_emitter_2D(event_name: String) -> FmodEventEmitter2D:
	var event_emitter = FmodEventEmitter2D.new()
	event_emitter.event_name = event_name
	event_emitter.autoplay = true
	event_emitter.auto_release = true
	add_child(event_emitter)
	return event_emitter


func _set_fmod_event_emitter_2D_parameters(event_emitter: FmodEventEmitter2D, parameters: Dictionary[String, float]) -> void:
	for parameter in parameters:
		event_emitter.set_parameter_by_id(int(parameter), parameters[parameter])
	
	if Engine.is_editor_hint(): ## TODO: Починить воспроизведение в редакторе.
		event_emitter.play()


func _exit_tree() -> void:
	if _music_player:
		_music_player.stop()
	if _bgs_player:
		_bgs_player.stop()


#func _ready() -> void:
	#var event_instance = FmodServer.create_event_instance("event:/mus/mus_bachbabach")
	#event_instance.position = 2000
	#event_instance.start()
	#await get_tree().create_timer(4).timeout
	#event_instance.stop(0)
	#event_instance = null
