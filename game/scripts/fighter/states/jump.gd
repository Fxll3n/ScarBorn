extends LimboState

var direction: Vector2 = Vector2.ZERO

func _enter() -> void:
	agent.gravity_on = true
	SoundManager.play_sound(preload("res://assets/audio/3CH.wav"))
	agent.velocity.y = agent.jump_velocity
	agent.jumps_count += 1
	direction = agent.get_input_direction()

func _update(delta: float) -> void:
	direction = agent.get_input_direction()
	
	if agent.is_on_floor() or agent.velocity.y > 0:
		dispatch(EVENT_FINISHED)
	elif Input.is_action_just_pressed("p%s_jump" % agent.id) and agent._can_jump():
		dispatch(&"jump")
	
	if direction.x != 0:
		agent.velocity.x = move_toward(agent.velocity.x, agent.walk_speed * direction.x, agent.walk_speed * delta)
	else:
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.walk_speed * delta)
