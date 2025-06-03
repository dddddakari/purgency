extends Node2D

@onready var slots := $BackgroundPanel/ItemGrid.get_children()
var container_inventory: Array = []
var container_owner: Node = null

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
	print("Hiding container UI")
	hide()
