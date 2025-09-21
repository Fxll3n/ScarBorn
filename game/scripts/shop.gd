extends Control
class_name Shop

signal player_ready

const SHOP_ITEM_SCENE = preload("uid://cl10ajuxf5cj8")

@onready var gold_count: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/GoldCount
@onready var items_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Items

@export var fighter: Fighter

func _ready() -> void:
	hide()
	refresh_shop()
	fighter.money_changed.connect(_update_gold)
	_update_gold(fighter.money)

func refresh_shop() -> void:
	for node in items_container.get_children():
		node.queue_free()
	for i in range(0, 3):
		var shop_item := SHOP_ITEM_SCENE.instantiate() as ShopItem
		items_container.add_child(shop_item)
		var item: Item = ItemRegistry.get_random_item_by_rarity("Plastic")
		shop_item.fighter = fighter
		shop_item.current_item = item
		shop_item.buy_cost = item.buy_price
		shop_item.reroll_cost = 2
		shop_item.update_visuals()
			

func _update_gold(new_amount: int) -> void:
	
	for item in items_container.get_children():
		if item is ShopItem:
			item.update_visuals()
			
	var t := create_tween()
	
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(gold_count, "text", "[wave amp=15.0 freq=2.5.0 connected=0][color=gold]XRFD", 0.1)
	
	t.set_ease(Tween.EASE_OUT)
	
	t.tween_property(gold_count, "text", "[wave amp=15.0 freq=2.5.0 connected=0][color=gold]%sG" % new_amount, 0.2)

func _on_continue_pressed() -> void:
	fighter.is_ready = true
	player_ready.emit()
	hide()


func _on_phase_changed(new_phase: BadStage.PHASES) -> void:
	match new_phase:
		BadStage.PHASES.FIGHT:
			_update_gold(fighter.money)
			hide()
		BadStage.PHASES.SHOP:
			_update_gold(fighter.money)
			refresh_shop()
			show()
		BadStage.PHASES.GAME_OVER:
			hide()
		BadStage.PHASES.NONE:
			hide()
