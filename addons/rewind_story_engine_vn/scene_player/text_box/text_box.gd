@tool
class_name VneTextBox
extends MarginContainer


@export var speaker_rich_text_label: RichTextAnimation
@export var text_rich_text_label: RichTextAnimation


func set_frame(frame: RSEFrame) -> void:
	var speaker = get_speaker(frame)
	if speaker_rich_text_label.bbcode != speaker:
		speaker_rich_text_label.bbcode = speaker
	text_rich_text_label.bbcode = frame.text
	
	if Engine.is_editor_hint():
		var text = frame.text
		if frame.speaker != "":
			text = frame.speaker_with_color + ": " + text
		print_rich(text)


func get_speaker(frame: RSEFrame) -> String:
	if frame._character == null:
		return "[skip]" + frame.speaker
	else:
		return "[skip][color=%s]%s[]" % [frame._character.color.to_html(false), frame.speaker]


func advance() -> bool:
	text_rich_text_label.advance()
	return true
