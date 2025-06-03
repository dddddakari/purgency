extends Control

@onready var icon: TextureRect = $TextureRect
@onready var quantity_label: Label = $Label

var item: Dictionary = {}

func set_item(new_item: Dictionary):
	item = new_item
	icon.texture = item.get("icon", null)
	quantity_label.text = str(item.get("quantity", 1))
	show()

func clear_slot():
	item = {}
	icon.texture = null
	quantity_label.text = ""
	hide()
