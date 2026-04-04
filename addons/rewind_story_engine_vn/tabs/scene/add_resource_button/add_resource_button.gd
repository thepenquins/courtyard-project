@tool
@abstract class_name VneAddResourceButton
extends Button


signal resource_edited(resource: VneResource)
signal resource_added(resource: VneResource)
signal resource_removed(resource: VneResource)
signal resources_order_changed(new_order: Array[VneResource])

@export var _res_container: Container

var _popup_menu: PopupMenu
var _resources: Array

var _added_resources: Array


func _init() -> void:
	_popup_menu = PopupMenu.new()
	_popup_menu.index_pressed.connect(_on_popup_menu_index_pressed)
	add_child(_popup_menu)
	_popup_menu.hide()


func _ready() -> void:
	icon = EditorIcons.get_icon("Add")
	if _res_container and _res_container.has_signal("order_changed"):
		_res_container.order_changed.connect(_on_container_order_changed)


@abstract func set_resources() -> void


func _fill_items() -> void:
	_popup_menu.clear()
	for resource: VneResource in _resources:
		_popup_menu.add_item(resource.name)


func _pressed() -> void:
	if _popup_menu.item_count == 0:
		return
	_popup_menu.position = get_screen_transform().origin + get_local_mouse_position()
	_popup_menu.popup()


func _on_popup_menu_index_pressed(index: int) -> void:
	var resource: VneResource = _resources[index]
	_add_resource(resource, index)


func _on_container_order_changed() -> void:
	var new_order: Array[VneResource]
	for child in _res_container.get_children():
		if child is VneResourceContainer:
			new_order.append(child.resource)
	resources_order_changed.emit(new_order)


func update() -> void:
	disabled = _resources == null or _resources.size() == 0
	_fill_items()
	_update_button_disabled()


func clear() -> void:
	_added_resources.clear()
	_clear_container()


func _clear_container() -> void:
	for child in _res_container.get_children():
		child.queue_free()


func _add_resource_container(resource: VneResource) -> VneResourceContainer:
	var container = _get_resource_container()
	container.selected.connect(_on_container_resource_selected)
	container.set_resource(resource)
	_res_container.add_child(container)
	return container


@abstract func _get_resource_container() -> VneResourceContainer


func _on_container_resource_selected(resource: VneResource) -> void:
	resource_edited.emit(resource)


func _get_index_of_resource(resource: VneResource) -> int:
	return VNE.visual_novel.get_resource_index_in_array(resource)


func _add_resource(resource: VneResource, index: int = -1, emit_signal: bool = true) -> void:
	if index == -1:
		index = _get_index_of_resource(resource)
	
	_added_resources.append(resource)
	_popup_menu.set_item_disabled(index, true)
	
	var resource_container = _add_resource_container(resource)
	resource_container.removed.connect(_remove_resource)
	
	if emit_signal:
		resource_added.emit(resource)
	
	_update_button_disabled()


func _remove_resource(resource: VneResource, index: int = -1) -> void:
	if index == -1:
		index = _get_index_of_resource(resource)
	
	_added_resources.erase(resource)
	_popup_menu.set_item_disabled(index, false)
	
	resource_removed.emit(resource)
	
	_update_button_disabled()


func _update_button_disabled() -> void:
	disabled = _resources.size() == _added_resources.size()


func select_resources(resources: Array) -> void:
	clear()
	update()
	for resource in resources:
		_add_resource(resource, -1, false)
