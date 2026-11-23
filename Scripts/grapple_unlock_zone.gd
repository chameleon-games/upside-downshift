extends Area3D


var is_triggered: bool = false

func _ready():
	# Explicitly activate the engine signals
	monitoring = true

func _on_body_entered(body: Node):
	if not is_triggered and body is CharacterBody3D:
		if "grapple_unlocked" in body:
			is_triggered = true
			
			# 1. Instantly flip the unlock switches safely!
			body.set("grapple_unlocked", true)
			body.grapple_unlocked = true
			print("PLAYER SECURED GRAPPLING HOOK - SYSTEM ACTIVE!")
			
			# 2. Turn off collisions instantly so Jolt doesn't track it anymore
			monitoring = false
			monitorable = false
			
			# 3. Wipe it out of existence immediately (No zero-scale physics crash!)
			queue_free()
