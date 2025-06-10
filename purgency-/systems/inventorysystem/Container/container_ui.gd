# container_ui.gd
extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

var container_items: Array = []
var container_visible := false
var selected_slot_index := -1
var current_container = null
var is_container_inventory := true

const SLOT_SCENE = preload("res://systems/inventorysystem/Slot.tscn")

func _ready():
	add_to_group("container_inventory")
	grid_container.columns = 4
	margin_container.visible = false

func show_container_inventory(items: Array, container_ref):
	current_container = container_ref
	container_items = items.duplicate()
	populate_container_ui()
	margin_container.visible = true
	container_visible = true

func hide_container():
	margin_container.visible = false
	container_visible = false
	current_container = null

func populate_container_ui():
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create all slots (12 like player inventory)
	for i in range(12):
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		slot.slot_index = i
		
		# Initialize slot after it's properly added to tree
		await get_tree().process_frame
		
		if i < container_items.size() and container_items[i]:
			slot.set_item(container_items[i])
		else:
			slot.set_item(null)

func handle_slot_click(clicked_index: int):
	if selected_slot_index == -1:  # First click (select)
		if clicked_index < container_items.size() and container_items[clicked_index]:
			selected_slot_index = clicked_index
			highlight_slot(clicked_index, true)
	else:  # Second click (transfer)
		# Get the other inventory (player inventory)
		var player_inventory = get_tree().get_first_node_in_group("inventory")
		if player_inventory and player_inventory.selected_slot_index != -1:
			# Transfer between player and container
			transfer_between_inventories(player_inventory, player_inventory.selected_slot_index, clicked_index)
			player_inventory.get_slot(player_inventory.selected_slot_index).set_highlight(false)
			player_inventory.selected_slot_index = -1
		else:
			# Transfer within container
			transfer_item(selected_slot_index, clicked_index)
		
		highlight_slot(selected_slot_index, false)
		selected_slot_index = -1

# Only declare get_slot once in the script
func get_slot(index: int) -> Slot:
	if index < grid_container.get_child_count():
		return grid_container.get_child(index) as Slot
	return null

func highlight_slot(index: int, should_highlight: bool):
	var slot = get_slot(index)
	if slot:
		slot.set_highlight(should_highlight)

func update_specific_slots(index1: int, index2: int):
	var slot1 = get_slot(index1)
	var slot2 = get_slot(index2)
	
	if slot1: 
		slot1.set_item(container_items[index1] if index1 < container_items.size() else null)
	if slot2: 
		slot2.set_item(container_items[index2] if index2 < container_items.size() else null)

func transfer_item(from_index: int, to_index: int):
	if from_index == to_index: 
		return
	
	# Ensure indices are valid
	var max_index = max(from_index, to_index)
	if max_index >= container_items.size():
		container_items.resize(max_index + 1)
	
	# Check if target slot is occupied
	if container_items[to_index]:
		# Swap items if target slot is occupied
		var temp = container_items[to_index]
		container_items[to_index] = container_items[from_index]
		container_items[from_index] = temp
	else:
		# Move item to empty slot
		container_items[to_index] = container_items[from_index]
		container_items[from_index] = null
	
	# Update visuals
	update_specific_slots(from_index, to_index)

func transfer_between_inventories(other_inventory, other_index: int, self_index: int):
	var other_item = other_inventory.inventory_items[other_index]
	var self_item = container_items[self_index] if self_index < container_items.size() else null
	
	# If target slot is empty
	if self_item == null:
		# Move item from other inventory to this one
		container_items[self_index] = other_item
		other_inventory.inventory_items[other_index] = null
	else:
		# If items are the same type, try to stack
		if self_item.name == other_item.name:
			self_item.quantity += other_item.quantity
			other_inventory.inventory_items[other_index] = null
		else:
			# Swap items if different types
			container_items[self_index] = other_item
			other_inventory.inventory_items[other_index] = self_item
	
	# Update both inventories
	other_inventory.update_specific_slots(other_index, other_index)
	update_specific_slots(self_index, self_index)
