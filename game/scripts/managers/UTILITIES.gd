extends Node

static func _static_init() -> void:
	setup_console()

static func setup_console() -> void:
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
