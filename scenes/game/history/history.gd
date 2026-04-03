class_name History extends Control

@export var container: Container
@export var scroll_container: ScrollContainer
@export var double_max_records: int = 256

@export var close_button: Button


func _ready() -> void:
	scroll_container.get_v_scroll_bar().changed.connect(_scroll_to_bottom)


func add_record(frame: RSEFrame, vn_frame: VneFrame) -> void:
	if container.get_child_count() > double_max_records:
		container.get_child(0).queue_free()
		container.get_child(1).queue_free()
	
	var speaker_text = ""
	if frame.speaker != "":
		speaker_text = get_speaker(frame, vn_frame)
	
	var speaker = _create_richerTextLabel(speaker_text, HORIZONTAL_ALIGNMENT_RIGHT)
	speaker.custom_minimum_size.x = 256
	if speaker.text != "":
		speaker.bbcode += ":"
	var text = _create_richerTextLabel(frame.text, HORIZONTAL_ALIGNMENT_LEFT)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _create_richerTextLabel(text: String, horizontal_alignment: HorizontalAlignment) -> RicherTextLabel:
	var label = RichTextAnimation.new()
	label.alignment = horizontal_alignment
	label.bbcode = "[skip]" + text
	container.add_child(label)
	return label


func get_speaker(frame: RSEFrame, vn_frame: VneFrame) -> String:
	if frame._character == null:
		return "[skip]" + frame.speaker
	else:
		var speaker = frame.speaker
		for character_frame: VneCharacterFrame in vn_frame.characters:
			for character_resource: VneCharacterResource in vn_frame.character_resources:
				if character_resource.character == frame._character:
					speaker = character_frame.displayed_name
		return "[skip][color=%s]%s[]" % [frame._character.color.to_html(false), speaker]


func _scroll_to_bottom() -> void:
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func clear() -> void:
	for child in container.get_children():
		child.queue_free()
