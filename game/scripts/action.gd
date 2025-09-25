extends LimboHSM

@onready var sprite: AnimatedSprite2D = blackboard.get_var(&"sprite")

func _enter() -> void:
	sprite.play()
