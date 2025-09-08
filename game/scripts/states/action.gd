extends FighterState

enum Phase { STARTUP, ACTIVE, RECOVERY }
var current_phase: Phase = Phase.STARTUP

func enter():
	current_phase = Phase.STARTUP
	fighter.sprite.play(fighter.current_move.animation_name)
	fighter.action_frame = 0
	_setup_hitbox()

func update(delta: float):
	fighter.action_frame += 1
	_update_phase()

func physics_update(delta: float):
	fighter.velocity.x = move_toward(fighter.velocity.x, 0, 300 * delta)
	if not fighter.is_on_floor():
		fighter.velocity.y += Fighter.GRAVITY * delta

func exit():
	fighter.hitbox.disable()
	fighter.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
	fighter.current_move = null
	fighter.action_frame = 0

func _update_phase():
	var move = fighter.current_move
	
	match current_phase:
		Phase.STARTUP:
			if fighter.action_frame >= move.startup:
				current_phase = Phase.ACTIVE
				fighter.hitbox.enable(move.damage, move.stun)
		Phase.ACTIVE:
			if fighter.action_frame >= move.startup + move.active:
				current_phase = Phase.RECOVERY
				fighter.hitbox.disable()
		Phase.RECOVERY:
			if fighter.action_frame >= move.startup + move.active + move.recovery:
				fighter.state_machine.change_state("idle")

func _setup_hitbox():
	var move = fighter.current_move
	var pos = move.hitbox_data.position
	var flipped_pos = Vector2(-pos.x if not fighter.facing_right else pos.x, pos.y)
	
	fighter.hitbox.setup(flipped_pos, move.hitbox_data.size)
	fighter.hitbox.enable(move.damage, move.stun)
