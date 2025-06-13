extends Node
class_name ItemTransfer

func transfer_item_between(
	source_items: Array,
	source_index: int,
	target_items: Array,
	target_index: int
) -> void:
	# Basic validation
	if source_index < 0 or target_index < 0:
		return
	
	# Ensure arrays are large enough
	while source_items.size() <= source_index:
		source_items.append(null)
	while target_items.size() <= target_index:
		target_items.append(null)
	
	var source_item = source_items[source_index]
	if source_item == null:
		return  # Nothing to transfer
	
	var target_item = target_items[target_index]
	
	# Case 1: Target slot is empty - just move the item
	if target_item == null:
		target_items[target_index] = source_item
		source_items[source_index] = null
		return
	
	# Case 2: Items are the same type - stack them
	if target_item.name == source_item.name:
		target_item.quantity += source_item.quantity
		source_items[source_index] = null
		return
	
	# Case 3: Different items - swap them
	var temp = target_items[target_index]
	target_items[target_index] = source_item
	source_items[source_index] = temp
