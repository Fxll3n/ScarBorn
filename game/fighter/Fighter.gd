class_name Fighter
extends CharacterBody2D

enum STATE {IDLE, ATTACK_START, ATTACK_ACTIVE, ATTACK_RECOVER, STUN}

@onready var sprite: AnimatedSprite2D = AnimatedSprite2D.new()
@onready var health: Health = Health.new()
@onready var hitbox: BasicHitBox2D = BasicHitBox2D.new()
@onready var hurtbox: BasicHurtBox2D = BasicHurtBox2D.new()

var current_state: STATE = STATE.IDLE
var frame_count: int = 0

var available_moves: Array[Move] = []
var current_move: Move = null

func _init() -> void:
	add_move(preload("res://moves/Punch.tres"))

func _ready() -> void:
	_setup()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		execute_move(0)

func _physics_process(delta: float) -> void:
	match current_state:
		STATE.IDLE:
			pass
		STATE.ATTACK_START:
			if frame_count >= current_move.startup:
				current_state = STATE.ATTACK_ACTIVE
				frame_count = 0
				enable_hitbox(current_move.hitbox_data, current_move.damage)
		STATE.ATTACK_ACTIVE:
			if frame_count >= current_move.active:
				current_state = STATE.ATTACK_RECOVER
				frame_count = 0
				disable_hitbox()
		STATE.ATTACK_RECOVER:
			if frame_count >= current_move.recovery:
				current_state = STATE.IDLE
				frame_count = 0
				sprite.play("idle") 
		STATE.STUN:
			pass
		_:
			pass
	
	frame_count += 1

func add_move(new_move: Move, slot: int = 0) -> void:
	available_moves.insert(slot, new_move)

func execute_move(slot: int = 0) -> void:
	if current_state != STATE.IDLE or available_moves.is_empty():
		return
	
	current_move = available_moves[slot]
	current_state = STATE.ATTACK_START
	frame_count = 0
	sprite.play(current_move.animation_name)

func enable_hitbox(hitbox_data: Rect2, damage: int) -> void:
	hitbox.ignore_collisions = false
	hitbox.amount = damage
	var hit_shape = hitbox.get_child(0).shape as RectangleShape2D
	var coll_shape = hitbox.get_child(0) as CollisionShape2D
	coll_shape.debug_color = Color.PURPLE
	hit_shape.size = hitbox_data.size
	hitbox.position = hitbox_data.position
	

func disable_hitbox() -> void:
	hitbox.ignore_collisions = true
	hitbox.amount = 0
	var hit_shape = hitbox.get_child(0).shape as RectangleShape2D
	var coll_shape = hitbox.get_child(0) as CollisionShape2D
	coll_shape.debug_color = Color.DIM_GRAY

func _setup() -> void:
	add_child(sprite)
	add_child(hitbox)
	add_child(hurtbox)
	add_child(health)
	var hit_coll := CollisionShape2D.new()
	var hurt_coll := CollisionShape2D.new()
	hit_coll.shape = RectangleShape2D.new()
	hurt_coll.shape = RectangleShape2D.new()
	sprite.sprite_frames = preload("res://fighter/fighter.tres")
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://transperency.gdshader")
	sprite.material = mat
	mat.set_shader_parameter("trans_color", Color("#a3e3fb"))
	hitbox.add_child(hit_coll)
	hurtbox.add_child(hurt_coll)
	hitbox.ignore_collisions = true
	hurtbox.health = health
	sprite.play("idle")
	var hurt_shape = hurt_coll.shape as RectangleShape2D
	hurt_shape.size = Vector2(50, 130)
	hurt_coll.position = Vector2(-10, 10)
