extends Control
class_name ContainerUI

@onready var container_slot_container = $MarginContainer/GridContainer

var container_items: Array = []
var container_owner: Node = null

func show_container_inventory(items: Array, owner: Node) -> void:
	# FIX: Don't duplicate - use direct reference to the container's items
	container_items = items
	container_owner = owner
	
	# Ensure we have enough slots
	while container_slot_container.get_child_count() < container_items.size():
		var slot = preload("res://systems/inventorysystem/Slot.tscn").instantiate()
		slot.slot_index = container_slot_container.get_child_count()
		slot.slot_owner = self
		container_slot_container.add_child(slot)
	
	# Populate all slots
	for i in range(container_items.size()):
		var slot = container_slot_container.get_child(i)
		slot.slot_index = i
		slot.slot_owner = self
		slot.set_item(container_items[i])
	
	show()

func hide_container():
	# FIX: Save container state before hiding
	if container_owner and container_owner.has_method("save_inventory"):
		container_owner.save_inventory()
	
	hide()
	container_items = []
	container_owner = null

func get_slot(index: int):
	if index >= 0 and index < container_slot_container.get_child_count():
		return container_slot_container.get_child(index)
	return null

# FIX: This should return the live container_items array, not build a new one
func get_container_items() -> Array:
	return container_items

func update_display():
	for i in range(container_slot_container.get_child_count()):
		var slot = container_slot_container.get_child(i)
		if i < container_items.size():
			slot.set_item(container_items[i])  
		else:
			slot.set_item(null)

func get_items_array() -> Array:
	return container_items

func refresh_inventory():
	for i in range(container_items.size()):
		var slot = get_slot(i)
		if slot:
			slot.set_item(container_items[i])

# FIX: Add save method that gets called after transfers
func save_container():
	if container_owner and container_owner.has_method("save_inventory"):
		container_owner.save_inventory()
