extends Label

@onready var state_machine: uMachine = $"../StateMachine"

func _ready() -> void:
	state_machine.state_transitioned.connect(_on_transition)

func _on_transition(old_state: StringName, new_state: StringName) -> void:
	text = new_state.to_upper()
