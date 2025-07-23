extends Area2D

@onready var interactable: Area2D = $interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

var dialogue_system = null
var last_dialogue_id = ""


func _on_interact():
	if not QuestManager.can_use_letter():
		print("Cannot use letter - already used")
		return
	
	print("Love Letter interaction")
	use_dialogue()
	
func use_dialogue():
	dialogue_system = get_parent().get_node("/root/Bathroom/Dialogue")
	var dialogue_file_path = "res://json/loveletter.json"
	
	if dialogue_system:
		if FileAccess.file_exists(dialogue_file_path):
			dialogue_system.d_file = dialogue_file_path 
			dialogue_system.start()
			print("dialogue started.")
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)
