extends Node3D

var ground_tex: Texture2D = null

func _ready():
	# Sky & Sun
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.68, 0.98)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.85, 0.85)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 35, 0)
	sun.light_energy = 1.2
	add_child(sun)

	# Asli Ground Texture direct binary load
	ground_tex = _force_load_texture()

	# 207MB Map
	var map_path = "res://assets/map/Bermuda_Map.glb"
	if ResourceLoader.exists(map_path):
		var map_scn = load(map_path)
		if map_scn:
			var map_inst = map_scn.instantiate()
			add_child(map_inst)
			_apply_all_surfaces(map_inst)

	# UI Joystick Add
	var ui = CanvasLayer.new()
	ui.name = "UI"
	ui.set_script(load("res://Joystick.gd"))
	add_child(ui)

	# Player Spawn
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var p = player_scn.instantiate()
		p.position = Vector3(0, 10.0, 0)
		add_child(p)

func _force_load_texture() -> Texture2D:
	var path = "res://assets/textures/Terrain_Ground_01_D.png"
	if not FileAccess.file_exists(path):
		path = "res://assets/textures/Terrain_Ground_02_D.png"
	
	if FileAccess.file_exists(path):
		var img = Image.new()
		if img.load(path) == OK:
			return ImageTexture.create_from_image(img)
	return null

func _apply_all_surfaces(node: Node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var mat = mesh.surface_get_material(i)
				# Agar surface untextured ya white hai, toh turant ground texture chipkao
				if mat == null or mat.albedo_texture == null:
					var new_mat = StandardMaterial3D.new()
					if ground_tex:
						new_mat.albedo_texture = ground_tex
						new_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
						new_mat.uv1_scale = Vector3(50, 50, 50)
					else:
						new_mat.albedo_color = Color(0.35, 0.5, 0.25)
					node.set_surface_override_material(i, new_mat)

	for c in node.get_children():
		_apply_all_surfaces(c)
