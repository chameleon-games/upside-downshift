extends Area3D



# This lets you select your level_2.tscn file directly from the Inspector!
@export_file("*.tscn") var next_level_scene: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.name == "Player" or body.is_in_group("player"):
		if next_level_scene != "":
			FadeTransition.change_scene(next_level_scene)
		else:
			print("Oops! You forgot to assign your next level scene in the Inspector!")
