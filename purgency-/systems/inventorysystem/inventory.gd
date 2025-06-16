# inventory.gd
extends PanelContainer

# UI node references
@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var margin_container: MarginContainer = $MarginContainer

# Inventory state
var inventory_items: Array = []  # Array of items
var inventory_visible := false  # Inventory visibility flag
var selected_slot_index := -1  # Currently selected slot

@onready var inventory_screen = get_parent()  # Parent inventory screen

# Preloaded resources
const SLOT_SCENE = preload("res://systems/inventorysystem/Slot.tscn")
const INVENTORY_DATA_PATH = "user://inventory_data.json"
const ItemTransferScript = preload("res://systems/inventorysystem/item_transfer.gd")
var item_transfer_instance = ItemTransferScript.new()  # Item transfer handler

func _ready():
	# Initial setup
	add_to_group("inventory")
	grid_container.columns = 4  # 4-column grid
	margin_container.visible = false
	load_inventory_from_json()
	populate_inventory_ui()

func load_inventory_from_json():
	inventory_items.clear() 
	
	# Load inventory from JSON file
	var file = FileAccess.open("res://entities/player/inventory_data.json", FileAccess.READ)
	if not file:
		push_error("Failed to open inventory.json")
		return

	var content = file.get_as_text()
	var data = JSON.parse_string(content)

	if typeof(data) != TYPE_ARRAY:
		push_error("Inventory JSON is not an array")
		return

	# Create items from JSON data
	for item_data in data:
		var name = item_data.get("name", "")
		var quantity = item_data.get("quantity", 0)
		var texture_path = item_data.get("texture", "")

		var texture = load(texture_path)
		if texture == null:
			print("Failed to load texture at path:", texture_path)

		var item = Item.create(name, quantity, texture)
		inventory_items.append(item)
		
	populate_inventory_ui()

func save_inventory_to_json():
	# Save inventory to JSON file
	var data = {"items": []}
	for item in inventory_items:
		if item != null:
			data["items"].append({
				"name": item.name,
				"quantity": item.quantity,
				"texture": item.texture.resource_path if item.texture else ""
			})

	var file = FileAccess.open(INVENTORY_DATA_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func handle_slot_click(clicked_index: int):
	# Handle inventory slot clicks
	if clicked_index < 0 or clicked_index >= grid_container.get_child_count():
		return

	if selected_slot_index == -1:
		# First click - select slot if it has an item
		if clicked_index < inventory_items.size() and inventory_items[clicked_index] != null:
			selected_slot_index = clicked_index
			var slot = get_slot(clicked_index)
			if slot:
				slot.set_highlight(true)
	else:
		# Second click - handle transfer
		if inventory_screen and inventory_screen.has_method("transfer_between_inventories"):
			var container_ui = inventory_screen.container_inventory_ui
			if container_ui and container_ui.selected_slot_index != -1:
				# Transfer between inventories
				inventory_screen.transfer_between_inventories(self, selected_slot_index, container_ui, container_ui.selected_slot_index)
				var container_slot = container_ui.get_slot(container_ui.selected_slot_index)
				if container_slot:
					container_slot.set_highlight(false)
				container_ui.selected_slot_index = -1
			else:
				# Transfer within inventory
				transfer_item(selected_slot_index, clicked_index)
		else:
			transfer_item(selected_slot_index, clicked_index)

		# Clear selection
		var prev_slot = get_slot(selected_slot_index)
		if prev_slot:
			prev_slot.set_highlight(false)
		selected_slot_index = -1

func transfer_item(from_index: int, to_index: int):
	# Transfer items between slots
	if from_index == to_index or from_index < 0 or to_index < 0:
		return

	# Ensure array size
	while inventory_items.size() <= max(from_index, to_index):
		inventory_items.append(null)
	
	# Perform transfer
	item_transfer_instance.transfer_item_between(inventory_items, from_index, inventory_items, to_index)
	update_specific_slots(from_index, to_index)
	save_inventory_to_json()

func populate_inventory_ui():
	# Populate UI with inventory slots
	for child in grid_container.get_children():
		child.queue_free()

	await get_tree().process_frame

	var slot_count = 12  # Total slots to create

	for i in range(slot_count):
		var slot = SLOT_SCENE.instantiate()
		slot.slot_index = i
		slot.slot_owner = self
		grid_container.add_child(slot)

		# Set item if exists
		if i < inventory_items.size() and inventory_items[i] != null:
			slot.set_item(inventory_items[i])
		else:
			slot.set_item(null)

func get_slot(index: int) -> Slot:
	# Get slot by index
	if index >= 0 and index < grid_container.get_child_count():
		return grid_container.get_child(index)
	return null

func update_specific_slots(index1: int, index2: int):
	# Update specific slots after transfer
	var slot1 = get_slot(index1)
	var slot2 = get_slot(index2)
	if slot1 and index1 < inventory_items.size():
		slot1.set_item(inventory_items[index1])
	if slot2 and index2 < inventory_items.size():
		slot2.set_item(inventory_items[index2])

func toggle_inventory():
	# Toggle inventory visibility
	inventory_visible = !inventory_visible
	margin_container.visible = inventory_visible
	if inventory_visible:
		load_inventory_from_json()

func show_inventory():
	# Show inventory
	inventory_visible = true
	margin_container.visible = true
	populate_inventory_ui()

func hide_inventory():
	# Hide inventory
	inventory_visible = false
	margin_container.visible = false
	save_inventory_to_json()

func _input(event):
	# Handle inventory toggle input
	if event.is_action_pressed("Inventory"):
		toggle_inventory()
