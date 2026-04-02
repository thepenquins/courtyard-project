class_name Game extends Node

@export var scene_player: VneScenePlayer
@export var options: GameOptions
@export var history: History
@export var pause: Control

var _prev_rse_frame: RSEFrame
var _prev_vn_frame: VneFrame

var _current_episode_uuid: String = ""
var _episode_uuid_order: PackedStringArray
var _score: int = 0


func _ready() -> void:
	scene_player.load_all_characters()
	_start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not pause.visible:
			_pause()
	if event.is_action_pressed("switch_history"):
		history.visible = not history.visible
		scene_player.text_box.visible = not history.visible
		scene_player.process_mode = Node.PROCESS_MODE_DISABLED if history.visible else Node.PROCESS_MODE_INHERIT
	if event.is_action_pressed("switch_interface_visibility"):
		pass


func _start() -> void:
	_set_scene_by_episode_uuid("2e06a402-8c35-4b45-a56a-461653c4289c")


func _set_scene_by_episode_uuid(uuid: String) -> void:
	if _current_episode_uuid != "":
		_episode_uuid_order.append(_current_episode_uuid)
	_current_episode_uuid = uuid
	
	history.clear()
	
	var episode = RSE.get_episode_by_uuid(uuid)
	var scene = VNE.visual_novel.get_scene_by_episode(episode)
	scene_player.set_scene(scene)


func _set_scene_by_episode_uuid_backward() -> void:
	_episode_uuid_order.erase(_current_episode_uuid)
	
	if _episode_uuid_order.size() == 0:
		print("Предыдущих сцен нет")
		return
	
	_current_episode_uuid = _episode_uuid_order[_episode_uuid_order.size() - 1]
	
	var episode = RSE.get_episode_by_uuid(_current_episode_uuid)
	var scene = VNE.visual_novel.get_scene_by_episode(episode)
	scene_player.set_scene_from_end(scene)


func _pause() -> void:
	pause.show()
	history.visible = false
	scene_player.text_box.visible = true
	scene_player.process_mode = Node.PROCESS_MODE_DISABLED


func _continue() -> void:
	pause.hide()
	scene_player.process_mode = Node.PROCESS_MODE_INHERIT


func _on_scene_player_frame_setting(rse_frame: RSEFrame, vn_frame: VneFrame) -> void:
	if _prev_rse_frame != null:
		history.add_record(_prev_rse_frame, _prev_vn_frame)
	
	_prev_rse_frame = rse_frame
	_prev_vn_frame = vn_frame


func _on_scene_player_scene_ended(scene: VneScene) -> void:
	if scene.episode.uuid == "2e06a402-8c35-4b45-a56a-461653c4289c": ## Начало
		options.add_options(["Резко перебить мать", "Молчать и наблюдать за срачем с удовольствием"])
		
		scene_player.set_process_input(false)
		var index = await options.option_selected
		scene_player.set_process_input(true)
		
		if index == 0:
			_set_scene_by_episode_uuid("c58d0710-b1fd-411f-995e-5efe754ceffa") ## Резко перебить мать
		elif index == 1:
			_score += 1
			_set_scene_by_episode_uuid("b13ca84a-5613-44ad-bad7-9042f629f977") ## Молчать и наблюдать за срачем с удовольствием
		
	elif scene.episode.uuid == "b13ca84a-5613-44ad-bad7-9042f629f977": ## Молчать и наблюдать за срачем с удовольствием
		_set_scene_by_episode_uuid("c58d0710-b1fd-411f-995e-5efe754ceffa") ## Резко перебить мать


func _on_scene_player_to_prev_scene() -> void:
	if _current_episode_uuid == "b13ca84a-5613-44ad-bad7-9042f629f977": ## Молчать и наблюдать за срачем с удовольствием
		_score -= 1
	#elif _current_episode_uuid == "b13ca84a-5613-44ad-bad7-9042f629f977": ## Молчать и наблюдать за срачем с удовольствием
		#_score -= 1
	#elif _current_episode_uuid == "b13ca84a-5613-44ad-bad7-9042f629f977": ## Молчать и наблюдать за срачем с удовольствием
		#_score -= 1
	_set_scene_by_episode_uuid_backward()
