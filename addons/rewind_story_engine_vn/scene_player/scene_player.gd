@tool class_name VneScenePlayer extends Node


signal frame_setting(rse_frame: RSEFrame, vn_frame: VneFrame)
signal scene_ended(scene: VneScene)
signal to_prev_scene

@export var location_container: Node
@export var characters_container: VneCharactersContainer
@export var text_box: VneTextBox

var _scene: VneScene
var _frame: VneFrame
var _index: int

static var _characters_packed_scenes: Dictionary[VneCharacterResource, PackedScene]
static var _locations: Dictionary[VneLocationResource, PackedScene]
static var _transitions: Dictionary[VneTransitionResource, PackedScene]
static var _vfx: Dictionary[VneVfxResource, PackedScene]

var _characters: Dictionary[VneCharacterResource, VneCharacter2D]

var _location_resource: VneLocationResource
var _current_location: VneLocation
var _current_music: VneMusicResource
var _editor_music_player: FmodEvent
var _music_player: FmodEventEmitter2D
var _current_bgs: VneBgsResource
var _editor_bgs_player: FmodEvent
var _bgs_player: FmodEventEmitter2D

var _current_vfx: Dictionary[VneVfxResource, VneVfx]

var _is_new_location: bool = true

var _ready_to_next_frame: bool = false

const REWIND_RELOAD_TIME: float = 0.05
var _current_rewind_reload: float = 0.0

var transition_playing: bool = false


func _ready() -> void:
	text_box.prev_button.pressed.connect(_prev_frame_pressed)
	text_box.next_button.pressed.connect(_next_frame_pressed)
	text_box.rewind_button.pressed.connect(_rewind)


func _input(event: InputEvent) -> void:
	if transition_playing:
		return
	
	if text_box.mouse_on_ui:
		return
	
	if not text_box.visible:
		return
	
	if event.is_action_pressed("next_frame"):
		_next_frame_pressed()
	if event.is_action_pressed("prev_frame"):
		_prev_frame_pressed()


func _next_frame_pressed() -> void:
	if Engine.is_editor_hint():
		text_box.advance()
	else:
		if _ready_to_next_frame:
			await play_transition(_frame.transition_out, true)
			if not next_frame():
				scene_ended.emit(_scene)
		else:
			if not transition_playing:
				text_box.advance()


func  _prev_frame_pressed() -> void:
	if not Engine.is_editor_hint():
		if _ready_to_next_frame:
			if not prev_frame():
				to_prev_scene.emit()
		else:
			text_box.skip()


func _process(delta: float) -> void:
	if _current_rewind_reload > 0:
		_current_rewind_reload -= delta
	
	if Input.is_action_pressed("rewind"):
		_rewind()


func _rewind() -> void:
	if not Engine.is_editor_hint() and _current_rewind_reload <= 0:
		_current_rewind_reload = REWIND_RELOAD_TIME
		if Settings.rewind_mode == Settings.RewindMode.Viewed:
			if Settings.profile.is_viewed(_scene.episode.uuid, _index + 1):
				if not next_frame(true):
					scene_ended.emit(_scene)
		else:
			if not next_frame(true):
				scene_ended.emit(_scene)


func _on_text_box_frame_ended() -> void:
	_ready_to_next_frame = true


func set_scene(scene: VneScene, frame_index: int = 0) -> void:
	_ready_to_next_frame = false
	_scene = scene
	set_frame(frame_index)



func set_scene_from_end(scene: VneScene) -> void:
	_ready_to_next_frame = true
	_scene = scene
	set_frame(_scene.episode.frames.size() - 1, true)


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
	
	if not Engine.is_editor_hint():
		Settings.profile.add_viewed(_scene.episode.uuid, _index)
	
	set_location(_frame.location)
	set_characters(_frame.characters, instantly)
	set_music(_frame.music)
	set_bgs(_frame.bgs)
	set_sfx(_frame.sfx)
	set_vfx(_frame.vfx)
	## ...
	
	var rse_frame = _scene.episode.get_frame_by_uuid(_frame.uuid)
	
	if not instantly:
		await play_transition(_frame.transition_in, true)
	
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
		
		#var location_scene: PackedScene = load(location_frame.location.path_to_file)
		_current_location = _locations[location_frame.location].instantiate()
		location_container.add_child(_current_location)
		
		_is_new_location = true
	else:
		_is_new_location = false
	
	# Нужно передать параметры в локацию.
	if _current_location:
		var new_location_state = _current_location.set_parameters(location_frame.parameters)
		if not _is_new_location:
			_is_new_location = new_location_state


func set_characters(character_frames: Array[VneCharacterFrame], instantly: bool = false) -> void:
	for character in _characters:
		var visible: bool = false
		for character_frame in character_frames:
			if character_frame.character == character:
				_characters[character].scaling_mode = character_frame.scaling_mode
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
	if Engine.is_editor_hint():
		_editor_music_player = set_audio_fmod_event(_editor_music_player, _current_music, music_frame)
	else:
		_music_player = set_audio_fmod_event_emitter_2d(_music_player, _current_music, music_frame)
	_current_music = music_frame.music


func set_bgs(bgs_frame: VneBgsFrame) -> void:
	if Engine.is_editor_hint():
		_editor_bgs_player = set_audio_fmod_event(_editor_bgs_player, _current_bgs, bgs_frame)
	else:
		_bgs_player = set_audio_fmod_event_emitter_2d(_bgs_player, _current_music, bgs_frame)
	_current_bgs = bgs_frame.bgs


func set_sfx(sfx_array: Array[VneSfxFrame]) -> void:
	for sfx in sfx_array:
		var emitter = set_audio_fmod_event(null, null, sfx)


func set_vfx(vfx_array: Array[VneVfxFrame]) -> void:
	var new_vfx_dict: Dictionary[VneVfxResource, VneVfx]
	for vfx in vfx_array:
		if _current_vfx.has(vfx.resource):
			new_vfx_dict[vfx.vfx] = _current_vfx[vfx.vfx]
			_current_vfx.erase(vfx.vfx)
		else:
			var vfx_scene = _vfx[vfx.vfx].instantiate() as VneVfx
			add_child(vfx_scene)
			new_vfx_dict[vfx.vfx] = vfx_scene
	
	for vfx: VneVfx in _current_vfx.values():
		vfx.queue_free()
	
	_current_vfx = new_vfx_dict.duplicate_deep()


func set_audio_fmod_event(fmod_event: FmodEvent, current_audio: VneAudioResource, audio_frame: VneFrameWithMultipleParameters) -> FmodEvent:
	if audio_frame.resource == null:
		if fmod_event:
			fmod_event.stop(0)
		return null
	
	if current_audio == audio_frame.resource:
		if fmod_event:
			_set_fmod_event_parameters(fmod_event, audio_frame.resource, audio_frame.parameters)
		return fmod_event
	
	if fmod_event:
		fmod_event.stop(0)
	
	fmod_event = _create_fmod_event(audio_frame.resource.path_to_file)
	_set_fmod_event_parameters(fmod_event, audio_frame.resource, audio_frame.parameters)
	
	return fmod_event


func set_audio_fmod_event_emitter_2d(event_emitter: FmodEventEmitter2D, current_audio: VneAudioResource, audio_frame: VneFrameWithMultipleParameters) -> FmodEventEmitter2D:
	if audio_frame.resource == null:
		if event_emitter:
			event_emitter.stop()
		return null
	
	if current_audio == audio_frame.resource:
		if event_emitter:
			_set_fmod_event_emitter_2D_parameters(event_emitter, audio_frame.resource, audio_frame.parameters)
		return event_emitter
	
	if event_emitter:
		event_emitter.stop()
	
	event_emitter = _create_fmod_event_emitter_2D(audio_frame.resource.path_to_file)
	_set_fmod_event_emitter_2D_parameters(event_emitter, audio_frame.resource, audio_frame.parameters)
	
	return event_emitter


func set_text(rse_frame: RSEFrame = null, instantly: bool = false) -> void:
	if not rse_frame:
		rse_frame = _scene.episode.get_frame_by_uuid(_frame.uuid)
	text_box.set_frame(rse_frame, _frame, instantly)


## Загрузить персонажей, если их нет.
func instantiate_all_characters() -> void:
	for character_resource in _characters_packed_scenes:
		if not _characters.has(character_resource):
			var character_scene: VneCharacter2D = _characters_packed_scenes[character_resource].instantiate()
			characters_container.add_character(character_scene)
			character_scene.set_visibility(false)
			_characters[character_resource] = character_scene


static func load_all_resources() -> void:
	load_all_characters()
	load_all_locations()
	load_all_transitions()
	load_all_vfx()


## Загрузить персонажей, если их нет.
static func load_all_characters() -> void:
	if VNE.visual_novel == null:
		return
	
	for character in VNE.visual_novel.characters:
		if not _characters_packed_scenes.has(character):
			if character.path_to_file == "":
				continue
			var character_packed_scene: PackedScene = load(character.path_to_file)
			_characters_packed_scenes[character] = character_packed_scene


## Загрузить локации, если их нет.
static func load_all_locations() -> void:
	if VNE.visual_novel == null:
		return
	
	for location in VNE.visual_novel.locations:
		if not _locations.has(location):
			if location.path_to_file == "":
				continue
			var location_packed_scene: PackedScene = load(location.path_to_file)
			_locations[location] = location_packed_scene


static func load_all_transitions() -> void:
	if VNE.visual_novel == null:
		return
	
	for transition in VNE.visual_novel.transitions:
		if not _transitions.has(transition):
			if transition.path_to_file == "":
				continue
			var transition_packed_scene: PackedScene = load(transition.path_to_file)
			_transitions[transition] = transition_packed_scene


static func load_all_vfx() -> void:
	if VNE.visual_novel == null:
		return
	
	for vfx in VNE.visual_novel.vfx:
		if not _vfx.has(vfx):
			if vfx.path_to_file == "":
				continue
			var vfx_packed_scene: PackedScene = load(vfx.path_to_file)
			_vfx[vfx] = vfx_packed_scene


func _create_fmod_event(event_name: String) -> FmodEvent:
	var event_instance = FmodServer.create_event_instance(event_name)
	event_instance.start()
	return event_instance


func _create_fmod_event_emitter_2D(event_name: String) -> FmodEventEmitter2D:
	var event_emitter = FmodEventEmitter2D.new()
	event_emitter.event_name = event_name
	event_emitter.autoplay = true
	event_emitter.auto_release = true
	add_child(event_emitter)
	return event_emitter


func _set_fmod_event_parameters(fmod_event: FmodEvent, audio: VneAudioResource, parameters: Dictionary[String, float]) -> void:
	if audio == null:
		return
	
	var event_description = FmodServer.get_event(audio.path_to_file)
	
	if not event_description.is_valid():
		return
	
	var event_parameters = event_description.get_parameters()
	
		
	for parameter in parameters:
		if event_description.get_parameter_by_id(int(parameter)):
			fmod_event.set_parameter_by_id(int(parameter), parameters[parameter])


func _set_fmod_event_emitter_2D_parameters(event_emitter: FmodEventEmitter2D, audio: VneAudioResource, parameters: Dictionary[String, float]) -> void:
	if audio == null:
		return
	
	var event_description = FmodServer.get_event(audio.path_to_file)
	
	if not event_description.is_valid():
		return
	
	var valid_parameters: Dictionary[String, float]
		
	var event_parameters = event_description.get_parameters()
	for parameter in parameters:
		var is_valid: bool = false
		for event_parameter: FmodParameterDescription in event_parameters:
			if event_parameter.get_id() == int(parameter):
				is_valid = true
				break
		if is_valid:
			valid_parameters[parameter] = parameters[parameter]
	
	for parameter in valid_parameters:
		event_emitter.set_parameter_by_id(int(parameter), valid_parameters[parameter])


func _exit_tree() -> void:
	stop_all_audio()


func stop_all_audio() -> void:
	if _editor_music_player:
		_editor_music_player.stop(0)
	if _editor_bgs_player:
		_editor_bgs_player.stop(0)
	
	if _music_player:
		_music_player.stop()
	if _bgs_player:
		_bgs_player.stop()


func play_all_audio() -> void:
	if _editor_music_player:
		_editor_music_player.start()
	if _editor_bgs_player:
		_editor_bgs_player.start()
	
	if _music_player:
		_music_player.play()
	if _bgs_player:
		_bgs_player.play()


func play_transition(transition_resource: VneTransitionResource, clear_text_box: bool) -> void:
	if transition_resource != null:
		transition_playing = true
		if clear_text_box:
			text_box.clear()
		var transition_packed_scene = _transitions[transition_resource]
		var transition_scene = transition_packed_scene.instantiate() as VneTransition
		add_child(transition_scene)
		await transition_scene.ended
		transition_playing = false
