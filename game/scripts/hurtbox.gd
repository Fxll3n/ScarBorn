class_name HurtBox
extends Area2D

signal hit(damage: int, stun: int)
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		print("%s found a hitbox!" % self.owner.name)
		if not area.enabled or area.owner == self.owner: 
			print("Hitbox is from owner %s" % area.owner)
			return
		print("%s took %s dmg and %s stun." % [owner, area.damage, area.stun])
		hit.emit(area.damage, area.stun)
