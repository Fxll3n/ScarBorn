class_name Fighter
extends CharacterBody2D

signal died
signal health_changed(current: int, maximum: int)

const MAX_HEALTH = 100
const WALK_SPEED = 200.0
const JUMP_VELOCITY = -400.0
const FRICTION = 600.0
const GRAVITY = 980.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: HitBox = $Hitbox
@onready var hurtbox: HurtBox = $Hurtbox
@onready var state_machine: uMachine = $StateMachine

var player_id: int = -1
var input: DeviceInput
var health: int = MAX_HEALTH
var inventory: Array[Item] = []
var facing_right: bool = true

var current_move: MoveData
var action_frame: int = 0
var stun_duration: int = 0
var max_jumps: int = 2
var current_jumps: int = 0

func _ready() -> void:
	set_player_id(-1)
	_initialize_systems()
	_load_default_items()

func _physics_process(delta: float) -> void:
	_handle_input()
	_update_facing()
	move_and_slide()

func set_player_id(id: int) -> void:
	player_id = id
	input = DeviceInput.new(id)

func take_damage(amount: int, stun_frames: int = 0) -> void:
	health = max(0, health - amount)
	health_changed.emit(health, MAX_HEALTH)
	
	if health <= 0:
		state_machine.change_state("dead")
		died.emit()
	else:
		stun_duration = stun_frames
		state_machine.change_state("stun")

func execute_move(move: MoveData) -> void:
	if not move:
		return
		
	current_move = move
	action_frame = 0
	state_machine.change_state("action")

func get_input_direction() -> Vector2:
	return input.get_vector("left", "right", "up", "down") if input else Vector2.ZERO

func _initialize_systems() -> void:
	hurtbox.hit.connect(_on_hurt)

func _load_default_items() -> void:
	inventory.append(load("res://assets/resources/BoxingGloves.tres"))

func _handle_input() -> void:
	if not input or stun_duration > 0:
		return
	elif state_machine.current_state.name.to_lower() == "action":
		return
	
	if is_on_floor():
		current_jumps = 0
	
	if input.is_action_just_pressed("jump") and current_jumps < max_jumps:
		state_machine.change_state("jump")
		current_jumps += 1
	elif input.is_action_just_pressed("a"):
		_try_execute_move(0)
	elif input.is_action_just_pressed("b"):
		_try_execute_move(1)
	elif input.is_action_just_pressed("c"):
		_try_execute_move(2)

func _try_execute_move(item_slot: int) -> void:
	print("Tried to use item in slot %s." % item_slot)
	if inventory.is_empty():
		push_warning("Player holds no items!")
		return
	elif inventory.size() <= item_slot:
		push_warning("Player doesn't hold an item in that slot.")
		return
	var item: Item = inventory.get(item_slot)
	if not item:
		return
	print(item.name)
		
	var move_key = _get_move_key()
	print(move_key)
	var move = item.variants.get(move_key)
	if move:
		execute_move(move)

func _get_move_key() -> String:
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

func _update_facing() -> void:
	if stun_duration > 0:
		return
	var dir = get_input_direction()
	if abs(dir.x) > 0.1:
		facing_right = dir.x < 0
		sprite.flip_h = not facing_right

func _on_hurt(damage: int, stun: int) -> void:
	take_damage(damage, stun)
