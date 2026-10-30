extends CharacterBody3D

@export var speed: float = 7.0
@export var rotation_speed: float = 12.0
var gravity: float = 9.8

var input_dir: Vector2 = Vector2.ZERO
var spring_arm: SpringArm3D
var model_node: Node3D

func _ready():
	# UI Signals connect karein
	var ui = get_node_or_null("../UI")
	if ui:
		if ui.has_signal("move_vector"):
			ui.connect("move_vector", Callable(self, "_on_move_vector"))
		if ui.has_signal("camera_rotate"):
			ui.connect("camera_rotate", Callable(self, "_on_camera_rotate"))

	# Camera & SpringArm setup
	spring_arm = SpringArm3D.new()
	spring_arm.position = Vector3(0.4, 1.5, 0.0)
	spring_arm.spring_length = 3.0
	spring_arm.margin = 0.2
	add_child(spring_arm)

	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 70.0
	spring_arm.add_child(cam)

	# Model load
	model_node = Node3D.new()
	add_child(model_node)
	
	if ResourceLoader.exists("res://assets/player/ns_twins_3d_model.glb"):
		var glb_res = load("res://assets/player/ns_twins_3d_model.glb")
		if glb_res:
			var m = glb_res.instantiate()
			model_node.add_child(m)

func _on_move_vector(vec: Vector2):
	input_dir = vec

func _on_camera_rotate(relative: Vector2):
	rotate_y(deg_to_rad(-relative.x * 0.25))
	if spring_arm:
		spring_arm.rotate_x(deg_to_rad(-relative.y * 0.2))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-50), deg_to_rad(30))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var forward = -transform.basis.z
	var right = transform.basis.x
	var move = (right * input_dir.x + forward * -input_dir.y).normalized()

	if move.length() > 0.05:
		velocity.x = move.x * speed
		velocity.z = move.z * speed
		var target_angle = atan2(-velocity.x, -velocity.z)
		if model_node:
			model_node.rotation.y = lerp_angle(model_node.rotation.y, target_angle - rotation.y, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
