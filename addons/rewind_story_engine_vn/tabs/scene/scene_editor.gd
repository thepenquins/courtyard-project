@tool
class_name VneSceneEditor
extends Control


const EMPTY_STRING = "[Пусто]"

@export var margin_container: MarginContainer

@export var ui_controls: Array[Control]

@export var location_option_button: VneAddResourceOptionButton
@export var music_option_button: VneAddResourceOptionButton
@export var bgs_option_button: VneAddResourceOptionButton
@export var add_sfx_button: VneAddSfxButton
@export var add_character_button: VneAddCharacterButton
@export var add_vfx_button: VneAddVfxButton
@export var transition_in_option_button: VneAddTransitionButton
@export var transition_out_option_button: VneAddTransitionButton

@export var auto_inherit_check_box: CheckBox
@export var inherit_prev_button: Button
@export var inherit_next_button: Button

@export var _frame_spin_box: SpinBox

@export var inspector: VneInspector

@export var scene_player: VneScenePlayer

var _scene: VneScene
var _frame: VneFrame
var _index: int

var _edited_resource: VneResource


func _ready() -> void:
	margin_container.visible = not _scene == null


func initialize() -> void:
	add_sfx_button.set_resources()
	add_character_button.set_resources()
	location_option_button.set_resources()
	music_option_button.set_resources()
	bgs_option_button.set_resources()
	add_vfx_button.set_resources()
	transition_in_option_button.set_resources()
	transition_out_option_button.set_resources()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			update_options()
			scene_player.load_all_characters()
			scene_player.play_all_audio()
			if _frame != null:
				set_frame(_index)
		else:
			scene_player.stop_all_audio()


func update_options() -> void:
	add_sfx_button.update()
	add_character_button.update()
	location_option_button.update()
	music_option_button.update()
	bgs_option_button.update()
	add_vfx_button.update()
	transition_in_option_button.update()
	transition_out_option_button.update()


func set_scene(scene: VneScene) -> void:
	margin_container.visible = not scene == null
	
	if _scene != scene:
		_scene = scene
		scene_player.set_scene(scene)
		set_frame(0)


func set_frame(index: int) -> void:
	if _scene == null:
		return
	
	var frame_info = _scene.get_frame(index, true)
	
	_frame = frame_info.frame
	_index = frame_info.index
	
	_frame_spin_box.set_value_no_signal(_index + 1)
	
	# Если выбранный ресурс уже есть на сцене, заново выбрать его.
	var edited_frame_data = _frame.get_frame_data_by_resource(_edited_resource)
	inspector.set_frame_data(edited_frame_data)
	
	# Если кадр новый и автонаследование включено, нужно наследовать предыдущий кадр.
	if frame_info.new and auto_inherit_check_box.button_pressed:
		_inherit_prev_frame()
		return
	
	_update_inherit_buttons()
	
	# Установить персонажей.
	add_character_button.select_resources(_frame.character_resources)
	
	# Установить локацию.
	location_option_button.select_resource(_frame.location.resource) ## TODO: Ошибка.
	
	# Установить музыку.
	music_option_button.select_resource(_frame.music.resource)
		
	# Установить фоновый звук.
	bgs_option_button.select_resource(_frame.bgs.resource)
	
	# Установить звуковые эффекты.
	add_sfx_button.select_resources(_frame.sfx_resources)
	
	# Установить визуальные эффекты.
	add_vfx_button.select_resources(_frame.vfx_resources)
	
	# Установить переход в начале.
	transition_in_option_button.select_resource(_frame.transition_in)
	
	# Установить переход в конце.
	transition_out_option_button.select_resource(_frame.transition_out)
	
	scene_player.set_frame(_index)


func _on_add_location_button_resource_selected(resource: VneResource) -> void:
	if _frame == null:
		return
	if not _frame.location:
		_frame.location = VneLocationFrame.new()
	_frame.location.resource = resource
	scene_player.set_location(_frame.location)
	
	if _edited_resource is VneLocationResource:
		inspector.set_frame_data(_frame.get_frame_data_by_resource(resource))
	
	_clear_frame_data(_frame.location)


func _on_add_music_button_resource_selected(resource: VneResource) -> void:
	if _frame == null:
		return
	if not _frame.music:
		_frame.music = VneMusicFrame.new()
	_frame.music.resource = resource
	scene_player.set_music(_frame.music)
	
	if _edited_resource is VneMusicResource:
		inspector.set_frame_data(_frame.get_frame_data_by_resource(resource))
	
	#_clear_frame_data(_frame.music)


func _on_add_bgs_button_resource_selected(resource: VneResource) -> void:
	if _frame == null:
		return
	if not _frame.bgs:
		_frame.bgs = VneBgsFrame.new()
	_frame.bgs.resource = resource
	scene_player.set_bgs(_frame.bgs)
	
	if _edited_resource is VneBgsResource:
		inspector.set_frame_data(_frame.get_frame_data_by_resource(resource))
	
	_clear_frame_data(_frame.bgs)


func _on_character_resource_added(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.add_character(resource)
	
	scene_player.set_characters(_frame.characters)


func _on_character_resource_removed(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.remove_character(resource)
	
	if _edited_resource is VneCharacterResource:
		_edited_resource = null
		inspector.set_frame_data(null)
	
	scene_player.set_characters(_frame.characters)


func _on_characters_resources_order_changed(new_order: Array[VneResource]) -> void:
	if _frame == null:
		return
	
	var new_characters: Array[VneCharacterFrame] = []
	for resource in new_order:
		var character_f = _frame.character_frames_by_resource.get(resource)
		if character_f:
			new_characters.append(character_f)
	_frame.characters = new_characters
	
	scene_player.set_characters(new_characters)


func _on_sfx_resource_added(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.add_sfx(resource)


func _on_sfx_resource_removed(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.remove_sfx(resource)
	
	if _edited_resource is VneSfxResource:
		_edited_resource = null
		inspector.set_frame_data(null)


func _on_sfx_resources_order_changed(new_order: Array[VneResource]) -> void:
	if _frame == null:
		return
	
	var new_sfxs: Array[VneSfxFrame] = []
	for resource in new_order:
		var sfx_f = _frame.sfx_frames_by_resource.get(resource)
		if sfx_f:
			new_sfxs.append(sfx_f)
	_frame.sfx = new_sfxs


func _on_vfx_resource_added(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.add_vfx(resource)


func _on_vfx_resource_removed(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.remove_vfx(resource)
	
	if _edited_resource is VneVfxResource:
		_edited_resource = null
		inspector.set_frame_data(null)


func _on_vfx_resources_order_changed(new_order: Array[VneResource]) -> void:
	if _frame == null:
		return
	
	var new_vfxs: Array[VneVfxFrame] = []
	for resource in new_order:
		var vfx_f = _frame.vfx_frames_by_resource.get(resource)
		if vfx_f:
			new_vfxs.append(vfx_f)
	_frame.vfx = new_vfxs


func _on_transition_in_option_button_resource_selected(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.transition_in = resource


func _on_transition_out_option_button_resource_selected(resource: VneResource) -> void:
	if _frame == null:
		return
	_frame.transition_out = resource


func _on_ui_check_button_toggled(toggled_on: bool) -> void:
	for control in ui_controls:
		if control is VneInspector:
			control.set_visability(not toggled_on)
		else:
			control.visible = not toggled_on


func _on_prev_frame_pressed() -> void:
	if _frame == null:
		return
	set_frame(_index - 1)


func _on_next_frame_pressed() -> void:
	if _frame == null:
		return
	set_frame(_index + 1)


func _on_frame_spin_box_value_changed(value: float) -> void:
	set_frame(value - 1)


# TODO: Наследовать последний кадр из предыдущего эпизода.
# TODO: Блокировать, если текущий кадр первый и нет предыдущих эпизодов.
func _inherit_prev_frame() -> void:
	# Если кадр первый, то наследовать в этом эпизоде нечего.
	# TODO: Нужно как-то проверить наличие предыдущего эпизода.
	if _index == 0:
		return
	
	var prev_frame_info = _scene.get_frame(_index - 1)
	if prev_frame_info.frame == null:
		return
	
	_frame.copy_from(prev_frame_info.frame)
	set_frame(_index)


func _inherit_next_frame() -> void:
	# Если кадр последний в эпизоде, то наследовать нечего.
	if _index >= _scene.frames.size() - 1:
		return
	
	var next_frame_info = _scene.get_frame(_index + 1)
	if next_frame_info.frame == null:
		return
	
	_frame.copy_from(next_frame_info.frame)
	set_frame(_index)


func _update_inherit_buttons() -> void:
	inherit_prev_button.disabled = _index == 0
	inherit_next_button.disabled = _index >= _scene.frames.size() - 1


func _on_clear_scene_button_pressed() -> void:
	_frame.clear()
	set_frame(_index)


func _on_resource_edited(resource: VneResource) -> void:
	if _edited_resource != resource:
		_edited_resource = resource
		inspector.set_frame_data(_frame.get_frame_data_by_resource(resource))


func _clear_frame_data(frame_data: VneBaseFrameData) -> void:
	if frame_data is VneFrameWithMultipleParameters:
		frame_data.parameters.clear()


func _on_inspector_frame_was_changed(frame_data: VneBaseFrameData) -> void:
	pass # Replace with function body.


func _on_inspector_audio_was_changed(frame_data: VneBaseFrameData) -> void:
	if frame_data is VneMusicFrame:
		scene_player.set_music(_frame.music)
	if frame_data is VneBgsFrame:
		scene_player.set_bgs(_frame.bgs)
	if frame_data is VneSfxFrame:
		scene_player.set_sfx(_frame.sfx)


func _on_inspector_character_was_changed(frame_data: VneBaseFrameData) -> void:
	scene_player.set_characters(_frame.characters)
	scene_player.set_text(null, true)


func _on_inspector_location_was_changed(frame_data: VneBaseFrameData) -> void:
	scene_player.set_location(_frame.location)


func _on_inherit_characters_next_button_pressed() -> void: 
	var total_frames = _scene.episode.frames_without_commentary.size()
	for i in range(_index + 1, total_frames):
		var frame_info = _scene.get_frame(i, true)
		if frame_info.frame:
			frame_info.frame.copy_characters_from(_frame)


func _on_inherit_location_next_button_pressed() -> void:
	var total_frames = _scene.episode.frames_without_commentary.size()
	for i in range(_index + 1, total_frames):
		var frame_info = _scene.get_frame(i, true)
		if frame_info.frame:
			frame_info.frame.copy_location_from(_frame)


func _on_inherit_music_next_button_pressed() -> void:
	var total_frames = _scene.episode.frames_without_commentary.size()
	for i in range(_index + 1, total_frames):
		var frame_info = _scene.get_frame(i, true)
		if frame_info.frame:
			frame_info.frame.copy_music_from(_frame)


func _on_inherit_bgs_next_button_pressed() -> void:
	var total_frames = _scene.episode.frames_without_commentary.size()
	for i in range(_index + 1, total_frames):
		var frame_info = _scene.get_frame(i, true)
		if frame_info.frame:
			frame_info.frame.copy_bgs_from(_frame)


func _on_inherit_sfx_next_button_pressed() -> void:
	var total_frames = _scene.episode.frames_without_commentary.size()
	for i in range(_index + 1, total_frames):
		var frame_info = _scene.get_frame(i, true)
		if frame_info.frame:
			frame_info.frame.copy_sfx_from(_frame)


func _on_inherit_vfx_next_button_pressed() -> void:
	var total_frames = _scene.episode.frames_without_commentary.size()
	for i in range(_index + 1, total_frames):
		var frame_info = _scene.get_frame(i, true)
		if frame_info.frame:
			frame_info.frame.copy_vfx_from(_frame)
