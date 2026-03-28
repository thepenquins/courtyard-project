@tool
extends EditorPlugin

const PATH_TO_PLUGIN_FOLDER = "user://rse"
const PATH_TO_PLUGIN_SETTINGS = "user://rse/settings.json"

const PATH_TO_GAME_HANDLER = "res://addons/rewind_story_engine/rse_handler.gd"
const MAIN_PANEL = preload("res://addons/rewind_story_engine/rewind_story_engine.tscn")

var path_to_story_file = ""
var plugin_controller: RSEPluginController


func _enter_tree():
	plugin_controller = MAIN_PANEL.instantiate()
	EditorInterface.get_editor_main_screen().add_child(plugin_controller)
	_make_visible(false)
	
	if not ProjectSettings.has_setting("autoload/RSE"):
		add_autoload_singleton("RSE", PATH_TO_GAME_HANDLER)
	
	_load_settings()


func _exit_tree():
	_save_settings()
	
	if plugin_controller:
		if plugin_controller.story != null:
			plugin_controller.story.save()
		plugin_controller.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if plugin_controller:
		plugin_controller.visible = visible


func _get_plugin_name():
	return "Rewind Story Engine"


func _get_plugin_icon():
	return load("res://addons/rewind_story_engine/icons/penquin.svg")


func _load_settings() -> void:
	if not DirAccess.dir_exists_absolute(PATH_TO_PLUGIN_FOLDER):
		return
	
	var file = FileAccess.open(PATH_TO_PLUGIN_SETTINGS, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		if json.data.has("path_to_last_story_file"):
			path_to_story_file = json.data["path_to_last_story_file"]
			if path_to_story_file != "":
				_load_last_story()
		if json.data.has("script_editor_font_size"):
			plugin_controller.episodes_editor.script_editor.font_size = json.data["script_editor_font_size"]


func _save_settings() -> void:
	if not DirAccess.dir_exists_absolute(PATH_TO_PLUGIN_FOLDER):
		DirAccess.make_dir_absolute(PATH_TO_PLUGIN_FOLDER)
	
	var path_to_last_story_file: String = ""
	if plugin_controller.story != null:
		path_to_last_story_file = plugin_controller.story._path_to_story_file
	
	var data = {
		"path_to_last_story_file" : path_to_last_story_file,
		"script_editor_font_size" : plugin_controller.episodes_editor.script_editor.font_size,
	}
	var json_string = JSON.stringify(data, " ")
	
	var file = FileAccess.open(PATH_TO_PLUGIN_SETTINGS, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()


func _load_last_story() -> void:
	if plugin_controller != null:
		plugin_controller.set_story(RSEStory.load_from_file(path_to_story_file))
