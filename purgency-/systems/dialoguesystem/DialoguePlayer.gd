extends CanvasLayer

@export_file("*.json") var d_file: String
const SampleButtonScene = preload("res://systems/dialoguesystem/Button.tscn")

var dialogue: Array = []
var curr_dialogue_id: int = -1
var d_active: bool = false
var id_map: Dictionary = {}

var player: CharacterBody2D = null

func _ready():
	$NinePatchRect.visible = false
	$Options.visible = false
	$Timer.wait_time = 0.1
	$Timer.one_shot = true

	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("Player not found in group 'player'.")

func start():
	if d_active:
		print("Dialogue already active — skipping.")
		return

	print("Starting dialogue with file:", d_file)
	d_active = true
	$NinePatchRect.visible = true

	if player:
		player.set_movement_enabled(false)
		print("Player movement disabled.")

	dialogue = load_dialogue()
	print("🧾 Dialogue size is:", dialogue.size())

	if dialogue.is_empty():
		print("No dialogue found in file. Cancelling.")
		end_dialogue()
		return

	curr_dialogue_id = -1
	next_script()

func load_dialogue() -> Array:
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
	return data

func _process(delta):
	if d_active and Input.is_action_just_pressed("ui_accept") and not $Options.visible:
		next_script()

func next_script(optional_id = null):
	$Options.visible = false
	clear_options()

	if optional_id != null:
		curr_dialogue_id = id_map.get(optional_id, -1)
	else:
		curr_dialogue_id += 1

	if curr_dialogue_id < 0 or curr_dialogue_id >= dialogue.size():
		print("Ending dialogue at ID:", curr_dialogue_id, "/", dialogue.size())
		end_dialogue()
		return

	var current_line = dialogue[curr_dialogue_id]
	print("Showing line", curr_dialogue_id, ":", current_line)

	$NinePatchRect.get_node("name").text = current_line.get("name", "")
	$NinePatchRect.get_node("text").text = current_line.get("text", "")

	if current_line.has("options"):
		show_options(current_line["options"])

func show_options(options_array):
	$Options.visible = true
	for option_data in options_array:
		var btn = SampleButtonScene.instantiate()
		btn.text = option_data.get("text", "...")
		btn.connect("pressed", Callable(self, "_on_option_selected").bind(option_data.get("next_id", "")))
		$Options.add_child(btn)

func _on_option_selected(next_id: String):
	next_script(next_id)

func clear_options():
	for child in $Options.get_children():
		child.queue_free()

func end_dialogue():
	if not d_active:
		return
	d_active = false
	$NinePatchRect.visible = false
	$Options.visible = false
	clear_options()

	# Redundant fallback: enable movement immediately too (in case Timer fails)
	if player:
		player.set_movement_enabled(true)
		print("Movement re-enabled in end_dialogue().")

	$Timer.start()  # Optional delay (cosmetic)

func _on_Timer_timeout():
	print("⏱️ Timer fired — attempting to enable player movement.")
	if player:
		player.set_movement_enabled(true)
		print("Movement re-enabled via timer.")
