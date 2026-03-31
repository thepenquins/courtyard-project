@tool extends VBoxContainer

@export var title: String:
	set(value):
		title = value
		if title == "":
			_title_label.text = "[Название раздрела]"
		else:
			_title_label.text = title
@export var developers: Dictionary[String, String]
@export var lexicographical_sort: bool = true

@export_tool_button("Сгенерировать раздрел") var generate_action = _generate

var _title_label: Label
var _developers_container: Container


func _init() -> void:
	_create_title_label()
	_create_developers_container()


func _ready() -> void:
	_generate()


func _create_title_label() -> void:
	_title_label = Label.new()
	add_child(_title_label)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.text = title
	move_child(_title_label, 0)


func _create_developers_container() -> void:
	_developers_container = VBoxContainer.new()
	add_child(_developers_container)


func _generate() -> void:
	if lexicographical_sort:
		developers.sort()
	
	for child in _developers_container.get_children():
		child.queue_free()
	
	for developer in developers:
		_create_developer(developer, developers[developer])


func _create_developer(developer_name: String, url: String) -> void:
	var developer = RichTextLabel.new()
	_developers_container.add_child(developer)
	developer.bbcode_enabled = true
	developer.fit_content = true
	developer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if url == "":
		developer.text = developer_name
	else:
		developer.text = "[url=%s]%s[/url]" % [url, developer_name]
	developer.add_theme_font_size_override("normal_font_size", 16)
	developer.meta_clicked.connect(_on_developer_meta_clicked)


func _on_developer_meta_clicked(meta: Variant) -> void:
	print(meta)
