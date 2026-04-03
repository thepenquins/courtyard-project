@tool extends VneLocation


@export var image1: Texture2D 
@export var image2: Texture2D 

@export var sprite_2d: Sprite2D


func _ready() -> void:
	sprite_2d.texture = image1


func set_parameters(new_parameters: Dictionary[String, float]) -> void:
	for new_parameter in new_parameters:
		if new_parameter == "Глаза":
			var value = new_parameters[new_parameter]
			if value == 0:
				sprite_2d.texture = image1
			elif value == 1:
				sprite_2d.texture = image2
