class_name Game extends Node

@export var scene_player: VneScenePlayer
@export var history: History
@export var pause: Control

var _prev_rse_frame: RSEFrame
var _prev_vn_frame: VneFrame


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
	var scene = VNE.visual_novel.get_scene_by_episode(RSE.get_episode_by_name("Эпизод #1"))
	scene_player.set_scene(scene)


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
