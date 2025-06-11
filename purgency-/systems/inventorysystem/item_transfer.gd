extends Node
class_name ItemTransfer

func transfer_item_between(
	source_items: Array,
	source_index: int,
	target_items: Array,
	target_index: int
) -> void:
	if source_index < 0 or target_index < 0:
		return
	
	# Ensure arrays are large enough
	var max_index = max(source_index, target_index)
	if source_items.size() <= max_index:
		source_items.resize(max_index + 1)
	if target_items.size() <= max_index:
		target_items.resize(max_index + 1)
	
	var source_item = source_items[source_index]
	if source_item == null:
		return
	
	var target_item = target_items[target_index]
	
	if target_item == null:
		# Move item
		target_items[target_index] = source_item
		source_items[source_index] = null
	elif target_item.name == source_item.name:
		# Stack items
		target_item.quantity += source_item.quantity
		source_items[source_index] = null
	else:
		# Swap items
		var temp = target_items[target_index]
		target_items[target_index] = source_item
		source_items[source_index] = temp
