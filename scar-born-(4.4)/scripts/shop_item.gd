extends Control
class_name ShopItem

@onready var item_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/ItemIcon
@onready var item_name: Label = $PanelContainer/MarginContainer/VBoxContainer/ItemName
@onready var reroll: Button = $PanelContainer/MarginContainer/VBoxContainer/Reroll
@onready var buy: Button = $PanelContainer/MarginContainer/VBoxContainer/Buy

var data: Item = null
var fighter: Fighter = null
var reroll_price: int = 10  # Base reroll price

signal item_bought(item: Item)
signal item_rerolled(old_price: int, new_price: int)

func _ready() -> void:
	reroll.pressed.connect(_on_reroll_pressed)
	buy.pressed.connect(_on_buy_pressed)

func update_visuals() -> void:
	if data == null:
		return
		
	item_icon.texture = data.icon
	item_name.text = data.name
	
	buy.text = "Buy (%dG)" % data.buy_price
	buy.tooltip_text = data.description
	reroll.text = "Reroll (%dG)" % reroll_price


func set_item(new_item: Item) -> void:
	data = new_item.duplicate()
	update_visuals()

func _on_reroll_pressed() -> void:
	var old_price = reroll_price
	reroll_price = int(reroll_price * 1.15) 
	data = ItemRegistry.get_random_item()
	update_visuals()
	item_rerolled.emit(old_price, reroll_price)

func _on_buy_pressed() -> void:
	item_bought.emit(data)
	queue_free()
