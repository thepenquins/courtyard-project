@tool
class_name WordCounter
extends RefCounted


static func count(text: String) -> int:
	var regex = RegEx.new()
	regex.compile("[\\p{L}\\d'-]+")
	return regex.search_all(text).size()
