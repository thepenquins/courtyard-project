class_name Profile
extends RefCounted


## Просмотренные эпизоды и кадры.
var viewed: Dictionary


func add_viewed(episode_uuid: String, frame_index: int) -> void:
	if not viewed.has(episode_uuid):
		viewed[episode_uuid] = []
	
	if not viewed[episode_uuid].has(float(frame_index)):
		viewed[episode_uuid].append(float(frame_index))


func is_viewed(episode_uuid: String, frame_index: int) -> bool:
	if not viewed.has(episode_uuid):
		return false
	
	if not viewed[episode_uuid].has(float(frame_index)):
		return false
	
	return true


func is_viewed_episode(episode_uuid: String) -> bool:
	return viewed.has(episode_uuid)


func save_to_file(path_to_file: String) -> void:
	var data := {
		"viewed" : viewed,
	}
	
	var json_string = JSON.stringify(data, " ")
	
	var file = FileAccess.open(path_to_file, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()


static func load_from_file(path_to_file: String) -> Profile:
	var profile = Profile.new()
	
	var file = FileAccess.open(path_to_file, FileAccess.READ)
	if file == null:
		return profile
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		profile.viewed = json.data["viewed"]
	
	print("Profile has been loaded.")
	if Engine.is_editor_hint():
		print("Viewed: %s" % profile.viewed)
	return profile
