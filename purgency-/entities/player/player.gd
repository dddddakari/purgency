extends CharacterBody2D

# Movement constants and variables
const SPEED = 200
var current_dir = "none"
var can_move = true


func _ready():
	add_to_group("player")  # ← Add this line!
	print("Player group membership after adding:", is_in_group("player"))
	# ... rest of your existing code ...

func set_movement_enabled(body):
	player_movement(true)

func _on_interaction_area_body_entered(body):
	print("Player entered area:", body.name)
	if body.has_method("_on_interaction_area_body_entered"):
		print("Body has interaction handler")

func _on_interaction_area_body_exited(body):
	print("Player exited area:", body.name)
	

func _physics_process(delta):
	player_movement(delta)

func player_movement(delta):
	if not can_move:
		return

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
		play_anim(0)
		velocity = Vector2.ZERO
	
	move_and_slide()


func play_anim(movement):
	var dir = current_dir
	var anim = $Sprite2D
		
	if dir == "right":
		anim.flip_h = true
		anim.play("walking_left" if movement == 1 else "to_the_side")
	elif dir == "left":
		anim.flip_h = false
		anim.play("walking_left" if movement == 1 else "to_the_side")
	elif dir == "up":
		anim.flip_h = false
		anim.play("walking_back" if movement == 1 else "back_idle")
	elif dir == "down":
		anim.flip_h = false
		anim.play("walking" if movement == 1 else "default")
