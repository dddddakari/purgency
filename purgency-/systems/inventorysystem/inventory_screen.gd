# inventory_screen.gd (FIXED)
extends CanvasLayer
class_name InventoryScreen

@onready var player_inventory_ui = $"Player"
@onready var container_inventory_ui = $"Container"

var selected_ui: Node = null
var selected_slot_index: int = -1
var current_container_node = null

func _ready():
	add_to_group("inventory_screen")

func open_inventories(container_inventory: Array, container_node: Node) -> void:
	if not container_node:
		return
	
	current_container_node = container_node
	
	# FIX: Get reference to the actual player inventory in the game world
	var main_inventory = get_tree().get_first_node_in_group("inventory")
	if main_inventory:
		# Sync the inventory screen's inventory with the main game inventory
		player_inventory_ui.inventory_items = main_inventory.inventory_items
		player_inventory_ui.show_inventory()
	else:
		# Fallback to loading from file if no main inventory found
		if player_inventory_ui.has_method("load_inventory"):
			player_inventory_ui.load_inventory()
		player_inventory_ui.show_inventory()
	
	container_inventory_ui.show_container_inventory(container_inventory, container_node)
	show()

func close_inventories() -> void:
	# FIX: Sync back to main inventory and save both
	var main_inventory = get_tree().get_first_node_in_group("inventory")
	if main_inventory:
		# Copy changes back to the main game inventory
		main_inventory.inventory_items = player_inventory_ui.inventory_items
		main_inventory.save_inventory()
	else:
		# Fallback to saving through the UI
		if is_instance_valid(player_inventory_ui) and player_inventory_ui.has_method("save_inventory"):
			player_inventory_ui.save_inventory()
	
	if is_instance_valid(container_inventory_ui) and container_inventory_ui.has_method("save_container"):
		container_inventory_ui.save_container()
	
	# Clear selection FIRST before hiding
	handle_global_slot_click(null, -1)
	
	# Reset state
	current_container_node = null
	container_inventory_ui.hide_container()
	player_inventory_ui.hide_inventory()
	hide()
	
func handle_global_slot_click(from_ui: Node, slot_index: int) -> void:
	# Always clear previous selection first
	if is_instance_valid(selected_ui) and selected_slot_index >= 0:
		var prev_slot = selected_ui.get_slot(selected_slot_index)
		if is_instance_valid(prev_slot):
			prev_slot.set_highlight(false)
	
	# If clicking the same slot again, just deselect
	if selected_ui == from_ui and selected_slot_index == slot_index:
		selected_ui = null
		selected_slot_index = -1
		return
	
	# Set new selection only if the slot exists
	if is_instance_valid(from_ui) and from_ui.has_method("get_slot"):
		var new_slot = from_ui.get_slot(slot_index)
		if is_instance_valid(new_slot):
			selected_ui = from_ui
			selected_slot_index = slot_index
			new_slot.set_highlight(true)

func transfer_between_inventories(from_ui, from_index: int, to_ui, to_index: int) -> void:
	if !from_ui || !to_ui:
		return
		
	# Get the correct item arrays
	var from_items = from_ui.inventory_items if from_ui.has_method("show_inventory") else from_ui.container_items
	var to_items = to_ui.inventory_items if to_ui.has_method("show_inventory") else to_ui.container_items
	
	# Ensure arrays are large enough
	while from_items.size() <= from_index:
		from_items.append(null)
	while to_items.size() <= to_index:
		to_items.append(null)
	
	# Get the items
	var from_item = from_items[from_index]
	var to_item = to_items[to_index]
	
	# Case 1: Moving to empty slot
	if from_item && !to_item:
		to_items[to_index] = from_item
		from_items[from_index] = null
	
	# Case 2: Stacking same items
	elif from_item && to_item && from_item.name == to_item.name:
		to_items[to_index].quantity += from_item.quantity
		from_items[from_index] = null
	
	# Case 3: Swapping different items
	elif from_item && to_item:
		var temp = to_item
		to_items[to_index] = from_item
		from_items[from_index] = temp
	
	# Update the specific slots
	if from_ui.has_method("get_slot"):
		var from_slot = from_ui.get_slot(from_index)
		if from_slot:
			from_slot.set_item(from_items[from_index])
	
	if to_ui.has_method("get_slot"):
		var to_slot = to_ui.get_slot(to_index)
		if to_slot:
			to_slot.set_item(to_items[to_index])
	
	# FIX: Auto-save both inventories AND sync back to main inventory
	if from_ui.has_method("save_inventory"):
		from_ui.save_inventory()
		# Also sync to main inventory if this is the player inventory UI
		if from_ui.has_method("show_inventory"):  # This identifies it as player inventory
			var main_inventory = get_tree().get_first_node_in_group("inventory")
			if main_inventory:
				main_inventory.inventory_items = from_ui.inventory_items
				main_inventory.save_inventory()
	elif from_ui.has_method("save_container"):
		from_ui.save_container()
	
	if to_ui != from_ui:
		if to_ui.has_method("save_inventory"):
			to_ui.save_inventory()
			# Also sync to main inventory if this is the player inventory UI
			if to_ui.has_method("show_inventory"):  # This identifies it as player inventory
				var main_inventory = get_tree().get_first_node_in_group("inventory")
				if main_inventory:
					main_inventory.inventory_items = to_ui.inventory_items
					main_inventory.save_inventory()
		elif to_ui.has_method("save_container"):
			to_ui.save_container()
	
	# Clear selection
	if is_instance_valid(selected_ui) and selected_slot_index >= 0:
		var prev_slot = selected_ui.get_slot(selected_slot_index)
		if is_instance_valid(prev_slot):
			prev_slot.set_highlight(false)
	selected_ui = null
	selected_slot_index = -1
	
func refresh_all():
	if player_inventory_ui.has_method("populate_inventory_ui"):
		player_inventory_ui.populate_inventory_ui()
	if container_inventory_ui.has_method("populate_inventory_ui"):
		container_inventory_ui.populate_inventory_ui()
