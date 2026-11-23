extends CanvasLayer

@onready var label: Label = $PanelContainer/Label
var is_open: bool = false

func _ready() -> void:
	# Lets this popup keep running while the game behind it is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func show_pickup(message: String) -> void:
	label.text = message
	show()
	is_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Frees mouse while reading
	get_tree().paused = true

# And inside _unhandled_input when closing:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Locks mouse back for 3D look!
func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	
	# Close when the player presses Space, Enter, E, or Left Click
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		is_open = false
		hide()
		get_tree().paused = false
		get_viewport().set_input_as_handled()
