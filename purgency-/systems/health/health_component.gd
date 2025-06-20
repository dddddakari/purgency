extends Node
class_name HealthComponent

signal health_changed(old_value: int, new_value: int)
signal health_depleted
signal damage_taken(amount: int)
signal health_restored(amount: int)

@export var max_health: int = 100
@export var invulnerable: bool = false

var current_health: int:
	set(value):
		var old_health = current_health
		current_health = clamp(value, 0, max_health)
		print("Health changed from ", old_health, " to ", current_health) # DEBUG
		health_changed.emit(old_health, current_health)
		
		if old_health > current_health:
			print("Damage taken: ", old_health - current_health) # DEBUG
			damage_taken.emit(old_health - current_health)
		elif old_health < current_health:
			print("Health restored: ", current_health - old_health) # DEBUG
			health_restored.emit(current_health - old_health)
		
		if current_health <= 0:
			print("Health depleted!") # DEBUG
			health_depleted.emit()

func _ready():
	print("HealthComponent ready - Max health: ", max_health) # DEBUG
	current_health = max_health

func take_damage(amount: int) -> void:
	if invulnerable or current_health <= 0:
		print("Damage blocked - invulnerable or dead") # DEBUG
		return
	print("Taking damage: ", amount) # DEBUG
	current_health -= amount

# ... rest of the file remains the same ...
