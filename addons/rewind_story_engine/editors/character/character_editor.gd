@tool
class_name RSECharacterEditor
extends RSEBaseEditor


@export var character_color_picker_button: ColorPickerButton
@export var file_name_line_edit: LineEdit
@export var emotions_item_list: ItemList


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


func _on_character_color_picker_button_color_changed(color: Color) -> void:
	if _selected_item == null:
		return
	var character: RSECharacter = _selected_item
	character.color = color
