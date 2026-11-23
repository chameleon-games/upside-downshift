extends Node3D

@onready var mesh = $MeshInstance3D
@onready var collection_zone = $CollectionZone

@export_multiline var pickup_message: String = "GRAPPLING HOOK UNLOCKED!\nHold RIGHT-CLICK to grapple and swing onto surfaces.\n\n[Press SPACE or CLICK to continue]"

var is_collected: bool = false

func _ready():
	if collection_zone:
		collection_zone.body_entered.connect(_on_body_entered)

func _process(delta):
	if mesh:
		mesh.rotate_y(1.5 * delta)

func _on_body_entered(body: Node):
	if not is_collected and body is CharacterBody3D:
		is_collected = true
		
		# Give the player the grapple ability safely
		if "grapple_unlocked" in body:
			body.grapple_unlocked = true
		
		# Animate the mesh shrinking
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 0.25)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN)
		await tween.finished
		
		# Show the dimmed screen + bottom instruction popup!
		var popup = get_tree().current_scene.find_child("PickupPopup", true, false)
		if popup and popup.has_method("show_pickup"):
			popup.show_pickup(pickup_message)
		
		queue_free()
