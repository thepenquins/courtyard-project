@tool
class_name VneAddCharacterButton
extends VneAddResourceButton


func set_resources():
	_resources = VNE.visual_novel.characters


func _get_resource_container() -> VneResourceContainer:
	return VneCharacterContainer.new()
