@tool extends VneLocation

@export var day: Texture2D 
@export var day_nightmare: Texture2D 
@export var day_curtains: Texture2D 
@export var day_curtains_nightmare: Texture2D 

@export var evening: Texture2D 

@export var night: Texture2D 
@export var night_nightmare: Texture2D 
@export var night_curtains: Texture2D 
@export var night_nightmare_curtains: Texture2D 

@export var sprite_2d: Sprite2D


func _ready() -> void:
	sprite_2d.texture = day


func set_parameters(new_parameters: Dictionary[String, float]) -> void:
	var time = new_parameters.get("Время суток", 0)
	var curtains = new_parameters.get("Шторы", 0)
	var nightmare = new_parameters.get("Мрак", 0)
	
	if time == 0: ## День
		if curtains == 0: 
			if nightmare == 0:
				sprite_2d.texture = day
			else:
				sprite_2d.texture = day_nightmare
		else:
			if nightmare == 0:
				sprite_2d.texture = day_curtains
			else:
				sprite_2d.texture = day_curtains_nightmare
	elif time == 1: ## Вечер.
		sprite_2d.texture = evening
	else: ## Ночь.
		if curtains == 0: 
			if nightmare == 0:
				sprite_2d.texture = night
			else:
				sprite_2d.texture = night_nightmare
		else:
			if nightmare == 0:
				sprite_2d.texture = night_curtains
			else:
				sprite_2d.texture = night_nightmare_curtains
