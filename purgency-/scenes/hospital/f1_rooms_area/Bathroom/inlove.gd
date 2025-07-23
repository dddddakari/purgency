extends Area2D

@onready var interactable: Area2D = $interactable

func _ready():
	interactable.interact = _on_interact

func _on_interact():
	var dialogue = get_node("/root/RoomsArea/Dialogue")
	dialogue.d_file = "res://json/eww.json"
	dialogue.start()
