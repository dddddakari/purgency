# container_ui.gd
extends PanelContainer

# UI node references
@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

# Container state
var container_items: Array = []  # Items in container
var container_visible := false  # Visibility flag
var selected_slot_index := -1  # Selected slot index
var current_container = null  # Current container reference

# Item transfer system
const ItemTransfer = preload("res://systems/inventorysystem/item_transfer.gd")
var item_transfer = ItemTransfer.new()

# Preloaded resources
const SLOT_SCENE = preload("res://systems/inventorysystem/Slot.tscn")

@onready var inventory_screen = get_parent()  # Parent inventory screen

func _ready():
	# Initial setup
	add_to_group("container_inventory")
	grid_container.columns = 4  # 4-column grid
	margin_container.visible = false

func show_container_inventory(items: Array, container_ref):
	# Show container inventory
	current_container = container_ref
	container_items = items.duplicate()
	populate_container_ui()
	margin_container.visible = true
	container_visible = true

func hide_container():
	# Hide container inventory
	margin_container.visible = false
	container_visible = false
	current_container = null

func populate_container_ui():
	# Populate UI with container slots
	for child in grid_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var slot_count = max(container_items.size(), 12)  # Minimum 12 slots
	for i in range(slot_count):
		var slot = SLOT_SCENE.instantiate()
		slot.slot_index = i
		slot.slot_owner = self
		grid_container.add_child(slot)
		
		if i < container_items.size() and container_items[i] != null:
			slot.set_item(container_items[i])
		else:
			slot.set_item(null)

func get_slot(index: int) -> Slot:
	# Get slot by index
	if index >= 0 and index < grid_container.get_child_count():
		return grid_container.get_child(index)
	return null

func update_specific_slots(index1: int, index2: int):
	# Update specific slots
	var slot1 = get_slot(index1)
	var slot2 = get_slot(index2)
	if slot1 and index1 < container_items.size():
		slot1.set_item(container_items[index1])
	if slot2 and index2 < container_items.size():
		slot2.set_item(container_items[index2])

func handle_slot_click(clicked_index: int):
	# Handle slot clicks
	if clicked_index < 0 or clicked_index >= grid_container.get_child_count():
		print("Clicked index out of range.")
		return

	var player_ui = inventory_screen.player_inventory_ui

	if selected_slot_index == -1:
		# First click - select slot if it has an item
		if clicked_index < container_items.size() and container_items[clicked_index] != null:
			selected_slot_index = clicked_index
			get_slot(clicked_index).set_highlight(true)
	else:
		# Second click - handle transfer
		if clicked_index < container_items.size():
			# Check if player has selection for cross-inventory transfer
			if player_ui and player_ui.selected_slot_index != -1:
				inventory_screen.transfer_between_inventories(self, selected_slot_index, player_ui, player_ui.selected_slot_index)
			else:
				# Internal container transfer
				transfer_item(selected_slot_index, clicked_index)
			
			# Clear selection
			get_slot(selected_slot_index).set_highlight(false)
			selected_slot_index = -1

			
func transfer_item(from_index: int, to_index: int):
	# Transfer items within container
	if from_index == to_index or from_index < 0 or to_index < 0:
		return
	
	# Ensure array size
	while container_items.size() <= max(from_index, to_index):
		container_items.append(null)
	
	# Perform transfer
	item_transfer.transfer_item_between(container_items, from_index, container_items, to_index)
	
	# Update affected slots
	update_specific_slots(from_index, to_index)
	
	# Save if container supports it
	if current_container and current_container.has_method("save_inventory"):
		current_container.save_inventory()

func set_inventory(new_items: Array) -> void:
	# Set container inventory
	container_items = new_items.duplicate()
	
func save_inventory() -> void:
	# Save container inventory to file
	var save_path = "user://container_inventory.json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data = []
		for item in container_items:
			if item != null:
				data.append({
					"name": item.name,
					"quantity": item.quantity,
					"texture": item.texture.resource_path if item.texture else ""
				})
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		push_error("Failed to open container inventory save file.")

func update_slots():
	# Refresh UI
	populate_container_ui()
