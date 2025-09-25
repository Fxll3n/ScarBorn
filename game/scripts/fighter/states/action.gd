extends LimboState

enum ACTION_PHASE { STARTUP, ACTIVE, RECOVERY }


var current_phase: ACTION_PHASE = ACTION_PHASE.STARTUP


func enter():
	current_phase = ACTION_PHASE.STARTUP
	agent.sprite.play(agent.current_move.animation_name)
	agent.action_frame = 0
	_setup_hitbox()

func update(delta: float):
	agent.action_frame += 1
	_update_phase()

func physics_update(delta: float):
	agent.velocity.x = move_toward(agent.velocity.x, 0, 300 * delta)
	if not agent.is_on_floor():
		agent.velocity.y += agent.GRAVITY * delta

func exit():
	agent.hitbox.disable()
	agent.hitbox.setup(Vector2.ZERO, Vector2.ZERO)
	agent.current_move = null
	agent.action_frame = 0

func _update_phase():
	var move = agent.current_move
	
	match current_phase:
		ACTION_PHASE.STARTUP:
			if agent.action_frame >= move.startup:
				current_phase = ACTION_PHASE.ACTIVE
				agent.hitbox.disable()
		ACTION_PHASE.ACTIVE:
			if agent.action_frame >= move.startup + move.active:
				current_phase = ACTION_PHASE.RECOVERY
				agent.hitbox.enable(move.damage, move.stun, move.knockback_direction)
		ACTION_PHASE.RECOVERY:
			if agent.action_frame >= move.startup + move.active + move.recovery:
				get_root().dispatch(EVENT_FINISHED)
				agent.hitbox.disable()

func _setup_hitbox():
	var move = agent.current_move
	var pos = move.hitbox_data.position
	var knockback = move.knockback_direction
	var flipped_pos = Vector2(-pos.x if not agent.facing_right else pos.x, pos.y)
	var fliped_knockback = Vector2(-knockback.x if agent.facing_right else knockback.x, knockback.y)
	
	agent.hitbox.setup(flipped_pos, move.hitbox_data.size)
	agent.hitbox.enable(move.damage, move.stun, fliped_knockback)
