extends CanvasLayer


@onready var slots := $BackgroundPanel/ItemGrid.get_children()
var container_inventory := []
var container_owner: Node2D = null

func _ready():
	print("Children of BackgroundPanel:", $BackgroundPanel.get_children())

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
