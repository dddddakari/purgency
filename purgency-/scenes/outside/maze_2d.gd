extends Area2D

@export_file("*.json") var dialogue_file: String = "res://json/maze.json"
@export var dialogue_player_path: NodePath = "/root/Hospital/Maze"

var dialogue_player: Node = null

func _ready() -> void:
	# Connect the body_entered signal of the Area2D (make sure your Area2D has a CollisionShape2D)
	#self.body_entered.connect(_on_body_entered)
	
	# Get the dialogue player node from the scene tree using the provided path
	dialogue_player = get_node_or_null(dialogue_player_path)
	if dialogue_player == null:
		push_error("❌ DialoguePlayer not found at path: " + str(dialogue_player_path))
	else:
		# Connect signals if they exist on dialogue_player
		if dialogue_player.has_signal("option_selected"):
			dialogue_player.connect("option_selected", Callable(self, "_on_option_selected"))
		else:
			push_warning("⚠ DialoguePlayer missing signal: option_selected")
		if dialogue_player.has_signal("dialogue_finished"):
			dialogue_player.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))
		else:
			push_warning("⚠ DialoguePlayer missing signal: dialogue_finished")

func _on_body_entered(body: Node) -> void:
	# Only trigger if the colliding body is in group "player"
	if not body.is_in_group("player"):
		return
	
	if dialogue_player == null:
		return

	# Check file existence before assigning and starting dialogue
	if not FileAccess.file_exists(dialogue_file):
		push_error("❌ Dialogue file not found: " + dialogue_file)
		return
	
	# Assign the file and start the dialogue
	dialogue_player.d_file = dialogue_file
	dialogue_player.start()

func _on_option_selected(option_index: int) -> void:
	if dialogue_player == null:
		print("❌ dialogue_player is null in _on_option_selected")
		return

	# Get the current dialogue dictionary from dialogue_player
	var current = dialogue_player.get_current_dialogue()
	if current == null:
		print("❌ current dialogue is null")
		return

	# Check option index validity
	var options = current.get("options", [])
	if option_index < 0 or option_index >= options.size():
		print("❌ Invalid option index:", option_index)
		return

	var selected_option = options[option_index]
	if not selected_option.has("next_id"):
		print("❌ Selected option has no next_id")
		return

	var next_id = selected_option["next_id"]
	print("✅ Option selected, next_id is:", next_id)

	# Find the dialogue entry matching next_id
	var next_dialogue = null
	for dialogue in dialogue_player.dialogue_data:
		if dialogue.get("id", "") == next_id:
			next_dialogue = dialogue
			break

	if next_dialogue == null:
		print("❌ Could not find dialogue entry for next_id:", next_id)
		return

	# Check if next dialogue line has action "change_scene"
	if next_dialogue.has("action") and next_dialogue["action"] == "change_scene":
		var scene_path = next_dialogue.get("scene_path", "")
		if scene_path != "":
			print("🚪 Changing scene to:", scene_path)
			get_tree().change_scene_to_file(scene_path)
		else:
			print("❌ scene_path is empty!")
	else:
		# If no scene change action, advance dialogue normally:
		if dialogue_player.has_method("goto_id"):
			dialogue_player.goto_id(next_id)
		else:
			print("❌ dialogue_player missing method: goto_id")

func _on_dialogue_finished() -> void:
	# This function gets called when dialogue finishes (optional, handle if needed)
	print("Dialogue finished.")
