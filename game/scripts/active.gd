extends LimboState

var frames: int = 0
var damage: int = 0
var stun: int = 0
var knockback: Vector2 = Vector2.ZERO

func _enter():
	frames = blackboard.get_var(&"active_frames", 0)
	damage = blackboard.get_var(&"damage", 0)
	stun = blackboard.get_var(&"stun", 0)
	knockback = blackboard.get_var(&"knockback", Vector2.ZERO)
	agent.hitbox.enable(damage, stun, Vector2(-knockback.x if agent.facing_right else knockback.x, knockback.y))

func _update(delta: float) -> void:
	if frames > 0:
		frames -= 1
		return
	dispatch(EVENT_FINISHED)
	
