extends Area2D

signal admin_trigger

var entered = false
var dialogue_triggered = false


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not dialogue_triggered:
		dialogue_triggered = true
		admin_trigger.emit()
		use_dialogue()
	else:
		entered = true


func use_dialogue():
	var dialogue = get_parent().get_node("Dialogue")
	if dialogue:
		dialogue.d_file = "res://json/pen_room_minigame.json"
		dialogue.start()
