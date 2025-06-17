extends CharacterBody2D
class_name NPCNurse

# Movement settings
@export var circle_radius: float = 100.0
@export var walk_speed: float = 50.0
@export var center_position: Vector2 = Vector2.ZERO
@export var min_stop_time: float = 0.2
@export var max_stop_time: float = 1.0
@export var stop_chance: float = 0.01  # 1% chance per frame

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var angle: float = 0.0
var is_moving: bool = true
var current_walk_speed: float = 0.0

func _ready():
	# Set center position to current position if not specified
	if center_position == Vector2.ZERO:
		center_position = position
	
	# Setup animations
	sprite.play("idle")  # Start with generic idle
	current_walk_speed = walk_speed
	
	# Setup timer
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if is_moving:
		# Update angle based on speed
		angle += current_walk_speed * delta / circle_radius
		
		# Calculate circular position
		var target_position = center_position + Vector2(
			sin(angle) * circle_radius,
			cos(angle) * circle_radius
		)
		
		# Move toward the target position
		velocity = (target_position - position).normalized() * current_walk_speed
		move_and_slide()
		
		# Update facing direction
		update_facing_direction(velocity.normalized())
		
		# Random chance to stop
		if randf() < stop_chance * delta * 60:  # Normalized to per-second chance
			stop_walking()
	else:
		# Stand still
		velocity = Vector2.ZERO

func update_facing_direction(direction: Vector2):
	if direction.length() > 0.1:
		if is_moving:
			# Only use directional animations when walking
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					sprite.play("walk_e")
					sprite.flip_h = false
				else:
					sprite.play("walk_w")
					sprite.flip_h = true
			else:
				if direction.y > 0:
					sprite.play("walk_s")
				else:
					sprite.play("walk_n")
		else:
			# Use generic idle when stopped
			sprite.play("idle")

func stop_walking():
	if is_moving:
		is_moving = false
		sprite.play("idle")  # Switch to generic idle
		timer.start(randf_range(min_stop_time, max_stop_time))

func resume_walking():
	if not is_moving:
		is_moving = true
		# Resume with appropriate walk animation based on direction
		var direction = Vector2(sin(angle), cos(angle)).normalized()
		update_facing_direction(direction)
		current_walk_speed = walk_speed

func _on_timer_timeout():
	resume_walking()
