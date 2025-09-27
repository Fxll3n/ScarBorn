extends LimboState

var frames: int = 0
var move_data: MoveData = null

func _enter():
	move_data = blackboard.get_var(&"move_data")
	frames = move_data.recovery
	agent.hitbox.disable()

func _update(delta: float) -> void:
	if frames > 0:
		frames -= 1
		return
	get_root().dispatch(EVENT_FINISHED)

func _exit() -> void:
	agent.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
