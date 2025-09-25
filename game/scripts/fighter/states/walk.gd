extends LimboState

func _enter():
	agent.sprite.play("walk")

func _update(delta: float):
	var direction = agent.get_input_direction()
	
	if direction.x == 0:
		dispatch(EVENT_FINISHED)
	elif not agent.is_on_floor():
		dispatch(&"fall")
	elif Input.is_action_just_pressed("p%s_jump" % agent.id):
		dispatch(&"jump")
	
	agent.velocity.x = direction.x * agent.walk_speed
