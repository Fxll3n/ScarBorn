class_name MoveData
extends Resource

@export var animation_name: StringName
@export_range(0, 60, 1, "suffix:frames") var startup: int = 0
@export_range(0, 60, 1, "suffix:frames") var active: int = 0
@export_range(0, 60, 1, "suffix:frames") var recovery: int = 0
@export_range(0, 60, 1, "suffix:frames") var stun: int = 0
@export_range(0, 100, 1, "suffix:dmg") var damage: int = 0
@export var hitbox_data: Rect2
@export var knockback_direction: Vector2

func get_total_frames() -> int:
	return startup + active + recovery
