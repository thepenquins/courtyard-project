@abstract class_name VneBaseFrameData extends RefCounted

var resource: VneResource


func get_string_data() -> PackedStringArray:
	var array: PackedStringArray
	if resource:
		array.append(resource.uuid)
	else:
		array.append("")
	return array


func fill_data(uuid: String, _file: FileAccess) -> void:
	resource = VNE.visual_novel.get_resource_by_uuid(uuid)


func copy_from(frame: VneBaseFrameData) -> void:
	resource = frame.resource
