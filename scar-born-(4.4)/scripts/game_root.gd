extends Node

@onready var current_scene: Node = %CurrentScene
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	LimboConsole.enabled = false
