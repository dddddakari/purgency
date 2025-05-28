extends Area2D

var entered = true

func _on_body_entered(body: Node2D) -> void:
	if entered == true:
			use_dialogue()
	
func use_dialogue():
	var dialogue = get_parent().get_node("OPDialogue")
	
	if dialogue:
		dialogue.start()
