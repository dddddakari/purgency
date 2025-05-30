extends Control

@onready var icon: TextureButton = $TextureButton
@onready var quantity_label: Label = $Label

var item: Dictionary = {}

func set_item(new_item: Dictionary) -> void:
	item = new_item
	icon.texture_normal = item.get("icon", null) 
	quantity_label.text = str(item.get("quantity", 1))
	show()



func clear_slot() -> void:
	item = {}
	icon.texture_normal = null
	quantity_label.text = ""
	hide()
