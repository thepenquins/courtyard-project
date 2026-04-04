@tool extends VneLocation

@export var day: Texture2D 
@export var day_nightmare: Texture2D 
@export var day_curtains: Texture2D 
@export var day_curtains_nightmare: Texture2D 

@export var evening: Texture2D 
@export var evening_curtains: Texture2D 
@export var evening_curtains_nightmare: Texture2D 

@export var night: Texture2D 
@export var night_nightmare: Texture2D 
@export var night_curtains: Texture2D 
@export var night_nightmare_curtains: Texture2D 

@export var sprite_2d: Sprite2D

var _time: float = 0


func _ready() -> void:
	sprite_2d.texture = day


func set_parameters(new_parameters: Dictionary[String, float]) -> bool:
	var prev_time = _time
	_time = new_parameters.get("Время суток", 0)
	var curtains = new_parameters.get("Шторы", 0)
	var nightmare = new_parameters.get("Мрак", 0)
	
	if _time == 0: ## День
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
		if prev_time == 1 or prev_time == 2:
			return true
	elif _time == 1: ## Вечер.
		if curtains == 1:
			if nightmare == 0:
				sprite_2d.texture = evening_curtains
			else:
				sprite_2d.texture = evening_curtains_nightmare
		else:
			sprite_2d.texture = evening
		if prev_time == 0 or prev_time == 2:
			return true
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
		if prev_time == 0 or prev_time == 1:
			return true
	
	return false
