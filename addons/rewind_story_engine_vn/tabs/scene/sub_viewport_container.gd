@tool extends SubViewportContainer


func _gui_input(event: InputEvent) -> void:
	$SubViewport/ScenePlayer._input(event)
