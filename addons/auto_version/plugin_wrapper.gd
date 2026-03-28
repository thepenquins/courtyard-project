@tool
extends EditorPlugin


var auto_version_plugin: AutoVersionExportPlugin


func _enter_tree() -> void:
    auto_version_plugin = AutoVersionExportPlugin.new()
    add_export_plugin(auto_version_plugin)


func _exit_tree() -> void:
    remove_export_plugin(auto_version_plugin)