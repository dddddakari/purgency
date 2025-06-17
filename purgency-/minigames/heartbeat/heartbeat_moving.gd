#reference: https://www.youtube.com/watch?v=rd4qApLPg1Y

extends Area2D

var speed = 5
var velocity = Vector2()


func _ready() -> void:
	velocity = Vector2(-speed, 0)
	
func _process(delta):
	translate(velocity)
