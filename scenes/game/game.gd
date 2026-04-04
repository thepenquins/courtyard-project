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
	scene_player.text_box.history_button.pressed.connect(switch_history)
	scene_player.text_box.hide_button.pressed.connect(switch_interface_visibility)
	
	scene_player.instantiate_all_characters()
	
	history.close_button.pressed.connect(set_history.bind(false))
	
	if save_to_load != null:
		load_save(save_to_load)
		save_to_load = null
	else:
		_new_game()


func _input(event: InputEvent) -> void:
	if not interface_visible:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed():
				set_interface_visibility(true)
				return
	if history.visible:
		if event is InputEventKey:
			if event.is_pressed():
				set_history(false)
				return
	
	if event.is_action_pressed("pause"):
		if not pause.visible:
			_pause()
	if event.is_action_pressed("switch_history"):
		switch_history()
	if event.is_action_pressed("switch_interface_visibility"):
		switch_interface_visibility()


func _new_game() -> void:
	_set_scene_by_episode_uuid("2e06a402-8c35-4b45-a56a-461653c4289c")


func load_save(save: Save) -> void:
	_score = save.local_variables["Score"]
	_set_scene_by_episode_uuid(save.episode_uuid, save.frame_index)


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

	_frame_setting_processing(rse_frame, vn_frame)


var first_vent_uuids = [
	"7652e22d-08db-49ed-a2e5-e3956346e35f",
	"4709f6b7-f839-43c3-b8ad-1d5d8f1b1d2a",
	"f8476a82-c88b-4eed-856a-f2360f3c0a86",
	"75b468ab-4abe-4ddb-af66-770bbbd1a26a",
	"75b468ab-4abe-4ddb-af66-770bbbd1a26a",
	"837fcf98-1981-42f4-85b9-471313e6738d",
	"25e35726-7463-476b-a30c-3391fa700730",
]


var second_vent_uuids = [
	"747370b6-3b67-4065-a51b-d771e8e4d513",
	"5322b889-b98f-4abc-9175-c70c28cd8cf0",
]


func _frame_setting_processing(rse_frame: RSEFrame, _vn_frame: VneFrame) -> void:
	if _current_episode_uuid == "2e06a402-8c35-4b45-a56a-461653c4289c":
		if rse_frame.uuid == "065b4619-ead9-4555-aa55-0c195e1446ee" or rse_frame.uuid == "ce7d8169-a703-419f-9de6-fa3988ad69e8":
			_reset_camera()
		
		if rse_frame.uuid == "386c1be4-ee71-4088-af15-f36f412b6d70" or rse_frame.uuid == "8b7e37a1-e972-496c-9273-e9167a76a27c": ## 1
			if not _sis_camera_1:
				_sis_camera_1 = true
				_sis_camera_2 = false
				camera_2d.zoom = Vector2(3, 3)
				_move_camera_from_to(Vector2(-250.0, 210.0), Vector2(200.0, 210.0), 5.0)
		elif rse_frame.uuid == "fe509ff8-5d20-4276-ac05-9bdd56001579" or rse_frame.uuid == "880a3636-e039-4e59-ab0c-4ce6a581614b": ## 2
			if not _sis_camera_2:
				_sis_camera_1 = false
				_sis_camera_2 = true
				_sis_camera_3 = false
				camera_2d.zoom = Vector2(3, 3)
				_move_camera_from_to(Vector2(200.0, 210.0), Vector2(-200.0, 350.0), 5.0)
		elif rse_frame.uuid == "bbc90e72-c43c-47ae-b950-d85c0e22db04" or rse_frame.uuid == "38143268-2375-4cd1-ba61-c1798eaec871": ## 3
			if not _sis_camera_3:
				_sis_camera_2 = false
				_sis_camera_3 = true
				_sis_camera_4 = false
				camera_2d.zoom = Vector2(3, 3)
				_move_camera_from_to(Vector2(-200.0, 350.0), Vector2(-43.0, 36.0), 5.0)
		elif rse_frame.uuid == "87fd976d-fa3e-4d6a-8b3c-0da937021e0f" or rse_frame.uuid == "68d723f4-2f0c-409a-a997-f0239cd42047" or rse_frame.uuid == "94e84c58-1791-4c43-9111-9e8acd50c47f": ## 4
			if not _sis_camera_4:
				_sis_camera_3 = false
				_sis_camera_4 = true
				_zoom_camera_from_to(Vector2(3, 3), Vector2(4, 4), 0.25)
				_move_camera_from_to(Vector2(-43.0, 36.0), Vector2(-24.0, -52.0), 0.5)
	
	if _current_episode_uuid == "6845e21f-aa2a-491f-9b0c-0b14f1c58443":
		if rse_frame.uuid == "fd01bd5a-e36c-4283-ae9d-fa663f680bec" or rse_frame.uuid == "8592acd8-9285-4c11-9348-a37a02013fae":
			_reset_camera()
		elif first_vent_uuids.has(rse_frame.uuid):
			if not _vent_camera_1:
				_vent_camera_1 = true
				_zoom_camera_from_to(Vector2(1, 1), Vector2(3, 3), 2.0)
				_move_camera_from_to(Vector2(0.0, 0.0), Vector2(-550.0, -270.0), 2.0)
				pass
		
	if _current_episode_uuid == "8a6235c6-99af-472d-a534-c46543194305":
		if rse_frame.uuid == "2149ed4f-fa74-4290-99ac-2aa132f7b77a" or rse_frame.uuid == "167b43c3-2de1-4522-9163-b2c518ccc579":
			_reset_camera()
		elif second_vent_uuids.has(rse_frame.uuid):
			if not _vent_camera_2:
				_vent_camera_2 = true
				_zoom_camera_from_to(Vector2(1, 1), Vector2(3, 3), 2.0)
				_move_camera_from_to(Vector2(0.0, 0.0), Vector2(-550.0, -270.0), 2.0)
				pass


var _sis_camera_1: bool = false
var _sis_camera_2: bool = false
var _sis_camera_3: bool = false
var _sis_camera_4: bool = false

var _vent_camera_1: bool = false
var _vent_camera_2: bool = false

@export var camera_2d: Camera2D
var _camera_tween_position: Tween
var _camera_tween_zoom: Tween

func _reset_camera() -> void:
	if _camera_tween_position:
		if _camera_tween_position.is_valid():
			_camera_tween_position.kill()
	if _camera_tween_zoom:
		if _camera_tween_zoom.is_valid():
			_camera_tween_zoom.kill()
	
	#camera_2d.position = Vector2.ZERO
	#camera_2d.zoom = Vector2.ONE
	
	_sis_camera_1 = false
	_sis_camera_2 = false
	_sis_camera_3 = false
	_sis_camera_4 = false
	
	_vent_camera_1 = false
	_vent_camera_2 = false
	
	if camera_2d.position != Vector2.ZERO:
		_move_camera_from_to(camera_2d.position, Vector2.ZERO, 0.2)
	if camera_2d.zoom != Vector2.ONE:
		_zoom_camera_from_to(camera_2d.zoom, Vector2.ONE, 0.2)


func _move_camera_from_to(from: Vector2, to: Vector2, duration: float) -> void:
	if _camera_tween_position:
		if _camera_tween_position.is_valid():
			_camera_tween_position.kill()
	
	camera_2d.position = from
	
	_camera_tween_position = create_tween()
	_camera_tween_position.tween_property(camera_2d, "position", to, duration).set_trans(Tween.TRANS_CUBIC)


func _zoom_camera_from_to(from: Vector2, to: Vector2, duration: float) -> void:
	if _camera_tween_zoom:
		if _camera_tween_zoom.is_valid():
			_camera_tween_zoom.kill()
	
	camera_2d.zoom = from
	
	_camera_tween_zoom = create_tween()
	_camera_tween_zoom.tween_property(camera_2d, "zoom", to, duration)


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
		Loader.load_scene("res://scenes/main_menu/main_menu.tscn")
	elif scene.episode.uuid == "edf5410c-93f4-4563-8d27-86a93945c8fd": ## Неплохая:
		print("Неплохая концовка")
		Loader.load_scene("res://scenes/main_menu/main_menu.tscn")
	
	_is_handling_scene_end = false


func _on_scene_player_to_prev_scene() -> void:
	if _current_episode_uuid == "b13ca84a-5613-44ad-bad7-9042f629f977": ## Молчать и наблюдать за срачем с удовольствием
		_score -= 1
	elif _current_episode_uuid == "a8433770-5067-4e07-bc16-a18ba2d082fd": ## Сказать, что они даже не пытаются поддержать
		_score -= 1
	elif _current_episode_uuid == "4908fa65-07fb-4d2d-9da8-decab666a086": ## Вязаную маму в ванне 1 штуку, пожалуйста
		_score -= 1
	_set_scene_by_episode_uuid_backward()


func switch_history() -> void:
	set_history(not history.visible)


func set_history(value: bool) -> void:
	history.visible = value
	scene_player.text_box.visible = not history.visible
	scene_player.process_mode = Node.PROCESS_MODE_DISABLED if history.visible else Node.PROCESS_MODE_INHERIT


func switch_interface_visibility() -> void:
	if history.visible:
		return
	
	if pause.visible:
		return
	
	set_interface_visibility(not interface_visible)


func set_interface_visibility(value: bool) -> void:
	interface_visible = value
	options.visible = interface_visible and options.options_container.get_child_count() > 0
	scene_player.text_box.visible = interface_visible


func _get_screenshot() -> void:
	_screenshoot = get_viewport().get_texture().get_image()


func _on_pause_save_pressed() -> void:
	SaveManager.create_save(_screenshoot, _current_episode_uuid, scene_player._index, {"Score" : _score})
	_continue()


func _on_pause_exit_to_menu_pressed() -> void:
	SaveManager.create_autosave(_screenshoot, _current_episode_uuid, scene_player._index, {"Score" : _score})
