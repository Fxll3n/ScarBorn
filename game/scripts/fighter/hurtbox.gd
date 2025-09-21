class_name HurtBox
extends Area2D

signal hit(damage: int, stun: int, knockback: Vector2)
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
static var visible_collisions: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	add_to_group("hurtboxes")

func _draw() -> void:
	if not visible_collisions or not collision_shape or not collision_shape.shape:
		return
	
	var shape_size = collision_shape.shape.size
	var shape_position = collision_shape.position - shape_size / 2
	draw_rect(Rect2(shape_position, shape_size), Color(0, 0, 1, 0.41), true)

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		if not area.enabled:
			return
		if area.owner == self.owner: 
			return
		hit.emit(area.damage, area.stun, area.knockback_velocity)
