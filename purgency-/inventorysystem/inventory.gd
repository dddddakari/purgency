extends PanelContainer

var inventory_items: Array = []
var inventory_visible := false
var slot_container: Node = null

var margin_container: Node = null

func _ready():
	print("Inventory children:")
	for child in get_children():
		print(" - ", child.name)
	margin_container = get_node("MarginContainer")
	slot_container = margin_container.get_node("GridContainer/SlotContainer")
	if slot_container == null:
		push_error("SlotContainer not found. Check your node path.")
		return
	load_inventory_from_json()
	margin_container.visible = false  # Hide UI at start

func toggle_inventory():
	inventory_visible = !inventory_visible
	margin_container.visible = inventory_visible


func _input(event):
	if event.is_action_pressed("Inventory"):
		print("Inventory key pressed!")
		toggle_inventory()


func load_inventory_from_json():
	var file = FileAccess.open("res://entities/player/inventory_data.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var data = JSON.parse_string(json_text)
		if typeof(data) == TYPE_DICTIONARY and data.has("items"):
			inventory_items = []
			for item_data in data["items"]:
				var item = Item.new()
				item.name = item_data.get("name", "")
				item.quantity = item_data.get("quantity", 1)
				
				var texture_path = item_data.get("texture", "")
				item.texture = load(texture_path) if texture_path != "" else null
				inventory_items.append(item)
			print("Loaded items:", inventory_items.size())
			populate_inventory_ui()
		else:
			push_error("Invalid inventory JSON format.")
	else:
		push_error("inventory_data.json not found.")


func populate_inventory_ui():
	if slot_container == null:
		push_error("Slot container is null! Check the node path.")
		return

	print("Populating slots, clearing old children...")
	for child in slot_container.get_children():
		child.queue_free()

	print("Adding slots for items:", inventory_items.size())
	for item in inventory_items:
		var slot = preload("res://inventorysystem/Slot.tscn").instantiate()
		slot.set_item(item)
		slot_container.add_child(slot)
