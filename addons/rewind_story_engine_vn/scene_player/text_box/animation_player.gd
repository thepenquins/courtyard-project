@tool extends AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		play("highlight")
