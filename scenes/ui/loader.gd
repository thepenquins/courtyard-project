extends Control

@export var animation_player: AnimationPlayer


func play_animation() -> void:
	animation_player.play("loading")
