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

var _is_handling_scene_end : bool = false

var interface_visible: bool = true

var _screenshoot: Image

static var save_to_load: Save


func _ready() -> void:
	scene_player.load_all_characters()
	scene_player.load_all_locations()
	
	if save_to_load != null:
		load_save(save_to_load)
		save_to_load = null
	else:
		_new_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not pause.visible:
			_pause()
	if event.is_action_pressed("switch_history"):
		history.visible = not history.visible
		scene_player.text_box.visible = not history.visible
		scene_player.process_mode = Node.PROCESS_MODE_DISABLED if history.visible else Node.PROCESS_MODE_INHERIT
	if event.is_action_pressed("switch_interface_visibility"):
		switch_interface_visibility()


func _new_game() -> void:
	_set_scene_by_episode_uuid("2e06a402-8c35-4b45-a56a-461653c4289c")


func load_save(save: Save) -> void:
	_score = save.local_variables["Score"]
	_set_scene_by_episode_uuid(save.episode_uuid, save.frame_index)
	
	print("Загрузка.")
	print(save.episode_name)
	print(save.frame_index)


func _set_scene_by_episode_uuid(uuid: String, frame_index: int = 0) -> void:
	if _current_episode_uuid == uuid:
		return
	
	if _current_episode_uuid != "":
		_episode_uuid_order.append(_current_episode_uuid)
	_current_episode_uuid = uuid
	
	history.clear()
	
	var episode = RSE.get_episode_by_uuid(uuid)
	var scene = VNE.visual_novel.get_scene_by_episode(episode)
	scene_player.set_scene(scene, frame_index)


func _set_scene_by_episode_uuid_backward() -> void:
	if _episode_uuid_order.size() < 1:
		print("Предыдущих сцен нет.")
		return
	
	_current_episode_uuid = _episode_uuid_order[_episode_uuid_order.size() - 1]
	_episode_uuid_order.erase(_current_episode_uuid)
	
	var episode = RSE.get_episode_by_uuid(_current_episode_uuid)
	var scene = VNE.visual_novel.get_scene_by_episode(episode)
	scene_player.set_scene_from_end(scene)


func _pause() -> void:
	history.visible = false
	scene_player.text_box.visible = false
	scene_player.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().physics_frame
	_get_screenshot()
	pause.show()


func _continue() -> void:
	pause.hide()
	scene_player.text_box.visible = true
	scene_player.process_mode = Node.PROCESS_MODE_INHERIT


func _on_scene_player_frame_setting(rse_frame: RSEFrame, vn_frame: VneFrame) -> void:
	if _prev_rse_frame != null:
		history.add_record(_prev_rse_frame, _prev_vn_frame)
	
	_prev_rse_frame = rse_frame
	_prev_vn_frame = vn_frame


func _on_scene_player_scene_ended(scene: VneScene) -> void:
	if _is_handling_scene_end:
		return
	_is_handling_scene_end = true
	
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
		
	elif scene.episode.uuid == "c58d0710-b1fd-411f-995e-5efe754ceffa": ## Резко перебить мать
		options.add_options(["Сказать, что они даже не пытаются поддержать", "Ответить как сигма"])
		
		scene_player.set_process_input(false)
		var index = await options.option_selected
		scene_player.set_process_input(true)
		
		if index == 0:
			_score += 1
			_set_scene_by_episode_uuid("a8433770-5067-4e07-bc16-a18ba2d082fd") ## Сказать, что они даже не пытаются поддержать
		elif index == 1:
			_set_scene_by_episode_uuid("4288bfb8-9f83-49b9-9fdf-00f6090e49e5") ## Ответить как сигма
	
	elif scene.episode.uuid == "a8433770-5067-4e07-bc16-a18ba2d082fd": ## Сказать, что они даже не пытаются поддержать
		_set_scene_by_episode_uuid("43e0c47f-5631-4ddc-bb19-f9a02aab8b8b") ## После выбора...
	elif scene.episode.uuid == "4288bfb8-9f83-49b9-9fdf-00f6090e49e5": ## Ответить как сигма
		_set_scene_by_episode_uuid("43e0c47f-5631-4ddc-bb19-f9a02aab8b8b") ## После выбора...
	
	elif scene.episode.uuid == "43e0c47f-5631-4ddc-bb19-f9a02aab8b8b": ## После выбора...
		options.add_options(["Как обычно", "Вязаную маму в ванне 1 штуку, пожалуйста"])
		
		scene_player.set_process_input(false)
		var index = await options.option_selected
		scene_player.set_process_input(true)
		
		if index == 0:
			_set_scene_by_episode_uuid("6845e21f-aa2a-491f-9b0c-0b14f1c58443") ## Как обычно
		elif index == 1:
			_score += 1
			_set_scene_by_episode_uuid("4908fa65-07fb-4d2d-9da8-decab666a086") ## Вязаную маму в ванне 1 штуку, пожалуйста
		
	elif scene.episode.uuid == "4908fa65-07fb-4d2d-9da8-decab666a086": ## Вязаную маму в ванне 1 штуку, пожалуйста
		_set_scene_by_episode_uuid("6845e21f-aa2a-491f-9b0c-0b14f1c58443") ## Как обычно
		
	elif scene.episode.uuid == "6845e21f-aa2a-491f-9b0c-0b14f1c58443": ## Как обычно
		if _score > 1:
			_set_scene_by_episode_uuid("8a6235c6-99af-472d-a534-c46543194305") ## Плохая концовка
		else:
			_set_scene_by_episode_uuid("edf5410c-93f4-4563-8d27-86a93945c8fd") ## Неплохая
	
	## Конец игры.
	elif scene.episode.uuid == "8a6235c6-99af-472d-a534-c46543194305": ## Плохая концовка:
		print("Плохая концовка")
		pass
	elif scene.episode.uuid == "edf5410c-93f4-4563-8d27-86a93945c8fd": ## Неплохая:
		print("Неплохая концовка")
		pass
	
	_is_handling_scene_end = false


func _on_scene_player_to_prev_scene() -> void:
	if _current_episode_uuid == "b13ca84a-5613-44ad-bad7-9042f629f977": ## Молчать и наблюдать за срачем с удовольствием
		_score -= 1
	elif _current_episode_uuid == "a8433770-5067-4e07-bc16-a18ba2d082fd": ## Сказать, что они даже не пытаются поддержать
		_score -= 1
	elif _current_episode_uuid == "4908fa65-07fb-4d2d-9da8-decab666a086": ## Вязаную маму в ванне 1 штуку, пожалуйста
		_score -= 1
	_set_scene_by_episode_uuid_backward()


func switch_interface_visibility() -> void:
	if history.visible:
		return
	
	if pause.visible:
		return
	
	interface_visible = not interface_visible
	
	options.visible = interface_visible
	scene_player.text_box.visible = interface_visible


func _get_screenshot() -> void:
	_screenshoot = get_viewport().get_texture().get_image()


func _on_pause_save_pressed() -> void:
	SaveManager.create_save(_screenshoot, _current_episode_uuid, scene_player._index, {"Score" : _score})
	_continue()


func _on_pause_exit_to_menu_pressed() -> void:
	SaveManager.create_autosave(_screenshoot, _current_episode_uuid, scene_player._index, {"Score" : _score})
