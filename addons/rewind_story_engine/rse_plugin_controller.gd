@tool
class_name RSEPluginController
extends Node


@export var tab_container: TabContainer

@export_category("File Dialog Boxes")
@export var open_file_dialog: FileDialog
@export var create_file_dialog: FileDialog

@export_category("Editors")
@export var record_editor: RSERecordEditor
@export var story_editor: RSEStoryEditor
@export var characters_editor: RSECharacterEditor
@export var episodes_editor: RSEEpisodeEditor


var story: RSEStory


func _on_create_story_button_pressed() -> void:
	create_file_dialog.show()


func _on_open_story_button_pressed() -> void:
	open_file_dialog.show()


func _on_create_file_dialog_file_selected(path: String) -> void:
	story = RSEStory.new(path)
	story.save()
	print("Создан файл истории: %s" % path)
	set_story(story)


func _on_open_file_dialog_file_selected(path: String) -> void:
	story = RSEStory.load_from_file(path)
	print("Открыт файл истории: %s" % path)
	set_story(story)


func set_story(story: RSEStory) -> void:
	self.story = story
	RSE.story = story
	initialize_windows()


func initialize_windows() -> void:
	tab_container.show()
	record_editor.initialize()
	story_editor.initialize()
	characters_editor.initialize()
	episodes_editor.initialize()


func return_to_main_window() -> void:
	self.story = null
	RSE.story = null
	tab_container.hide()
