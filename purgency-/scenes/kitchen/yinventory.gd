extends Button

@onready var container_ui = get_parent().get_parent()  # Adjust if needed

func _ready() -> void:
	pressed.connect(_on_interact)

func _on_interact() -> void:
	if container_ui:
		if container_ui.visible:
			container_ui.hide()
			print("Inventory closed")
		else:
			container_ui.show()
			print("Inventory opened")

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		if container_ui:
			container_ui.hide()
