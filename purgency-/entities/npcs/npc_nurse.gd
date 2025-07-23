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

var start_position: Vector2
var target_position: Vector2
var is_moving: bool = true
var moving_up: bool = true  # Start by moving up

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
	
	
var is_distracted: bool = false
var has_received_letter: bool = false

func receive_love_letter():
	if QuestManager.has_quest_item("love_letter"):
		has_received_letter = true
		stop_walking()
		# Play happy animation
		sprite.play("happy")
		# Remove the letter from inventory
		QuestManager.remove_quest_item("love_letter")
		# Nurse stays still for a while
		timer.start(5.0)

func react_to_distraction():
	is_distracted = true
	stop_walking()
	# Play surprised animation
	sprite.play("surprised")
	# Nurse stays still for a while
	timer.start(5.0)

func _on_timer_timeout():
	if is_distracted or has_received_letter:
		# Reset after distraction/letter
		is_distracted = false
		has_received_letter = false
		sprite.play("idle")
		timer.start(randf_range(1.0, 2.0))  # Short delay before resuming
	else:
		resume_walking()
