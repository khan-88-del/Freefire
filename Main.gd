extends Node3D

var ground_tex: Texture2D

func _ready():
	# Lighting & Environment
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.48, 0.70, 0.98)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.9, 0.9)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 40, 0)
	sun.light_energy = 1.3
	add_child(sun)

	# Direct Image file load (Bina Godot import cache ke)
	var img_path = "res://assets/textures/ground.png"
	if FileAccess.file_exists(img_path):
		var img = Image.new()
		if img.load(img_path) == OK:
			ground_tex = ImageTexture.create_from_image(img)

	# Map load
	var map_path = "res://assets/map/Bermuda_Map.glb"
	if ResourceLoader.exists(map_path):
		var scn = load(map_path)
		if scn:
			var inst = scn.instantiate()
			add_child(inst)
			_fix_all_white_surfaces(inst)

	# Joystick UI
	var ui = CanvasLayer.new()
	ui.name = "UI"
	ui.set_script(load("res://Joystick.gd"))
	add_child(ui)

	# Player Spawn
	var p_scn = load("res://Player.tscn")
	if p_scn:
		var p = p_scn.instantiate()
		p.position = Vector3(0, 15.0, 0)
		add_child(p)

func _fix_all_white_surfaces(node: Node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var old_mat = mesh.surface_get_material(i)
				# Agar container ya metal car na ho toh zameen aur raste par ground texture pakka lagao
				var n_name = node.name.to_lower()
				if not ("container" in n_name or "car" in n_name or "barrel" in n_name):
					var new_mat = StandardMaterial3D.new()
					if ground_tex:
						new_mat.albedo_texture = ground_tex
						new_mat.uv1_scale = Vector3(45, 45, 45)
					else:
						new_mat.albedo_color = Color(0.25, 0.45, 0.2)
					node.set_surface_override_material(i, new_mat)

	for c in node.get_children():
		_fix_all_white_surfaces(c)
