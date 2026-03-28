@tool
class_name RSEBaseEditor
extends Control


@export var base_data_item_list: ItemList
@export var add_item_button: Button
@export var remove_item_button: Button
@export var remove_confirmation_dialog: ConfirmationDialog
@export var name_line_edit: LineEdit

@export var uuid_line_edit: LineEdit
@export var uuid_copy_button: Button
@export var short_key_line_edit: LineEdit
@export var short_key_copy_button: Button


var _selected_index: int
var _selected_item: RSEBaseData
var _items: Array


func _ready() -> void:
	base_data_item_list.item_selected.connect(_select_item)
	add_item_button.pressed.connect(_on_add_data_button_pressed)
	remove_item_button.pressed.connect(_on_remove_data_button_pressed)
	
	remove_confirmation_dialog.dialog_text = "Вы уверены? Это действие нельзя отменить."
	remove_confirmation_dialog.confirmed.connect(_remove_item)
	
	name_line_edit.text_changed.connect(_on_name_line_edit_text_changed)
	uuid_copy_button.pressed.connect(_copy_to_clipboard_from.bind(uuid_line_edit))
	short_key_copy_button.pressed.connect(_copy_to_clipboard_from.bind(short_key_line_edit))


func initialize() -> void:
	update_item_list()


func update_item_list() -> void:
	base_data_item_list.clear()
	_selected_index = -1
	_selected_item = null
	_items.clear()
	_fill_items()
	if base_data_item_list.item_count != 0:
		_select_item(0)


func _fill_items() -> void:
	print("WARNING: _fill_items() not implemented.")


func _add_item(data: RSEBaseData) -> int:
	var index = base_data_item_list.add_item(data.name)
	_items.append(data)
	name_line_edit.grab_focus()
	return index


func _remove_item(index: int = -1) -> void:
	if base_data_item_list.item_count == 0:
		return
	
	if index == -1:
		index = _selected_index
	
	var item = _items[index]
	_remove_data_from_story(item)
	
	base_data_item_list.remove_item(index)
	_items.erase(item)
	
	
	if base_data_item_list.item_count > 0:
		_select_item(0)


func _remove_data_from_story(data: RSEBaseData) -> void:
	print("WARNING: _remove_data_from_story() not implemented.")


func _select_item(index: int) -> void:
	_selected_index = index
	_selected_item = _items[index]
	name_line_edit.text = _selected_item.name
	uuid_line_edit.text = _selected_item.uuid
	short_key_line_edit.text = _selected_item.short_key


func _create_data() -> RSEBaseData:
	print("WARNING: _create_data() not implemented.")
	return null


func _on_add_data_button_pressed() -> void:
	var data = _create_data()
	if not data == null:
		_select_item(_add_item(data))


func _on_remove_data_button_pressed() -> void:
	if _selected_item == null:
		return
		
	remove_confirmation_dialog.show()


func _on_name_line_edit_text_changed(new_text: String) -> void:
	if _selected_item == null:
		return
	
	_selected_item.name = new_text
	base_data_item_list.set_item_text(_selected_index, new_text)


func _copy_to_clipboard_from(line_edit: LineEdit) -> void:
	DisplayServer.clipboard_set(line_edit.text)
