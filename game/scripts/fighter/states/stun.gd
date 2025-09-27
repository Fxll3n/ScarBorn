extends LimboState

func _enter() -> void:
	agent.gravity_on = true
	agent.hitbox.disable()
	agent.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
	agent.sprite.play("stun")

func _update(delta: float) -> void:
	if agent.stun_frames > 0:
		print(agent.stun_frames)
		agent.stun_frames -= 1
	else:
		get_root().dispatch(EVENT_FINISHED)
	
	agent.velocity.x = move_toward(agent.velocity.x, 0, agent.friction * delta)

func _exit() -> void:
	agent.stun_frames = 0
