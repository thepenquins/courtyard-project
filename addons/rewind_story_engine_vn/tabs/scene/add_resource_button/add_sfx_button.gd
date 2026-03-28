@tool
class_name VneAddSfxButton
extends VneAddResourceButton


func set_resources():
	_resources = VNE.visual_novel.sfx


func _get_resource_container() -> VneResourceContainer:
	return VneSfxContainer.new()
