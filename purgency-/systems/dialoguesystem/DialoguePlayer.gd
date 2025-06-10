extends CanvasLayer

@export_file("*.json") var d_file: String
const SampleButtonScene = preload("res://systems/dialoguesystem/Button.tscn")

var dialogue = []
var curr_dialogue_id = 0
var d_active = false
var id_map = {} 


func _ready():
	$NinePatchRect.visible = false
	$Options.visible = false
	
func start():
	if d_active:
		return
	
	d_active = true
	$NinePatchRect.visible = true
	
	dialogue = load_dialogue()
	curr_dialogue_id = -1
	next_script()
	
	
func load_dialogue():
	if not FileAccess.file_exists(d_file):
		push_error("Dialogue file not found: " + d_file)
		return []

	var file = FileAccess.open(d_file, FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)

	if typeof(data) != TYPE_ARRAY:
		push_error("Parsed data is not an array.")
		return []

	# Build the ID map
	id_map = {}
	for i in data.size():
		if data[i].has("id"):
			id_map[data[i]["id"]] = i

	print("Dialogue loaded successfully.")
	return data


func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept"):
			next_script()
		
func next_script(optional_id = null):
	$Options.visible = false
	clear_options()

	if optional_id != null:
		curr_dialogue_id = id_map.get(optional_id, -1)
	else:
		curr_dialogue_id += 1

	if curr_dialogue_id >= len(dialogue) or curr_dialogue_id == -1:
		$Timer.start()
		$NinePatchRect.visible = false
		return

	var current_line = dialogue[curr_dialogue_id]
	$NinePatchRect.get_node("name").text = current_line.get("name", "Unknown")
	$NinePatchRect.get_node("text").text = current_line.get("text", "")

	# Handle options
	if current_line.has("options"):
		show_options(current_line["options"])
	else:
		# Only allow input if no options
		$Options.visible = false

		
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
	
func _on_Timer_timeout():
	d_active = false
