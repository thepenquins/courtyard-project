@tool
@abstract class_name VneAddResourceOptionButton
extends OptionButton


signal resource_selected(resource: VneResource)
signal resource_edited(resource: VneResource)


const EMPTY_STRING = "[Пусто]"

var _resources: Array
var _resource: VneResource


func _init() -> void:
	fit_to_longest_item = false
	item_selected.connect(_on_item_selected)


@abstract func set_resources() -> void


func _fill_items() -> void:
	clear()
	_add_first_item()
	for resource in _resources:
		add_item(resource.name)


func _add_first_item() -> void:
	add_item(EMPTY_STRING)


func _on_item_selected(index: int) -> void:
	if index == 0:
		resource_selected.emit(null)
	else:
		_resource = _resources[index - 1]
		resource_selected.emit(_resources[index - 1])


func update() -> void:
	_fill_items()


func select_resource(resource: VneResource) -> void:
	_resource = resource
	if resource == null:
		select(0)
	else:
		select(VNE.visual_novel.get_resource_index_in_array(resource) + 1)


func _on_edit_pressed() -> void:
	resource_edited.emit(_resource)
