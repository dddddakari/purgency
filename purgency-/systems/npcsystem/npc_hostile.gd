extends NPCBase
class_name NPC_Hostilea

@export var follow_distance: float = 50.0
@export var follow_speed: float = 80.0

func _ready():
	move_speed = follow_speed
	set_physics_process(true)
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, follow_distance, Color(1, 0, 0, 0.3))

# Start following when player enters interaction area
func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		print("InteractionArea hit by:", body.name)
		player_ref = body
		current_state = State.FOLLOW

func _on_interaction_area_body_exited(body):
	if body == player_ref:
		print("Player left interaction area:", body.name)
		player_ref = null
		current_state = State.IDLE

		
func handle_state(delta):
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO

		State.FOLLOW:
			if player_ref:
				var to_player = player_ref.global_position - global_position
				var distance = to_player.length()

				if distance > follow_distance:
					var direction = to_player.normalized()
					velocity = direction * move_speed
				else:
					velocity = Vector2.ZERO
