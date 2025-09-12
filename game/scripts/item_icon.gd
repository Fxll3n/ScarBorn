class_name ItemIcon
extends TextureProgressBar

var data: Item

func _ready() -> void:
	pass

func update_visual() -> void:
	if not data:
		return
	
	texture_under = data.icon
	texture_progress = data.icon
	tint_progress = Color(0, 0, 0, 0.4)
	fill_mode = FILL_CLOCKWISE

func start_cooldown(item: Item, move_cooldown: int) -> void:
	if item.name != data.name:
		return
	max_value = move_cooldown
	value = move_cooldown
	var t := create_tween()
	t.tween_property(self, "value", 0, float(move_cooldown) * 1.0/60.0) 
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_CIRC)
