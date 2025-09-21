class_name BadStage
extends Node2D

enum PHASES {FIGHT, SHOP, GAME_OVER, NONE}

signal countdown_started()
signal countdown_finished()
signal fight_started()
signal fight_ended(fighter1: Fighter, fighter2: Fighter)
signal round_timeout()
signal fighter_died(dead_fighter: Fighter, alive_fighter: Fighter)
signal phase_changed(new_phase: PHASES)

const PLAYER_SPAWNS = [Vector2(-300.0, 40.0), Vector2(300.0, 40.0)]
const COUNTDOWN_SOUNDS: Array[AudioStream] = [
	preload("uid://5x0jgdcn6hbt"),
	preload("uid://ddoq5hcg1gjni"),
	preload("uid://dkqev62va8ud8"),
	preload("uid://dbg1ebjyrwo8v")
]
const STAGE_MUSIC = [
	preload("uid://bol7pkpei8j4v"),
	preload("uid://dbr3ri20djg3t")
]

@export var fighter1: Fighter
@export var fighter2: Fighter
@export var round_duration: float = 120.0

@onready var countdown_label: RichTextLabel = $UI/Control/PlayerUI/Label
@onready var round_timer: Timer = $RoundTimer
@onready var player_ui: HBoxContainer = $UI/Control/PlayerUI
@onready var shops_ui: HBoxContainer = $UI/Control/Shops

var current_phase: PHASES = PHASES.NONE

func _ready() -> void:
	round_timer.timeout.connect(_on_round_timeout)
	round_timer.wait_time = round_duration
	connect_fighter_signals()
	await start_countdown()
	start_fight()

func _process(delta: float) -> void:
	music_logic()
	update_countdown_display()

func get_current_phase() -> PHASES:
	return current_phase

func set_phase(new_phase: PHASES) -> void:
	if current_phase != new_phase:
		current_phase = new_phase
		phase_changed.emit(new_phase)

func spawn_fighters() -> void:
	fighter1.global_position = PLAYER_SPAWNS[0]
	fighter2.global_position = PLAYER_SPAWNS[1]

func connect_fighter_signals() -> void:
	if not fighter1.died.is_connected(_on_fighter_died):
		fighter1.died.connect(_on_fighter_died.bind(fighter1))
	if not fighter2.died.is_connected(_on_fighter_died):
		fighter2.died.connect(_on_fighter_died.bind(fighter2))

func setup_fighter_process_modes() -> void:
	fighter1.process_mode = Node.PROCESS_MODE_PAUSABLE
	fighter2.process_mode = Node.PROCESS_MODE_PAUSABLE

func heal_fighters_full() -> void:
	fighter1.heal(fighter1.MAX_HEALTH - fighter1.health)
	fighter2.heal(fighter2.MAX_HEALTH - fighter2.health)

func start_countdown() -> void:
	countdown_started.emit()
	get_tree().paused = true
	
	for sound in COUNTDOWN_SOUNDS:
		SoundManager.play_ui_sound(sound)
		await get_tree().create_timer(1.0).timeout
	
	get_tree().paused = false
	countdown_finished.emit()

func start_fight() -> void:
	set_phase(PHASES.FIGHT)
	get_tree().paused = false
	round_timer.start()
	fight_started.emit()

func stop_fight() -> void:
	round_timer.stop()
	get_tree().paused = true
	fight_ended.emit(fighter1, fighter2)

func get_other_fighter(fighter: Fighter) -> Fighter:
	return fighter2 if fighter == fighter1 else fighter1

func get_time_remaining() -> float:
	return round_timer.time_left

func is_fight_active() -> bool:
	return current_phase == PHASES.FIGHT and not round_timer.is_stopped()

func are_fighters_ready() -> bool:
	return fighter1.is_ready and fighter2.is_ready

func music_logic() -> void:
	if not SoundManager.is_music_playing() and current_phase != PHASES.NONE:
		play_random_track(0.3)

func play_track(id: int, volume: float = 1.0) -> void:
	if id >= 0 and id < STAGE_MUSIC.size():
		SoundManager.play_music_at_volume(STAGE_MUSIC[id], volume)

func play_random_track(volume: float = 1.0) -> void:
	SoundManager.play_music_at_volume(STAGE_MUSIC.pick_random(), volume)

func update_countdown_display() -> void:
	if current_phase == PHASES.FIGHT:
		countdown_label.text = "[shake rate=30.0 level=10 connected=1][outline_size=6]%s" % int(round_timer.time_left)

func _on_round_timeout() -> void:
	round_timeout.emit()
	set_phase(PHASES.SHOP)
	fighter1.lose_streak = 0
	fighter2.lose_streak = 0
	
	fighter1.money += 10
	fighter2.money += 10
	
	stop_fight()

func _on_fighter_died(dead_fighter: Fighter) -> void:
	round_timer.paused = true
	var alive_fighter = get_other_fighter(dead_fighter)
	fighter_died.emit(dead_fighter, alive_fighter)
	dead_fighter.lose_streak += 1
	alive_fighter.lose_streak = 0
	
	dead_fighter.set_money(dead_fighter.money + (dead_fighter.lose_streak * 2 + 5))
	alive_fighter.set_money(alive_fighter.money + (10 + alive_fighter.money * .1))
	var dead_id: int = dead_fighter.player_id
	var alive_id: int = alive_fighter.player_id
	
	dead_fighter.set_player_id(-2)
	alive_fighter.set_player_id(-2)
	await get_tree().create_timer(5).timeout
	dead_fighter.set_player_id(dead_id)
	alive_fighter.set_player_id(alive_id)
	stop_fight()
	set_phase(PHASES.SHOP)

func _on_fighter_ready() -> void:
	if not are_fighters_ready():
		return
	round_timer.paused = false
	fighter1.is_ready = false
	fighter2.is_ready = false
	fighter1.state_machine.change_state("idle")
	fighter2.state_machine.change_state("idle")
	fighter1.velocity = Vector2.ZERO
	fighter2.velocity = Vector2.ZERO
	heal_fighters_full()
	spawn_fighters()
	set_phase(PHASES.FIGHT)
	round_timer.wait_time = round_duration
	await start_countdown()
	start_fight()
