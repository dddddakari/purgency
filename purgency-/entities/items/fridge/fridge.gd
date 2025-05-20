extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
		print("fridge opened	")
