class_name ShopItem
extends Control

@onready var item_name: Label = $PanelContainer/MarginContainer/VBoxContainer/ItemName
@onready var item_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/ItemIcon
@onready var reroll_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/Reroll
@onready var buy_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/Buy
@onready var current_item: Item = ItemRegistry.get_random_item_by_rarity("Plastic")

var fighter: Fighter = null
var shop: Shop = owner

var reroll_cost: int = 0
var buy_cost: int = 0

func _ready() -> void:
	buy_cost = current_item.buy_price
	reroll_cost = 2

func update_visuals() -> void:
	item_icon.texture = current_item.icon
	item_name.text = current_item.name
	
	if fighter.money >= buy_cost:
		buy_btn.disabled = false
	else:
		buy_btn.disabled = true
	
	if fighter.money >= reroll_cost:
		reroll_btn.disabled = false
	else:
		reroll_btn.disabled = false


func _reroll() -> void:
	current_item = ItemRegistry.get_random_item()
	reroll_cost = int(reroll_cost * 1.5)
	buy_cost = current_item.buy_price
	
	reroll_btn.tooltip_text = "Rerolls that specific item.\nCosts:\t%s" % reroll_cost

func _buy() -> void:
	if not fighter:
		return
	
	fighter.add_item(0, current_item)
	fighter.money -= buy_cost
	shop._update_gold(fighter.money)
	self.hide()
