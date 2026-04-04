@tool extends TextureRect

@export var icon_name: StringName:
	set(value):
		icon_name = value
		if Engine.is_editor_hint():
			texture = EditorIcons.get_icon(icon_name)
