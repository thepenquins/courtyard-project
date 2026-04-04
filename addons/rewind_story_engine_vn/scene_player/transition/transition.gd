@tool class_name VneTransition extends Control

signal ended

@export var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	animation_player.play("transition")


func _on_animation_player_animation_finished(anim_name: String) -> void:
	ended.emit()
	await get_tree().process_frame 
	queue_free()


func end() -> void:
	var length = animation_player.get_current_animation_length()
	animation_player.advance(length)
