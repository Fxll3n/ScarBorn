extends Phase



func enter() -> void:
	stage.disable_all_fighters()
	stage.setup_shops() 
	stage.shop_cards.show()
