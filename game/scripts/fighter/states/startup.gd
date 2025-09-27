extends LimboState

var frames: int = 0
var move_data: MoveData = null

func _enter():
	move_data = blackboard.get_var(&"move_data")
	frames = move_data.startup
	agent.sprite.play(move_data.animation_name)

func _update(delta: float) -> void:
	if frames > 0:
		frames -= 1
		return
	dispatch(EVENT_FINISHED)
