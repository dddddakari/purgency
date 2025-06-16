# inventory_screen.gd
extends CanvasLayer
class_name InventoryScreen

# UI references
@onready var player_inventory_ui = $Player  # Player inventory UI
@onready var container_inventory_ui = $Container  # Container inventory UI

var current_container_node = null  # Current open container

func open_inventories(container_inventory: Array, container_node: Node) -> void:
	# Open both player and container inventories
	if not container_node:
		return
	
	current_container_node = container_node
	player_inventory_ui.show_inventory()
	container_inventory_ui.show_container_inventory(container_inventory, container_node)
	show()

func close_inventories() -> void:
	# Close inventories and save state
	if current_container_node and current_container_node.has_method("set_inventory"):
		# Update container inventory
		current_container_node.set_inventory(container_inventory_ui.container_items)
		if current_container_node.has_method("save_inventory"):
			current_container_node.save_inventory()
	
	# Save container inventory if applicable
	if current_container_node and current_container_node.has_method("set_inventory") and current_container_node.has_method("save_inventory"):
		if container_inventory_ui:
			current_container_node.set_inventory(container_inventory_ui.container_items)
			current_container_node.save_inventory()
	
	# Save player inventory
	if player_inventory_ui:
		player_inventory_ui.save_inventory_to_json()

	# Reset state
	current_container_node = null
	container_inventory_ui.hide_container()
	player_inventory_ui.hide_inventory()
	hide()
	
func transfer_between_inventories(from_ui, from_index: int, to_ui, to_index: int) -> void:
	# Transfer items between different inventories
	var from_items = from_ui.container_items if from_ui.has_method("show_container_inventory") else from_ui.inventory_items
	var to_items = to_ui.container_items if to_ui.has_method("show_container_inventory") else to_ui.inventory_items

	# Ensure arrays are large enough
	while from_items.size() <= from_index:
		from_items.append(null)
	while to_items.size() <= to_index:
		to_items.append(null)
		
	# Skip if source is empty
	if from_items[from_index] == null:
		return

	# Handle different transfer cases
	if to_items[to_index] == null:
		# Move item to empty slot
		to_items[to_index] = from_items[from_index]
		from_items[from_index] = null
	elif to_items[to_index].name == from_items[from_index].name:
		# Stack items of same type
		to_items[to_index].quantity += from_items[from_index].quantity
		from_items[from_index] = null
	else:
		# Swap different items
		var temp = to_items[to_index]
		to_items[to_index] = from_items[from_index]
		from_items[from_index] = temp

	# Update both UIs
	if from_ui.has_method("populate_container_ui"):
		from_ui.populate_container_ui()
	elif from_ui.has_method("populate_inventory_ui"):
		from_ui.populate_inventory_ui()

	if to_ui.has_method("populate_container_ui"):
		to_ui.populate_container_ui()
	elif to_ui.has_method("populate_inventory_ui"):
		to_ui.populate_inventory_ui()

	# Clear selections
	from_ui.selected_slot_index = -1
	to_ui.selected_slot_index = -1
