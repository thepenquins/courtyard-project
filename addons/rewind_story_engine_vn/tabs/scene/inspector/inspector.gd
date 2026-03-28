@tool class_name VneInspector extends PanelContainer

@export var resource_name_label: RichTextLabel
@export var parameters_container: VBoxContainer

var _frame_data: VneBaseFrameData


func set_frame_data(frame_data: VneBaseFrameData) -> void:
	#if _frame_data != null:
		#if _frame_data.resource == frame_data.resource:
			#return
	
	_frame_data = frame_data
	
	if _frame_data == null:
		visible = false
		return
	
	visible = true
	
	_clear_container()
	
	resource_name_label.text = frame_data.resource.name
	
	if frame_data.resource is VneAudioResource: 
		_set_audio(frame_data.resource)
	elif frame_data is VneCharacterFrame: 
		_set_character(frame_data.resource)
	elif frame_data is VneLocationFrame: 
		_set_location(frame_data.resource)
	elif frame_data is VneVfxFrame: 
		_set_fvx(frame_data.resource)

#region audio
func _set_audio(audio_resource: VneAudioResource) -> void:
	_create_category_label("Аудио")
	var is_fmod = audio_resource.audio_type == VneAudioResource.AudioType.FMOD
	
	if is_fmod:
		_create_category_label("FMOD")
		_set_fmod_parameters(audio_resource.path_to_file)

#region FMOD
func _set_fmod_parameters(event_path: String) -> void:
	var event_description = FmodServer.get_event(event_path)
	if not event_description.is_valid():
		return
	
	for param_desc: FmodParameterDescription in event_description.get_parameters():
		var param_control: VneInspectorParameter
		var current_value = _get_parameter_value_from_frame(str(param_desc.get_id()))
		if param_desc.is_labeled():
			var labels = event_description.get_parameter_labels_by_id(param_desc.get_id())
			param_control = VneOptionInspectorParameter.new(param_desc.get_name(), labels)
			param_control.set_value(current_value)
		elif param_desc.is_discrete():
			param_control = VneIntInspectorParameter.new(param_desc.get_name(), param_desc.get_minimum(), param_desc.get_maximum())
			param_control.set_value(current_value)
		else:
			param_control = VneFloatInspectorParameter.new(param_desc.get_name(), param_desc.get_minimum(), param_desc.get_maximum())
			param_control.set_value(current_value)
			
		param_control.set_meta("param_id", param_desc.get_id())
		param_control.value_changed.connect(_on_fmod_parameter_changed.bind(str(param_desc.get_id())))
		parameters_container.add_child(param_control)


func _get_parameter_value_from_frame(param_id: String) -> float:
	if _frame_data is VneFrameWithMultipleParameters:
		return _frame_data.parameters.get(param_id, 0.0)
	return 0.0


func _on_fmod_parameter_changed(value: Variant, param_id: String) -> void:
	if _frame_data is VneFrameWithMultipleParameters:
		_frame_data.parameters[param_id] = float(value)
#endregion
#endregion

#region character
func _set_character(character_resource: VneCharacterResource) -> void:
	_create_category_label("Персонаж")
	
	if character_resource.emotions.size() > 0:
		var current_emotion = (_frame_data as VneCharacterFrame).emotion
		var parameter := VneOptionInspectorParameter.new("Эмоция", character_resource.emotions)
		parameter.value_changed_string.connect(_on_character_emotion_changed)
		parameter.set_value_string(current_emotion)
		parameters_container.add_child(parameter)


func _on_character_emotion_changed(value: String) -> void:
	if _frame_data is VneCharacterFrame:
		_frame_data.emotion = value
#endregion

func _set_location(location_resource: VneLocationResource) -> void:
	_create_category_label("Локация")


func _set_fvx(fvx_resource: VneVfxResource) -> void:
	_create_category_label("Визуальный эффект")


func set_visability(visible: bool) -> void:
	if visible:
		visible = _frame_data != null
	self.visible = visible


func _clear_container() -> void:
	for child in parameters_container.get_children():
		child.queue_free()


func _create_category_label(category_name: String) -> void:
	var label = RichTextLabel.new()
	parameters_container.add_child(label)
	label.text = category_name
	label.fit_content = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
