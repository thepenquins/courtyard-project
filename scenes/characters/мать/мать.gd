@tool extends VneCharacter2D

@export var hair: Sprite2D
var hair_0 = preload("res://scenes/characters/мать/sprites/0/sprite_hair_0.png")
var hair_1 = preload("res://scenes/characters/мать/sprites/1/sprite_hair_0.png")
var hair_2 = preload("res://scenes/characters/мать/sprites/2/sprite_hair_0.png")

@export var glasses: Sprite2D
var glasses_0 = preload("res://scenes/characters/мать/sprites/0/sprite_glasses_0.png")
var glasses_1 = preload("res://scenes/characters/мать/sprites/1/sprite_glasses_0.png")
var glasses_2 = preload("res://scenes/characters/мать/sprites/2/sprite_glasses_0.png")


func _process_scaling_mode_setter() -> void:
	match scaling_mode:
		0:
			hair.texture = hair_0
			glasses.texture = glasses_0
		1:
			hair.texture = hair_1
			glasses.texture = glasses_1
		2:
			hair.texture = hair_2
			glasses.texture = glasses_2
