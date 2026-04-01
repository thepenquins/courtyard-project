@tool @abstract class_name VneLocation extends Node

@export var uuid: String:
	set(value):
		uuid = value
		_load_location_resource()
@export var parameters: Dictionary[String, PackedStringArray]

@export_subgroup("Tools")
@export_tool_button("Обновить параметры в ресурсе") var button = _update_resource

var _location_resource: VneLocationResource


func _load_location_resource() -> void:
	_location_resource = VNE.visual_novel.get_resource_by_uuid(uuid)
	if not _location_resource:
		push_warning("Не удалось получить локацию по UUID: %s." % uuid)
	else:
		print_rich("Ресурс локации [b]%s[/b] успешно загружен." % _location_resource.name)


func _update_resource() -> void:
	if _location_resource:
		_location_resource.parameters = parameters


@abstract func set_parameters(new_parameters: Dictionary[String, float]) -> void
