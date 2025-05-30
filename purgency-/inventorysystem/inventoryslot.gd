extends Control

@onready var icon = $TextureButton
@onready var quantity_label = $Label

var item = null

func set_item(new_item):
	item = new_item
	icon.texture = item["icon"]
	quantity_label.text = str(item.get("quantity", 1))
	show()

func clear_slot():
	item = null
	icon.texture = null
	quantity_label.text = ""
	hide()
