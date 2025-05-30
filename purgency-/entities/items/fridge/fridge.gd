extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge

var fridge_inventory: Array = [
	{"name": "Whiskey", "icon": preload("res://assets/icons/Food/Whiskey.png"), "quantity": 1},
	{"name": "Wine", "icon": preload("res://assets/icons/Food/Wine.png"), "quantity": 3}
]


func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
		var container_ui = get_tree().get_root().get_node("res://scenes/kitchen/ContainerUI.tscn")
		if container_ui:
			print("container reached")
			container_ui.show_container_inventory(fridge_inventory, self)
		else:
			push_error(" ContainerUI not found in scene tree!")
		print("fridge opened	")
