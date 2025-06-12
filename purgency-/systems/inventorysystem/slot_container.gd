extends PanelContainer
class_name Slot

@export var highlight_color := Color(1, 1, 0, 0.3)  # Yellow highlight
@export var empty_texture: Texture2D

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity_label: Label = $Label
@onready var highlight: ColorRect = $Highlight if has_node("Highlight") else null

var current_item = null  # Item or null
var slot_index: int = -1
var is_selected := false
var slot_owner: Node = null  # inventory or container_ui

func _ready():
	custom_minimum_size = Vector2(64, 64)
	if !highlight:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		add_child(highlight)
		move_child(highlight, 0)
		highlight.color = highlight_color
		highlight.size = size
		highlight.hide()
	else:
		highlight.color = highlight_color
		highlight.hide()

	update_display()

func set_item(item):
	current_item = item
	update_display()

func update_display():
	if current_item != null:
		texture_rect.texture = current_item.texture
		quantity_label.text = str(current_item.quantity)
	else:
		texture_rect.texture = empty_texture
		quantity_label.text = ""

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		if slot_owner:
			slot_owner.handle_slot_click(slot_index)

func set_highlight(should_highlight: bool):
	is_selected = should_highlight
	if highlight:
		highlight.visible = should_highlight
	else:
		modulate = highlight_color if should_highlight else Color.WHITE
