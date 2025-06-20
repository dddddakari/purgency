extends CharacterBody2D

# Movement constants and variables
const SPEED = 200
var current_dir = "none"
var can_move = true

# Combat variables
var is_attacking: bool = false
var attack_cooldown: float = 0.5
var attack_range: float = 60.0
var attack_damage: int = 15
var can_attack: bool = true

@onready var health_component: HealthComponent = $HealthComponent

func _ready():
	add_to_group("player")  # ← Add this line!
	print("Player group membership after adding:", is_in_group("player"))
	# ... rest of your existing code ...

func _on_interaction_area_body_entered(body):
	print("Player entered area:", body.name)
	if body.has_method("_on_interaction_area_body_entered"):
		print("Body has interaction handler")

func _on_interaction_area_body_exited(body):
	print("Player exited area:", body.name)
	

func _physics_process(delta):
	player_movement(delta)
	handle_attack_input()

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

func handle_attack_input():
	if Input.is_action_just_pressed("attack") and can_attack and not is_attacking:
		perform_attack()


func perform_attack():
	print("Player attacking at position: ", global_position) # DEBUG
	can_attack = false
	is_attacking = true
	
	# Play attack animation
	play_anim(2)
	
	# Detect enemies in range
	var space_state = get_world_2d().direct_space_state
	if space_state:
		print("Checking for enemies in attack range...") # DEBUG
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = CircleShape2D.new()
		query.shape.radius = attack_range
		query.transform = Transform2D(0, global_position)
		query.collision_mask = 2
		
		var results = space_state.intersect_shape(query)
		print("Found ", results.size(), " potential targets") # DEBUG
		for result in results:
			if result.collider.has_method("take_damage"):
				print("Hit enemy: ", result.collider.name) # DEBUG
				result.collider.health_component.take_damage(attack_damage)

func _on_attack_cooldown_end():
	can_attack = true
	is_attacking = false

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

func _on_health_changed(old_value: int, new_value: int):
	print("Player health: ", new_value)

func _on_player_death():
	# Handle player death (game over, respawn, etc.)
	print("Player died!")
	can_move = false
	$Sprite2D.play("death")  # If you have a "death" animation
	await $Sprite2D.animation_finished
	# Game Over logic
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")  # Or show UI instead
	queue_free()
