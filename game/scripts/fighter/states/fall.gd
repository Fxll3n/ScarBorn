extends LimboState

@onready var direction: Vector2 = Vector2.ZERO

func _enter() -> void:
	direction = agent.get_input_direction()
	agent.sprite.play("fall")

func _update(delta: float) -> void:
	direction = agent.get_input_direction()
	
	if agent.is_on_floor():
		get_root().dispatch(EVENT_FINISHED)
	
	if direction.x != 0:
		agent.velocity.x = move_toward(agent.velocity.x, agent.walk_speed * direction.x, agent.walk_speed * delta)
	else:
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.walk_speed * delta)
	
	agent.velocity.y = move_toward(agent.velocity.y, agent.gravity, agent.gravity * delta)
