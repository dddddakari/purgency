# item_transfer.gd
extends Node
class_name ItemTransfer

func transfer_item_between(source_items: Array, source_index: int, target_items: Array, target_index: int) -> bool:
	# Validate indices
	if source_index < 0 or target_index < 0:
		return false
	
	# Ensure arrays are large enough
	var max_index = max(source_index, target_index)
	if source_items.size() <= max_index:
		source_items.resize(max_index + 1)
	if target_items.size() <= max_index:
		target_items.resize(max_index + 1)
	
	var source_item = source_items[source_index]
	# No item to transfer
	if source_item == null:
		return false
	
	var target_item = target_items[target_index]
	
	# Case 1: Target slot is empty - MOVE
	if target_item == null:
		target_items[target_index] = source_item
		source_items[source_index] = null
		return true
	
	# Case 2: Same item type - STACK
	elif target_item.name == source_item.name:
		target_item.quantity += source_item.quantity
		source_items[source_index] = null
		return true
	
	# Case 3: Different items - SWAP
	else:
		var temp = target_item
		target_items[target_index] = source_item
		source_items[source_index] = temp
		return true
