extends Node2D

var entered = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.name == "CharacterBody2D": 
		get_tree().change_scene_to_file.call_deferred("res://minigames/maze/Jumpscare.tscn")

	

func _on_exit_body_entered(_body: Node2D) -> void:
	if _body.name == "CharacterBody2D":
		get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/f1_rooms_area/RoomsArea.tscn")
