extends Node

func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("game.tscn")

func _on_button_settings_pressed() -> void:
	get_tree().change_scene_to_file("settings.tscn")

func _on_button_exit_pressed() -> void:
	get_tree().quit()
