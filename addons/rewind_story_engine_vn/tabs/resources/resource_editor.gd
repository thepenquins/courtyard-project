@tool
class_name VneResourceEditor
extends Control


signal resource_renamed(resource: VneResource)
signal resource_path_changed(resource: VneResource)


@export var info: Control
@export var editor: Control

@export var uuid_line_edit: LineEdit
@export var short_key_line_edit: LineEdit

@export var path_to_file_container: HBoxContainer
@export var name_line_edit: LineEdit
@export var path_to_file_line_edit: LineEdit

@export var open_file_dialog: FileDialog

@export var character_editor: VneCharacterEditor
@export var audio_editor: VneAudioEditor

var _resource: VneResource


func set_resource(resource: VneResource) -> void:
	_resource = resource
	
	if resource == null:
		info.show()
		editor.hide()
		return
	
	info.hide()
	editor.show()
	
	uuid_line_edit.text = resource.uuid
	short_key_line_edit.text = resource.short_key
	name_line_edit.text = resource.name
	path_to_file_line_edit.text = resource.path_to_file
	
	character_editor.visible = resource is VneCharacterResource
	path_to_file_container.visible = resource is not VneAudioResource
	audio_editor.visible = resource is VneAudioResource
	
	if resource is VneCharacterResource:
		character_editor.set_resource(resource)
	if resource is VneAudioResource:
		audio_editor.set_resource(resource)


func _on_resource_name_line_edit_text_changed(new_text: String) -> void:
	_resource.name = new_text
	resource_renamed.emit(_resource)


func _on_open_file_dialog_button_pressed() -> void:
	open_file_dialog.show()


func _on_open_file_dialog_file_selected(path: String) -> void:
	path_to_file_line_edit.text = path
	_resource.path_to_file = path
	resource_path_changed.emit(_resource)


func _on_copy_uuid_button_pressed() -> void:
	DisplayServer.clipboard_set(uuid_line_edit.text)


func _on_copy_short_key_button_pressed() -> void:
	DisplayServer.clipboard_set(short_key_line_edit.text)


func _on_audio_editor_resource_path_changed(resource: VneResource) -> void:
	resource_renamed.emit(resource)
