extends AnimatableBody3D

# Customize how far the door drops and how fast it slides in the inspector!
@export var slide_offset: Vector3 = Vector3(0, -5.0, 0) # Default: Drops down 5 units
@export var slide_duration: float = 0.8

@onready var open_position: Vector3 = global_position + slide_offset

func _ready():
	# Recalculate target relative position in case the door was shifted in the editor
	open_position = global_position + slide_offset

func open_door():
	# Code-based animation engine (Tween) handles the entire sliding motion smoothly!
	var door_tween = create_tween()
	door_tween.tween_property(self, "global_position", open_position, slide_duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
