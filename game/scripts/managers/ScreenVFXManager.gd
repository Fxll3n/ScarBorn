extends Node

var screenshake_camera: Camera2D
var hitstop_duration: float = 0.0

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if hitstop_duration > 0:
		hitstop_duration -= delta
		if hitstop_duration <= 0:
			end_hitstop()

func setup_camera(camera: Camera2D) -> void:
	screenshake_camera = camera

func hitstop(duration_frames: int) -> void:
	hitstop_duration = duration_frames / 60.0
	Engine.time_scale = 0.0
	set_process(true)

func end_hitstop() -> void:
	Engine.time_scale = 1.0
	set_process(false)

func screenshake(intensity: float, duration: float) -> void:
	if not screenshake_camera:
		return
	
	var original_pos = screenshake_camera.global_position
	var tween = create_tween()
	
	var shake_count = int(duration * 60) 
	for i in shake_count:
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(
			screenshake_camera, 
			"global_position", 
			original_pos + shake_offset, 
			1.0/60.0
		)
	
	tween.tween_property(
		screenshake_camera, 
		"global_position", 
		original_pos, 
		0.1
	)
