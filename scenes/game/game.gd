class_name Game extends Node

@export var scene_player: VneScenePlayer
@export var pause: Control


func _ready() -> void:
	_start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not pause.visible:
			_pause()


func _start() -> void:
	var scene = VNE.visual_novel.get_scene_by_episode(RSE.get_episode_by_name("Эпизод #1"))
	scene_player.set_scene(scene)


func _pause() -> void:
	pause.show()
	scene_player.process_mode = Node.PROCESS_MODE_DISABLED


func _continue() -> void:
	pause.hide()
	scene_player.process_mode = Node.PROCESS_MODE_INHERIT
