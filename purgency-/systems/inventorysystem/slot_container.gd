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

	# Initialize highlight if it's not present in the scene
	if !highlight:
		highlight = ColorRect.new()
		highlight.name = "Highlight"
		highlight.color = highlight_color
		highlight.size_flags_horizontal = SIZE_EXPAND_FILL
		highlight.size_flags_vertical = SIZE_EXPAND_FILL
		highlight.anchor_right = 1.0
		highlight.anchor_bottom = 1.0
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(highlight)
		move_child(highlight, 0)
	highlight.visible = false

	update_display()

func set_item(item):
	current_item = item  # This is okay as it's just a reference
	update_display()  # Make sure this always shows current state

func update_display():
	if current_item != null:
		texture_rect.texture = current_item.texture
		quantity_label.text = str(current_item.quantity)
	else:
		texture_rect.texture = empty_texture
		quantity_label.text = ""

func set_highlight(should_highlight: bool):
	is_selected = should_highlight
	if is_instance_valid(highlight):
		highlight.visible = should_highlight
	else:
		modulate = highlight_color if should_highlight else Color.WHITE
	queue_redraw()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()

		var inventory_screen = get_tree().root.find_child("InventoryScreen", true, false)
		if not inventory_screen:
			return

		# Handle transfer if there's already a selected slot
		if inventory_screen.selected_ui and inventory_screen.selected_slot_index >= 0:
			# Prevent transfer to same slot
			if inventory_screen.selected_ui != slot_owner or inventory_screen.selected_slot_index != slot_index:
				inventory_screen.transfer_between_inventories(
					inventory_screen.selected_ui,
					inventory_screen.selected_slot_index,
					slot_owner,
					slot_index
				)
		else:
			inventory_screen.handle_global_slot_click(slot_owner, slot_index)
