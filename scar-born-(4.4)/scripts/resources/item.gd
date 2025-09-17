class_name Item
extends Resource

@export_category("Info")
@export var name: StringName
@export var icon: Texture2D
@export_multiline var description: String
@export_range(0, 999, 1, "suffix:gold") var buy_price: int = 0
@export_range(0, 999, 1, "suffix:gold") var sell_price: int = 0
@export_enum("Plastic", "Alloy", "Metal") var rarity: String = "Plastic"
@export_category("Moves")
@export var variants: Dictionary[String, MoveData] = {}
