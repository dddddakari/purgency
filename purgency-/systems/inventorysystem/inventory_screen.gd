extends CanvasLayer
class_name InventoryScreen

@onready var player_inventory_ui = $Player
@onready var container_inventory_ui = $Container

var current_container_node = null

func open_inventories(container_inventory: Array, container_node: Node) -> void:
	if not container_node:
		return
	
	current_container_node = container_node
	player_inventory_ui.show_inventory()
	container_inventory_ui.show_container_inventory(container_inventory, container_node)
	show()

func close_inventories() -> void:
	if current_container_node and current_container_node.has_method("set_inventory"):
		# Update with the current container_items
		current_container_node.set_inventory(container_inventory_ui.container_items)
		if current_container_node.has_method("save_inventory"):
			current_container_node.save_inventory()
	
	# Rest of your existing close logic...
	# Save container inventory if applicable
	if current_container_node and current_container_node.has_method("set_inventory") and current_container_node.has_method("save_inventory"):
		# Update container node's inventory with current UI container items before saving
		if container_inventory_ui:
			# You must write the container's current container_items back to the container node
			current_container_node.set_inventory(container_inventory_ui.container_items)
			current_container_node.save_inventory()
	
	# Save player inventory as well
	if player_inventory_ui:
		player_inventory_ui.save_inventory_to_json()

	current_container_node = null
	container_inventory_ui.hide_container()
	player_inventory_ui.hide_inventory()
	hide()
	
	
func transfer_between_inventories(from_ui, from_index: int, to_ui, to_index: int) -> void:
	# Get the correct item arrays
	var from_items = from_ui.container_items if from_ui.has_method("show_container_inventory") else from_ui.inventory_items
	var to_items = to_ui.container_items if to_ui.has_method("show_container_inventory") else to_ui.inventory_items
	
	print("Attempting transfer:")
	print("From UI:", from_ui.name, " Slot:", from_index, " Item:", from_items[from_index] if from_index < from_items.size() else "null")
	print("To UI:", to_ui.name, " Slot:", to_index, " Item:", to_items[to_index] if to_index < to_items.size() else "null")
	
	# Create a new ItemTransfer instance for this operation
	var transfer = ItemTransfer.new()
	transfer.transfer_item_between(from_items, from_index, to_items, to_index)
	
	# Update both UIs
	if from_ui.has_method("update_slots"):
		from_ui.update_slots()
	elif from_ui.has_method("populate_container_ui"):
		from_ui.populate_container_ui()
	elif from_ui.has_method("populate_inventory_ui"):
		from_ui.populate_inventory_ui()
	
	if to_ui.has_method("update_slots"):
		to_ui.update_slots()
	elif to_ui.has_method("populate_container_ui"):
		to_ui.populate_container_ui()
	elif to_ui.has_method("populate_inventory_ui"):
		to_ui.populate_inventory_ui()
	
	# Clear selections
	from_ui.selected_slot_index = -1
	to_ui.selected_slot_index = -1
	
	# Save changes
	if from_ui.has_method("save_inventory_to_json"):
		from_ui.save_inventory_to_json()
	elif from_ui.has_method("save_inventory"):
		from_ui.save_inventory()
	
	if to_ui.has_method("save_inventory_to_json"):
		to_ui.save_inventory_to_json()
	elif to_ui.has_method("save_inventory"):
		to_ui.save_inventory()
