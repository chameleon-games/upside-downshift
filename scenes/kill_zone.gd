extends Area3D

func _ready():
	# Connect the engine signal that detects when a physics body enters this area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	# Confirm the object falling into the zone is your player by checking for its die() function
	if body.has_method("die"):
		body.die()
