@tool
class_name RSEStoryEditor
extends Control


@export var plugin_controller: RSEPluginController
@export var title_label: Label
@export var info_label: Label
@export var story_name_line_edit: LineEdit
@export var confirmation_dialog: ConfirmationDialog
@export var pot_file_dialog: FileDialog


func initialize() -> void:
	story_name_line_edit.text = RSE.story.name
	title_label.text = RSE.story.name
	update_info()


func update_info() -> void:
	info_label.text = "Записи: %s" % split_number_into_thousandths(RSE.story.records.size())
	info_label.text += "\nПерсонажи: %s" % split_number_into_thousandths(RSE.story.characters.size()) 
	info_label.text += "\nЭпизоды: %s" % split_number_into_thousandths(RSE.story.episodes.size())
	info_label.text += "\nСлов: %s" % split_number_into_thousandths(RSE.story.get_words_count())


func split_number_into_thousandths(number: int) -> String:
	var regex = RegEx.new()
	regex.compile("(\\d)(?=(\\d{3})+$)")  # Ищем каждые 3 цифры с конца
	var formatted = regex.sub(str(number), "$1 ", true)  # Заменяем на "$1 "
	return formatted


func _on_save_story_button_pressed() -> void:
	RSE.story.save()


func _on_story_name_line_edit_text_changed(new_text: String) -> void:
	RSE.story.name = new_text
	title_label.text = new_text


func _on_unload_story_button_pressed() -> void:
	confirmation_dialog.show()


func _on_confirmation_dialog_confirmed() -> void:
	plugin_controller.return_to_main_window()


func _on_generate_pot_button_pressed() -> void:
	pot_file_dialog.show()


func _on_pot_file_dialog_file_selected(path:String) -> void:
	var pot = RSE.story.generate_pot()
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(pot)
	file.close()
