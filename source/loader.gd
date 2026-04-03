extends Node


signal progress_changed(value: int)
signal load_complete()


var _path_to_scene: String
var _loaded_resource: PackedScene

var _progress: Array = []

var _loader_scene: Control


func _ready() -> void:
	var packed = load("res://scenes/ui/loader.tscn") as PackedScene
	_loader_scene = packed.instantiate()
	add_child(_loader_scene)
	
	VneScenePlayer.load_all_resources()


func _process(_delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(_path_to_scene, _progress)
	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			if _loader_scene:
				_loader_scene.hide()
			set_process(false)
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_changed.emit(_progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_resource = ResourceLoader.load_threaded_get(_path_to_scene)
			progress_changed.emit(1.0)
			load_complete.emit()
			get_tree().change_scene_to_packed(_loaded_resource)
			if _loader_scene:
				_loader_scene.hide()
			set_process(false)

	#_print_progress()


func load_scene(path_to_scene: String, use_sub_threads: bool = true) -> void:
	_path_to_scene = path_to_scene
	_start_load(use_sub_threads)


func _start_load(use_sub_threads: bool = true) -> void:
	var state = ResourceLoader.load_threaded_request(_path_to_scene, "", use_sub_threads)
	if state == OK:
		if _loader_scene:
			_loader_scene.show()
			_loader_scene.play_animation()
		set_process(true)


func _print_progress() -> void:
	print("Loading progress: %s" % _progress[0])
