extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge
@onready var container_ui := get_node_or_null("/root/Kitchen01/ContainerCanvas/container_ui")

var fridge_open := false

# Sample fridge inventory
var fridge_inventory: Array = [
	{"name": "Whiskey", "icon": preload("res://assets/icons/Food/Whiskey.png"), "quantity": 1},
	{"name": "Wine", "icon": preload("res://assets/icons/Food/Wine.png"), "quantity": 3}
]

func _ready():
	# Connect interaction logic
	if interactable:
		interactable.interact = _on_interact
	else:
		push_error("Missing 'interactable' node in fridge!")

func _on_interact():
	print("Fridge interacted.")
	print("Looking for container_ui...")
	print("Found container_ui: ", container_ui)

	if container_ui == null:
		push_error("Fridge UI (container_ui) not found!")
		return

	if fridge_open:
		print("Closing fridge UI.")
		container_ui.hide_container()
		fridge_open = false
	else:
		print("Opening fridge UI.")
		container_ui.show_container_inventory(fridge_inventory, self)
		fridge_open = true
