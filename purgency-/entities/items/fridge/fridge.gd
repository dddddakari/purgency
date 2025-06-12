# fridge.gd
extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge
@onready var container_ui: CanvasLayer = get_node_or_null("/root/Kitchen01/ContainerCanvas/InventoryScreen")
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
	
	var Wine = Item.new()
	Wine.name = "Wine"
	Wine.quantity = 1
	Wine.texture = preload("res://assets/icons/Food/Wine.png")
	
	fridge_inventory = [whiskey, wine, Wine]
	
	# Ensure we have 12 slots
	while fridge_inventory.size() < 12:
		fridge_inventory.append(null)
	
	if interactable:
		interactable.interact = Callable(self, "_on_interact")
	else:
		push_error("Missing 'interactable' node in fridge!")

func _on_interact():
	print("fridge open!!!")
	if container_ui == null:
		container_ui = get_node_or_null("/root/Kitchen01/ContainerCanvas/InventoryScreen")
		if container_ui == null:
			push_error("Inventory Screen not found!")
			return

	fridge_open = !fridge_open
	
	if fridge_open:
		container_ui.open_inventories(fridge_inventory, self)
	else:
		container_ui.close_inventories()



func handle_slot_click(clicked_index: int):
	if selected_slot_index == -1:
		# First selection: only select if there is an item
		if clicked_index < fridge_inventory.size() and fridge_inventory[clicked_index]:
			selected_slot_index = clicked_index
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(clicked_index, true)
	else:
		# Second click: attempt transfer or swap between selected slot and clicked slot
		if clicked_index == selected_slot_index:
			# Deselect if clicked same slot again
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(selected_slot_index, false)
			selected_slot_index = -1
			return
		
		var source_item = fridge_inventory[selected_slot_index]
		var target_item = fridge_inventory[clicked_index]

		# Example: swap or merge (you need to implement your transfer logic)
		if source_item and (target_item == null or source_item.name == target_item.name):
			# For stacking same items
			if target_item:
				target_item.quantity += source_item.quantity
				fridge_inventory[selected_slot_index] = null
			else:
				fridge_inventory[clicked_index] = source_item
				fridge_inventory[selected_slot_index] = null
		else:
			# Swap different items
			fridge_inventory[selected_slot_index] = target_item
			fridge_inventory[clicked_index] = source_item
		
		if container_ui.has_method("highlight_slot"):
			container_ui.highlight_slot(selected_slot_index, false)
		
		selected_slot_index = -1
		
		# Update UI after changes
		container_ui.populate_container_ui()
