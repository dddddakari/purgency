extends Area2D

var entered = false


func _on_body_entered(_body: Node2D) -> void:
	entered = true


func _on_body_exited(_body: Node2D) -> void:
	entered = false

func _process(_delta):
	if entered == true:
		if Input.is_action_just_pressed("interact_area"):
			get_tree().change_scene_to_file("res://scenes/bikecutscene/bike.tscn")
