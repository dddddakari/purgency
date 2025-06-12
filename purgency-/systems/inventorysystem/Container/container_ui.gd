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
	if clicked_index < 0 or clicked_index >= grid_container.get_child_count():
		return
	
	if selected_slot_index == -1:
		if clicked_index < container_items.size() and container_items[clicked_index] != null:
			selected_slot_index = clicked_index
			var slot = get_slot(clicked_index)
			if slot:
				slot.set_highlight(true)
	else:
		if inventory_screen and inventory_screen.player_inventory_ui:
			var player_ui = inventory_screen.player_inventory_ui
			if player_ui.selected_slot_index != -1:
				inventory_screen.transfer_between_inventories(self, selected_slot_index, player_ui, player_ui.selected_slot_index)
				var container_slot = player_ui.get_slot(player_ui.selected_slot_index)
				if container_slot:
					container_slot.set_highlight(false)
				player_ui.selected_slot_index = -1
			else:
				transfer_item(selected_slot_index, clicked_index)
		else:
			transfer_item(selected_slot_index, clicked_index)

		var prev_slot = get_slot(selected_slot_index)
		if prev_slot:
			prev_slot.set_highlight(false)
		selected_slot_index = -1

func transfer_item(from_index: int, to_index: int):
	if from_index == to_index or from_index < 0 or to_index < 0:
		return

	while container_items.size() <= max(from_index, to_index):
		container_items.append(null)

	item_transfer.transfer_item_between(container_items, from_index, container_items, to_index)
	update_specific_slots(from_index, to_index)

func set_inventory(new_inventory: Array):
	container_items = new_inventory.duplicate()
	populate_container_ui()

func update_slots():
	populate_container_ui()
