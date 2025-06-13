extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

var container_items: Array = []
var container_visible := false
var selected_slot_index := -1
var current_container = null

const ItemTransfer = preload("res://systems/inventorysystem/item_transfer.gd")
var item_transfer = ItemTransfer.new()

const SLOT_SCENE = preload("res://systems/inventorysystem/Slot.tscn")

@onready var inventory_screen = get_parent()

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
	for child in grid_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var slot_count = max(container_items.size(), 12)
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
	if index >= 0 and index < grid_container.get_child_count():
		return grid_container.get_child(index)
	return null

func update_specific_slots(index1: int, index2: int):
	var slot1 = get_slot(index1)
	var slot2 = get_slot(index2)
	if slot1 and index1 < container_items.size():
		slot1.set_item(container_items[index1])
	if slot2 and index2 < container_items.size():
		slot2.set_item(container_items[index2])

func handle_slot_click(clicked_index: int):
	print("Container UI: Slot clicked:", clicked_index)
	if clicked_index < 0 or clicked_index >= grid_container.get_child_count():
		print("Clicked index out of range.")
		return

	var player_ui = inventory_screen.player_inventory_ui

	if selected_slot_index == -1:
		# Select slot in container
		if clicked_index < container_items.size() and container_items[clicked_index] != null:
			selected_slot_index = clicked_index
			get_slot(clicked_index).set_highlight(true)
			print("Container UI selected slot:", clicked_index)
	else:
		# If we have a selection in this container
		if clicked_index < container_items.size():
			# If player has a selection, transfer between inventories
			if player_ui and player_ui.selected_slot_index != -1:
				inventory_screen.transfer_between_inventories(self, selected_slot_index, player_ui, player_ui.selected_slot_index)
			else:
				# Transfer within container
				transfer_item(selected_slot_index, clicked_index)
			
			# Clear selection
			get_slot(selected_slot_index).set_highlight(false)
			selected_slot_index = -1

			
func transfer_item(from_index: int, to_index: int):
	if from_index == to_index or from_index < 0 or to_index < 0:
		return
	
	# Ensure array size
	while container_items.size() <= max(from_index, to_index):
		container_items.append(null)
	
	# Use the item transfer system
	item_transfer.transfer_item_between(container_items, from_index, container_items, to_index)
	
	# Update specific slots
	update_specific_slots(from_index, to_index)
	
	# Save if needed
	if current_container and current_container.has_method("save_inventory"):
		current_container.save_inventory()

# Update set_inventory to use container_items:
func set_inventory(new_items: Array) -> void:
	container_items = new_items.duplicate()
	
func save_inventory() -> void:
	# Save container inventory to file or wherever you want
	var save_path = "user://container_inventory.json"  # Change as needed per container
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data = []
		for item in container_items:  # CHANGED FROM inventory_items TO container_items
			if item != null:
				data.append({
					"name": item.name,
					"quantity": item.quantity,
					"texture": item.texture.resource_path if item.texture else ""
				})
		file.store_string(JSON.stringify(data))
		file.close()
		print("Container inventory saved to ", save_path)
	else:
		push_error("Failed to open container inventory save file.")

func update_slots():
	populate_container_ui()
