@tool
class_name RSEEpisodeEditor
extends RSEBaseEditor


@export var open_file_dialog: FileDialog
@export var script_editor: RSEScriptEditor


var episode: RSEEpisode:
	get:
		return _selected_item as RSEEpisode


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.ctrl_pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			script_editor.increase_font_size()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			script_editor.decrease_font_size()


func _fill_items() -> void:
	for episode: RSEEpisode in RSE.episodes:
		_add_item(episode)


func _create_data() -> RSEBaseData:
	return RSE.story.add_episode()


func _remove_data_from_story(data: RSEBaseData) -> void:
	RSE.story.remove_episode(data)


func _select_item(index: int) -> void:
	_export_episode()
	super(index)
	_import_episode()


func _export_episode() -> void:
	if episode == null:
		return
	
	episode.frames.clear()

	var uuid: String = ""
	var speaker: String = ""

	for line in script_editor.text.split("\n"):
		if line.is_empty():
			uuid = ""
			speaker = ""
		
		elif line.begins_with("#"):
			var frame = RSEFrame.new(RSE.story)
			frame.text = line
			episode.frames.append(frame)
			continue

		elif line.begins_with("[UUID:"):
			uuid = line.replace("[UUID:", "")
			uuid = uuid.replace("]", "")
			uuid = uuid.replace(" ", "")
		
		elif line.begins_with("—"):
			var frame: RSEFrame
			if uuid == "":
				frame = episode.add_frame()
			else:
				frame = RSEFrame.new(RSE.story)
				episode.frames.append(frame)
				frame.uuid = uuid
			
			frame.speaker = speaker
			frame.text = line.substr(2)
		
		else:
			speaker = line


func _import_episode() -> void:
	var script_text: String

	var last_speaker: String
	for frame in episode.frames:
		if frame.is_commentary:
			script_text += "\n%s" % frame.text
			continue

		if frame.speaker != "" and last_speaker != frame.speaker:
			last_speaker = frame.speaker
			if script_text != "": # Если это не первая строка, добавляем перенос.
				script_text += "\n"
			script_text += frame.speaker + "\n"
		if frame.speaker == "" and script_text != "":
			script_text += "\n"
		script_text += "[UUID: %s]\n" % frame.uuid
		script_text += "— %s\n" % frame.text
	
	script_editor.text = script_text
	script_editor.clear_undo_history()


func _on_load_from_file_button_pressed() -> void:
	open_file_dialog.show()


func _on_open_episode_file_button_pressed() -> void:
	var path = ProjectSettings.globalize_path(episode.path_to_data_file_full)
	OS.shell_open(path)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			pass
