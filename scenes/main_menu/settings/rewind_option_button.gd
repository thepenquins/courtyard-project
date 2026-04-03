extends OptionButton


func _ready():
	text = get_item_text(Settings.rewind_mode)
	item_selected.connect(_set_rewind_mode)


func _set_rewind_mode(index: int) -> void:
	Settings.rewind_mode = index as Settings.RewindMode
