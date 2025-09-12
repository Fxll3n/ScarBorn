class_name Stage
extends Node2D

const FIGHTER_SCENE = preload("res://scenes/actors/player.tscn")
const PLAYER_CARD = preload("res://scenes/actors/player_icon.tscn")

@onready var fighters_node: Node = $Fighters
@onready var environment_node: Node = $Environment
@onready var fighter_cards: HBoxContainer = $FighterCards/Control/Cards
@onready var p_cam: PhantomCamera2D = $PhantomCamera2D

var fighters: Array[Fighter] = []

func _ready() -> void:
	setup_console()
	spawn_fighter(-1)

func spawn_fighter(id: int, fighter_name: String = "Fighter") -> void:
	var fighter: Fighter = FIGHTER_SCENE.instantiate()
	fighter.set_player_id(id) if id >= -1 else null
	fighters.append(fighter)
	fighters_node.add_child(fighter)
	fighter.global_position = Vector2(0, -400)
	var card := PLAYER_CARD.instantiate()
	card._ready()
	card.setup(fighter)
	fighter.health_changed.connect(card._on_fighter_health_changed)
	fighter_cards.add_child(card)
	p_cam.follow_targets.append(fighter)
	p_cam.follow_mode = p_cam.FollowMode.GROUP

func setup_console() -> void:
	LimboConsole.register_command(
		spawn_fighter,
		"spawn_fighter",
		"Spawns a fighter with and id and name."
	)
