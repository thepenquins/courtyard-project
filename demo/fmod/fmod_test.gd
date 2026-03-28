extends Control

@export var fmod_event_emitter_2d_1: FmodEventEmitter2D
@export var fmod_event_emitter_2d_2: FmodEventEmitter2D

var emitter_1_playing: bool = false
var emitter_2_playing: bool = false


func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	emitter_1_playing = not emitter_1_playing
	if emitter_1_playing:
		fmod_event_emitter_2d_1.play()
	else:
		fmod_event_emitter_2d_1.stop()


func _on_button_2_pressed() -> void:
	emitter_2_playing = not emitter_2_playing
	if emitter_2_playing:
		fmod_event_emitter_2d_2.play()
	else:
		fmod_event_emitter_2d_2.stop()
