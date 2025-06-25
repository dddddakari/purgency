# item.gd - Enhanced Item System
extends Resource
class_name Item

# Item types enum
enum ItemType {
	QUEST,
	FOOD,
	DRINK,
	COLLECTIBLE
}

# Item properties
@export var name: String
@export var quantity: int = 1
@export var texture: Texture2D
@export var item_type: ItemType = ItemType.COLLECTIBLE
@export var description: String = ""
@export var can_use: bool = false
@export var can_stack: bool = true
@export var max_stack_size: int = 99

# Item stats/effects
@export var health_restore: int = 0
@export var is_quest_item: bool = false
@export var rarity: String = "Common" # Common, Uncommon, Rare, Epic, Legendary
@export var value: int = 0 # For trading/selling

# Static constructor function
static func create(p_name: String, p_quantity: int, p_texture: Texture2D, p_type: ItemType = ItemType.COLLECTIBLE) -> Item:
	var item = Item.new()
	item.name = p_name
	item.quantity = p_quantity
	item.texture = p_texture
	item.item_type = p_type
	item.setup_item_properties()
	return item

# Enhanced constructor with all properties
static func create_full(data: Dictionary) -> Item:
	var item = Item.new()
	item.name = data.get("name", "Unknown Item")
	item.quantity = data.get("quantity", 1)
	item.texture = load(data.get("texture", "")) if data.get("texture", "") != "" else null
	item.item_type = data.get("item_type", ItemType.COLLECTIBLE)
	item.description = data.get("description", "")
	item.can_use = data.get("can_use", false)
	item.can_stack = data.get("can_stack", true)
	item.max_stack_size = data.get("max_stack_size", 99)
	item.health_restore = data.get("health_restore", 0)
	item.is_quest_item = data.get("is_quest_item", false)
	item.rarity = data.get("rarity", "Common")
	item.value = data.get("value", 0)
	return item

# Setup default properties based on item type
func setup_item_properties():
	match item_type:
		ItemType.QUEST:
			is_quest_item = true
			can_use = false
			can_stack = false
			max_stack_size = 1
			rarity = "Epic"
		ItemType.FOOD:
			can_use = true
			can_stack = true
			max_stack_size = 20
			if health_restore == 0:
				health_restore = 25
		ItemType.DRINK:
			can_use = true
			can_stack = true
			max_stack_size = 10
			if health_restore == 0:
				health_restore = 15
		ItemType.COLLECTIBLE:
			can_use = false
			can_stack = true
			max_stack_size = 99

# Use the item
func use_item(user_node) -> bool:
	if not can_use:
		print("Item cannot be used: ", name)
		return false
	
	match item_type:
		ItemType.FOOD, ItemType.DRINK:
			if user_node.has_method("restore_health"):
				user_node.restore_health(health_restore)
				print("Used ", name, " - Restored ", health_restore, " health")
				return true
			elif user_node.has_property("health"):
				user_node.health = min(user_node.health + health_restore, user_node.health_max)
				print("Used ", name, " - Restored ", health_restore, " health")
				return true
		_:
			print("Item type not implemented for use: ", ItemType.keys()[item_type])
			return false
	
	return false

# Get item color based on rarity
func get_rarity_color() -> Color:
	match rarity:
		"Common":
			return Color.WHITE
		"Uncommon":
			return Color.GREEN
		"Rare":
			return Color.BLUE
		"Epic":
			return Color.PURPLE
		"Legendary":
			return Color.GOLD
		_:
			return Color.WHITE

# Convert to dictionary for saving
func to_dict() -> Dictionary:
	return {
		"name": name,
		"quantity": quantity,
		"texture": texture.resource_path if texture else "",
		"item_type": item_type,
		"description": description,
		"can_use": can_use,
		"can_stack": can_stack,
		"max_stack_size": max_stack_size,
		"health_restore": health_restore,
		"is_quest_item": is_quest_item,
		"rarity": rarity,
		"value": value
	}

# Get item type as string
func get_type_string() -> String:
	return ItemType.keys()[item_type]
