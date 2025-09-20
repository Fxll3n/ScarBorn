class_name Slot
extends Control

@onready var texture_progress_bar: TextureProgressBar = $PanelContainer/MarginContainer/TextureProgressBar
var slot_id: int

func _change_icon(new_icon: Texture2D) -> void:
	texture_progress_bar.texture_under = new_icon
	texture_progress_bar.texture_progress = new_icon

func _on_used(slot: int, cooldown: float) -> void:
	if slot_id != slot:
		return
	texture_progress_bar.value = 100
	
	var t := create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	t.tween_property(texture_progress_bar, "value", 0, float(cooldown/60))
