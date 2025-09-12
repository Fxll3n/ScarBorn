extends Control

@onready var fighter_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FighterIcon
@onready var fighter_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FighterName
@onready var health_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/HealthBar
@onready var move_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MoveContainer

func _ready() -> void:
	pass

func setup(fighter: Fighter) -> void:
	if not fighter:
		return
	fighter_name.text = "%s" % fighter.name
	health_bar.max_value = fighter.MAX_HEALTH
	health_bar.value = fighter.health
	
	for item in fighter.inventory:
		var item_icon := ItemIcon.new()
		item_icon.data = item
		item_icon.update_visual()
		fighter.used_item.connect(item_icon.start_cooldown)
		move_container.add_child(item_icon)
	

func _on_fighter_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

	
