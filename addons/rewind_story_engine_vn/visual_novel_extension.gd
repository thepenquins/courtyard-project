@tool
extends EditorPlugin


const PATH_TO_GAME_HANDLER = "res://addons/rewind_story_engine_vn/vne_handler.gd"
const MAIN_PANEL = preload("res://addons/rewind_story_engine_vn/visual_novel_extension.tscn")

var plugin_controller: VnePluginController
var fmod_bank_loader: FmodBankLoader


func _enter_tree() -> void:
	plugin_controller = MAIN_PANEL.instantiate()
	EditorInterface.get_editor_main_screen().add_child(plugin_controller)
	_make_visible(false)
	
	#if Engine.is_editor_hint():
	fmod_bank_loader = FmodBankLoader.new()
	fmod_bank_loader.bank_paths = [
		"res://audio/banks/Master.strings.bank",
		"res://audio/banks/Master.bank",
		]
	add_child(fmod_bank_loader)
	
	if not ProjectSettings.has_setting("autoload/VNE"):
		add_autoload_singleton("VNE", PATH_TO_GAME_HANDLER)


func _exit_tree() -> void:
	if plugin_controller:
		plugin_controller.queue_free()
	if fmod_bank_loader:
		fmod_bank_loader.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if plugin_controller:
		plugin_controller.visible = visible


func _get_plugin_name():
	return "RSE Visual Novel Extension"


func _get_plugin_icon():
	return load("res://addons/rewind_story_engine_vn/icons/icon.svg")
