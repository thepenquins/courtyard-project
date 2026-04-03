extends Node


var snd_hover: AudioStreamMP3 = load("res://audio/snd_hover.mp3")
var snd_select: AudioStreamMP3 = load("res://audio/snd_select.mp3")


func play_hover() -> void:
	_add_player(snd_hover)


func play_click() -> void:
	_add_player(snd_select)


func _add_player(snd: AudioStream) -> void:
	var audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = snd
	audio_stream_player.play()
	audio_stream_player.bus = "&SFX"
	audio_stream_player.finished.connect(_on_audio_stream_player_finished.bind(audio_stream_player))


func _on_audio_stream_player_finished(audio_stream_player: AudioStreamPlayer) -> void:
	audio_stream_player.queue_free()
