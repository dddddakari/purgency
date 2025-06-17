# inventory.gd (updated)
extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

var inventory_items: Array = []
var inventory_visible := false
var selected_slot_index: int = -1

const SLOT_SCENE = preload("res://systems/inventorysystem/Slot.tscn")
const INVENTORY_DATA_PATH = "user://inventory_data.json"
var item_transfer = preload("res://systems/inventorysystem/item_transfer.gd").new()

func _ready():
	add_to_group("inventory")
	grid_container.columns = 4
	margin_container.visible = false
	load_inventory()
	populate_inventory_ui()

func load_inventory():
	inventory_items.clear()
	var file = FileAccess.open(INVENTORY_DATA_PATH, FileAccess.READ)
	if not file:
		inventory_items.resize(12) # Default empty inventory
		return
	
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY or not data.has("items"):
		inventory_items.resize(12)
		return
	
	for item_data in data["items"]:
		if item_data == null:
			inventory_items.append(null)
			continue
			
		var item = Item.create(
			item_data.get("name", ""),
			item_data.get("quantity", 1),
			load(item_data.get("texture", ""))
		)
		inventory_items.append(item)

func save_inventory():
	var data = {"items": []}
	for item in inventory_items:
		if item == null:
			data["items"].append(null)
			continue
			
		data["items"].append({
			"name": item.name,
			"quantity": item.quantity,
			"texture": item.texture.resource_path if item.texture else ""
		})

	var file = FileAccess.open(INVENTORY_DATA_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func populate_inventory_ui():
	for child in grid_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var slot_count = max(inventory_items.size(), 12)
	for i in range(slot_count):
		var slot = SLOT_SCENE.instantiate()
		slot.slot_index = i
		slot.slot_owner = self
		grid_container.add_child(slot)
		
		if i < inventory_items.size() and inventory_items[i] != null:
			slot.set_item(inventory_items[i])
		else:
			slot.set_item(null)

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
	
	# Ensure arrays are large enough
	while inventory_items.size() <= max(from_index, to_index):
		inventory_items.append(null)
	
	# Perform the transfer
	item_transfer.transfer_item_between(inventory_items, from_index, inventory_items, to_index)
	
	# Update the specific slots that changed
	var slot1 = get_slot(from_index)
	var slot2 = get_slot(to_index)
	if slot1:
		slot1.set_item(inventory_items[from_index])
	if slot2:
		slot2.set_item(inventory_items[to_index])
	
	save_inventory()

# Add this helper function
func get_slot(index: int) -> Slot:
	if index >= 0 and index < grid_container.get_child_count():
		return grid_container.get_child(index)
	return null
	
# Add to both inventory.gd and container_ui.gd
func update_slots():
	populate_inventory_ui()

# Add this to both files
func update_specific_slot(index: int):
	if index < 0 or index >= grid_container.get_child_count():
		return
	
	var slot = grid_container.get_child(index)
	if index < inventory_items.size():  # or container_items.size() for container_ui
		slot.set_item(inventory_items[index])  # or container_items[index]
	else:
		slot.set_item(null)
		
func toggle_inventory():
	inventory_visible = !inventory_visible
	margin_container.visible = inventory_visible
	if inventory_visible:
		populate_inventory_ui()

func show_inventory():
	inventory_visible = true
	margin_container.visible = true
	populate_inventory_ui()

func hide_inventory():
	inventory_visible = false
	margin_container.visible = false
	# Don't repopulate here - just save the current state
	save_inventory()

func _input(event):
	if event.is_action_pressed("Inventory"):
		toggle_inventory()
		
func update_display():
	for i in range(grid_container.get_child_count()):
		var slot = grid_container.get_child(i)
		if i < inventory_items.size():  # or container_items.size() for container_ui
			slot.set_item(inventory_items[i])  # or container_items[i]
		else:
			slot.set_item(null)
			
# Add to both scripts
func get_items_array() -> Array:
	return inventory_items  # or container_items for container_ui
