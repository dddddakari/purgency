extends Area2D

var entered = false

func _on_body_entered(body: Node2D) -> void:
	pass
	#if entered:
		#use_dialogue()
	#else:
		#entered = true

			
func use_dialogue():
	var dialogue = get_parent().get_node("SecurityDialogue")
	if dialogue:
		dialogue.d_file = "res://json/security.json"
		dialogue.start()
