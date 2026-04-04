@tool class_name VneCharactersContainer extends Node


@export var center_width_point: float = 960.0
@export var bottom_point: float = 1080.0
@export var characters_spacing: float = 256

var _move_tweens: Dictionary = {} 


func add_character(character: VneCharacter2D) -> void:
	add_child(character)
	character.position = Vector2(center_width_point, bottom_point)


func move_characters(instant: bool = false):
	var visible_children = []
	for child in get_children():
		if child is VneCharacter2D and child.visibility:
			visible_children.append(child)
	
	var count = visible_children.size()
	if count == 0:
		return

	var total_width = (count - 1) * characters_spacing
	var leftmost_x = center_width_point - total_width / 2.0
	var target_positions = {}
	for i in range(count):
		var child = visible_children[i]
		target_positions[child] = Vector2(leftmost_x + i * characters_spacing, bottom_point)
	
	for child in get_children():
		if child is VneCharacter2D:
			if _move_tweens.has(child) and _move_tweens[child] and _move_tweens[child].is_valid():
				_move_tweens[child].kill()
			
			if child in target_positions:
				var target_pos = target_positions[child]
				if instant:
					child.position = target_pos
				else:
					var tween = create_tween()
					tween.tween_property(child, "position", target_pos, 0.5).set_trans(Tween.TRANS_BACK)
					_move_tweens[child] = tween
