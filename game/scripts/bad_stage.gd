class_name BadStage
extends Node2D

enum PHASES {FIGHT, SHOP, GAME_OVER, NONE}

const PLAYER_SPAWNS = [Vector2(-300.0,40.0), Vector2(300.0,40.0)]
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

@onready var countdown_label: RichTextLabel = $UI/Control/PlayerUI/Label
@onready var round_timer: Timer = $RoundTimer

var current_phase: PHASES = PHASES.NONE

func _ready() -> void:
	round_timer.timeout.connect(_on_round_timeout)
	setup_fight()

func _process(delta: float) -> void:
	music_logic()
	countdown_label.text = "[shake rate=30.0 level=10 connected=1][outline_size=6]%s" % int(round_timer.time_left)

func setup_fight() -> void:
	round_timer.wait_time = 120
	countdown_label.text = "[shake rate=30.0 level=10 connected=1][outline_size=6]%s" % int(round_timer.time_left)

	fighter1.global_position = PLAYER_SPAWNS.get(0)
	fighter2.global_position = PLAYER_SPAWNS.get(1)
	
	fighter1.process_mode = Node.PROCESS_MODE_PAUSABLE
	fighter2.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	SceneManager.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	for sound in COUNTDOWN_SOUNDS:
		SoundManager.play_ui_sound(sound)
		await get_tree().create_timer(1).timeout
	
	get_tree().paused = false
	
	current_phase = PHASES.FIGHT
	round_timer.start()

func music_logic() -> void:
	if not SoundManager.is_music_playing() and current_phase != PHASES.NONE:
		play_track(-1, 0.3)

func play_track(id: int = -1, volume: float = 1.0) -> void:
	if id >= STAGE_MUSIC.size():
		return
	
	if id <= -1:
		SoundManager.play_music_at_volume(STAGE_MUSIC.pick_random(), volume)
	else:
		SoundManager.play_music_at_volume(STAGE_MUSIC.get(id), volume)

func _on_round_timeout() -> void:
	pass
