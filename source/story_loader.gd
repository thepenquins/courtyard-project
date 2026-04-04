extends Node


func _enter_tree() -> void:
	RSE.story = RSEStory.load_from_file("res://story_courtyard/courtyard.rse")
	VNE.set_story(RSE.story)
