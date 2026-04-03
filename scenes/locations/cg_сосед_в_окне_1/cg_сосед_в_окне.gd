@tool extends VneLocation


@export var light: Texture2D 
@export var dark: Texture2D 
@export var evening: Texture2D 
@export var night: Texture2D 

@export var sprite_2d: Sprite2D


func _ready() -> void:
	sprite_2d.texture = light


func set_parameters(new_parameters: Dictionary[String, float]) -> void:
	for new_parameter in new_parameters:
		if new_parameter == "Свет":
			var value = new_parameters[new_parameter]
			if value == 0:
				sprite_2d.texture = light
			elif value == 1:
				sprite_2d.texture = dark
			elif value == 2:
				sprite_2d.texture = evening
			elif value == 3:
				sprite_2d.texture = night
