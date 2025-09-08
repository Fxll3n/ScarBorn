extends FighterState

var direction: Vector2 = Vector2.ZERO

func enter() -> void:
	fighter.velocity.y = Fighter.JUMP_VELOCITY
	direction = fighter.get_input_direction()

func update(delta: float) -> void:
	direction = fighter.get_input_direction()
	
	if fighter.is_on_floor():
		transition_to("idle")
	elif fighter.velocity.y > 0:
		transition_to("fall")
		

func physics_update(delta: float):
	if direction.x != 0:
		fighter.velocity.x = move_toward(fighter.velocity.x, Fighter.WALK_SPEED * direction.x, Fighter.WALK_SPEED * delta)
	else:
		fighter.velocity.x = move_toward(fighter.velocity.x, 0, Fighter.WALK_SPEED * delta)
	
	fighter.velocity.y = move_toward(fighter.velocity.y, Fighter.GRAVITY, Fighter.GRAVITY * delta)
