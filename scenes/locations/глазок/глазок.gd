@tool extends VneLocation

@export var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player.play("RESET")


func set_parameters(new_parameters: Dictionary[String, float]) -> void:
	for new_parameter in new_parameters:
		if new_parameter == "Состояние":
			var value = new_parameters[new_parameter]
			if value == 0:
				animation_player.play("RESET")
			elif value == 1:
				animation_player.play("opened")
			elif value == 2:
				animation_player.play("opened_nightmare")
