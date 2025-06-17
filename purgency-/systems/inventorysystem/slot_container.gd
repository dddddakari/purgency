# slot_container.gd (updated)
extends PanelContainer
class_name Slot

@export var highlight_color := Color(1, 1, 0, 0.3)
@export var empty_texture: Texture2D

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity_label: Label = $Label
@onready var highlight: ColorRect = $Highlight if has_node("Highlight") else null

var current_item = null
var slot_index: int = -1
var is_selected := false
var slot_owner: Node = null

func _ready():
	custom_minimum_size = Vector2(64, 64)
	
	# Initialize highlight if missing
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

func set_highlight(should_highlight: bool):
	is_selected = should_highlight
	if highlight:
		highlight.visible = should_highlight
	else:
		modulate = highlight_color if should_highlight else Color.WHITE

# Optional: Long-press functionality (remove if not needed)
var press_timer := 0.0
const LONG_PRESS_DURATION := 0.5

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			press_timer = 0.0
		elif press_timer >= LONG_PRESS_DURATION and slot_owner:
			slot_owner.handle_long_press(slot_index)
			
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		
		# Find the InventoryScreen in the scene
		var inventory_screen = get_tree().root.find_child("InventoryScreen", true, false)
		if !inventory_screen:
			return
		
		# If we have a selected slot, attempt transfer
		if inventory_screen.selected_ui && inventory_screen.selected_slot_index >= 0:
			inventory_screen.transfer_between_inventories(
				inventory_screen.selected_ui,
				inventory_screen.selected_slot_index,
				slot_owner,
				slot_index
			)
		else:
			# Otherwise select this slot
			inventory_screen.handle_global_slot_click(slot_owner, slot_index)
				
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		press_timer += delta
