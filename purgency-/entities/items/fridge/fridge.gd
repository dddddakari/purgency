# fridge.gd
extends Area2D

# Node references
@onready var interactable: Area2D = $interactable  # Interaction trigger area
@onready var sprite_2d: Sprite2D = $Fridge  # Visual representation
@onready var container_ui: CanvasLayer = get_node_or_null("/root/Kitchen01/ContainerCanvas/InventoryScreen")  # Inventory UI
@onready var player_inventory = get_tree().get_first_node_in_group("inventory")  # Player's inventory

# State variables
var fridge_open := false  # Tracks if fridge is open
var fridge_inventory: Array = []  # Stores items in fridge
var selected_slot_index := -1  # Currently selected inventory slot

func _ready():
	# Initialize default items in fridge
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
	
	# Ensure we have 12 inventory slots
	while fridge_inventory.size() < 12:
		fridge_inventory.append(null)
	
	# Set up interaction callback
	if interactable:
		interactable.interact = Callable(self, "_on_interact")
	else:
		push_error("Missing 'interactable' node in fridge!")

func _on_interact():
	print("fridge open!!!")
	if container_ui == null:
		# Try to find inventory UI if not already set
		container_ui = get_node_or_null("/root/Kitchen01/ContainerCanvas/InventoryScreen")
		if container_ui == null:
			push_error("Inventory Screen not found!")
			return

	# Toggle fridge open/closed state
	fridge_open = !fridge_open
	
	if fridge_open:
		# Open and show inventory
		container_ui.open_inventories(fridge_inventory, self)
	else:
		# Close inventory
		container_ui.close_inventories()

func handle_slot_click(clicked_index: int):
	# Handle inventory slot selection and item transfer
	if selected_slot_index == -1:
		# First selection - only if slot has item
		if clicked_index < fridge_inventory.size() and fridge_inventory[clicked_index]:
			selected_slot_index = clicked_index
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(clicked_index, true)
	else:
		# Second click - transfer or swap items
		if clicked_index == selected_slot_index:
			# Deselect if same slot clicked again
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(selected_slot_index, false)
			selected_slot_index = -1
			return
		
		var source_item = fridge_inventory[selected_slot_index]
		var target_item = fridge_inventory[clicked_index]

		# Transfer logic
		if source_item and (target_item == null or source_item.name == target_item.name):
			# Stack same items
			if target_item:
				target_item.quantity += source_item.quantity
				fridge_inventory[selected_slot_index] = null
			else:
				# Move to empty slot
				fridge_inventory[clicked_index] = source_item
				fridge_inventory[selected_slot_index] = null
		else:
			# Swap different items
			fridge_inventory[selected_slot_index] = target_item
			fridge_inventory[clicked_index] = source_item
		
		# Clear highlights
		if container_ui.has_method("highlight_slot"):
			container_ui.highlight_slot(selected_slot_index, false)
		
		selected_slot_index = -1
		
		# Update UI
		container_ui.populate_container_ui()
