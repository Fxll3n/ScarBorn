extends Label

const LBL_TEXT: String = "FPS(CUR):\t\t%s\nFPS(AVG):\t\t%s"

var last_fps: Array[float] = []

func _ready() -> void:
	text = LBL_TEXT

func _process(delta: float) -> void:
	last_fps.insert(0, Engine.get_frames_per_second())
	if last_fps.size() > 100:
		last_fps.pop_back()
	text = LBL_TEXT % [last_fps.get(0), get_avg_fps()]

func get_avg_fps() -> float:
	var avg: float = 0
	
	for count in last_fps:
		avg += count
	
	return avg / last_fps.size()
