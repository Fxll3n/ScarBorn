class_name PlayerIcon
extends Control

@onready var fighter_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FighterIcon
@onready var fighter_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/FighterName
@onready var health_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/HealthBar
@onready var move_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MoveContainer

var fighter: Fighter
var item_icons: Array[ItemIcon] = []

func setup(new_fighter: Fighter) -> void:
	if not new_fighter:
		push_error("PlayerIcon: Cannot setup with null fighter")
		return
	
	disconnect_previous_fighter()
	
	fighter = new_fighter
	update_fighter_info()
	connect_fighter_signals()
	rebuild_item_icons()

func disconnect_previous_fighter() -> void:
	if not fighter:
		return
	
	if fighter.item_added.is_connected(_on_item_added):
		fighter.item_added.disconnect(_on_item_added)
	if fighter.used_item.is_connected(_on_item_used):
		fighter.used_item.disconnect(_on_item_used)

func connect_fighter_signals() -> void:
	fighter.item_added.connect(_on_item_added)
	fighter.used_item.connect(_on_item_used)

func update_fighter_info() -> void:
	fighter_name.text = fighter.name
	update_health_bar(fighter.health, fighter.MAX_HEALTH)

func update_health_bar(current: int, maximum: int) -> void:
	var health_tween: Tween = create_tween()
	health_bar.max_value = maximum
	
	health_tween.set_ease(Tween.EASE_OUT)
	health_tween.set_trans(Tween.TRANS_BOUNCE)
	
	health_tween.tween_property(health_bar, "value", current, randf_range(0.3, 0.5))
	

func rebuild_item_icons() -> void:
	clear_item_icons()
	create_item_icons()

func clear_item_icons() -> void:
	for icon in item_icons:
		if is_instance_valid(icon):
			icon.queue_free()
	item_icons.clear()

func create_item_icons() -> void:
	for i in range(fighter.inventory.size()):
		var item = fighter.inventory[i]
		if not item:
			continue
		
		var item_icon = create_item_icon(item, i)
		item_icons.append(item_icon)
		move_container.add_child(item_icon)
		
		# Connect the fighter's used_item signal to this specific icon
		fighter.used_item.connect(item_icon.start_cooldown)

func create_item_icon(item: Item, slot: int) -> ItemIcon:
	var item_icon := ItemIcon.new()
	item_icon.set_item(item, slot)
	return item_icon

func get_item_icon_by_slot(slot: int) -> ItemIcon:
	for icon in item_icons:
		if icon.slot_id == slot:
			return icon
	return null

func _on_fighter_health_changed(current: int, maximum: int) -> void:
	update_health_bar(current, maximum)

func _on_item_added(item: Item, slot: int) -> void:
	rebuild_item_icons()

func _on_item_used(slot: int, cooldown_frames: int) -> void:
	var icon = get_item_icon_by_slot(slot)
	if icon:
		icon.start_cooldown(slot, cooldown_frames)

func _exit_tree() -> void:
	disconnect_previous_fighter()
