extends Control
class_name Shop

@onready var gold_count: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/GoldCount
@onready var items_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Items

@export var fighter: Fighter

func reroll_shop() -> void:
	for node in items_container.get_children():
		if node is ShopItem:
			node.fighter = fighter
			node.update_visuals()
			node.show()

func _update_gold(new_amount: int) -> void:
	
	var t := create_tween()
	
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(gold_count, "text", "[wave amp=15.0 freq=2.5.0 connected=0][color=gold]XRFD", 0.1)
	
	t.set_ease(Tween.EASE_OUT)
	
	t.tween_property(gold_count, "text", "[wave amp=15.0 freq=2.5.0 connected=0][color=gold]%sG" % new_amount, 0.4)

func _on_continue_pressed() -> void:
	pass
