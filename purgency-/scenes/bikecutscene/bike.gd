extends Node2D

func _ready():
	# Disable input by showing a fullscreen blocker
	$InputBlocker.visible = true
	$AnimatedSprite2D.play("Bike_Cutscene")
	$AnimatedSprite2D.animation_finished.connect(_on_cutscene_finished)

func _on_cutscene_finished():
	# Re-enable input (optional, for debugging)
	$InputBlocker.visible = false
	# Transition to your next scene
	get_tree().change_scene_to_file("res://scenes/outside/Hospital.tscn")
