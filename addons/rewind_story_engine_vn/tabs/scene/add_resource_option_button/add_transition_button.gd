@tool
class_name VneAddTransitionButton
extends VneAddResourceOptionButton


const WITHOUT_TRANSITION_STRING = "[Без перехода]"


func _init() -> void:
	super()
	fit_to_longest_item = true


func set_resources() -> void:
	_resources = VNE.visual_novel.transitions


func _add_first_item() -> void:
	add_item(WITHOUT_TRANSITION_STRING)
