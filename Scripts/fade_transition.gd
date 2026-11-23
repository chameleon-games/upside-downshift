extends CanvasLayer

@onready var rect: ColorRect = $ColorRect
var is_transitioning: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene(target_path: String, fade_time: float = 0.45) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	# 1. Fade to black
	var tween_out = create_tween()
	tween_out.tween_property(rect, "color:a", 1.0, fade_time)
	await tween_out.finished
	
	# 2. Switch to the next level while screen is black
	get_tree().change_scene_to_file(target_path)
	
	# 3. Fade back in from black
	var tween_in = create_tween()
	tween_in.tween_property(rect, "color:a", 0.0, fade_time)
	await tween_in.finished
	
	is_transitioning = false
