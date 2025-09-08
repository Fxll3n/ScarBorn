class_name HitBox
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var enabled: bool = false
var damage: int = 0
var stun: int = 0

func setup(pos: Vector2, size: Vector2):
	position = pos
	collision_shape.shape.size = size

func enable(dmg: int, stun_frames: int):
	enabled = true
	damage = dmg
	stun = stun_frames

func disable():
	enabled = false
	damage = 0
	stun = 0
