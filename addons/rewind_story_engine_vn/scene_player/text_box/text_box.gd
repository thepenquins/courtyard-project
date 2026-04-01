@tool
class_name VneTextBox
extends MarginContainer

signal frame_ended

@export var speaker_rich_text_label: RichTextAnimation
@export var text_rich_text_label: RichTextAnimation

@export var click_to_continue_texture_rect: TextureRect

var _playing: bool = true


func set_frame(frame: RSEFrame, vn_frame: VneFrame, instantly: bool = false) -> void:
	speaker_rich_text_label.bbcode = get_speaker(frame, vn_frame)
	text_rich_text_label.bbcode = frame.text
	
	if instantly:
		skip()
	
	if Engine.is_editor_hint():
		var text = frame.text
		if frame.speaker != "":
			text = frame.speaker_with_color + ": " + text
		print_rich(text)


func get_speaker(frame: RSEFrame, vn_frame: VneFrame) -> String:
	if frame._character == null:
		return "[skip]" + frame.speaker
	else:
		var speaker = frame.speaker
		for character_frame: VneCharacterFrame in vn_frame.characters:
			for character_resource: VneCharacterResource in vn_frame.character_resources:
				if character_resource.character == frame._character:
					if character_frame.displayed_name != "":
						speaker = character_frame.displayed_name
		return "[skip][color=%s]%s[]" % [frame._character.color.to_html(false), speaker]


func advance() -> void:
	text_rich_text_label.advance()


func skip() -> void:
	text_rich_text_label.bbcode = "[skip]" + text_rich_text_label.bbcode


## Временное решение.
func _physics_process(delta: float) -> void:
	click_to_continue_texture_rect.modulate.a = 0 if _playing else 1 


func _on_text_richer_text_label_anim_finished() -> void:
	frame_ended.emit()
	_playing = false


func _on_text_richer_text_label_anim_continued() -> void:
	_playing = true


func _on_text_richer_text_label_anim_paused() -> void:
	_playing = false


func _on_text_richer_text_label_anim_started() -> void:
	_playing = true
