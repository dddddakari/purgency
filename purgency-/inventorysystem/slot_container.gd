# explanation vid -> https://youtu.be/rQkswXvVIGw?si=2RU2SFhPIQJ-d_FR
# sooo well explained 
extends PanelContainer
class_name Slot

@export var highlight_color := Color(1, 1, 0, 0.3)  # Yellow highlight
@export var empty_texture: Texture2D

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity_label: Label = $Label
@onready var highlight: ColorRect = $Highlight if has_node("Highlight") else null

var current_item: Item = null
var slot_index: int = -1
var is_selected := false

func _ready():
	custom_minimum_size = Vector2(64, 64)
	
	# Initialize highlight (create if missing)
	if !highlight:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		add_child(highlight)
		move_child(highlight, 0)  # Ensure it's behind other elements
		highlight.color = highlight_color
		highlight.size = size
		highlight.hide()
	else:
		highlight.color = highlight_color
		highlight.hide()
	
	update_display()

func set_item(item: Item):
	current_item = item
	update_display()

func update_display():
	if current_item:
		texture_rect.texture = current_item.texture
		quantity_label.text = str(current_item.quantity)
	else:
		texture_rect.texture = empty_texture
		quantity_label.text = ""

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			var inventory = get_tree().get_first_node_in_group("inventory")
			if inventory:
				inventory.handle_slot_click(slot_index)

func set_highlight(should_highlight: bool):
	is_selected = should_highlight
	if highlight:
		if should_highlight:
			highlight.show()
		else:
			highlight.hide()
	else:
		# Fallback visual feedback if highlight is missing
		modulate = highlight_color if should_highlight else Color.WHITE
