extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func check_ending():
	if bad_points > good_points:
		get_tree().change_scene_to_file("res://scenes/bad_ending.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/good_ending.tscn")
