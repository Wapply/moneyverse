extends Node

func _on_start_pressed():
	get_tree().change_scene_to_file("game.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("settings.tscn")

func _on_exit_pressed():
	get_tree().quit()
