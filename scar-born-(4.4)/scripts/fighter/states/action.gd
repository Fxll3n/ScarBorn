extends FighterState

enum ACTION_PHASE { STARTUP, ACTIVE, RECOVERY }
var current_phase: ACTION_PHASE = ACTION_PHASE.STARTUP

func enter():
	current_phase = ACTION_PHASE.STARTUP
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
		ACTION_PHASE.STARTUP:
			if fighter.action_frame >= move.startup:
				current_phase = ACTION_PHASE.ACTIVE
				fighter.hitbox.enable(move.damage, move.stun)
		ACTION_PHASE.ACTIVE:
			if fighter.action_frame >= move.startup + move.active:
				current_phase = ACTION_PHASE.RECOVERY
				fighter.hitbox.disable()
		ACTION_PHASE.RECOVERY:
			if fighter.action_frame >= move.startup + move.active + move.recovery:
				transition_to("idle")

func _setup_hitbox():
	var move = fighter.current_move
	var pos = move.hitbox_data.position
	var flipped_pos = Vector2(-pos.x if not fighter.facing_right else pos.x, pos.y)
	
	fighter.hitbox.setup(flipped_pos, move.hitbox_data.size)
	fighter.hitbox.enable(move.damage, move.stun)
