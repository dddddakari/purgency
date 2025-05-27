extends CanvasLayer

@export_file("*.json") var d_file: String

var dialogue = []
var curr_dialogue_id = 0
var d_active = false

func _ready():
	$NinePatchRect.visible = false
	
	
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
	return JSON.parse_string(content)

func _input(event: InputEvent):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script():
	curr_dialogue_id +=1
	
	if curr_dialogue_id >= len(dialogue):
		$Timer.start()
		$NinePatchRect.visible = false
		return
	
	$NinePatchRect/Name.text = dialogue[curr_dialogue_id]['name']
	$NinePatchRect/DialogueText.text = dialogue[curr_dialogue_id]['text']


func _on_Timer_timeout():
	d_active = false
