extends Control

const SLOT_SCENE: PackedScene = preload("uid://dcf6h3d4vu6s6")

@export var fighter: Fighter
@onready var fighter_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/FighterIcon
@onready var fighter_name: Label = $MarginContainer/VBoxContainer/HBoxContainer/FighterName
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var move_container: HBoxContainer = $MarginContainer/VBoxContainer/MoveContainer

func _ready() -> void:
	hide()
	if fighter == null:
		print("Error: Fighter is null!")
		return
		
	fighter.health_changed.connect(_on_health_changed.bind(fighter.max_health))
	fighter.inventory_changed.connect(_on_inventory_changed)
	fighter_name.text = fighter.name

func _on_health_changed(current: int, maximum: int) -> void:
	if maximum > health_bar.max_value:
		health_bar.max_value = maximum
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	t.tween_property(health_bar, "value", current, 0.2)

func _clear_slots() -> void:
	print("clearing slots")
	for node in move_container.get_children():
		node.queue_free()

func _on_inventory_changed(new_inv: Array[Item]) -> void:
	print("Inv Updated - Array size: %d" % new_inv.size())
	_clear_slots()
	var i := 0
	for item in new_inv:
		print("Processing item: %s" % item.name if item != null else "null item")
		if item == null:
			print("Warning: null item at index %d" % i)
			i += 1
			continue
			
		print("Created slot for: %s" % item.name)
		var slot := SLOT_SCENE.instantiate() as Slot
		move_container.add_child(slot)
		slot._change_icon(item.icon)
		slot.slot_id = i
		fighter.used_item.connect(slot._on_used)
		i += 1


func _on_phase_changed(new_phase: BadStage.PHASES) -> void:
	match new_phase:
		BadStage.PHASES.FIGHT:
			show()
		BadStage.PHASES.SHOP:
			hide()
		BadStage.PHASES.GAME_OVER:
			hide()
		BadStage.PHASES.NONE:
			hide()
