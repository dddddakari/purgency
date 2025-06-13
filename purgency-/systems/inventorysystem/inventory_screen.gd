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

	# Ensure arrays are large enough
	while from_items.size() <= from_index:
		from_items.append(null)
	while to_items.size() <= to_index:
		to_items.append(null)

	print("Transferring from:", from_ui.name, " slot:", from_index, " to:", to_ui.name, " slot:", to_index)
	print("From item:", from_items[from_index])
	print("To item:", to_items[to_index])

	# Perform the transfer
	if from_items[from_index] == null:
		return

	if to_items[to_index] == null:
		# Move item
		to_items[to_index] = from_items[from_index]
		from_items[from_index] = null
	elif to_items[to_index].name == from_items[from_index].name:
		# Stack items
		to_items[to_index].quantity += from_items[from_index].quantity
		from_items[from_index] = null
	else:
		# Swap items
		var temp = to_items[to_index]
		to_items[to_index] = from_items[from_index]
		from_items[from_index] = temp

	# Force update both UIs
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
