@tool
class_name RSEScriptEditor
extends CodeEdit


const MIN_FONT_SIZE = 12
const MAX_FONT_SIZE = 48
const FONT_STEP = 2

var font_size: int:
	get:
		return get_theme_font_size("font_size")
	set(value):
		if value < MIN_FONT_SIZE or value > MAX_FONT_SIZE:
			return
		add_theme_font_size_override("font_size", value)

var _characters: PackedStringArray = []


func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	gutters_draw_line_numbers = true # Показывать номер строк.
	indent_use_spaces = true # Использовать пробелы вместо табов.

	syntax_highlighter = RSEScriptHighlighter.new()

	text_changed.connect(_on_text_changed)


func increase_font_size() -> void:
	var size = get_theme_font_size("font_size")
	font_size = size + FONT_STEP


func decrease_font_size() -> void:
	var size = get_theme_font_size("font_size")
	font_size = size - FONT_STEP


func _on_text_changed() -> void:
	var caret_line = get_caret_line()
	var caret_column = get_caret_column()
	var line = get_line(caret_line)

	# Автозамена "-" на "— " в начале строки.
	if caret_column == 1 and line.begins_with("-"):
		begin_complex_operation()
		set_line(caret_line, "— " + line.substr(1))
		set_caret_column(2)
		end_complex_operation()
	# Добавление пробела после "—".
	elif line.begins_with("—"):
		var pos = line.find("—")
		if pos == 0 and line.length() >= 2:
			if line[1] != " ":
				begin_complex_operation()
				set_line(caret_line, "— " + line.substr(1))
				set_caret_column(3)
				end_complex_operation()

	# Триггер автозаполнения персонажей.
	if line.strip_edges() == "!":
		_update_auto_completion()
		request_code_completion(true)
	# Удаление знака "!" после выбора.
	elif line.begins_with("!"):
		var new_text = line.substr(1).strip_edges()
		begin_complex_operation()
		set_line(caret_line, new_text)
		end_complex_operation()


func _update_characters_list():
	_characters.clear()

	for character in RSE.story.characters:
		_characters.append(character.name)
	
	for line in text.split("\n"):
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("!"):
			continue
		if not line.begins_with("[") and not line.begins_with("#") and not line.begins_with("—"):
			var name = line
			if not name in _characters:
				_characters.append(name)


func _update_auto_completion() -> void:
	_update_characters_list()

	for character in _characters:
		add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, character, character)
	update_code_completion_options(true)


func _filter_code_completion_candidates(candidates: Array[Dictionary]) -> Array[Dictionary]:
	for candidate in candidates:
		(candidate["insert_text"] as String).replace("\"", "")
	return candidates
