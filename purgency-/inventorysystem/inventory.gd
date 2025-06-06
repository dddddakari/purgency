extends PanelContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

var inventory_items: Array = []
var inventory_visible := false
var selected_slot_index := -1

const SLOT_SCENE = preload("res://inventorysystem/Slot.tscn")
const INVENTORY_DATA_PATH = "res://entities/player/inventory_data.json"

func _ready():
	add_to_group("inventory")
	grid_container.columns = 4
	margin_container.visible = false
	load_inventory_from_json()  # Now this function is defined before being called

# Core inventory functions
func load_inventory_from_json():
	if not FileAccess.file_exists(INVENTORY_DATA_PATH):
		push_error("Inventory file not found!")
		return
	
	var file = FileAccess.open(INVENTORY_DATA_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	if not data or not data.has("items"):
		push_error("Invalid inventory data format!")
		return
	
	inventory_items = []
	for item_data in data["items"]:
		var item = Item.new()
		item.name = item_data.get("name", "")
		item.quantity = item_data.get("quantity", 1)
		
		var texture_path = item_data.get("texture", "")
		if texture_path:
			item.texture = load(texture_path)
			if not item.texture:
				push_warning("Failed to load texture: ", texture_path)
		
		inventory_items.append(item)
	
	populate_inventory_ui()

func save_inventory_to_json():
	var data = {"items": []}
	for item in inventory_items:
		if item:  # Only save valid items
			data["items"].append({
				"name": item.name,
				"quantity": item.quantity,
				"texture": item.texture.resource_path if item.texture else ""
			})
	
	var file = FileAccess.open(INVENTORY_DATA_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	print("Inventory saved successfully")

# Inventory interaction functions
func handle_slot_click(clicked_index: int):
	if selected_slot_index == -1:  # First click (select)
		if clicked_index < inventory_items.size() and inventory_items[clicked_index]:
			selected_slot_index = clicked_index
			get_slot(clicked_index).set_highlight(true)
	else:  # Second click (transfer)
		transfer_item(selected_slot_index, clicked_index)
		get_slot(selected_slot_index).set_highlight(false)
		selected_slot_index = -1

func transfer_item(from_index: int, to_index: int):
	if from_index == to_index: return
	
	# Ensure indices are valid
	var max_index = max(from_index, to_index)
	if max_index >= inventory_items.size():
		inventory_items.resize(max_index + 1)
	
	# Perform transfer
	var item_to_move = inventory_items[from_index]
	inventory_items[from_index] = null
	inventory_items[to_index] = item_to_move
	
	# Update visuals
	update_specific_slots(from_index, to_index)
	save_inventory_to_json()
	print("Transferred item from ", from_index, " to ", to_index)

# Helper functions
func populate_inventory_ui():
	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create all 12 slots with proper initialization
	for i in range(12):
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		
		# Initialize slot after it's properly added to tree
		await get_tree().process_frame
		
		slot.slot_index = i
		if i < inventory_items.size() and inventory_items[i]:
			slot.set_item(inventory_items[i])
		else:
			slot.set_item(null)

func get_slot(index: int) -> Slot:
	if index < grid_container.get_child_count():
		return grid_container.get_child(index) as Slot
	return null

func update_specific_slots(index1: int, index2: int):
	var slot1 = get_slot(index1)
	var slot2 = get_slot(index2)
	
	if slot1: slot1.set_item(inventory_items[index1])
	if slot2: slot2.set_item(inventory_items[index2])

# UI functions
func toggle_inventory():
	inventory_visible = !inventory_visible
	margin_container.visible = inventory_visible
	
	if inventory_visible:
		load_inventory_from_json()
	else:
		save_inventory_to_json()

func _input(event):
	if event.is_action_pressed("Inventory"):
		toggle_inventory()
