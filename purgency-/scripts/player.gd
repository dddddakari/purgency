extends CharacterBody2D

const SPEED = 200
var current_dir = "none"

func _ready():
	$Sprite2D.play("default")

func _physics_process(_delta):
	player_movement(_delta)
	
func player_movement(_delta):
	
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
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $Sprite2D
	
	if dir == "right":
		anim.flip_h = true
		if movement == 1:
			anim.play("walking_left")
		elif movement == 0:
			anim.play("to_the_side")
	elif dir == "left":
		anim.flip_h = false
		if movement == 1:
			anim.play("walking_left")
		elif movement == 0:
			anim.play("to_the_side")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("walking_back")
		elif movement == 0:
			anim.play("back_idle")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("walking")
		elif movement == 0:
			anim.play("default")
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
