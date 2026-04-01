@tool extends VneLocation

@export var day: Texture2D 
@export var night: Texture2D 

@export var sprite_2d: Sprite2D


func _ready() -> void:
	sprite_2d.texture = day


func set_parameters(new_parameters: Dictionary[String, float]) -> void:
	for new_parameter in new_parameters:
		if new_parameter == "Время суток":
			var value = new_parameters[new_parameter]
			if value == 0:
				sprite_2d.texture = day
			elif value == 1:
				sprite_2d.texture = night
