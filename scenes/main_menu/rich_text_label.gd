extends RichTextLabel


func _on_meta_clicked(meta: Variant) -> void:
	AudioPlayer.play_click()
	OS.shell_open(meta)
