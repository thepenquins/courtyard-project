@tool
class_name VnePluginController
extends Control


const INFO_CONNECT_RSE = "Для начала работы необходимо подключить аддон Rewind Story Engine!"
const INFO_STORY_RSE = "Начните создавать или загрузите историю в Rewind Story Engine."
const INFO_READY = "История загружена и готова к работе."

const PANEL_STYLE_BOX = preload("res://addons/rewind_story_engine/styles/style_box_flat.tres")
const RICH_TEXT_LABEL_STYLE_BOX = preload("res://addons/rewind_story_engine_vn/styles/rich_text_box_style_empty.tres")


@export var info_label: Label

@export var main_container: Container
@export var tab_resources: VneBaseTreeTab
@export var tab_scene: VneBaseTreeTab


func _enter_tree() -> void:
	if not _check_rse_plugin():
		info_label.text = INFO_CONNECT_RSE
		return
	
	RSE.story_setting.connect(setting_story)
	
	if RSE.story == null:
		info_label.text = INFO_STORY_RSE
		return
	
	setting_story(RSE.story)
	InputMap.load_from_project_settings()


func _exit_tree() -> void:
	VNE.visual_novel.save_vn()
	if _check_rse_plugin():
		RSE.story_setting.disconnect(setting_story)


func _check_rse_plugin() -> bool:
	return ProjectSettings.has_setting("autoload/RSE")


func setting_story(story: RSEStory):
	if not story == null:
		story.character_added.connect(_on_story_character_added)
		story.character_removed.connect(_on_story_character_removed)
	
	VNE.set_story(story)
	
	_update_info()


func _update_info() -> void:
	if RSE.story == null:
		info_label.text = INFO_STORY_RSE
		main_container.hide()
	else:
		info_label.text = INFO_READY
		main_container.show()
		initialize_windows()


func _on_story_character_added(character: RSECharacter) -> void:
	VNE.visual_novel.add_character_resource(character)


func _on_story_character_removed(character: RSECharacter) -> void:
	VNE.visual_novel.remove_character_resource(character)


func initialize_windows() -> void:
	main_container.show()
	tab_resources.initialize()
	tab_scene.initialize()
