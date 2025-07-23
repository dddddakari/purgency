extends CharacterBody2D
class_name NPCNurse

# Movement settings
@export var move_distance: float = 40.0  # How far up/down the NPC moves
@export var walk_speed: float = 50.0
@export var min_stop_time: float = 0.2
@export var max_stop_time: float = 1.0
@export var stop_chance: float = 0.03 # set this higher if you want

# Animation ( single image for now)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var keycard_scene = preload("res://entities/items/keycard/keycard.tscn") # Create this scene

var is_distracted: bool = false
var has_received_letter: bool = false
var start_position: Vector2
var target_position: Vector2
var is_moving: bool = true
var moving_up: bool = true  # Start by moving up
var is_leaving: bool = false
var exit_speed: float = 100.0
var exit_target: Vector2

func _ready():
	#starting position is the Vector Coordinates, so Vector2(0,0)
	start_position = position
	# simply this is target_position = start_position + Vector2(0, -40)
	target_position = start_position + Vector2(0, -move_distance)  # First target: up
	
	sprite.play("idle")
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_moving:
		# Move toward target position
		var direction = (target_position - position).normalized()
		velocity = direction * walk_speed
		move_and_slide()
		
		# Update facing direction (only up/down animations)
		update_facing_direction(direction)
		
		# Check if reached target
		if position.distance_to(target_position) < 5.0:
			switch_direction()
		
		# Random chance to stop
		if randf() < stop_chance * delta * 60:
			stop_walking()
	else:
		velocity = Vector2.ZERO

	if is_leaving:
		var direction = (exit_target - position).normalized()
		velocity = direction * exit_speed
		move_and_slide()
		
		# Check if reached target
		if position.distance_to(exit_target) < 10.0:
			print("Nurse: Reached exit point!")
			set_physics_process(false)
			timer.start(0.5) # Small delay before disappearing

func update_facing_direction(direction: Vector2):
	if direction.length() > 0.1:
		if is_moving:
			if direction.y < 0:  # Moving up
				sprite.play("walk_n")
			else:  # Moving down
				sprite.play("walk_s")
		else:
			sprite.play("idle")

func switch_direction():
	moving_up = !moving_up
	if moving_up:
		target_position = start_position + Vector2(0, -move_distance)
	else:
		target_position = start_position + Vector2(0, move_distance)

func stop_walking():
	if is_moving:
		is_moving = false
		sprite.play("idle")
		timer.start(randf_range(min_stop_time, max_stop_time))

func resume_walking():
	if not is_moving:
		is_moving = true
		# Resume with correct walk animation
		var direction = (target_position - position).normalized()
		update_facing_direction(direction)
	

func receive_love_letter():
	print("NPC Nurse: Received love letter!")
	has_received_letter = true
	stop_walking()
	sprite.play("happy")
	# Start emotional reaction sequence
	timer.start(2.0) # Wait 2 seconds before reacting

func _on_timer_timeout():
	if has_received_letter and not is_leaving:
		start_emotional_exit()
	elif is_leaving:
		queue_free() # Nurse disappears after leaving
	else:
		# Original timer behavior
		if is_distracted or has_received_letter:
			is_distracted = false
			has_received_letter = false
			sprite.play("idle")
			timer.start(randf_range(1.0, 2.0))
		else:
			resume_walking()


func start_emotional_exit():
	print("Nurse: Starting emotional exit!")
	is_leaving = true
	sprite.play("walk_s") # Play walking animation
	
	# Calculate exit position (adjust based on your level layout)
	exit_target = global_position + Vector2(0, 300) # Moving down
	drop_keycard()
	
	# Start moving
	set_physics_process(true)

func drop_keycard():
	print("Nurse: Dropping keycard!")
	var keycard = keycard_scene.instantiate()
	keycard.position = global_position + Vector2(20, 20) # Offset from nurse
	get_parent().add_child(keycard)

func react_to_distraction():
	print("NPC Nurse: Reacting to distraction!")
	is_distracted = true
	stop_walking()
	sprite.play("surprised")
	timer.start(5.0)
