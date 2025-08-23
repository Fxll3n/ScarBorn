@abstract
class_name Entity
extends CharacterBody2D

signal died()

var current_health: float = 0
var max_health: float = 0

func damage(damage_amount: float) -> void:
	current_health -= damage_amount
	if current_health <= 0:
		died.emit()
	return

func heal(heal_amount: float) -> void:
	current_health += heal_amount

func set_health(new_health: float) -> void:
	current_health = new_health
