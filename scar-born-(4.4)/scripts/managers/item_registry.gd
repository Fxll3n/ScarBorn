extends Node

var items: Array[Item] = []
var items_by_name: Dictionary = {}
var items_by_rarity: Dictionary = {
	"Plastic": [],
	"Alloy": [],
	"Metal": []
}

const ITEMS_FOLDER_PATH: String = "res://assets/resources/"

func _ready() -> void:
	load_all_items()

func load_all_items() -> void:
	items.clear()
	items_by_name.clear()
	
	# Clear rarity arrays
	for rarity in items_by_rarity.keys():
		items_by_rarity[rarity].clear()
	
	var dir = DirAccess.open(ITEMS_FOLDER_PATH)
	if dir == null:
		push_error("[ItemRegistry]: Failed to access items folder: " + ITEMS_FOLDER_PATH)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var full_path = ITEMS_FOLDER_PATH + file_name
			var resource = load(full_path)
			
			if resource is Item:
				var item = resource as Item
				items.append(item)
				items_by_name[item.name] = item
				
				if item.rarity in items_by_rarity:
					items_by_rarity[item.rarity].append(item)
				else:
					push_warning("[ItemRegistry]: Unknown rarity '%s' for item '%s'" % [item.rarity, item.name])
				
				print("[ItemRegistry]: Loaded item: %s (Rarity: %s)" % [item.name, item.rarity])
			else:
				push_warning("[ItemRegistry]: File %s is not a valid Item resource" % file_name)
		
		file_name = dir.get_next()
	
	print("[ItemRegistry]: Loaded %d items total" % items.size())
	print("- Plastic: %d items" % items_by_rarity["Plastic"].size())
	print("- Alloy: %d items" % items_by_rarity["Alloy"].size())
	print("- Metal: %d items" % items_by_rarity["Metal"].size())

func get_random_item() -> Item:
	if items.is_empty():
		push_error("No items loaded in ItemRegistry!")
		return null
	return items[randi() % items.size()]

func get_random_item_by_rarity(rarity: String) -> Item:
	if rarity not in items_by_rarity:
		push_error("[ItemRegistry]: Unknown rarity: " + rarity)
		return null
	
	var rarity_items = items_by_rarity[rarity]
	if rarity_items.is_empty():
		push_error("[ItemRegistry]: No items found for rarity: " + rarity)
		return null
	
	return rarity_items[randi() % rarity_items.size()]

func get_item_by_name(item_name: String) -> Item:
	if item_name in items_by_name:
		return items_by_name[item_name]
	
	push_warning("[ItemRegistry]: Item not found: " + item_name)
	return null

func get_items_by_rarity(rarity: String) -> Array[Item]:
	if rarity in items_by_rarity:
		return items_by_rarity[rarity].duplicate()
	return []

func get_all_items() -> Array[Item]:
	return items.duplicate()

func get_weighted_random_item() -> Item:
	var weights = {
		"Plastic": 60,
		"Alloy": 30,
		"Metal": 10
	}
	
	var total_weight = 0
	for weight in weights.values():
		total_weight += weight
	
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for rarity in weights.keys():
		current_weight += weights[rarity]
		if random_value < current_weight and not items_by_rarity[rarity].is_empty():
			return get_random_item_by_rarity(rarity)
	
	return get_random_item()

func reload_items() -> void:
	print("[ItemRegistry]: Reloading items...")
	load_all_items()

func get_items_by_price_range(min_price: int, max_price: int) -> Array[Item]:
	var filtered_items: Array[Item] = []
	for item in items:
		if item.buy_price >= min_price and item.buy_price <= max_price:
			filtered_items.append(item)
	return filtered_items

func debug_print_all_items() -> void:
	print("\n=== ItemRegistry Debug ===")
	for item in items:
		print("%s | %s | %dG | %s" % [item.name, item.rarity, item.buy_price, item.description.substr(0, 50)])
	print("========================\n")
