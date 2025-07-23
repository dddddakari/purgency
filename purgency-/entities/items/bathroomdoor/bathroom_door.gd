extends Area2D

@onready var interactable: Area2D = $interactable

func _ready() -> void:
	interactable.interact = _on_interact
	# Debug: Make the collision shape visible
	if interactable.has_node("CollisionShape2D"):
		interactable.get_node("CollisionShape2D").debug_color = Color.RED

func _on_interact():
	print("bathroom door interaction")
	
	if QuestManager.nurse_left_to_find_janitor:
		print("Loading animated couple scene")
		if ResourceLoader.exists("res://scenes/hospital/f1_rooms_area/Bathroom/Bathroom_together.tscn"):
			# Remove any existing nurse instance first
			var nurse = get_tree().get_first_node_in_group("nurse")
			if nurse:
				nurse.queue_free()
			
			get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/f1_rooms_area/Bathroom/Bathroom_together.tscn")
		else:
			push_error("Bathroom_together scene not found!")
	else:
		print("Loading normal bathroom scene")
		if ResourceLoader.exists("res://scenes/hospital/f1_rooms_area/Bathroom/BathroomPooped.tscn"):
			get_tree().change_scene_to_file.call_deferred("res://scenes/hospital/f1_rooms_area/Bathroom/BathroomPooped.tscn")
		else:
			push_error("BathroomPooped scene not found!")
