extends Node
class_name NPCState

## Handles state transitions and behaviors

@export var initial_state: NodePath

var current_state: NPCState
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is NPCState:
			states[child.name.to_lower()] = child
			child.state_machine = self
	
	if initial_state:
		change_state(get_node(initial_state).name)

func change_state(new_state_name: String):
	var new_state = states.get(new_state_name.to_lower())
	if new_state and new_state != current_state:
		if current_state:
			current_state.exit()
		current_state = new_state
		current_state.enter()

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event):
	if current_state:
		current_state.handle_input(event)
