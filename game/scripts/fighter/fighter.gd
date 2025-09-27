class_name Fighter
extends CharacterBody2D

signal died
signal health_changed(new_health: int)
signal money_changed(new_amount: int)
signal inventory_changed(new_inventory: Array[Item])
signal used_item(slot: int, cooldown: float)

const HIT_SOUNDS = [
	preload("res://assets/audio/2AH.wav"),
	preload("res://assets/audio/2BH.wav"),
	preload("res://assets/audio/2CH.wav"),
	preload("res://assets/audio/2DH.wav"),
	preload("res://assets/audio/2EH.wav")
]

@export_category("Info")
@export var id: int = 0
@export_range(0, 300, 1, "suffix:hp") var max_health: int = 100
@export_range(0, 2, 1, "suffix:jumps") var max_jumps: int = 0
@export var inventory: Array[Item] = []
@export_category("Constants")
@export var friction: float = 400
@export var walk_speed: float = 200
@export var jump_velocity: float = -400

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var state_label: Label = $StateLabel
@onready var vel_dir: RayCast2D = $VelDir
@onready var hitbox: HitBox = $Hitbox
@onready var hurtbox: HurtBox = $Hurtbox

@onready var hsm: LimboHSM = $LimboHSM
@onready var stun_state: LimboState = $LimboHSM/Stun
@onready var idle_state: LimboState = $LimboHSM/Idle
@onready var walk_state: LimboState = $LimboHSM/Walk
@onready var jump_state: LimboState = $LimboHSM/Jump
@onready var fall_state: LimboState = $LimboHSM/Fall

@onready var action_hsm: LimboHSM = $LimboHSM/Action
@onready var startup_phase: LimboState = $LimboHSM/Action/Startup
@onready var active_phase: LimboState = $LimboHSM/Action/Active
@onready var recovery_phase: LimboState = $LimboHSM/Action/Recovery

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


var input_direction: Vector2 = Vector2.ZERO
var current_move: MoveData = null

var current_health: int = max_health
var money: int = 0
var jumps_count: int = 0
var i_frames: int = 0
var stun_frames: int = 0
var lose_streak: int = 0
var win_streak: int = 0
var paused: bool = false
var is_ready: bool = false
var facing_right: bool = true
var gravity_on: bool = true

func _ready() -> void:
	_initilize_hsm()
	_connect_signals()

func _process(delta: float) -> void:
	_update_facing()
	if hsm.get_active_state() == null:
		return
	state_label.text = hsm.get_active_state().name

func _physics_process(delta: float) -> void:
	if not gravity_on:
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, gravity, gravity * delta)
	
	move_and_slide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("p%s_a" % id):
		print("p%s_a" % id)
		use_move(0)
	elif event.is_action_pressed("p%s_b" % id):
		use_move(1)
	elif event.is_action_pressed("p%s_c" % id):
		use_move(2)

func damage(dmg_amount: int) -> void:
	current_health -= dmg_amount
	current_health = clampi(current_health, 0, max_health)
	
	health_changed.emit(current_health)
	
	if current_health <= 0:
		died.emit()

func apply_stun(frames: int) -> void:
	stun_frames += max(0, frames)
	hsm.change_active_state(stun_state)

func apply_knockback(knockback_direction: Vector2) -> void:
	velocity = knockback_direction

func heal(heal_amount: int) -> void:
	current_health += heal_amount
	current_health = clampi(current_health, 0, max_health)
	
	health_changed.emit(current_health)

func increase_money(amount: int) -> void:
	money += amount
	money = clampi(money, 0, 999)
	money_changed.emit(money)

func decrease_money(amount: int) -> void:
	money -= amount
	money = clampi(money, 0, 999)
	money_changed.emit(money)

func get_input_direction() -> Vector2:
	if id < 1 or id > 2 or paused:
		return Vector2.ZERO
	var dir = Input.get_vector("p%s_left" % id, "p%s_right" % id, "p%s_up" % id, "p%s_down" % id)
	vel_dir.target_position = dir * 100
	return dir

func use_move(item_id: int) -> MoveData:
	if inventory.is_empty():
		print("[Fighter:%s] Inventory is empty." % [id])
		return null
	
	if inventory.size() <= item_id:
		print("[Fighter:%s] Inventory doesn't contain an index of `%s`" % [id, item_id])
		return
	
	var item: Item = inventory.get(item_id)
	
	if item == null:
		print("[Fighter%s] No Item resource at id `%s`" % [id, item_id])
		return null
	
	var code: String = _get_move_code()
	var move: MoveData = item.variants.get(code) as MoveData
	
	if move == null:
		print("[Fighter%s] No MoveData found for key `%s`" % [id, code])
		return null
	
	current_move = move
	hsm.change_active_state(action_hsm)
	
	used_item.emit(item_id, int(move.get_total_frames()/60.0))
	return move

func add_item(item: Item) -> void:
	if item == null:
		print("[Fighter%s] Cannot add item to inventory, item was null." % id)
		return
	
	inventory.insert(0, item)
	inventory_changed.emit(inventory)

func remove_item(item_id: int = 0) -> void:
	if inventory.is_empty():
		print("[Fighter%s] Inventory is empty." % id)
		return
	
	if inventory.size() <= item_id:
		print("[Fighter%s] Inventory does not contain index of `%s`" % [id, item_id])
		return
	
	inventory.remove_at(item_id)
	inventory_changed.emit(inventory)

func _get_move_code() -> String:
	var direction = get_input_direction()
	var ground_suffix = "_ground" if is_on_floor() else "_air"
	
	if direction.y < -0.5:
		return "up_special" + ground_suffix
	elif direction.y > 0.5:
		return "down_special" + ground_suffix
	elif direction.x < -0.5:
		return "left_special" + ground_suffix
	elif direction.x > 0.5:
		return "right_special" + ground_suffix
	else:
		return "neutral" + ground_suffix

func _can_act() -> bool:
	return hsm.get_active_state() != stun_state or hsm.get_active_state() != action_hsm

func _can_jump() -> bool:
	return not jumps_count < max_jumps

func _update_facing() -> void:
	if stun_frames > 0 or hsm.get_active_state() == action_hsm:
		return
	var dir = get_input_direction()
	if abs(dir.x) > 0.1:
		facing_right = dir.x < 0
		sprite.flip_h = not facing_right

func _is_vincible() -> bool:
	return i_frames < 1

func _initilize_hsm() -> void:
	#region Setup
	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(idle_state)
	
	hsm.blackboard.bind_var_to_property("move_data", self, "current_move", true)
	action_hsm.blackboard.link_var("move_data", hsm.blackboard, "move_data", true)
	
	#endregion
	#region Transitions
	# All -> One
	hsm.add_transition(hsm.ANYSTATE, action_hsm, &"action", _can_act)
	hsm.add_transition(hsm.ANYSTATE, stun_state, &"stun", _is_vincible)
	# Stun -> Other
	hsm.add_transition(stun_state, idle_state, stun_state.EVENT_FINISHED)
	# Idle -> Other
	hsm.add_transition(idle_state, walk_state, &"walk")
	hsm.add_transition(idle_state, jump_state, &"jump", _can_jump)
	# Walk -> Other
	hsm.add_transition(walk_state, idle_state, walk_state.EVENT_FINISHED)
	hsm.add_transition(walk_state, jump_state, &"jump", _can_jump)
	hsm.add_transition(walk_state, fall_state, &"fall")
	# Jump -> Other
	hsm.add_transition(jump_state, fall_state, jump_state.EVENT_FINISHED)
	# Fall -> Other
	hsm.add_transition(fall_state, jump_state, &"jump", _can_jump)
	hsm.add_transition(fall_state, idle_state, fall_state.EVENT_FINISHED)
	# Action Phases
	action_hsm.add_transition(startup_phase, active_phase, startup_phase.EVENT_FINISHED)
	action_hsm.add_transition(active_phase, recovery_phase, active_phase.EVENT_FINISHED)
	hsm.add_transition(action_hsm, idle_state, action_hsm.EVENT_FINISHED)
	
	#endregion

func _connect_signals() -> void:
	#region Signal Connections
	hurtbox.hit.connect(_on_hurt)
	#endregion
	inventory_changed.emit(inventory)
func _on_hurt(dmg_amount: int, stun_amount: int, knockback: Vector2):
	damage(dmg_amount)
	apply_stun(stun_amount)
	apply_knockback(knockback)
