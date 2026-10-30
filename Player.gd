extends CharacterBody3D

@export var speed: float = 7.0
@export var rotation_speed: float = 12.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var input_dir: Vector2 = Vector2.ZERO
@onready var spring_arm = $SpringArm3D
@onready var model = $ModelNode

func _ready():
	var ui = get_node_or_null("../UI")
	if ui:
		ui.move_vector.connect(_on_move_vector)
		ui.camera_rotate.connect(_on_camera_rotate)

func _on_move_vector(vec: Vector2):
	input_dir = vec

func _on_camera_rotate(relative: Vector2):
	# Horizontal camera view (Free Fire look around)
	rotate_y(deg_to_rad(-relative.x * 0.25))
	# Vertical camera tilt
	if spring_arm:
		spring_arm.rotate_x(deg_to_rad(-relative.y * 0.2))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-55), deg_to_rad(30))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var forward = -transform.basis.z
	var right = transform.basis.x
	var move = (right * input_dir.x + forward * -input_dir.y).normalized()

	if move.length() > 0.05:
		velocity.x = move.x * speed
		velocity.z = move.z * speed
		# Character mesh smooth rotation moving direction me
		var target_angle = atan2(-velocity.x, -velocity.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle - rotation.y, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
