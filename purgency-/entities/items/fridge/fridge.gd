# fridge.gd
extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge
@onready var container_ui: Control = get_node_or_null("/root/Kitchen01/ContainerCanvas/ContainerUI") # Make sure this path is correct

var fridge_open := false
var fridge_inventory: Array = []

func _ready():
	# Initialize items properly
	var whiskey = Item.new()
	whiskey.name = "Whiskey"
	whiskey.quantity = 1
	whiskey.texture = preload("res://assets/icons/Food/Whiskey.png")
	
	var wine = Item.new()
	wine.name = "Wine"
	wine.quantity = 3
	wine.texture = preload("res://assets/icons/Food/Wine.png")
	
	fridge_inventory = [whiskey, wine]
	
	if interactable:
		interactable.interact = _on_interact
	else:
		push_error("Missing 'interactable' node in fridge!")

func _on_interact():
	print("fridge open!")
	if container_ui == null:
		container_ui = get_node_or_null("/root/Kitchen01/ContainerCanvas/Inventory")
		if container_ui == null:
			push_error("Container UI not found! Check the node path.")
			return

	if fridge_open:
		container_ui.hide_container()
		fridge_open = false
	else:
		container_ui.show_container_inventory(fridge_inventory, self)
		fridge_open = true
