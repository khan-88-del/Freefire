extends Node3D

var ground_texture: Texture2D = null

func _ready():
	# 1. Environment & Sun
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.48, 0.70, 0.98)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.85, 0.85)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 35, 0)
	sun.light_energy = 1.3
	add_child(sun)

	# 2. Asli Terrain Ground Texture dhoondhein aur load karein
	ground_texture = _get_real_ground_tex()

	# 3. 207MB Bermuda Map Load
	var map_path = "res://assets/map/Bermuda_Map.glb"
	if ResourceLoader.exists(map_path):
		var map_scn = load(map_path)
		if map_scn:
			var map_inst = map_scn.instantiate()
			add_child(map_inst)
			_setup_map(map_inst)

	# 4. Visible Touch Joystick Layer
	var ui = CanvasLayer.new()
	ui.name = "UI"
	ui.set_script(load("res://Joystick.gd"))
	add_child(ui)

	# 5. Spawn Player
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var p_inst = player_scn.instantiate()
		p_inst.position = Vector3(0, 15.0, 0)
		add_child(p_inst)

func _get_real_ground_tex() -> Texture2D:
	var candidates = [
		"res://assets/textures/Terrain_Ground_01_D.png",
		"res://assets/textures/Terrain_Ground_02_D.png",
		"res://assets/textures/Arabian_Nights_Ground_D.png"
	]
	for path in candidates:
		if FileAccess.file_exists(path):
			var img = Image.new()
			if img.load(path) == OK:
				return ImageTexture.create_from_image(img)
	
	# Directory se scan karein agar exact name me fark ho
	var dir = DirAccess.open("res://assets/textures")
	if dir:
		dir.list_dir_begin()
		var fn = dir.get_next()
		while fn != "":
			if "terrain" in fn.lower() or "ground" in fn.lower():
				var p = "res://assets/textures/" + fn
				var img = Image.new()
				if img.load(p) == OK:
					return ImageTexture.create_from_image(img)
			fn = dir.get_next()
	return null

func _setup_map(node: Node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
		var n_name = node.name.to_lower()

		# Sirf ground surface par actual tiled ground texture lagana
		if "terrain" in n_name or "ground" in n_name or "plane" in n_name:
			var m = node.mesh
			if m:
				for s in range(m.get_surface_count()):
					if ground_texture:
						var mat = StandardMaterial3D.new()
						mat.albedo_texture = ground_texture
						mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
						mat.uv1_scale = Vector3(60, 60, 60)
						node.set_surface_override_material(s, mat)

	for c in node.get_children():
		_setup_map(c)
