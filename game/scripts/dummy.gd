extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: HurtBox = $HurtBox
@onready var hitbox: HitBox = $HitBox
@onready var timer: Timer = $Timer

func _ready() -> void:
	hurtbox.hit.connect(_on_hit)
	sprite.animation_finished.connect(_on_anim_finish)
	timer.timeout.connect(_on_timeout)
	timer.start(2.5)
	

func _on_hit(damage: int, _stun: int) -> void:
	print("Took %s damage and %s stun frames." % [damage, _stun])
	sprite.play("hit_%s" % randi_range(1,3))

func _on_anim_finish() -> void:
	sprite.play("idle")

func _on_timeout() -> void:
	hitbox.setup(Vector2(-20, 0), Vector2(30, 30))
	hitbox.enable(10, 24)
	await get_tree().create_timer(0.5).timeout
	hitbox.setup(Vector2.ZERO, Vector2.ZERO)
	hitbox.disable()
	timer.start(2.5)
