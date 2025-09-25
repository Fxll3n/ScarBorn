extends Node

var current_popup: Control = null
var popup_canvas_layer: CanvasLayer = null

func _ready() -> void:
	setup_console()

func setup_console() -> void:
	LimboConsole.toggled.connect(_on_console_toggles)
	
	LimboConsole.register_command(
		turn_visible_collisions,
		"collision_visibility",
		"Toggles the visibility of collision shapes."
	)
	LimboConsole.add_argument_autocomplete_source(
		"collision_visibility",
		0,
		func():
			return [true, false]
	)
	LimboConsole.register_command(
		add_item,
		"add_item",
		"adds item to chosen player"
	)
	LimboConsole.add_argument_autocomplete_source(
		"add_item",
		0,
		func():
			var dir = DirAccess.open("res://assets/resources/")
			if not dir:
				return []
			var items = []
			for file in dir.get_files():
				if file.ends_with(".tres"):
					items.append(file.get_basename())
			return items
	)
	LimboConsole.add_argument_autocomplete_source(
		"add_item",
		2,
		func(): return get_tree().get_nodes_in_group("players").map(
				func(node): return node.name)
	)
	LimboConsole.register_command(
		damage_fighter,
		"damage",
		"Damages a fighter."
	)
	LimboConsole.add_argument_autocomplete_source(
		"damage",
		0,
		func(): return get_tree().get_nodes_in_group("players").map(
				func(node): return node.name)
	)
	LimboConsole.register_command(
		show_popup,
		"show_instructions",
		"Shows the instructions in the begining of the game."
	)
	LimboConsole.add_argument_autocomplete_source(
		"show_instructions",
		0,
		func():
			return [true, false]
	)
	LimboConsole.register_command(
		game_speed,
		"set_game_speed",
		"Sets the game speed."
	)

func add_item(item: String, slot: int = 0,fighter: String = "Fighter") -> void:
	var fighter_node: Fighter = find_node_by_name(fighter, "players") as Fighter
	
	if slot >= fighter_node.inventory.size() or fighter_node.inventory.size() >= 3:
		return
	
	if not fighter_node:
		print("Player '%s' not found" % fighter)
		return
	
	var item_path = "res://assets/resources/" + item + ".tres"
	if not ResourceLoader.exists(item_path):
		print("Item '%s' not found at path: %s" % [item, item_path])
		return
	
	var item_resource = load(item_path).duplicate()
	if not item_resource is Item:
		print("Resource '%s' is not a valid Item" % item)
		return
	
	fighter_node.inventory.insert(slot, item_resource)
	fighter_node.inventory_updated.emit(fighter_node.inventory)
	LimboConsole.print_line("Added '%s' to %s's inventory" % [item_resource.name, fighter])

func damage_fighter(fighter: String, amount: int, stun_frames: int) -> void:
	var fighter_node: Fighter = find_node_by_name(fighter, "players") as Fighter
	
	if not fighter_node:
		print("Player '%s' not found" % fighter)
		return
	
	fighter_node.damage(amount)
	fighter_node.apply_stun(stun_frames)

func game_speed(speed: float = 1.0) -> void:
	Engine.time_scale = speed
	Engine.physics_ticks_per_second = int(speed * 60)


func show_popup(show: bool = true) -> void:
	LimboConsole.close_console()
	if not show:
		if current_popup:
			current_popup.queue_free()
			current_popup = null
		if popup_canvas_layer:
			popup_canvas_layer.queue_free()
			popup_canvas_layer = null
		get_tree().paused = false
		return
	
	if current_popup:
		return
	
	popup_canvas_layer = CanvasLayer.new()
	popup_canvas_layer.layer = 100
	popup_canvas_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	current_popup = SceneManager.create_scene_instance("pop_up")
	current_popup.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	get_tree().root.add_child(popup_canvas_layer)
	popup_canvas_layer.add_child(current_popup)
	await LimboConsole.toggled
	get_tree().paused = show
	set_process(!show)

func find_node_by_name(node_name: String, group: String) -> Node:
	var fighters = get_tree().get_nodes_in_group(group)
	for fighter in fighters:
		if fighter.name.to_lower() == node_name.to_lower():
			return fighter
	return null

static func turn_visible_collisions(on: bool = false) -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		for node in tree.get_nodes_in_group("hitboxes"):
			if node is HitBox:
				node.visible_collisions = on
				node.queue_redraw()
		
		for node in tree.get_nodes_in_group("hurtboxes"):
			if node is HurtBox:
				node.visible_collisions = on
				node.queue_redraw()


func _on_console_toggles(is_shown: bool) -> void:
	
	get_tree().paused = is_shown
		
