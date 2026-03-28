@tool
extends VneBaseTreeTab


const NEW_RESOURCE_NAME = "Новый ресурс"


var _characters_category: TreeItem
var _locations_category: TreeItem
var _music_category: TreeItem
var _bgs_category: TreeItem
var _sfx_category: TreeItem
var _vfx_category: TreeItem
var _transitions_category: TreeItem

@export var resource_editor: VneResourceEditor

var resources_by_item: Dictionary[TreeItem, VneResource]
var _current_resource: VneResource


func _initialize_process() -> void:
	popup_menu.set_item_icon(0, EditorIcons.get_icon("ClassList"))
	popup_menu.set_item_icon(2, EditorIcons.get_icon("Remove"))


func _pre_update_tree_process() -> void:
	pass


func _after_update_tree_process() -> void:
	var item = resources_by_item.find_key(_current_resource)
	if item:
		tree.set_selected(item, 0)
	else:
		resource_editor.set_resource(null)


func _pre_fill_tree_process() -> void:
	_characters_category = _add_category("Персонажи", EditorIcons.get_icon("CharacterBody2D"), false)
	_locations_category = _add_category("Локации", EditorIcons.get_icon("WorldEnvironment"))
	_music_category = _add_category("Музыка", EditorIcons.get_icon("AudioStreamMP3"))
	_bgs_category = _add_category("Фоновые звуки", EditorIcons.get_icon("AudioStream"))
	_sfx_category = _add_category("Звуковые эффекты", EditorIcons.get_icon("AudioStreamPlayer2D"))
	_vfx_category = _add_category("Визуальные эффекты", EditorIcons.get_icon("CPUParticles2D"))
	_transitions_category = _add_category("Переходы", EditorIcons.get_icon("Animation"))



func update_tree(root_name: String = "root") -> void:
	super("Ресурсы")


func _add_category(c_name: String, c_icon: Texture2D = null, add_button: bool = true) -> TreeItem:
	var category_item = tree.create_item(_tree_root)
	
	category_item.set_selectable(0, false)
	category_item.set_text(0, c_name)
	category_item.set_icon(0, c_icon)
	if add_button:
		category_item.add_button(0, EditorIcons.get_icon("Add"))
	
	return category_item


func fill_tree() -> void:
	resources_by_item.clear()
	for resource in VNE.resources:
		var item: TreeItem
		if resource is VneCharacterResource:
			item = add_item(resource.name, _characters_category)
		if resource is VneLocationResource:
			item = add_item(resource.name, _locations_category)
		elif resource is VneMusicResource:
			item = add_item(resource.name, _music_category)
		elif resource is VneBgsResource:
			item = add_item(resource.name, _bgs_category)
		elif resource is VneSfxResource:
			item = add_item(resource.name, _sfx_category)
		elif resource is VneVfxResource:
			item = add_item(resource.name, _vfx_category)
		elif resource is VneTransitionResource:
			item = add_item(resource.name, _transitions_category)
		_check_resource_path(resource, item)
		resources_by_item[item] = resource


func _on_tree_button_clicked(category: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if mouse_button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var item = add_item(NEW_RESOURCE_NAME, category)
		var resource: VneResource
		match category:
			_locations_category:
				resource = VneLocationResource.new(RSE.story.get_uuid(), NEW_RESOURCE_NAME)
			_music_category:
				resource = VneMusicResource.new(RSE.story.get_uuid(), NEW_RESOURCE_NAME)
			_bgs_category:
				resource = VneBgsResource.new(RSE.story.get_uuid(), NEW_RESOURCE_NAME)
			_sfx_category:
				resource = VneSfxResource.new(RSE.story.get_uuid(), NEW_RESOURCE_NAME)
			_vfx_category:
				resource = VneVfxResource.new(RSE.story.get_uuid(), NEW_RESOURCE_NAME)
			_transitions_category:
				resource = VneTransitionResource.new(RSE.story.get_uuid(), NEW_RESOURCE_NAME)
		resources_by_item[item] = resource
		VNE.visual_novel.add_resource(resource)


func _on_tree_cell_selected() -> void:
	super()
	_current_resource = resources_by_item[_selected_item]
	resource_editor.set_resource(_current_resource)


func _on_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	super(mouse_position, mouse_button_index)
	if mouse_button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		_current_resource = resources_by_item[_selected_item]
		popup_menu.set_item_disabled(2, _current_resource is VneCharacterResource)


func _on_popup_menu_index_pressed(index: int) -> void:
	if index == 2:
		confirmation_dialog.show()


func _on_confirmation_dialog_confirmed() -> void:
	VNE.visual_novel.remove_resource(resources_by_item[_selected_item])
	resources_by_item.erase(_selected_item)
	_selected_item.free()
	_selected_item = null
	_current_resource = null
	resource_editor.set_resource(null)


func _on_resource_editor_resource_renamed(resource: VneResource) -> void:
	var item: TreeItem = resources_by_item.find_key(resource)
	item.set_text(0, resource.name)


func _on_resource_editor_resource_path_changed(resource: VneResource) -> void:
	var item: TreeItem = resources_by_item.find_key(resource)
	_check_resource_path(resource, item)


func _check_resource_path(resource: VneResource, item: TreeItem) -> void:
	if resource.path_to_file == "":
		item.set_icon(0, EditorIcons.get_icon("NodeWarning"))
		item.set_tooltip_text(0, "Пустой ресурс.")
	else:
		item.set_icon(0, null)
		item.set_tooltip_text(0, "")
