extends Area2D

# Dialogue configuration
@export_file("*.json") var dialogue_file: String = "res://json/nurse.json"
@export_file("*.json") var dialogue_file_with_letter: String = "res://json/nurseletter.json"
@export var dialogue_player_path: NodePath = "/root/RoomsArea/Dialogue"

var dialogue_player: Node = null  # Reference to dialogue system

func _ready() -> void:
	
	# Get dialogue player node
	dialogue_player = get_node_or_null(dialogue_player_path)
	if dialogue_player == null:
		push_error("DialoguePlayer not found at path: " + str(dialogue_player_path))
	else:
		# Connect signals if available
		if dialogue_player.has_signal("option_selected"):
			dialogue_player.connect("option_selected", Callable(self, "_on_option_selected"))
		else:
			push_warning("DialoguePlayer missing signal: option_selected")
		if dialogue_player.has_signal("dialogue_finished"):
			dialogue_player.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

func _on_body_entered(body: Node2D) -> void:
	# Trigger dialogue when player enters
	if not body.is_in_group("player"):
		return
	
	if dialogue_player == null:
		return

	# Choose dialogue file based on quest items
	var selected_dialogue_file = get_appropriate_dialogue_file()
	
	# Check dialogue file exists
	if not FileAccess.file_exists(selected_dialogue_file):
		push_error("Dialogue file not found: " + selected_dialogue_file)
		return
	
	# Start dialogue
	dialogue_player.d_file = selected_dialogue_file
	dialogue_player.start()

func get_appropriate_dialogue_file() -> String:
	# Check if player has the love letter
	if QuestManager.has_quest_item("love_letter"):
		print("Player has love letter - using special nurse dialogue")
		return dialogue_file_with_letter
	else:
		print("Player doesn't have love letter - using normal nurse dialogue")
		return dialogue_file

func _on_option_selected(option_index: int) -> void:
	# Handle dialogue option selection
	if dialogue_player == null:
		print("dialogue_player is null in _on_option_selected")
		return

	# Get current dialogue state
	var current = dialogue_player.get_current_dialogue()
	if current == null:
		print("current dialogue is null")
		return

	# Validate selected option
	var options = current.get("options", [])
	if option_index < 0 or option_index >= options.size():
		print("Invalid option index:", option_index)
		return

	var selected_option = options[option_index]
	if not selected_option.has("next_id"):
		print("Selected option has no next_id")
		return

	var next_id = selected_option["next_id"]
	print("Option selected, next_id is:", next_id)

	# Handle special quest actions
	handle_quest_actions(next_id, selected_option)

	# Find next dialogue entry
	var next_dialogue = null
	for dialogue in dialogue_player.dialogue_data:
		if dialogue.get("id", "") == next_id:
			next_dialogue = dialogue
			break

	if next_dialogue == null:
		print("Could not find dialogue entry for next_id:", next_id)
		return

	# Handle scene change if specified
	if next_dialogue.has("action") and next_dialogue["action"] == "change_scene":
		var scene_path = next_dialogue.get("scene_path", "")
		if scene_path != "":
			print("Changing scene to:", scene_path)
			get_tree().change_scene_to_file(scene_path)
		else:
			print("scene_path is empty!")
	else:
		# Continue dialogue normally
		if dialogue_player.has_method("goto_id"):
			dialogue_player.goto_id(next_id)
		else:
			print("dialogue_player missing method: goto_id")

func handle_quest_actions(next_id: String, selected_option: Dictionary) -> void:
	# Handle quest item actions based on dialogue choices
	match next_id:
		"give_letter":
			# Player chose to give the love letter to the nurse
			if QuestManager.has_quest_item("love_letter"):
				QuestManager.remove_quest_item("love_letter")
				QuestManager.add_quest_item("letter_delivered")
				print("Love letter given to nurse!")
		
		"keep_letter":
			# Player chose to keep the letter
			print("Player decided to keep the love letter")
		
		"blackmail_option":
			# Player chose to use letter for blackmail (if you want this option)
			if QuestManager.has_quest_item("love_letter"):
				QuestManager.add_quest_item("blackmail_evidence")
				print("Letter used as blackmail evidence")
	


func _on_dialogue_finished() -> void:
	# Dialogue finished handler
	print("Dialogue finished.")
