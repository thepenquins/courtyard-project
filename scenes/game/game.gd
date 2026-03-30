class_name Game extends Control

@export var scene_player: VneScenePlayer


func _ready() -> void:
	_start()


func _start() -> void:
	var scene = VNE.visual_novel.get_scene_by_episode(RSE.get_episode_by_name("Эпизод #1"))
	scene_player.set_scene(scene)
