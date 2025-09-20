extends Control

const MENU_MUSIC = [
	preload("res://assets/audio/05. Ken Stage.mp3")
]

@onready var menus: Control = $PanelContainer/MarginContainer/Menus
@onready var pop_up: Control = $PanelContainer/MarginContainer/VBoxContainer

func _ready() -> void:
	SoundManager.play_music(MENU_MUSIC.pick_random())
	LimboConsole.enabled = false
	LimboConsole._options.pause_when_open = false
	menus.hide()
	pop_up.show()

func _on_continue_pressed() -> void:
	SoundManager.play_ui_sound(preload("res://assets/audio/24H.wav"))
	pop_up.hide()
	menus.show()


func _on_play_coop_pressed() -> void:
	pass # Replace with function body.


func _on_play_single_pressed() -> void:
	SoundManager.play_ui_sound(preload("res://assets/audio/24H.wav"))
	SoundManager.play_ui_sound(preload("res://assets/audio/22H.wav"))
	SoundManager.stop_music(1)
	LimboConsole.enabled = true
	SceneManager.change_scene(
		"demo_stage",
		SceneManager.create_options(1, "pixel", 0.1, true),
		SceneManager.create_options(0.5, "pixel", 0.1, true),
		SceneManager.create_general_options(Color.BLACK)
		)
