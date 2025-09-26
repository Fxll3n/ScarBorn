extends LimboState

var frames: int = 0
var move_data: MoveData = null

func _enter():
	move_data = blackboard.get_var(&"move")
	frames = move_data.startup
	_setup_hitbox()

func _update(delta: float) -> void:
	if frames > 0:
		frames -= 1
		return
	dispatch(EVENT_FINISHED)


func _setup_hitbox():
	var pos = move_data.hitbox_data.position
	var flipped_pos = Vector2(-pos.x if not agent.facing_right else pos.x, pos.y)
	
	agent.hitbox.setup(flipped_pos, move_data.hitbox_data.size)
