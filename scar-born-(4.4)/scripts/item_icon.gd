class_name ItemIcon
extends TextureProgressBar

signal cooldown_finished

@export var empty_texture: Texture2D
@export var cooldown_color: Color = Color(0, 0, 0, 0.4)

var item_data: Item
var slot_id: int = 0
var cooldown_tween: Tween

func _ready() -> void:
	setup_default_appearance()

func setup_default_appearance() -> void:
	fill_mode = FILL_CLOCKWISE
	value = 0
	update_visual()

func set_item(item: Item, slot: int = 0) -> void:
	item_data = item
	slot_id = slot
	update_visual()

func clear_item() -> void:
	item_data = null
	update_visual()

func update_visual() -> void:
	if item_data:
		texture_under = item_data.icon
		texture_progress = item_data.icon
		tint_progress = cooldown_color
		modulate.a = 1.0
	else:
		texture_under = empty_texture
		texture_progress = empty_texture
		tint_progress = Color.TRANSPARENT
		modulate.a = 0.5

func start_cooldown(slot: int, duration_frames: int) -> void:
	if slot != slot_id or duration_frames <= 0:
		return
	
	stop_cooldown()
	
	max_value = duration_frames
	value = duration_frames
	
	cooldown_tween = create_tween()
	cooldown_tween.set_ease(Tween.EASE_IN_OUT)
	cooldown_tween.set_trans(Tween.TRANS_CIRC)
	
	var duration_seconds = float(duration_frames) / 60.0
	cooldown_tween.tween_property(self, "value", 0, duration_seconds)
	cooldown_tween.tween_callback(func(): cooldown_finished.emit())

func start_cooldown_direct(duration_frames: int) -> void:
	if duration_frames <= 0:
		return
	
	stop_cooldown()
	
	max_value = duration_frames
	value = duration_frames
	
	cooldown_tween = create_tween()
	cooldown_tween.set_ease(Tween.EASE_IN_OUT)
	cooldown_tween.set_trans(Tween.TRANS_CIRC)
	
	var duration_seconds = float(duration_frames) / 60.0
	cooldown_tween.tween_property(self, "value", 0, duration_seconds)
	cooldown_tween.tween_callback(func(): cooldown_finished.emit())

func stop_cooldown() -> void:
	if cooldown_tween:
		cooldown_tween.kill()
	value = 0

func is_on_cooldown() -> bool:
	return value > 0

func get_cooldown_progress() -> float:
	if max_value <= 0:
		return 0.0
	return value / max_value

func get_remaining_cooldown_seconds() -> float:
	return value / 60.0
