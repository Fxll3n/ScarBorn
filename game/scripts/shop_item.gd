class_name ShopItem
extends Control

@onready var item_name: Label = $PanelContainer/MarginContainer/VBoxContainer/ItemName
@onready var item_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/ItemIcon
@onready var reroll_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/Reroll
@onready var buy_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/Buy

var current_item: Item = null
var fighter: Fighter = null

var reroll_cost: int = 0
var buy_cost: int = 0


func update_visuals() -> void:
	item_icon.texture = current_item.icon
	item_name.text = current_item.name
	
	reroll_btn.tooltip_text = "Rerolls that specific item.\nCosts:\t%s" % reroll_cost
	buy_btn.tooltip_text = "Costs:\t%s" % buy_cost
	
	if fighter.money >= buy_cost:
		buy_btn.disabled = false
	else:
		buy_btn.disabled = true
	
	if fighter.money >= reroll_cost:
		reroll_btn.disabled = false
	else:
		reroll_btn.disabled = false


func _reroll() -> void:
	if not fighter or fighter.money < reroll_cost:
		return
	
	fighter.decrease_money(reroll_cost)
	current_item = ItemRegistry.get_random_item()
	reroll_cost = int(reroll_cost * 1.5)
	buy_cost = current_item.buy_price
	update_visuals()

func _buy() -> void:
	if not fighter or fighter.money < buy_cost:
		return
	
	fighter.decrease_money(buy_cost)
	fighter.add_item(current_item)
	update_visuals()
	queue_free()
