# fridge.gd
extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge
@onready var container_ui: Control = get_node_or_null("/root/Kitchen01/ContainerCanvas/ContainerUI")
@onready var player_inventory = get_tree().get_first_node_in_group("inventory")

var fridge_open := false
var fridge_inventory: Array = []
var selected_slot_index := -1

func _ready():
	# Initialize items
	var whiskey = Item.new()
	whiskey.name = "Whiskey"
	whiskey.quantity = 1
	whiskey.texture = preload("res://assets/icons/Food/Whiskey.png")
	
	var wine = Item.new()
	wine.name = "Wine"
	wine.quantity = 3
	wine.texture = preload("res://assets/icons/Food/Wine.png")
	
	fridge_inventory = [whiskey, wine]
	
	# Ensure we have 12 slots
	while fridge_inventory.size() < 12:
		fridge_inventory.append(null)
	
	if interactable:
		interactable.interact = Callable(self, "_on_interact")
	else:
		push_error("Missing 'interactable' node in fridge!")

func _on_interact():
	if container_ui == null:
		container_ui = get_node_or_null("/root/Kitchen01/ContainerCanvas/ContainerUI")
		if container_ui == null:
			push_error("Container UI not found!")
			return

	fridge_open = !fridge_open
	
	if fridge_open:
		container_ui.show_container_inventory(fridge_inventory, self)
		if player_inventory:
			player_inventory.toggle_inventory(true)
	else:
		container_ui.hide_container()
		if player_inventory:
			player_inventory.toggle_inventory(false)

func handle_slot_click(clicked_index: int):
	if selected_slot_index == -1:  # First click (select)
		if clicked_index < fridge_inventory.size() and fridge_inventory[clicked_index]:
			selected_slot_index = clicked_index
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(clicked_index, true)
	else:  # Second click (transfer)
		transfer_item(selected_slot_index, clicked_index)
		if container_ui.has_method("highlight_slot"):
			container_ui.highlight_slot(selected_slot_index, false)
		selected_slot_index = -1

func transfer_item(from_index: int, to_index: int):
	if from_index == to_index: 
		return
	
	# Ensure indices are valid
	var max_index = max(from_index, to_index)
	if max_index >= fridge_inventory.size():
		fridge_inventory.resize(max_index + 1)
	
	# Check if target slot is occupied
	if fridge_inventory[to_index]:
		# Swap items if target slot is occupied
		var temp = fridge_inventory[to_index]
		fridge_inventory[to_index] = fridge_inventory[from_index]
		fridge_inventory[from_index] = temp
	else:
		# Move item to empty slot
		fridge_inventory[to_index] = fridge_inventory[from_index]
		fridge_inventory[from_index] = null
	
	# Update visuals through container UI
	if container_ui.has_method("update_slots"):
		container_ui.update_slots(from_index, to_index)
