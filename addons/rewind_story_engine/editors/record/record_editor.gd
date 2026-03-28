@tool
class_name RSERecordEditor
extends RSEBaseEditor


@export var record_text_edit: TextEdit


func _fill_items() -> void:
	for record: RSEBaseData in RSE.records:
		_add_item(record)


func _create_data() -> RSEBaseData:
	return RSE.story.add_record()


func _remove_data_from_story(data: RSEBaseData) -> void:
	RSE.story.remove_record(data)


func _select_item(index: int) -> void:
	super(index)
	var record: RSERecord = _selected_item
	record_text_edit.text = record.text


func _on_record_text_edit_text_changed() -> void:
	var record: RSERecord = _selected_item
	record.text = record_text_edit.text
