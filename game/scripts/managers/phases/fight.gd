extends Phase

func _ready() -> void:
	stage.fight_ended.connect(_on_fight_ended)

func enter() -> void:
	stage.start_fight_sequence()
	stage.shop_cards.hide()

func exit() -> void:
	stage.end_fight()
	stage.disable_all_fighters()

func _on_fight_ended() -> void:
	transition_to("SHOP")
