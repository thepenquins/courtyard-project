@tool class_name VneVfx extends Control

@export var video_stream_player: VideoStreamPlayer


func _ready() -> void:
	z_index = 20
	
	if Engine.is_editor_hint():
		video_stream_player.play()


func set_parameters(parameters: Dictionary[String, float]) -> void:
	pass
