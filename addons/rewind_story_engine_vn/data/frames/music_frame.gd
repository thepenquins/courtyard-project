class_name VneMusicFrame extends VneFrameWithMultipleParameters

var music: VneMusicResource:
	get:
		return resource


func _set_resource_process() -> void:
	if not Engine.is_editor_hint():
		return
	
	if resource == null:
		return
	
	var event_description = FmodServer.get_event(resource.path_to_file)
	if not event_description.is_valid():
		return
	
	for param_desc: FmodParameterDescription in event_description.get_parameters():
		parameters[str(param_desc.get_id())] = param_desc.get_default_value()
