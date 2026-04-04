@tool extends Control

@export var developers: PackedStringArray = []
@export var separator: String = " • "
@export var speed: float = 100.0
@export var spacing: float = 50.0
@export var pause_on_hover: bool = true
@export var font: Font = null:
	set(value):
		font = value
		_apply_font()
@export var text_color: Color = Color.WHITE:
	set(value):
		text_color = value
		_apply_color()

var _labels: Array[Label] = []
var _text: String = ""
var _paused: bool = false


func _ready():
	_create_labels()
	_update_text()
	await get_tree().process_frame
	_reset_positions()
	resized.connect(_reset_positions)
	if pause_on_hover:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)


func _create_labels():
	for i in 4:
		var label = Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.clip_text = false
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		_labels.append(label)
	_apply_font()
	_apply_color()


func _apply_font():
	if font == null:
		return
	for label in _labels:
		label.add_theme_font_override("font", font)


func _apply_color():
	for label in _labels:
		label.add_theme_color_override("font_color", text_color)


func _update_text():
	if developers.is_empty():
		_text = ""
		for label in _labels:
			label.text = ""
		return
	_text = separator.join(developers)
	for label in _labels:
		label.text = _text
	await resized
	for label in _labels:
		await label.resized


func _reset_positions():
	if _text.is_empty():
		return
	var y_center = (size.y - _labels[0].size.y) / 2
	var x = 0.0
	for i in range(_labels.size()):
		_labels[i].position = Vector2(x, y_center)
		x += _labels[i].size.x + spacing


func _process(delta):
	if _text.is_empty() or not visible or _paused:
		return
	for label in _labels:
		label.position.x -= speed * delta
	if _labels[0].position.x + _labels[0].size.x < 0:
		var first = _labels.pop_front()
		var last = _labels[-1]
		first.position.x = last.position.x + last.size.x + spacing
		_labels.append(first)


func _on_mouse_entered():
	_paused = true


func _on_mouse_exited():
	_paused = false


func set_developers(new_developers: PackedStringArray):
	developers = new_developers
	_update_text()
	_reset_positions()
