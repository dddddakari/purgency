# inventory_screen.gd (updated)
extends CanvasLayer
class_name InventoryScreen

@onready var player_inventory_ui = $Player
@onready var container_inventory_ui = $Container

var selected_ui: Node = null
var selected_slot_index: int = -1
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
		current_container_node.set_inventory(container_inventory_ui.container_items)
	
	current_container_node = null
	container_inventory_ui.hide_container()
	player_inventory_ui.hide_inventory()
	hide()
	
func handle_global_slot_click(from_ui: Node, slot_index: int) -> void:
	# Deselect previous
	if selected_ui and selected_slot_index >= 0:
		var prev_slot = selected_ui.get_slot(selected_slot_index)
		if prev_slot:
			prev_slot.set_highlight(false)
	
	# Select new slot or clear selection if clicking same slot
	if selected_ui == from_ui and selected_slot_index == slot_index:
		selected_ui = null
		selected_slot_index = -1
	else:
		selected_ui = from_ui
		selected_slot_index = slot_index
		var new_slot = from_ui.get_slot(slot_index)
		if new_slot:
			new_slot.set_highlight(true)
		
func transfer_between_inventories(from_ui, from_index: int, to_ui, to_index: int) -> void:
	if !from_ui || !to_ui:
		return
	
	# Get the correct arrays
	var from_items = from_ui.container_items if from_ui.has_method("show_container_inventory") else from_ui.inventory_items
	var to_items = to_ui.container_items if to_ui.has_method("show_container_inventory") else to_ui.inventory_items
	
	# Create transfer instance
	var transfer = ItemTransfer.new()
	var success = transfer.transfer_item_between(from_items, from_index, to_items, to_index)
	
	if success:
		# Update both UIs
		from_ui.update_display()
		to_ui.update_display()
		
		# Save changes
		if from_ui.has_method("save_inventory"):
			from_ui.save_inventory()
		if to_ui.has_method("save_inventory"):
			to_ui.save_inventory()
	
	# Clear selection regardless of success
	handle_global_slot_click(null, -1)
