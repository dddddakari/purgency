# player.gd
extends CharacterBody2D

# Movement constants and variables
const SPEED = 200  # Movement speed
var current_dir = "none"  # Current facing direction
var can_move = true  # Movement enabled flag

func _ready():
	# Initialize animation and add to player group
	$Sprite2D.play("default")
	add_to_group("player")

func set_movement_enabled(enabled: bool) -> void:
	# Enable/disable player movement
	can_move = enabled
	print("set_movement_enabled called with:", enabled)
	if not enabled:
		velocity = Vector2.ZERO
		move_and_slide()

func _physics_process(delta):
	# Handle physics-based movement
	player_movement(delta)

func player_movement(delta):
	# Skip movement if disabled
	if not can_move:
		return

	# Handle input for movement
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
	else: 
		# Idle state
		play_anim(0)
		velocity = Vector2.ZERO
	
	move_and_slide()

func play_anim(movement):
	# Handle animation based on movement state
	var dir = current_dir
	var anim = $Sprite2D
	
	if dir == "right":
		anim.flip_h = true
		anim.play("walking_left" if movement else "to_the_side")
	elif dir == "left":
		anim.flip_h = false
		anim.play("walking_left" if movement else "to_the_side")
	elif dir == "up":
		anim.flip_h = false
		anim.play("walking_back" if movement else "back_idle")
	elif dir == "down":
		anim.flip_h = false
		anim.play("walking" if movement else "default")
