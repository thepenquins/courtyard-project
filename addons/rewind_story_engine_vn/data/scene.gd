class_name VneScene
extends RSEBaseData


const FILE_EXTENSION: String = "vns"


var episode: RSEEpisode
var frames: Dictionary[String, VneFrame]


func _init(uuid: String) -> void:
	super(uuid, "")
	self._extension = FILE_EXTENSION


func set_episode(episode: RSEEpisode) -> void:
	self.episode = episode


func get_frame(index: int, create_new: bool = false) -> VneFrameInfo:
	var ep_frames = episode.frames_without_commentary
	
	if index < 0:
		index = 0
	
	if index >= ep_frames.size():
		index = ep_frames.size() - 1
	
	var frame: VneFrame
	var new := false
	var ep_frame = ep_frames[index]
	if frames.has(ep_frame.uuid):
		frame = frames[ep_frame.uuid]
	elif create_new:
		new = true
		frame = _create_frame(ep_frame)
	
	return VneFrameInfo.new(frame, index, new)


func _create_frame(ep_frame: RSEFrame) -> VneFrame:
	var frame = VneFrame.new(ep_frame.uuid, ep_frame.name)
	frames[ep_frame.uuid] = frame
	return frame


func get_string_data() -> PackedStringArray:
	var array = super()
	array.append(episode.uuid)
	
	## Добавление пустой строки перед кадрами.
	array.append("")
	
	for ep_frame in episode.frames_without_commentary:
		if frames.has(ep_frame.uuid):
			var frame = frames[ep_frame.uuid]
			array.append_array(frame.get_string_data())
			## Добавление пустой строки между кадрами.
			array.append("")
	
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	episode = RSE.story.get_episode_by_uuid(file.get_line())
	
	## Считывание пустой строки перед кадрами.
	file.get_line()
	
	while file.get_position() < file.get_length():
		var frame = VneFrame.new("")
		frame.fill_data(file)
		frames[frame.uuid] = frame
		## Считывание пустой строки между кадрами.
		file.get_line()
