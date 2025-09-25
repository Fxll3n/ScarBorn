extends LimboState

func _enter():
	agent.jumps_count = 0
	agent.sprite.play("idle")

func _update(delta: float) -> void:
	var direction = agent.get_input_direction()
	
	if direction.x != 0:
		dispatch("walk")
	elif Input.is_action_just_pressed("p%s_jump" % agent.id):
		dispatch(&"jump")
		
	if agent.is_on_floor():
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.friction * delta)
	else:
		agent.velocity.y += agent.gravity * delta
