@tool
class_name VneAddVfxButton
extends VneAddResourceButton


func set_resources():
	_resources = VNE.visual_novel.vfx


func _get_resource_container() -> VneResourceContainer:
	return VneVfxContainer.new()
