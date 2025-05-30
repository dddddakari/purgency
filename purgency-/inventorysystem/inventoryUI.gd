extends CanvasLayer

@onready var slots = $Panel/GridContainer.get_children()
@onready var inventory_data = preload("res://inventorysystem/inventory.gd").new()

func update_ui():
	var items = inventory_data.get_inventory()
	for i in range(slots.size()):
		if i < items.size():
			slots[i].set_item(items[i])
		else:
			slots[i].clear_slot()
