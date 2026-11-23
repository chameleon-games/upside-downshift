extends Area3D



# Drag your SlidingDoor node into this slot inside the inspector panel!
@export var target_door: AnimatableBody3D

var is_activated: bool = false

func _ready():
	# Make sure the area is actively set to listen for collisions
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	# FIX: Checks if the object is a CharacterBody3D (your player) regardless of its name!
	if not is_activated and body is CharacterBody3D:
		is_activated = true
		
		# Smoothly push the physical button plate down into the floor slightly
		var switch_tween = create_tween()
		switch_tween.tween_property(self, "position:y", position.y - 0.15, 0.1)
		
		# If a door is cleanly linked, fire its transition slide!
		if target_door and target_door.has_method("open_door"):
			target_door.open_door()
		else:
			print("Switch pressed, but no valid Target Door is linked in the Inspector!")
