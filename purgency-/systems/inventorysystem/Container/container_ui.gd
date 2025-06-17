# container_ui.gd (updated)
extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

var container_items: Array = []
var container_visible := false
var selected_slot_index: int = -1
var current_container = null

const SLOT_SCENE = preload("res://systems/inventorysystem/Slot.tscn")
var item_transfer = preload("res://systems/inventorysystem/item_transfer.gd").new()

func _ready():
	add_to_group("container_inventory")
	grid_container.columns = 4
	margin_container.visible = false

func show_container_inventory(items: Array, container_ref):
	current_container = container_ref
	container_items = items.duplicate(true)  # Deep copy
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
	
	await get_tree().process_frame
	
	# Create slots (minimum 12)
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
	if index < 0 or index >= grid_container.get_child_count():
		return null
	return grid_container.get_child(index)

func handle_slot_click(index: int):
	if get_parent().has_method("handle_global_slot_click"):
		# If we already have a selection, attempt transfer
		if get_parent().selected_ui && get_parent().selected_slot_index >= 0:
			# Transfer between selected slot and this one
			get_parent().transfer_between_inventories(
				get_parent().selected_ui,
				get_parent().selected_slot_index,
				self,
				index
			)
		else:
			# Otherwise just select this slot
			get_parent().handle_global_slot_click(self, index)


func transfer_item(from_index: int, to_index: int):
	if from_index == to_index or from_index < 0 or to_index < 0:
		return
	
	# Ensure array size
	var max_index = max(from_index, to_index)
	while container_items.size() <= max_index:
		container_items.append(null)
	
	# Perform transfer
	item_transfer.transfer_item_between(container_items, from_index, container_items, to_index)
	update_specific_slots(from_index, to_index)
	
	# Save if container supports it
	if current_container and current_container.has_method("save_inventory"):
		current_container.save_inventory()

func update_specific_slots(index1: int, index2: int):
	var slot1 = get_slot(index1)
	var slot2 = get_slot(index2)
	if slot1:
		slot1.set_item(container_items[index1] if index1 < container_items.size() else null)
	if slot2:
		slot2.set_item(container_items[index2] if index2 < container_items.size() else null)

func update_slots():
	populate_container_ui()

func update_display():
	for i in range(grid_container.get_child_count()):
		var slot = grid_container.get_child(i)
		if i < container_items.size():  # or container_items.size() for container_ui
			slot.set_item(container_items[i])  # or container_items[i]
		else:
			slot.set_item(null)
