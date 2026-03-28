@tool
extends VneBaseTreeTab


@export var scene_editor: VneSceneEditor

var episodes_by_item: Dictionary[TreeItem, RSEEpisode]
var _current_scene: VneScene


func _initialize_process() -> void:
	scene_editor.initialize()


func _pre_update_tree_process() -> void:
	pass


func _after_update_tree_process() -> void:
	if _current_scene:
		var item = episodes_by_item.find_key(_current_scene.episode)
		if item:
			tree.set_selected(item, 0)
		else:
			scene_editor.set_scene(null)


func _pre_fill_tree_process() -> void:
	pass


func fill_tree() -> void:
	episodes_by_item.clear()
	for episode in RSE.episodes:
		var item = add_item(episode.name)
		episodes_by_item[item] = episode
		if episode.frames.size() == 0:
			item.set_selectable(0, false)
			item.set_custom_color(0, Color(0.5, 0.5, 0.5))
			item.set_icon(0, EditorIcons.get_icon("NodeWarning"))
			item.set_tooltip_text(0, "У этого эпизода отсутствуют кадры!")


func _on_tree_cell_selected() -> void:
	super()
	var episode = episodes_by_item[_selected_item]
	_current_scene = VNE.visual_novel.get_scene_by_episode(episode)
	scene_editor.set_scene(_current_scene)
