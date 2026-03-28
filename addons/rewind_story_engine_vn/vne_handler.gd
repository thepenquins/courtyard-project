@tool
extends Node


var visual_novel: VneVisualNovel


var resources: Array[VneResource]:
	get:
		if visual_novel:
			return visual_novel.resources
		return []

var scenes: Array[VneScene]:
	get:
		if visual_novel:
			return visual_novel.scenes
		return []


func set_story(story: RSEStory) -> void:
	visual_novel = VneVisualNovel.new(story)
	visual_novel.load_vn()
