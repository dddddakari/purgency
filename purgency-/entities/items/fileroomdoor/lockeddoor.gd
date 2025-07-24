extends Area2D

@onready var interactable: Area2D = $interactable
var keycard = null
var dialogue_system = null
var last_dialogue_id = ""

func _ready():
	interactable.interact = _on_interact
	# Find the keycard in the scene (adjust path as needed)
	keycard = get_node_or_null("/root/RoomsArea/Keycard")

func _on_interact():
	if keycard and keycard.has_method("try_open_file_room"):
		if keycard.try_open_file_room():
			open_file_room()
	else:
		# Fallback if keycard can't be found
		if QuestManager.has_quest_item("nurse_keycard"):
			open_file_room()
		else:
			print("File room is locked")

func open_file_room():
	print("Opening file room!")
	# Add your scene change or door opening logic here
	use_dialogue()
func use_dialogue():
	dialogue_system = get_parent().get_node("/root/RoomsArea/Dialogue")
	var dialogue_file_path = "res://json/lockeddoor.json"
	
	if dialogue_system:
		if FileAccess.file_exists(dialogue_file_path):
			dialogue_system.d_file = dialogue_file_path 
			dialogue_system.start()
			print("Love dialogue started.")
			
			# Start monitoring the dialogue system
			_monitor_dialogue()
		else:
			push_error("Dialogue file not found: " + dialogue_file_path)

func _monitor_dialogue():
	# Check dialogue state every frame while it's active
	if dialogue_system and dialogue_system.d_active:
		# Store the current dialogue ID for when dialogue ends
		if dialogue_system.curr_dialogue_id >= 0 and dialogue_system.curr_dialogue_id < dialogue_system.dialogue.size():
			var current_dialogue = dialogue_system.dialogue[dialogue_system.curr_dialogue_id]
			if current_dialogue.has("id"):
				last_dialogue_id = current_dialogue["id"]
		
		# Continue monitoring next frame
		await get_tree().process_frame
		if dialogue_system.d_active:
			_monitor_dialogue()
		else:
			# Dialogue has ended, handle the result
			_on_dialogue_finished()

func _on_dialogue_finished():
	print("Medicine Cart: Dialogue finished with ID: ", last_dialogue_id)
	
	if last_dialogue_id == "bad_ending_vro":
		print("Medicine Cart: Player chose to knock over cart")
		QuestManager.set_cabinet_knocked()
		QuestManager.complete_quest_bad()
		visible = false
		set_process(false)
		interactable.set_process(false)
		
		var nurse = get_tree().get_first_node_in_group("nurse")
		if nurse:
			nurse.react_to_distraction()
