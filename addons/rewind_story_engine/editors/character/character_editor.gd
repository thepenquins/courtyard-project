@tool
class_name RSECharacterEditor
extends RSEBaseEditor


@export var character_color_picker_button: ColorPickerButton
@export var file_name_line_edit: LineEdit
@export var emotions_item_list: ItemList
@export var scene_file_dialog: FileDialog


func initialize() -> void:
	super()
	_fill_emotions_item_list()


func _fill_emotions_item_list() -> void:
	for emotion in RSEEmotions.Emotion.keys():
		emotions_item_list.add_item(emotion)


func _fill_items() -> void:
	for character: RSECharacter in RSE.characters:
		_add_item(character)


func _create_data() -> RSEBaseData:
	return RSE.story.add_character()


func _remove_data_from_story(data: RSEBaseData) -> void:
	RSE.story.remove_character(data)


func _select_item(index: int) -> void:
	super(index)
	var character: RSECharacter = _selected_item
	character_color_picker_button.color = character.color
	file_name_line_edit.text = character.path_to_scene_file


func _on_character_color_picker_button_color_changed(color: Color) -> void:
	if _selected_item == null:
		return
	
	_selected_item.color = color


func _on_select_scene_button_pressed() -> void:
	scene_file_dialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	file_name_line_edit.text = path
	_selected_item.path_to_scene_file = path
