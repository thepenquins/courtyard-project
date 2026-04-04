extends Button


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)


func _pressed() -> void:
	AudioPlayer.play_click()


func _on_mouse_entered() -> void:
	AudioPlayer.play_hover()
