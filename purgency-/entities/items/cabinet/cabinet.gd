extends Area2D
# Node references
@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Fridge
@onready var container_ui: CanvasLayer = get_node_or_null("/root/RoomsArea/ContainerCanvas/InventoryScreen")
@onready var player_inventory = get_tree().get_first_node_in_group("inventory")
# State variables
var cabinet_open := false
var cabinet_inventory: Array = []
var selected_slot_index := -1

func _ready():
	if cabinet_inventory.is_empty():
		# Initialize default items only ONCE
		var apple = Item.new()
		apple.name = "Apple"
		apple.quantity = 1
		apple.texture = preload("res://assets/icons/Food/AppleWorm.png")
		
		var bugs = Item.new()
		bugs.name = "Bugs"
		bugs.quantity = 10
		bugs.texture = preload("res://assets/icons/Food/Bug.png")
		
		
		cabinet_inventory = [apple, bugs]
		
		# Pad to 12 slots
		while cabinet_inventory.size() < 12:
			cabinet_inventory.append(null)
	
	if interactable:
		interactable.interact = Callable(self, "_on_interact")
	else:
		push_error("Missing 'interactable' node in cabinet!")

func _on_interact():
	print("cabinet open!!!")
	if container_ui == null:
		container_ui = get_node_or_null("/root/RoomsArea/ContainerCanvas/InventoryScreen")
		if container_ui == null:
			push_error("Inventory Screen not found!")
			return
	
	cabinet_open = !cabinet_open
	if cabinet_open:
		container_ui.open_inventories(cabinet_inventory, self)
	else:
		container_ui.close_inventories()

func handle_slot_click(clicked_index: int):
	if selected_slot_index == -1:
		if clicked_index < cabinet_inventory.size() and cabinet_inventory[clicked_index]:
			selected_slot_index = clicked_index
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(clicked_index, true)
	else:
		if clicked_index == selected_slot_index:
			if container_ui.has_method("highlight_slot"):
				container_ui.highlight_slot(selected_slot_index, false)
			selected_slot_index = -1
			return
		
		var source_item = cabinet_inventory[selected_slot_index]
		var target_item = cabinet_inventory[clicked_index]
		
		if source_item and (target_item == null or source_item.name == target_item.name):
			if target_item:
				target_item.quantity += source_item.quantity
				cabinet_inventory[selected_slot_index] = null
			else:
				cabinet_inventory[clicked_index] = source_item
				cabinet_inventory[selected_slot_index] = null
		else:
			cabinet_inventory[selected_slot_index] = target_item
			cabinet_inventory[clicked_index] = source_item
		
		if container_ui.has_method("highlight_slot"):
			container_ui.highlight_slot(selected_slot_index, false)
		selected_slot_index = -1
		
		# Update UI — make sure this method exists if you're calling it
		if container_ui.has_method("populate_container_ui"):
			container_ui.populate_container_ui()

func set_inventory(items: Array) -> void:
	cabinet_inventory = items.duplicate(true)

func get_inventory() -> Array:
	return cabinet_inventory
