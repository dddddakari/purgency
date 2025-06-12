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
	current_container_node = null
	container_inventory_ui.hide_container()
	player_inventory_ui.hide_inventory()
	hide()

func transfer_between_inventories(from_inventory_ui, from_index: int, to_inventory_ui, to_index: int) -> void:
	if from_index < 0 or to_index < 0:
		return
	
	var from_items = from_inventory_ui.inventory_items if from_inventory_ui.has_method("inventory_items") else from_inventory_ui.container_items
	var to_items = to_inventory_ui.inventory_items if to_inventory_ui.has_method("inventory_items") else to_inventory_ui.container_items

	if from_items == null or to_items == null:
		return

	# Ensure arrays are large enough
	while from_items.size() <= from_index:
		from_items.append(null)
	while to_items.size() <= to_index:
		to_items.append(null)

	var source_item = from_items[from_index]
	if source_item == null:
		return

	var target_item = to_items[to_index]

	if target_item == null:
		to_items[to_index] = source_item
		from_items[from_index] = null
	elif target_item.name == source_item.name:
		target_item.quantity += source_item.quantity
		from_items[from_index] = null
	else:
		to_items[to_index] = source_item
		from_items[from_index] = target_item

	from_inventory_ui.update_specific_slots(from_index, from_index)
	to_inventory_ui.update_specific_slots(to_index, to_index)

	# Save changes
	if from_inventory_ui == player_inventory_ui or to_inventory_ui == player_inventory_ui:
		player_inventory_ui.save_inventory_to_json()

	if current_container_node and current_container_node.has_method("save_inventory"):
		current_container_node.save_inventory()
