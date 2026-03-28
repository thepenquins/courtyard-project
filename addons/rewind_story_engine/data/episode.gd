class_name RSEEpisode
extends RSEBaseData


const FILE_EXTENSION: String = "rsee"

var _story
var _uuid_generator

var frames: Array[RSEFrame]
var frames_without_commentary: Array[RSEFrame]:
	get:
		var array: Array[RSEFrame]
		for frame in frames:
			if not frame.is_commentary:
				array.append(frame)
		return array


func _init(uuid: String, story: RSEStory) -> void:
	super(uuid)
	self._story = story
	self._extension = FILE_EXTENSION
	self._uuid_generator = UUIDGenerator.new()


func get_string_data() -> PackedStringArray:
	var array = super()
	
	## Добавление пустой строки перед кадрами.
	array.append("")
	
	for frame in frames:
		array.append_array(frame.get_string_data())
		## Добавление пустой строки между кадрами.
		array.append("")
	
	return array


func fill_data(file: FileAccess) -> void:
	super(file)
	
	## Считывание пустой строки перед кадрами.
	file.get_line()
	
	while file.get_position() < file.get_length():
		var frame = RSEFrame.new(_story)
		frame.fill_data(file)
		frames.append(frame)
		## Считывание пустой строки между кадрами.
		file.get_line()


func add_frame() -> RSEFrame:
	var frame = RSEFrame.new(_story, _uuid_generator.v4())
	frames.append(frame)
	return frame


func move_frame_forward(frame: RSEFrame) -> bool:
	var index = frames.find(frame)
	
	## Если элемент последний в массиве, то двигать вперёд некуда.
	if index == frames.size() - 1:
		return false
	
	frames.pop_at(index)
	frames.insert(index + 1, frame)
	
	return true


func move_frame_back(frame: RSEFrame) -> bool:
	var index = frames.find(frame)
	
	## Если элемент первый в массиве, то двигать назад некуда.
	if index == 0:
		return false
	
	frames.pop_at(index)
	frames.insert(index - 1, frame)
	
	return true


func remove_frame(frame: RSEFrame) -> void:
	for index in frames.size():
		if frames[index] == frame:
			frames.remove_at(index)
			break


# TODO: Добавить обработку комментариев.
func parse_text_file(path_to_file: String) -> void:
	var file = FileAccess.open(path_to_file, FileAccess.READ)
	
	var speaker: String = ""
	var text: String = ""
	
	while file.get_position() < file.get_length():
		var line = file.get_line()
		
		if line.begins_with("#"):
			continue
		
		if line.is_empty():
			speaker = ""
			text = ""
			continue
		
		if line.begins_with("!"):
			speaker = line.substr(1)
			continue
		
		text = line
		
		## Итоговый кадр.
		## --------------------------------------------------
		var frame: RSEFrame = add_frame()
		frame.speaker = speaker
		frame.text = text
		## --------------------------------------------------
	
	file.close()


func get_words_count() -> int:
	var words_count: int = 0
	
	for frame in frames:
		words_count += WordCounter.count(frame.text)
	
	return words_count


func get_frame_by_uuid(uuid: String, include_commentary: bool = false) -> RSEFrame:
	for frame in frames:
		if not include_commentary and frame.is_commentary:
			continue
		if frame.uuid == uuid:
			return frame
	return null
