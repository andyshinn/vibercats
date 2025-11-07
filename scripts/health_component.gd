extends Node

class_name HealthComponent

## Reusable health component for entities
## Can be attached to any node that needs health

@export var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(current: float, maximum: float)
signal died()

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: float):
	current_health -= amount
	current_health = max(0, current_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()

func heal(amount: float):
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	return current_health > 0

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0
