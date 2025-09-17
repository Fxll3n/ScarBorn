extends Control
class_name Shop

const SHOP_ITEM_SCENE := preload("res://scenes/actors/shop_item.tscn")

@onready var current_gold: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var items: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Items

var player: Fighter = null

signal shop_closed

func _ready() -> void:
	setup_items()
	update_gold_display()

func on_continue_pressed() -> void:
	shop_closed.emit()
	visible = false

func set_gold_count(new_amount: int) -> void:
	player.money = new_amount
	update_gold_display()

func update_gold_display() -> void:
	current_gold.text = "[color=gold]Gold: %d[/color]" % player.money

func clear_items() -> void:
	for item in items.get_children():
		item.queue_free()

func setup_items(count: int = 3) -> void:
	clear_items()
	
	for i in count:
		var new_shop_item := SHOP_ITEM_SCENE.instantiate() as ShopItem
		var random_item = ItemRegistry.get_random_item()
		
		new_shop_item.set_item(random_item)
		new_shop_item.item_bought.connect(_on_item_bought)
		new_shop_item.item_rerolled.connect(_on_item_rerolled)
		
		items.add_child(new_shop_item)

func _on_item_bought(item: Item) -> void:
	if player.money >= item.buy_price:
		player.money -= item.buy_price
		update_gold_display()
		player.add_item(0, item)
		
	else:
		print("Not enough gold!")

func _on_item_rerolled(old_price: int, new_price: int) -> void:
	if player.money >= old_price:
		player.money -= old_price
		update_gold_display()
	else:
		print("Not enough gold to reroll!")

func refresh_shop() -> void:
	setup_items()

func can_afford(price: int) -> bool:
	return player.money >= price
