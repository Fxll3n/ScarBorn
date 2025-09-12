extends FighterState

@onready var direction: Vector2 = Vector2.ZERO

func enter() -> void:
	direction = fighter.get_input_direction()
	fighter.sprite.play("fall")

func update(delta: float) -> void:
	direction = fighter.get_input_direction()
	
	if fighter.is_on_floor():
		transition_to("idle")

func physics_update(delta: float) -> void:
	if direction.x != 0:
		fighter.velocity.x = move_toward(fighter.velocity.x, Fighter.WALK_SPEED * direction.x, Fighter.WALK_SPEED * delta)
	else:
		fighter.velocity.x = move_toward(fighter.velocity.x, 0, Fighter.WALK_SPEED * delta)
	
	fighter.velocity.y = move_toward(fighter.velocity.y, Fighter.GRAVITY, Fighter.GRAVITY * delta)
