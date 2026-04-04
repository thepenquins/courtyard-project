@tool class_name VneAudioEditor extends Control

signal resource_path_changed(resource: VneResource)

@export var audio_type_option_button: OptionButton
@export var regular_container: HBoxContainer
@export var path_to_file_line_edit: LineEdit
@export var file_dialog: FileDialog

@export var fmod__container: HBoxContainer
@export var fmod_event_option_button: OptionButton
var fmod_event_options: Dictionary[String, int]

var _resource: VneAudioResource


func _ready() -> void:
	audio_type_option_button.clear()
	for audio_type in VneAudioResource.AudioType.keys():
		audio_type_option_button.add_item(audio_type)
	_select_container_by_audio_type(audio_type_option_button.selected)
	_update_fmod_events()


func _on_audio_type_option_button_item_selected(index: int) -> void:
	_select_container_by_audio_type(index)
	if _resource != null:
		_resource.audio_type = index
		path_to_file_line_edit.text = _resource.path_to_file
		if fmod_event_options.has(_resource.path_to_file):
			fmod_event_option_button.select(fmod_event_options[_resource.path_to_file])


func _select_container_by_audio_type(audio_type: VneAudioResource.AudioType) -> void:
	regular_container.visible = audio_type == VneAudioResource.AudioType.Regular
	fmod__container.visible = audio_type == VneAudioResource.AudioType.FMOD


func _update_fmod_events() -> void:
	fmod_event_option_button.clear()
	fmod_event_options.clear()
	if ProjectSettings.has_setting("autoload/FmodManager"):
		for bank in FmodServer.get_all_banks():
			var fmod_bank := bank as FmodBank
			var events := fmod_bank.get_description_list()
			events.sort_custom(sort_fmod_events_by_path)
			var index := 0
			for event in events:
				var event_path = event.get_path()
				fmod_event_option_button.add_item(event_path)
				fmod_event_options[event_path] = index
				index += 1
	
	if _resource != null:
		if fmod_event_options.has(_resource.path_to_file):
			fmod_event_option_button.select(fmod_event_options[_resource.path_to_file])
		else:
			_resource.path_to_file = fmod_event_options.values()[0]
			resource_path_changed.emit(_resource)


func set_resource(audio_resource: VneAudioResource) -> void:
	_resource = audio_resource
	
	if _resource == null:
		return
		
	audio_type_option_button.select(audio_resource.audio_type)
	_select_container_by_audio_type(audio_resource.audio_type)
	
	if audio_resource.audio_type == VneAudioResource.AudioType.Regular:
		path_to_file_line_edit.text = audio_resource.path_to_file
	else:
		if fmod_event_options.has(audio_resource.path_to_file):
			fmod_event_option_button.select(fmod_event_options[audio_resource.path_to_file])


func _on_fmod_event_option_button_item_selected(index: int) -> void:
	if _resource != null:
		_resource.path_to_file = fmod_event_option_button.get_item_text(index)
		resource_path_changed.emit(_resource)


func _on_open_file_dialog_button_pressed() -> void:
	file_dialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	if _resource != null:
		_resource.path_to_file = path
		resource_path_changed.emit(_resource)


static func sort_fmod_events_by_path(a, b):
	return a.get_path().casecmp_to(b.get_path()) < 0
