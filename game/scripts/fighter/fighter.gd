class_name Fighter
extends CharacterBody2D

signal died
signal health_changed(current: int, maximum: int)
signal inventory_updated(updated_inventory: Array[Item])
signal used_item(slot: int, move_cooldown: int)
signal money_changed(new_amount: int)

const MAX_HEALTH = 100
const WALK_SPEED = 200.0
const JUMP_VELOCITY = -400.0
const FRICTION = 600.0
const GRAVITY = 980.0
const HIT_SOUNDS = [
	preload("res://assets/audio/2AH.wav"),
	preload("res://assets/audio/2BH.wav"),
	preload("res://assets/audio/2CH.wav"),
	preload("res://assets/audio/2DH.wav"),
	preload("res://assets/audio/2EH.wav")
]

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: HitBox = $Hitbox
@onready var hurtbox: HurtBox = $Hurtbox
@onready var state_machine: uMachine = $StateMachine
@onready var self_heal_timer: Timer = Timer.new()

@export var player_id: int = -1
var input: DeviceInput
var health: int = MAX_HEALTH
var inventory: Array[Item] = []
var facing_right: bool = true
var money: int = 10

var current_move: MoveData
var action_frame: int = 0
var stun_duration: int = 0
var max_jumps: int = 2
var current_jumps: int = 0
var lose_streak: int = 0
var is_ready: bool = false

func _ready() -> void:
	if player_id <= -2:
		add_child(self_heal_timer)
		self_heal_timer.one_shot = true
		self_heal_timer.timeout.connect(_on_heal_timeout)
	
	set_player_id(player_id)
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
		stun_duration += stun_frames
		if state_machine.current_state.name.to_lower() != "stun":
			state_machine.change_state("stun")

func heal(amount: int) -> void:
	health = max(0, health + amount)
	health_changed.emit(health, MAX_HEALTH)

func add_item(slot: int, item: Item) -> int:
	if inventory.size() >= 3:
		push_warning("Player already has max number of")
		return 1
	
	inventory.insert(slot, item)
	inventory_updated.emit(inventory)
	return 0

func execute_move(move: MoveData) -> void:
	if not move:
		return
		
	current_move = move
	action_frame = 0
	state_machine.change_state("action")

func get_input_direction() -> Vector2:
	if  input.device < -1:
		return Vector2.ZERO
	return input.get_vector("left", "right", "up", "down") if input else Vector2.ZERO

func set_money(new_amount: int) -> void:
	money = clampi(new_amount, -999, 999)
	money_changed.emit(money)

func _initialize_systems() -> void:
	hurtbox.hit.connect(_on_hurt)

func _load_default_items() -> void:
	inventory.append(load("res://assets/resources/BoxingGloves.tres"))
	inventory_updated.emit(inventory)

func _handle_input() -> void:
	if not input or stun_duration > 0 or input.device < -1:
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
	if inventory.is_empty():
		push_warning("Player holds no items!")
		return
	elif inventory.size() <= item_slot:
		push_warning("Player doesn't hold an item in that slot.")
		return
	var item: Item = inventory.get(item_slot)
	if not item:
		return
		
	var move_key = _get_move_key()
	var move = item.variants.get(move_key) as MoveData
	if move:
		used_item.emit(item_slot, move.get_total_frames())
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
	if stun_duration > 0 or state_machine.current_state.name.to_lower() == "action":
		return
	var dir = get_input_direction()
	if abs(dir.x) > 0.1:
		facing_right = dir.x < 0
		sprite.flip_h = not facing_right

func _on_hurt(damage: int, stun: int, knockback: Vector2) -> void:
	SoundManager.play_sound_with_pitch(HIT_SOUNDS.pick_random(), randf_range(0.8, 1.2))
	#ScreenEffects.hitstop(6)
	#ScreenEffects.screenshake(8.0, 0.3)
	take_damage(damage, stun)
	velocity = knockback
	
	if self_heal_timer:
		self_heal_timer.start(3)

func _on_heal_timeout() -> void:
	heal(MAX_HEALTH - health)
