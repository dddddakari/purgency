extends Node2D

var entered = false

func _on_bathroom_body_entered(_body: Node2D) -> void:
	if _body.name == "Player": 
		get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/f1_rooms_area/Bathroom/Bathroom.tscn")


func _on_bathroom_body_exited(_body: Node2D) -> void:
	pass # Replace with function body.
