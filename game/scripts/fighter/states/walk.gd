extends FighterState

func enter():
	fighter.sprite.play("walk")

func update(delta: float):
	var direction = fighter.get_input_direction()
	
	if abs(direction.x) < 0.1:
		fighter.state_machine.change_state("idle")
	elif not fighter.is_on_floor():
		fighter.state_machine.change_state("fall")

func physics_update(delta: float):
	var direction = fighter.get_input_direction()
	if fighter.is_on_floor():
		fighter.velocity.x = direction.x * Fighter.WALK_SPEED
	else:
		fighter.velocity.y += Fighter.GRAVITY * delta
