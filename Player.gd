extends CharacterBody3D

@export var speed: float = 6.5
var gravity: float = 9.8
var input_dir: Vector2 = Vector2.ZERO

var spring_arm: SpringArm3D
var model_node: Node3D
var anim_player: AnimationPlayer

func _ready():
	var ui = get_node_or_null("../UI")
	if ui:
		ui.connect("move_vector", Callable(self, "_on_move_vector"))
		ui.connect("camera_rotate", Callable(self, "_on_camera_rotate"))

	# Camera Setup (Right shoulder third-person)
	spring_arm = SpringArm3D.new()
	spring_arm.position = Vector3(0.4, 1.6, 0.0)
	spring_arm.spring_length = 3.2
	spring_arm.margin = 0.2
	add_child(spring_arm)

	var cam = Camera3D.new()
	cam.current = true
	cam.fov = 70.0
	spring_arm.add_child(cam)

	# Model container
	model_node = Node3D.new()
	add_child(model_node)

	# Character model load
	if ResourceLoader.exists("res://assets/player/ns_twins_3d_model.glb"):
		var glb = load("res://assets/player/ns_twins_3d_model.glb").instantiate()
		# Player face camera se opposite (peeth camera ki taraf)
		glb.rotation.y = deg_to_rad(180)
		model_node.add_child(glb)
		
		# AnimationPlayer search
		anim_player = _find_anim_player(glb)

	# Animations load & register
	_setup_animations()

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for c in node.get_children():
		var ap = _find_anim_player(c)
		if ap: return ap
	return null

func _setup_animations():
	if not anim_player:
		anim_player = AnimationPlayer.new()
		add_child(anim_player)

	var anim_dict = {
		"idle": "res://assets/anims/idle.glb",
		"walk_f": "res://assets/anims/Walk_F.glb",
		"walk_b": "res://assets/anims/Walk_B.glb",
		"walk_l": "res://assets/anims/Walk_L.glb",
		"walk_r": "res://assets/anims/Walk_R.glb"
	}

	for k in anim_dict.keys():
		var path = anim_dict[k]
		if ResourceLoader.exists(path):
			var glb_anim = load(path).instantiate()
			var ap = _find_anim_player(glb_anim)
			if ap:
				var anim_list = ap.get_animation_list()
				if anim_list.size() > 0:
					var a = ap.get_animation(anim_list[0])
					a.loop_mode = Animation.LOOP_LINEAR
					var lib = anim_player.get_animation_library("")
					if not lib:
						lib = AnimationLibrary.new()
						anim_player.add_animation_library("", lib)
					lib.add_animation(k, a)

	if anim_player.has_animation("idle"):
		anim_player.play("idle")

func _on_move_vector(vec: Vector2):
	input_dir = vec

func _on_camera_rotate(relative: Vector2):
	rotate_y(deg_to_rad(-relative.x * 0.22))
	if spring_arm:
		spring_arm.rotate_x(deg_to_rad(-relative.y * 0.18))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-50), deg_to_rad(28))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var forward = -transform.basis.z
	var right = transform.basis.x
	var move = (right * input_dir.x + forward * -input_dir.y).normalized()

	if input_dir.length() > 0.1:
		velocity.x = move.x * speed
		velocity.z = move.z * speed
		
		# 4 Directions walk animations handling
		if anim_player:
			if abs(input_dir.x) > abs(input_dir.y):
				if input_dir.x > 0 and anim_player.current_animation != "walk_r":
					anim_player.play("walk_r")
				elif input_dir.x < 0 and anim_player.current_animation != "walk_l":
					anim_player.play("walk_l")
			else:
				if input_dir.y < 0 and anim_player.current_animation != "walk_f":
					anim_player.play("walk_f")
				elif input_dir.y > 0 and anim_player.current_animation != "walk_b":
					anim_player.play("walk_b")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		if anim_player and anim_player.current_animation != "idle":
			anim_player.play("idle")

	move_and_slide()
