extends FighterState

func enter() -> void:
	fighter.hitbox.disable()
	fighter.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
	fighter.action_frame = 0
	fighter.sprite.play("stun")

func update(delta: float) -> void:
	if fighter.action_frame >= fighter.stun_duration:
		transition_to("idle")
	else:
		fighter.action_frame += 1

func physics_update(delta: float) -> void:
	if not fighter.is_on_floor():
		fighter.velocity.y = move_toward(fighter.velocity.y, Fighter.GRAVITY, Fighter.GRAVITY * delta)
	fighter.velocity.x = move_toward(fighter.velocity.x, 0, Fighter.FRICTION * delta)

func exit() -> void:
	fighter.action_frame = 0
	fighter.stun_duration = 0
