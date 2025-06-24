extends Area2D

var speed = 5
var velocity = Vector2()
var screen_size

func _ready() -> void:
	velocity = Vector2(-speed, 0)
	screen_size = get_viewport_rect().size

func _process(delta):
	translate(velocity)

	# Wrap around to the right when off-screen on the left
	if position.x < -50:
		position.x = screen_size.x + 50
