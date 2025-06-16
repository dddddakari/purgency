# item.gd
extends Resource
class_name Item

# Item properties
@export var name: String  # Item name
@export var quantity: int  # Stack quantity
@export var texture: Texture2D  # Visual representation

# Static constructor function
static func create(p_name: String, p_quantity: int, p_texture: Texture2D) -> Item:
	var item = Item.new()
	item.name = p_name
	item.quantity = p_quantity
	item.texture = p_texture
	return item
