extends CanvasLayer

# Inventory slots in the grid
var slots: Array[Node] = []

# Inventory data and owner reference
var container_inventory: Array = []
var container_owner: Node2D = null

func _ready():
	# Attempt to get the GridContainer that holds the item slots
	var grid = get_node_or_null("BackgroundPanel/ItemGrid")
	
	if grid == null:
		push_error(" ERROR: 'BGPanel/ItemGrid' not found. Check your scene hierarchy and node names.")
	else:
		slots = grid.get_children()
		print("Found slots:", slots.size())

func show_container_inventory(inventory: Array, owner: Node) -> void:
	container_inventory = inventory
	container_owner = owner
	update_ui()
	show()

func update_ui() -> void:
	for i in range(slots.size()):
		if i < container_inventory.size():
			slots[i].set_item(container_inventory[i])
		else:
			slots[i].clear_slot()

func hide_container():
	hide()
