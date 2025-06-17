#reference: https://www.youtube.com/watch?v=7CCofjq_dHM

extends CanvasLayer

@export_file("*.json") var d_file: String
const SampleButtonScene = preload("res://systems/dialoguesystem/Button.tscn")

var dialogue := []
var curr_dialogue_id := -1
var d_active := false
var id_map := {}

var player: CharacterBody2D = null
var waiting_for_input := false

var can_advance := true  # Controls if input can advance dialogue


func _ready():
	print("DialoguePlayer: _ready called")
	$NinePatchRect.visible = false
	$Options.visible = false

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("[Warning] Player not found in group 'player'.")
	else:
		print("Player found:", player)


func start():
	print("DialoguePlayer: start() called")
	if d_active:
		print("[Warning] Dialogue already active — skipping start().")
		return

	print("Starting dialogue with file:", d_file)
	d_active = true
	$NinePatchRect.visible = true

	if player:
		player.set_movement_enabled(false)
		print("Player movement disabled.")

	dialogue = load_dialogue()
	print("Dialogue size is:", dialogue.size())

	if dialogue.is_empty():
		print("[Warning] No dialogue found in file. Cancelling dialogue.")
		end_dialogue()
		return

	curr_dialogue_id = -1
	waiting_for_input = false
	can_advance = true
	print("Calling next_script() to start dialogue flow.")
	next_script()


func load_dialogue() -> Array:
	print("Loading dialogue JSON from:", d_file)
	if not FileAccess.file_exists(d_file):
		push_error("Dialogue file not found: " + d_file)
		return []

	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = file.get_as_text()
	print("Raw JSON content:", content)

	var data = JSON.parse_string(content)
	if data == null:
		push_error("Failed to parse JSON.")
		return []

	if typeof(data) != TYPE_ARRAY:
		push_error("JSON root is not an array.")
		return []

	id_map.clear()
	for i in data.size():
		if data[i].has("id"):
			id_map[data[i]["id"]] = i

	print("Parsed", data.size(), "dialogue entries.")
	print("ID map contents:", id_map)
	return data


func _process(delta):
	if not d_active:
		return

	if waiting_for_input and not $Options.visible and can_advance and Input.is_action_just_pressed("ui_accept"):
		print("Input detected to advance dialogue")
		can_advance = false  # Lock input immediately
		waiting_for_input = false
		next_script()


func next_script(optional_id = null):
	$Options.visible = false
	clear_options()

	if optional_id != null:
		curr_dialogue_id = id_map.get(optional_id, -1)
		if curr_dialogue_id == -1:
			print("[Warning] next_id '%s' not found in dialogue." % optional_id)
			end_dialogue()
			return
	else:
		curr_dialogue_id += 1

	if curr_dialogue_id < 0 or curr_dialogue_id >= dialogue.size():
		end_dialogue()
		return

	var current_line = dialogue[curr_dialogue_id]

	var name_label = $NinePatchRect.get_node("name")
	var text_label = $NinePatchRect.get_node("text")

	name_label.text = current_line.get("name", "")
	text_label.text = current_line.get("text", "")

	print("Displaying:", name_label.text, "-", text_label.text)

	if current_line.has("options") and current_line["options"].size() > 0:
		show_options(current_line["options"])
		waiting_for_input = false
		can_advance = false
	else:
		waiting_for_input = true
		can_advance = true


func show_options(options_array):
	print("show_options called with %d options" % options_array.size())
	$Options.visible = true
	for option_data in options_array:
		var btn = SampleButtonScene.instantiate()
		btn.text = option_data.get("text", "...")
		# Use .bind to pass next_id string properly
		btn.pressed.connect(self._on_option_selected.bind(option_data.get("next_id", "")))
		$Options.add_child(btn)
		print("Option button added with text:", btn.text)


func _on_option_selected(next_id: String) -> void:
	print("Option selected, next id:", next_id)
	
	# Disable all buttons immediately to prevent multiple triggers
	for btn in $Options.get_children():
		btn.disabled = true

	$Options.visible = false
	clear_options()

	waiting_for_input = false
	can_advance = false  # Lock input immediately on option select

	# Find next dialogue entry from id_map
	var next_index = id_map.get(next_id, -1)
	if next_index == -1:
		print("❌ next_id not found:", next_id)
		end_dialogue()
		return

	var next_dialogue = dialogue[next_index]

	# Check for scene change action
	if next_dialogue.has("action") and next_dialogue["action"] == "change_scene":
		var scene_path = next_dialogue.get("scene_path", "")
		if scene_path != "":
			print("Changing scene to:", scene_path)
			get_tree().change_scene_to_file(scene_path)
			return  # Stop dialogue flow here
		else:
			print("scene_path is empty!")
			end_dialogue()
			return

	next_script(next_id)
	can_advance = true


func _deferred_next_script(next_id: String) -> void:
	next_script(next_id)
	await get_tree().create_timer(0.1).timeout
	can_advance = true

func clear_options():
	var count = $Options.get_child_count()
	print("Clearing %d option buttons." % count)
	for child in $Options.get_children():
		child.queue_free()


func end_dialogue():
	print("\n--- end_dialogue called ---")
	if not d_active:
		print("Dialogue already inactive; nothing to end.")
		return

	d_active = false
	waiting_for_input = false
	can_advance = false
	$NinePatchRect.visible = false
	$Options.visible = false
	clear_options()

	if player:
		player.set_movement_enabled(true)
		print("Movement re-enabled in end_dialogue().")
