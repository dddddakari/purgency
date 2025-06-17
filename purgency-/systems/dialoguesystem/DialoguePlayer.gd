# DialoguePlayer.gd
extends CanvasLayer

# Dialogue system configuration
@export_file("*.json") var d_file: String  # Dialogue file path
const SampleButtonScene = preload("res://systems/dialoguesystem/Button.tscn")  # Option button scene

# Dialogue state variables
var dialogue: Array = []  # Loaded dialogue data
var curr_dialogue_id: int = -1  # Current dialogue index
var d_active: bool = false  # Dialogue active flag
var id_map: Dictionary = {}  # Maps dialogue IDs to indices

# Player reference
var player: CharacterBody2D = null  # Player reference
var waiting_for_input: bool = false  # Waiting for player input
var can_advance: bool = true  # Controls if input can advance dialogue

func _ready():
	$NinePatchRect.visible = false
	$Options.visible = false

	# Get player reference
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("[Warning] Player not found in group 'player'.")
	else:
		print("Player found:", player)

func start():
	if d_active:
		return

	d_active = true
	$NinePatchRect.visible = true

	# Disable player movement during dialogue
	if player:
		player.set_movement_enabled(false)

	# Load dialogue data
	dialogue = load_dialogue()

	if dialogue.is_empty():
		end_dialogue()
		return

	# Reset dialogue state
	curr_dialogue_id = -1
	waiting_for_input = false
	can_advance = true
	next_script()

func load_dialogue() -> Array:
	if not FileAccess.file_exists(d_file):
		push_error("Dialogue file not found: " + d_file)
		return []

	# Read and parse dialogue file
	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = file.get_as_text()

	var data = JSON.parse_string(content)
	if data == null:
		push_error("Failed to parse JSON.")
		return []

	if typeof(data) != TYPE_ARRAY:
		push_error("JSON root is not an array.")
		return []

	# Build ID map for quick lookup
	id_map.clear()
	for i in data.size():
		if data[i].has("id"):
			id_map[data[i]["id"]] = i

	return data

func _process(delta):
	if not d_active:
		return

	# Handle input to advance dialogue
	if waiting_for_input and not $Options.visible and can_advance and Input.is_action_just_pressed("ui_accept"):
		can_advance = false  # Lock input immediately
		waiting_for_input = false
		next_script()

func next_script(optional_id = null):
	# Advance to next dialogue segment
	$Options.visible = false
	clear_options()

	# Handle optional ID or sequential progression
	if optional_id != null:
		curr_dialogue_id = id_map.get(optional_id, -1)
		if curr_dialogue_id == -1:
			end_dialogue()
			return
	else:
		curr_dialogue_id += 1

	# Check if dialogue ended
	if curr_dialogue_id < 0 or curr_dialogue_id >= dialogue.size():
		end_dialogue()
		return

	# Display current dialogue line
	var current_line = dialogue[curr_dialogue_id]
	var name_label = $NinePatchRect.get_node("name")
	var text_label = $NinePatchRect.get_node("text")

	name_label.text = current_line.get("name", "")
	text_label.text = current_line.get("text", "")

	# Handle options or simple progression
	if current_line.has("options") and current_line["options"].size() > 0:
		show_options(current_line["options"])
		waiting_for_input = false
		can_advance = false
	else:
		waiting_for_input = true
		can_advance = true

func show_options(options_array):
	$Options.visible = true
	
	# Create option buttons
	for option_data in options_array:
		var btn = SampleButtonScene.instantiate()
		btn.text = option_data.get("text", "...")
		# Bind next_id to button press
		btn.pressed.connect(self._on_option_selected.bind(option_data.get("next_id", "")))
		$Options.add_child(btn)

func _on_option_selected(next_id: String) -> void:
	
	# Disable all buttons to prevent multiple triggers
	for btn in $Options.get_children():
		btn.disabled = true

	$Options.visible = false
	clear_options()

	waiting_for_input = false
	can_advance = false  # Lock input

	# Find next dialogue entry
	var next_index = id_map.get(next_id, -1)
	if next_index == -1:
		end_dialogue()
		return

	var next_dialogue = dialogue[next_index]

	# Handle scene change action
	if next_dialogue.has("action") and next_dialogue["action"] == "change_scene":
		var scene_path = next_dialogue.get("scene_path", "")
		if scene_path != "":
			get_tree().change_scene_to_file(scene_path)
			return  # Stop dialogue
		else:
			print("scene_path is empty!")
			end_dialogue()
			return

	# Continue to next dialogue segment
	next_script(next_id)
	can_advance = true

func _deferred_next_script(next_id: String) -> void:
	# Deferred next script call
	next_script(next_id)
	await get_tree().create_timer(0.1).timeout
	can_advance = true

func clear_options():
	# Clear all option buttons
	var count = $Options.get_child_count()
	for child in $Options.get_children():
		child.queue_free()

func end_dialogue():
	
# DIALOGUE ALREADY NOT ACTIVE NO NEED TO STOP IT
	if not d_active:
		return

	# Clean up dialogue state
	d_active = false
	waiting_for_input = false
	can_advance = false
	$NinePatchRect.visible = false
	$Options.visible = false
	clear_options()

	# Re-enable player movement
	if player:
		player.set_movement_enabled(true)
