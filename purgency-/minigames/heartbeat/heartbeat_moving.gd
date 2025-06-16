extends Area2D

var speed = 5
var velocity = Vector2()


func _ready() -> void:
	velocity = Vector2(-speed, 0)
	
func _process(delta):
	translate(velocity)
