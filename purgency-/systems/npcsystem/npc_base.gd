extends CharacterBody2D
class_name NPCBase

## Base class for all NPCs with common functionality

# Enums
enum State { IDLE, WANDER, FOLLOW, PATH, DIALOGUE, CUSTOM }

# Exported variables
@export_category("NPC Settings")
@export var move_speed: float = 30.0
@export var acceleration: float = 5.0
@export var wander_radius: float = 100.0
@export var detection_radius: float = 150.0

# Nodes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var interaction_area: Area2D = $InteractionArea

# Variables
var current_state: State = State.IDLE
var player_ref: Node2D = null
var start_position: Vector2
var is_interactable: bool = true
var dialogue_file: String = ""

func _ready():
	start_position = global_position
	initialize_npc()
	setup_interaction_area()

func initialize_npc():
	# Override in inherited classes
	pass

func setup_interaction_area():
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(delta):
	handle_state(delta)
	move_and_slide()

func handle_state(delta):
	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration)
		State.WANDER:
			handle_wander(delta)
		State.FOLLOW:
			if player_ref:
				move_toward(player_ref.global_position)
		State.PATH:
			handle_path()
		State.DIALOGUE:
			velocity = Vector2.ZERO
		State.CUSTOM:
			handle_custom_state(delta)

func handle_wander(delta):
	# Basic wander implementation - override for more complex behavior
	if is_at_destination() or randf() < 0.02:
		set_random_destination()
	move_toward(destination, delta)

func handle_path():
	# Path following logic - override as needed
	pass

func handle_custom_state(delta):
	# For custom state behavior in child classes
	pass

func move_toward(target_position: Vector2, delta: float = 1.0):
	var direction = (target_position - global_position).normalized()
	velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
	update_facing_direction(direction)

func update_facing_direction(direction: Vector2):
	# Basic direction handling - override for custom animations
	if abs(direction.x) > abs(direction.y):
		sprite.flip_h = direction.x < 0
	sprite.play("walk" if velocity.length() > 5 else "idle")

func is_at_destination() -> bool:
	return global_position.distance_to(destination) < 5.0

func set_random_destination():
	destination = start_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		if is_interactable:
			show_interaction_prompt(true)

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null
		show_interaction_prompt(false)

func show_interaction_prompt(show: bool):
	# Implement UI prompt showing/hiding
	pass

func interact():
	if dialogue_file != "":
		start_dialogue(dialogue_file)

func start_dialogue(file: String):
	current_state = State.DIALOGUE
	# Implement your dialogue system call here
	# Example: DialogueManager.start_dialogue(file)

func end_dialogue():
	current_state = State.IDLE
