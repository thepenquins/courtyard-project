@tool
extends Node


var story: RSEStory

var records: Array[RSERecord]:
	get:
		return story.records

var characters: Array[RSECharacter]:
	get:
		return story.characters

var episodes: Array[RSEEpisode]:
	get:
		return story.episodes


func get_record_by_name(record_name: String) -> RSERecord:
	if record_name == "":
		return
	
	for record in story.records:
		if record.name == record_name:
			return record
		
	return null


func get_character_by_name(character_name: String) -> RSECharacter:
	if character_name == "":
		return
	
	for character in story.characters:
		if character.name == character_name:
			return character
		
	return null


func get_episode_by_name(episode_name: String) -> RSEEpisode:
	if episode_name == "":
		return
	
	for episode in story.episodes:
		if episode.name == episode_name:
			return episode
		
	return null
