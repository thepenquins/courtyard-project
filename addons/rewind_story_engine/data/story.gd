class_name RSEStory
extends RefCounted


const PATH_RECORDS: String = "records"
const PATH_CHARACTERS: String = "characters"
const PATH_EPISODES: String = "episodes"


var _directory: String
var _path_to_story_file: String

var _uuid_generator: UUIDGenerator


var name: String

var records: Array[RSERecord]
var characters: Array[RSECharacter]
var episodes: Array[RSEEpisode]


func _init(path_to_story_file: String):
	_directory = path_to_story_file.get_base_dir()
	_path_to_story_file = path_to_story_file
	_uuid_generator = UUIDGenerator.new()
	
	var dir = DirAccess.open(_directory)
	if not dir.dir_exists(PATH_RECORDS):
		dir.make_dir(PATH_RECORDS)
	if not dir.dir_exists(PATH_CHARACTERS):
		dir.make_dir(PATH_CHARACTERS)
	if not dir.dir_exists(PATH_EPISODES):
		dir.make_dir(PATH_EPISODES)


func get_uuid() -> String:
	return _uuid_generator.v4()


func add_record() -> RSERecord:
	var record = RSERecord.new(get_uuid())
	records.append(record)
	return record


func add_character() -> RSECharacter:
	var character = RSECharacter.new(get_uuid())
	characters.append(character)
	return character


func add_episode() -> RSEEpisode:
	var episode = RSEEpisode.new(get_uuid(), self)
	episodes.append(episode)
	return episode


func remove_record(record: RSERecord) -> void:
	for index in records.size():
		if records[index] == record:
			records.remove_at(index)
			var p = _directory.path_join(PATH_RECORDS).path_join(record.path_to_data_file)
			DirAccess.remove_absolute(p)
			break


func remove_character(character: RSECharacter) -> void:
	for index in characters.size():
		if characters[index] == character:
			characters.remove_at(index)
			var p = _directory.path_join(PATH_CHARACTERS).path_join(character.path_to_data_file)
			DirAccess.remove_absolute(p)
			break


func remove_episode(episode: RSEEpisode) -> void:
	for index in episodes.size():
		if episodes[index] == episode:
			episodes.remove_at(index)
			var p = _directory.path_join(PATH_EPISODES).path_join(episode.path_to_data_file)
			DirAccess.remove_absolute(p)
			break


func get_words_count() -> int:
	var words_count: int = 0
	
	for record in records:
		words_count += WordCounter.count(record.text)
	
	for episode in episodes:
		words_count += episode.get_words_count()
		
	return words_count


func get_character_by_name(character_name: String) -> RSECharacter:
	if character_name == "":
		return
	
	for character in characters:
		if character.name == character_name:
			return character
		
	return null


#region Translation
func generate_pot() -> String:
	var pot: String = ""
	var keys: PackedStringArray = []
	
	pot = add_string_to_pot(pot, keys, "") ## Первая запись должна быть пустой.
	pot = add_header(pot)

	pot = add_string_to_pot(pot, keys, name)
	
	for record in records:
		pot = add_string_to_pot(pot, keys, record.name)
		pot = add_string_to_pot_with_uuid(pot, keys, record.text, record.uuid)
	
	for character in characters:
		pot = add_string_to_pot(pot, keys, character.name)
	
	for episode in episodes:
		pot = add_string_to_pot_with_uuid(pot, keys, episode.name, episode.uuid)
		for frame in episode.frames:
			if frame.is_commentary:
				continue
			pot = add_string_to_pot_with_uuid(pot, keys, frame.text, frame.uuid)
	
	return pot


func add_string_to_pot(pot: String, keys: PackedStringArray, text: String) -> String:
	if not keys.has(text):
		pot += get_pot_string(text)
		keys.append(text)
	
	return pot


func add_header(pot: String) -> String:
	pot += "\"POT-Creation-Date: %s\"\n" % Time.get_datetime_string_from_system()
	pot += "\"Content-Type: text/plain; charset=UTF-8\"\n"
	pot += "\"Content-Transfer-Encoding: 8bit\"\n"
	pot += "\n"

	return pot


func add_string_to_pot_with_uuid(pot: String, keys: PackedStringArray, text: String, uuid: String) -> String:
	if not keys.has(uuid):
		pot += add_comment(pot, text)
		pot += get_pot_string(uuid)
		keys.append(uuid)
	
	return pot


func add_comment(pot: String, text: String) -> String:
	var comment: String = ""
	for line in text.split("\n"):
		comment += "# %s\n" % line
	return comment


func get_pot_string(text: String) -> String:
	if "\n" in text:
		var lines = text.split("\n")
		var output = 'msgid ""'
		for line in lines:
			output += '"\n%s\\n"' % line
		return output + 'msgstr ""\n\n'
	return 'msgid "%s"\nmsgstr ""\n\n' % text
#endregion

#region Saving
func save() -> void:
	print("Сохранение истории: %s" % _path_to_story_file)
	
	var file = FileAccess.open(_path_to_story_file, FileAccess.WRITE)
	
	file.store_line(name)
	
	file.close()
	
	save_records()
	save_characters()
	save_episodes()


func save_characters() -> void:
	var dir_path = _directory.path_join(PATH_CHARACTERS)
	for character in characters:
		character.save_data(dir_path)


func save_records() -> void:
	var dir_path = _directory.path_join(PATH_RECORDS)
	for record in records:
		record.save_data(dir_path)


func save_episodes() -> void:
	var dir_path = _directory.path_join(PATH_EPISODES)
	for episode in episodes:
		episode.save_data(dir_path)
#endregion

#region Loading
static func load_from_file(path_to_file: String) -> RSEStory:
	if Engine.is_editor_hint():
		print("Загрузка истории: %s" % path_to_file)
		
	var story = RSEStory.new(path_to_file)
	
	var file = FileAccess.open(story._path_to_story_file, FileAccess.READ)
	
	story.name = file.get_line()
	
	file.close()
	
	var directory = path_to_file.get_base_dir()
	
	load_records(directory.path_join(PATH_RECORDS), story)
	load_characters(directory.path_join(PATH_CHARACTERS), story)
	load_episodes(directory.path_join(PATH_EPISODES), story)

	RSEBaseData.sort_data_array_by_name(story.records)
	RSEBaseData.sort_data_array_by_name(story.characters)
	RSEBaseData.sort_data_array_by_name(story.episodes)
	
	return story


static func get_files(directory: String, extension: String) -> PackedStringArray:
	var files: PackedStringArray
	
	var dir = DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(extension):
				files.append(file_name)
			file_name = dir.get_next()
	
	return files


static func load_records(directory: String, story: RSEStory) -> void:
	for file in get_files(directory, RSERecord.FILE_EXTENSION):
		var record = RSERecord.new("")
		record.load_data(directory.path_join(file))
		story.records.append(record)


static func load_characters(directory: String, story: RSEStory) -> void:
	for file in get_files(directory, RSECharacter.FILE_EXTENSION):
		var character = RSECharacter.new("")
		character.load_data(directory.path_join(file))
		story.characters.append(character)


static func load_episodes(directory: String, story: RSEStory) -> void:
	for file in get_files(directory, RSEEpisode.FILE_EXTENSION):
		var episode = RSEEpisode.new("", story)
		episode.load_data(directory.path_join(file))
		story.episodes.append(episode)
#endregion
