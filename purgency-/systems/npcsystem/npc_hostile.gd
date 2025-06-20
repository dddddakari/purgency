extends NPCBase

# Movement
@export var speed: float = 150
@export var min_follow_distance: float = 30  # Stops this close to player

func _ready():
	# Find player by group (make sure your player is in "player" group)
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		print("Enemy found player: ", player_ref.name)
	else:
		print("Enemy failed to find player")
		set_physics_process(false)  # Disable if no player

func _physics_process(delta):
	if !player_ref or !player_ref.can_move:  # Don't follow if player is dead
		velocity = Vector2.ZERO
		return
	
	var direction = (player_ref.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player_ref.global_position)
	
	# Only move if player is beyond minimum distance
	if distance_to_player > min_follow_distance:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	
	# Face the player (optional visual)
	if direction.x != 0:
		$Sprite2D.flip_h = direction.x < 0
