extends Node2D

@onready var heartbeat_moving: Area2D = $HeartbeatMoving


var loop_amount := 10

func_ loop():
	$Heart
