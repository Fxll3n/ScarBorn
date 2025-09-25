extends LimboState

func _enter() -> void:
	agent.hitbox.disable()
	agent.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
	agent.action_frame = 0
	agent.sprite.play("stun")

func _update(delta: float) -> void:
	if agent.action_frame >= agent.stun_duration:
		get_root().dispatch(EVENT_FINISHED)
	else:
		agent.action_frame += 1
	
	if not agent.is_on_floor():
		agent.velocity.y = move_toward(agent.velocity.y, agent.gravity, agent.gravity * delta)
	agent.velocity.x = move_toward(agent.velocity.x, 0, agent.friction * delta)

func _exit() -> void:
	agent.action_frame = 0
	agent.stun_duration = 0
