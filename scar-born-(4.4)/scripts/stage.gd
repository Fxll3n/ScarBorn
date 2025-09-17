class_name Stage
extends Node2D

signal fight_began
signal fight_ended
signal shop_began
signal shop_ended
signal winner_declared(winner: Fighter)

enum STATES {FIGHT, SHOP, GAME_OVER}

const STAGE_MUSIC = preload("res://assets/audio/33. Guile Stage.mp3")
const FIGHTER_SCENE = preload("res://scenes/actors/player.tscn")
const SHOP_SCENE = preload("res://scenes/actors/shop_item.tscn")
const PLAYER_CARD = preload("res://scenes/actors/player_icon.tscn")
const SPAWNS: Array[Vector2] = [Vector2(-350, 10), Vector2(350, 10)]

const COUNTDOWN_SOUNDS = [
	preload("res://assets/audio/3.wav"),
	preload("res://assets/audio/2.wav"),
	preload("res://assets/audio/1.wav"),
	preload("res://assets/audio/Fight!.wav")
]

@onready var fighters_node: Node = $Fighters
@onready var environment_node: Node = $Environment
@onready var fighter_cards: HBoxContainer = $FighterCards/Control/Cards
@onready var shop_cards: HBoxContainer = $FighterCards/Control/Shops
@onready var p_cam: PhantomCamera2D = $PhantomCamera2D
@onready var phase_manager: uMachine = $PhaseManager

var player1: Fighter
var player2: Fighter
var is_fight_active: bool = false
var winner: Fighter
var round_count: int = 1

func _ready() -> void:
	setup_two_players()

func _process(delta: float) -> void:
	if not SoundManager.is_music_playing() or is_fight_active:
		SoundManager.play_music_at_volume(STAGE_MUSIC, 0.2)
	
	check_fight_winner()

func setup_two_players() -> void:
	player1 = spawn_player(1, "Player 1", SPAWNS[0])
	player2 = spawn_player(2, "Player 2", SPAWNS[1])

func spawn_player(id: int, player_name: String, pos: Vector2) -> Fighter:
	var fighter: Fighter = FIGHTER_SCENE.instantiate()
	
	fighter.set_player_id(id)
	fighter.name = player_name
	fighter.global_position = pos
	
	fighters_node.add_child(fighter)
	
	setup_fighter_ui(fighter)
	setup_shop(fighter)
	setup_camera_follow(fighter)
	
	return fighter

func setup_fighter_ui(fighter: Fighter) -> void:
	var card := PLAYER_CARD.instantiate()
	fighter_cards.add_child(card)
	card.setup(fighter)
	fighter.health_changed.connect(card._on_fighter_health_changed)

func setup_shop(fighter: Fighter) -> void:
	var shop := SHOP_SCENE.instantiate()
	shop_cards.add_child(shop)
	shop.fighter = fighter
	shop.update_visuals()

func setup_camera_follow(fighter: Fighter) -> void:
	p_cam.follow_targets.append(fighter)
	p_cam.follow_mode = p_cam.FollowMode.GROUP

func check_fight_winner() -> void:
	if not is_fight_active:
		return
	
	if player1.health <= 0:
		end_fight_with_winner(player2)
	elif player2.health <= 0:
		end_fight_with_winner(player1)

func end_fight_with_winner(fight_winner: Fighter) -> void:
	if not is_fight_active:
		return
		
	winner = fight_winner
	is_fight_active = false
	disable_both_players()
	
	print(winner.name + " wins!")
	winner_declared.emit(winner)
	fight_ended.emit()

func start_fight_sequence() -> void:
	disable_both_players()
	await play_countdown()
	enable_both_players()
	start_background_music()
	is_fight_active = true
	fight_began.emit()

func play_countdown() -> void:
	const COUNTDOWN_DELAY = 1.0
	const FIGHT_DELAY = 0.5
	
	for i in range(3):
		SoundManager.play_sound(COUNTDOWN_SOUNDS[i])
		await get_tree().create_timer(COUNTDOWN_DELAY).timeout
	
	SoundManager.play_sound(COUNTDOWN_SOUNDS[3])
	await get_tree().create_timer(FIGHT_DELAY).timeout

func disable_both_players() -> void:
	set_player_active(player1, false)
	set_player_active(player2, false)

func enable_both_players() -> void:
	set_player_active(player1, true)
	set_player_active(player2, true)

func set_player_active(player: Fighter, active: bool) -> void:
	if player:
		player.set_process(active)
		player.set_physics_process(active)
		player.set_process_input(active)

func start_background_music() -> void:
	SoundManager.play_music(STAGE_MUSIC)


func show_fight_ui() -> void:
	fighter_cards.visible = true
	shop_cards.visible = false

func show_shop_ui() -> void:
	fighter_cards.visible = true
	shop_cards.visible = true
	disable_both_players()

func show_game_over_ui() -> void:
	# You can add a game over screen here
	# For now, just wait 3 seconds and restart
	await get_tree().create_timer(3.0).timeout
	restart_fight()

func restart_fight() -> void:
	# Reset player health and positions
	reset_players()
	round_count += 1
	start_fight_sequence()

func reset_players() -> void:
	if player1:
		player1.health = player1.max_health
		player1.global_position = SPAWNS[0]
	
	if player2:
		player2.health = player2.max_health
		player2.global_position = SPAWNS[1]

func end_fight() -> void:
	if not is_fight_active:
		return
	
	is_fight_active = false
	disable_both_players()
	fight_ended.emit()

func get_alive_players() -> Array[Fighter]:
	var alive: Array[Fighter] = []
	if player1 and player1.health > 0:
		alive.append(player1)
	if player2 and player2.health > 0:
		alive.append(player2)
	return alive

func get_player_by_name(player_name: String) -> Fighter:
	if player1 and player1.name.to_lower() == player_name.to_lower():
		return player1
	elif player2 and player2.name.to_lower() == player_name.to_lower():
		return player2
	return null

func get_player_by_id(id: int) -> Fighter:
	if player1 and player1.player_id == id:
		return player1
	elif player2 and player2.player_id == id:
		return player2
	return null
