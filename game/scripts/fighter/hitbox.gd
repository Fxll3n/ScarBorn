class_name HitBox
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
static var visible_collisions: bool = false
var enabled: bool = false
var damage: int = 0
var stun: int = 0
var knockback_velocity: Vector2 = Vector2.ZERO


func _draw() -> void:
	if not visible_collisions or not collision_shape or not collision_shape.shape:
		return
	
	var shape_size = collision_shape.shape.size
	var shape_position = collision_shape.position - shape_size / 2
	draw_rect(Rect2(shape_position, shape_size), Color(1, 0, 0, 0.41), true)

func setup(pos: Vector2, size: Vector2):
	position = pos
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = size
	queue_redraw()

func enable(dmg: int, stun_frames: int, knockback: Vector2):
	enabled = true
	damage = dmg
	stun = stun_frames
	knockback_velocity = knockback
	queue_redraw()

func disable():
	enabled = false
	damage = 0
	stun = 0
	knockback_velocity = Vector2.ZERO
	queue_redraw()

func _ready():
	add_to_group("hitboxes")
