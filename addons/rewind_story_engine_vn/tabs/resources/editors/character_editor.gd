@tool class_name VneCharacterEditor extends Control


@export var _tree: Tree
var _tree_root: TreeItem
var _tree_emotions: TreeItem
var _tree_outfits: TreeItem

var _resource: VneResource


func set_resource(character_resource: VneCharacterResource) -> void:
	_resource = character_resource
	
	_tree.clear()
	
	if _resource == null:
		return
	
	_tree_root = _tree.create_item()
	_tree_emotions = _tree.create_item(_tree_root)
	_tree_emotions.set_selectable(0, false)
	_tree_emotions.set_text(0, "Эмоции")
	_tree_emotions.set_icon(0, EditorIcons.get_icon("Sprite2D"))
	for emotion in character_resource.emotions:
		var emotion_item = _tree.create_item(_tree_emotions)
		emotion_item.set_text(0, emotion)
	
	_tree_outfits = _tree.create_item(_tree_root)
	_tree_outfits.set_selectable(0, false)
	_tree_outfits.set_icon(0, EditorIcons.get_icon("ViewportSpeed"))
	_tree_outfits.set_text(0, "Костюмы")


func _on_emotions_tree_item_selected() -> void:
	pass # Replace with function body.
