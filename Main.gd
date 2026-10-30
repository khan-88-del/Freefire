extends Node3D

var ground_tex: Texture2D

func _ready():
	# Daylight & Sky
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.48, 0.70, 0.98)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.9, 0.9)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 35, 0)
	sun.light_energy = 1.3
	add_child(sun)

	# Raw Ground Texture load
	var p = "res://assets/textures/Terrain_Ground_01_D.png"
	if FileAccess.file_exists(p):
		var img = Image.new()
		if img.load(p) == OK:
			ground_tex = ImageTexture.create_from_image(img)

	# 207MB Bermuda Map Load
	var map_path = "res://assets/map/Bermuda_Map.glb"
	if ResourceLoader.exists(map_path):
		var map_scn = load(map_path)
		if map_scn:
			var map_inst = map_scn.instantiate()
			add_child(map_inst)
			_setup_map(map_inst)

	# Joystick UI Layer
	var ui = CanvasLayer.new()
	ui.name = "UI"
	ui.set_script(load("res://Joystick.gd"))
	add_child(ui)

	# Player Spawn
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var p_inst = player_scn.instantiate()
		p_inst.position = Vector3(0, 15.0, 0)
		add_child(p_inst)

func _setup_map(node: Node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
		var n_lower = node.name.to_lower()
		
		# White floor / terrain fix: apply terrain texture on large ground meshes
		if "ground" in n_lower or "terrain" in n_lower or "plane" in n_lower or node.name.begins_with("Mesh"):
			var m = node.mesh
			if m:
				for s in range(m.get_surface_count()):
					var mat = StandardMaterial3D.new()
					if ground_tex:
						mat.albedo_texture = ground_tex
						mat.uv1_scale = Vector3(50, 50, 50)
					else:
						mat.albedo_color = Color(0.28, 0.42, 0.22)
					node.set_surface_override_material(s, mat)

	for c in node.get_children():
		_setup_map(c)
