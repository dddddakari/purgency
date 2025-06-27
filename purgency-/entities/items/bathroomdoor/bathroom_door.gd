extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	# Debug: Make the collision shape visible
	interactable.get_node("CollisionShape2D").debug_color = Color.RED

func _on_interact():
	print("bathroom door interaction")
	get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/f1_rooms_area/Bathroom/Bathroom.tscn")
