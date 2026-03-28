@tool extends Button

@export var icon_name: StringName:
	set(value):
		icon_name = value
		if Engine.is_editor_hint():
			icon = EditorIcons.get_icon(icon_name)
