extends LimboState

var frames: int = 0
var move_data: MoveData = null

func _enter():
	move_data = blackboard.get_var(&"move_data")
	frames = move_data.active
	_setup_hitbox()

func _update(delta: float) -> void:
	if frames > 0:
		frames -= 1
		return
	dispatch(EVENT_FINISHED)
	

func _setup_hitbox() -> void:
	var pos = move_data.hitbox_data.position
	var knockback = move_data.knockback_direction
	var flipped_pos = Vector2(-pos.x if not agent.facing_right else pos.x, pos.y)
	var fliped_knockback = Vector2(-knockback.x if agent.facing_right else knockback.x, knockback.y)
	
	agent.hitbox.setup(flipped_pos, move_data.hitbox_data.size)
	agent.hitbox.enable(move_data.damage, move_data.stun, fliped_knockback)
