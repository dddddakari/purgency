extends Node2D

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/kitchen/kitchen01.tscn")
	print("new game started")

func _on_continue_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	pass # Replace with function body.
