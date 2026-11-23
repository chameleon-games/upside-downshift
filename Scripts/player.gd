extends CharacterBody3D


var input_direction : Vector2
var speed : float

# --- GRAVITY FLIP PARAMETERS ---
var gravity_direction: int = 1 
var can_flip: bool = true
@export var flip_action: String = "flip"
@export var flip_cooldown: float = 0.5 
var spawn_position: Vector3 = Vector3.ZERO

# --- GRAPPLING SWING PARAMETERS ---
var grapple_unlocked: bool = false 
@export var level_2_scene: PackedScene 
@export var level_3_scene: PackedScene

@export var grapple_max_distance: float = 45.0  
@export var swing_air_acceleration: float = 18.0 
@export var reel_up_speed: float = 12.0          
var is_grappling: bool = false
var grapple_target_point: Vector3 = Vector3.ZERO
var grapple_rope_length: float = 0.0
var grapple_line: MeshInstance3D

# --- CAMERA & FOV PARAMETERS ---
@export var base_fov: float = 75.0       
@export var sprint_fov: float = 85.0     
@export var fov_change_speed: float = 8.0 

# --- CAMERA BOB PARAMETERS ---
@export var bob_frequency: float = 4.2     
@export var bob_amplitude: float = 0.06    
@export var bob_horizontal_amount: float = 0.03 

var bob_time: float = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera

@export var look_sensitivity: float = 0.005
@export var walk_speed = 5.0
@export var sprint_speed = 7.0
@export var sneak_speed = 2.0
@export var acceleration = 60.0
@export var jump_velocity: float = 6.5 
@export var air_control = 5.0
@export var air_resistance = 2.0

@onready var default_cam_y: float = camera.position.y
@onready var default_cam_x: float = camera.position.x

# --- AUDIO FOOTSTEP SYSTEM ---
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
var step_distance_tracker: float = 0.0

func _ready():
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spawn_position = global_position
	
	var current_path = get_tree().current_scene.scene_file_path
	if (level_2_scene and current_path == level_2_scene.resource_path) or (level_3_scene and current_path == level_3_scene.resource_path):
		grapple_unlocked = true
	else:
		grapple_unlocked = false
	
	grapple_line = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.035
	cyl.bottom_radius = 0.035
	cyl.height = 1.0
	grapple_line.mesh = cyl
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.0, 1.0, 1.0)
	grapple_line.material_override = mat
	grapple_line.visible = false
	grapple_line.top_level = true
	add_child(grapple_line)
	
	var hud_layer = CanvasLayer.new()
	var crosshair = ColorRect.new()
	crosshair.color = Color(1.0, 1.0, 1.0, 0.8) 
	crosshair.custom_minimum_size = Vector2(6, 6) 
	
	hud_layer.add_child(crosshair)
	add_child(hud_layer)
	
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * look_sensitivity * gravity_direction)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var is_grounded = is_on_floor()

	if Input.is_action_just_pressed(flip_action) and can_flip:
		flip_gravity()
		can_flip = false
		get_tree().create_timer(flip_cooldown).timeout.connect(func(): can_flip = true)

	if Input.is_action_pressed("click_right") and grapple_unlocked:
		if not is_grappling:
			launch_grapple_hook()
	else:
		is_grappling = false

	if not is_grounded:
		velocity.y -= 18.0 * gravity_direction * delta
	
	var target_fov = base_fov
	if Input.is_action_pressed("sprint") and velocity.length() > 0.1:
		speed = sprint_speed
		target_fov = sprint_fov 
	elif Input.is_action_pressed("sneak"):
		speed = sneak_speed
	else:
		speed = walk_speed
		
	camera.fov = lerp(camera.fov, target_fov, delta * fov_change_speed)
	
	if Input.is_action_just_pressed("jump") and is_grounded:
		velocity.y = jump_velocity * gravity_direction

	input_direction = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	var target_velocity = direction * speed

	if is_grappling:
		can_flip = true
		draw_grapple_line()
		
		grapple_rope_length = move_toward(grapple_rope_length, 7.0, reel_up_speed * delta)
		
		if direction != Vector3.ZERO:
			velocity.x += direction.x * swing_air_acceleration * delta
			velocity.z += direction.z * swing_air_acceleration * delta
			
		var vector_to_anchor = global_position - grapple_target_point
		var current_distance = vector_to_anchor.length()
		
		if current_distance > grapple_rope_length:
			var outward_direction = vector_to_anchor.normalized()
			var outward_velocity = velocity.dot(outward_direction)
			if outward_velocity > 0:
				velocity -= outward_direction * outward_velocity
				
			global_position = grapple_target_point + outward_direction * grapple_rope_length
	else:
		clear_grapple_line()
		
		if is_grounded:
			var current_accel = acceleration if direction else acceleration * 2.0
			velocity.x = move_toward(velocity.x, target_velocity.x, current_accel * delta)
			velocity.z = move_toward(velocity.z, target_velocity.z, current_accel * delta)
		else:
			if direction:
				velocity.x = move_toward(velocity.x, target_velocity.x, air_control * delta)
				velocity.z = move_toward(velocity.z, target_velocity.z, air_control * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, air_resistance * delta)
				velocity.z = move_toward(velocity.z, 0, air_resistance * delta)
	
	var horizontal_speed = Vector3(velocity.x, 0, velocity.z).length()
	if is_grounded and horizontal_speed > 0.1:
		bob_time += delta * horizontal_speed * (bob_frequency / 2.0)
		var new_y = default_cam_y + sin(bob_time) * bob_amplitude
		var new_x = default_cam_x + cos(bob_time / 2.0) * bob_horizontal_amount
		camera.position.y = lerp(camera.position.y, new_y, delta * 10.0)
		camera.position.x = lerp(camera.position.x, new_x, delta * 10.0)
		
		step_distance_tracker += delta * horizontal_speed
		var step_gap_threshold = 2.2 if speed == sprint_speed else 1.6
		
		if step_distance_tracker >= step_gap_threshold:
			if footstep_player:
				footstep_player.stop() 
				footstep_player.play()
				footstep_player.pitch_scale = randf_range(0.93, 1.07)
			step_distance_tracker = 0.01 
			
		if footstep_player and footstep_player.playing and step_distance_tracker > 0.4:
			footstep_player.stop()
	else:
		bob_time = 0.0
		step_distance_tracker = 0.0
		if footstep_player and footstep_player.playing:
			footstep_player.stop()
			
		camera.position.y = lerp(camera.position.y, default_cam_y, delta * 10.0)
		camera.position.x = lerp(camera.position.x, default_cam_x, delta * 10.0)
	
	move_and_slide()

func launch_grapple_hook():
	var space_state = get_world_3d().direct_space_state
	var center_of_screen = get_viewport().size / 2
	
	var from = camera.project_ray_origin(center_of_screen)
	var to = from + camera.project_ray_normal(center_of_screen) * grapple_max_distance
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		grapple_target_point = result.position
		grapple_rope_length = (global_position - grapple_target_point).length()
		is_grappling = true

func draw_grapple_line():
	grapple_line.visible = true
	
	# Offset slightly down & right from the camera so it comes from your "hand" instead of your eyeballs!
	var hand_offset = (camera.global_transform.basis.x * 0.35) + (camera.global_transform.basis.y * -0.25) + (-camera.global_transform.basis.z * 0.4)
	var start_pos = camera.global_position + hand_offset
	var end_pos = grapple_target_point
	
	var distance = start_pos.distance_to(end_pos)
	if distance < 0.01:
		return
	
	# Position the cylinder right in the middle between your hand and the grapple target
	grapple_line.global_position = (start_pos + end_pos) * 0.5
	
	# Point it toward the grapple target and tilt 90 degrees so the cylinder aligns with the target
	grapple_line.look_at(end_pos, Vector3.UP)
	grapple_line.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	
	# Stretch the cylinder height to match the exact rope length!
	grapple_line.scale = Vector3(1.0, distance, 1.0)

func clear_grapple_line():
	if grapple_line:
		grapple_line.visible = false

func flip_gravity():
	gravity_direction *= -1
	up_direction = Vector3(0, 1 if gravity_direction == 1 else -1, 0)
	velocity.y += 0.1 * gravity_direction
	
	var target_roll = 180.0 if gravity_direction == -1 else 0.0
	var tween = create_tween()
	tween.tween_property(head, "rotation_degrees:z", target_roll, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	get_tree().call_group("gravity_objects", "respond_to_gravity_shift", gravity_direction)

func die():
	get_tree().reload_current_scene()
	global_position = spawn_position
	velocity = Vector3.ZERO
	
	# Reset the grapple hook on death!
	grapple_unlocked = false
	is_grappling = false
	clear_grapple_line()
	
	if gravity_direction == -1:
		flip_gravity()
