extends Control
class_name ContainerUI

@onready var container_slot_container = $MarginContainer/GridContainer

var container_items: Array = []
var container_owner: Node = null

func show_container_inventory(items: Array, owner: Node) -> void:
	container_items = items.duplicate(true)
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
	hide()
	container_items = []
	container_owner = null

func get_slot(index: int):
	if index >= 0 and index < container_slot_container.get_child_count():
		return container_slot_container.get_child(index)
	return null

func get_container_items() -> Array:
	var updated_items := []
	for child in container_slot_container.get_children():
		updated_items.append(child.current_item)
	return updated_items
	
func get_items_array() -> Array:
	return container_items
