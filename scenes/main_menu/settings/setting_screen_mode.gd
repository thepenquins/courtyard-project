extends OptionButton


func _ready():
	select(get_item_index(Settings.screen_mode))
	item_selected.connect(_set_screen_mode)


func _set_screen_mode(index: int) -> void:
	Settings.screen_mode = get_item_id(index) as DisplayServer.WindowMode
