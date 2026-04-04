class_name AutoVersionExportPlugin extends EditorExportPlugin


func _get_name() -> String:
	return "Auto Version"


func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	var version = ProjectSettings.get_setting("application/config/version") as String

	var splitted_version = version.split(".")
	if splitted_version.size() < 2:
		return
	
	var major = splitted_version[0] as int
	var minor = splitted_version[1] as int

	minor += 1

	version = "%s.%s" % [major, minor]

	ProjectSettings.set_setting("application/config/version", version)
	ProjectSettings.save()

	print("Версия сборки: %s" % version)
