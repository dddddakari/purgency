# container_ui.gd
extends PanelContainer  # Or inherit from your inventory.gd if possible

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

var container_items: Array = []
var container_visible := false
var selected_slot_index := -1
var current_container = null

const SLOT_SCENE = preload("res://inventorysystem/Slot.tscn")

func _ready():
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
			get_slot(clicked_index).set_highlight(true)
	else:  # Second click (transfer)
		transfer_item(selected_slot_index, clicked_index)
		get_slot(selected_slot_index).set_highlight(false)
		selected_slot_index = -1

func get_slot(index: int) -> Slot:
	if index < grid_container.get_child_count():
		return grid_container.get_child(index) as Slot
	return null

func transfer_item(from_index: int, to_index: int):
	pass
