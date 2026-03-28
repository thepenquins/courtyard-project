@tool
class_name VneCharacterContainer
extends VneResourceContainer


func set_resource(resource: VneResource) -> void:
	super(resource)
	text = "[b]" + (resource as VneCharacterResource).character.name_with_color
