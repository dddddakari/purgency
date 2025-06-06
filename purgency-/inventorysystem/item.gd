# item.gd
extends Resource
class_name Item

@export var name: String
@export var quantity: int
@export var texture: Texture2D

# Add this constructor function
static func create(p_name: String, p_quantity: int, p_texture: Texture2D) -> Item:
	var item = Item.new()
	item.name = p_name
	item.quantity = p_quantity
	item.texture = p_texture
	return item
