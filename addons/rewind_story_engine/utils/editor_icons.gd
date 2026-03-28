@tool class_name EditorIcons extends Object


static var base_control: Control


static func get_icon(icon_name: StringName) -> Texture2D:
	if not Engine.is_editor_hint():
		return null
	if not base_control:
		base_control = EditorInterface.get_base_control()
	return base_control.get_theme_icon(icon_name, "EditorIcons")
