class_name Fighter
extends CharacterBody2D

signal died
signal health_changed(new_health: int)
signal money_changed(old_amount: int, new_amount: int)
signal inventory_changed(new_inventory: Array[Item])

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

func _ready() -> void:
	_initilize_hsm()

func _process(delta: float) -> void:
	if hsm.get_active_state() == null:
		return
	state_label.text = hsm.get_active_state().name

func _physics_process(delta: float) -> void:
	move_and_slide()

func _initilize_hsm() -> void:
	#region Setup
	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(idle_state)
	
	hsm.blackboard.bind_var_to_property("current_move", self, "current_move", true)
	hsm.blackboard.bind_var_to_property("inventory", self, "inventory", true)
	hsm.blackboard.bind_var_to_property("hitbox", self, "hitbox", true)
	hsm.blackboard.bind_var_to_property("hurtbox", self, "hurtbox", true)
	hsm.blackboard.bind_var_to_property("sprite", self, "sprite", true)
	
	#endregion
	#region Transitions
	# All -> One
	hsm.add_transition(hsm.ANYSTATE, stun_state, &"stun", _is_vincible)
	# Stun -> Other
	hsm.add_transition(stun_state, hsm.ANYSTATE, stun_state.EVENT_FINISHED)
	# Action -> Other
	hsm.add_transition(hsm.ANYSTATE, action_hsm, &"action", _can_act)
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
	#endregion
	

func damage(dmg_amount: int) -> void:
	current_health -= max(0, dmg_amount)
	
	health_changed.emit(current_health)
	
	if current_health <= 0:
		died.emit()

func apply_stun(frames: int) -> void:
	stun_frames += max(0, frames)

func heal(heal_amount: int) -> void:
	current_health += min(max_health, max(0, heal_amount))

func get_input_direction() -> Vector2:
	if id < 1 and id > 2:
		return Vector2.ZERO
	var dir = Input.get_vector("p%s_left" % id, "p%s_right" % id, "p%s_up" % id, "p%s_down" % id)
	vel_dir.target_position = dir * 100
	return dir

func _can_act() -> bool:
	return hsm.get_active_state() != stun_state or hsm.get_active_state() != action_hsm

func _can_jump() -> bool:
	return not jumps_count < max_jumps

func _is_vincible() -> bool:
	return i_frames < 1
