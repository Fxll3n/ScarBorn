extends Control
@onready var menus: Control = $PanelContainer/MarginContainer/Menus
@onready var pop_up: Control = $PanelContainer/MarginContainer/VBoxContainer


func _ready() -> void:
	LimboConsole.enabled = false
	LimboConsole._options.pause_when_open = false
	menus.hide()
	pop_up.show()

func _on_continue_pressed() -> void:
	pop_up.hide()
	menus.show()


func _on_play_coop_pressed() -> void:
	pass # Replace with function body.


func _on_play_single_pressed() -> void:
	LimboConsole.enabled = true
	SceneManager.change_scene(
		"test_stage_2",
		SceneManager.create_options(1, "pixel", 0.1, true),
		SceneManager.create_options(0.5, "pixel", 0.1, true),
		SceneManager.create_general_options(Color.BLACK)
		)
