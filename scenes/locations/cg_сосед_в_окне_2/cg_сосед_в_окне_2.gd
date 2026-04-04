@tool extends VneLocation


@export var normal: Texture2D 
@export var zoomed: Texture2D 

@export var sprite_2d: Sprite2D


func _ready() -> void:
	sprite_2d.texture = normal


func set_parameters(new_parameters: Dictionary[String, float]) -> bool:
	for new_parameter in new_parameters:
		if new_parameter == "Приближение":
			var value = new_parameters[new_parameter]
			if value == 0:
				sprite_2d.texture = normal
			elif value == 1:
				sprite_2d.texture = zoomed
	
	return false
