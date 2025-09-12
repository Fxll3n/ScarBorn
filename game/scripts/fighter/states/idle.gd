extends FighterState

func enter():
	fighter.sprite.play("idle")

func update(delta: float):
	var direction = fighter.get_input_direction()
	
	if abs(direction.x) > 0.1:
		fighter.state_machine.change_state("walk")
	elif not fighter.is_on_floor():
		fighter.state_machine.change_state("fall")

func physics_update(delta: float):
	if fighter.is_on_floor():
		fighter.velocity.x = move_toward(fighter.velocity.x, 0, Fighter.FRICTION * delta)
	else:
		fighter.velocity.y += Fighter.GRAVITY * delta
