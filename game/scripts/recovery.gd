extends LimboState

var frames: int = 0

func _enter():
	frames = blackboard.get_var(&"recovery_frames", 0)
	agent.hitbox.disable()

func _update(delta: float) -> void:
	if frames > 0:
		frames -= 1
		return
	get_root().dispatch(EVENT_FINISHED)

func _exit() -> void:
	agent.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
