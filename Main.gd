extends Node3D

var default_ground_tex: Texture2D = null

func _ready():
	# 1. Environment & Sun Light Setup
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.68, 0.98)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.65, 0.65, 0.65)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 45, 0)
	sun.light_energy = 1.0
	add_child(sun)

	# 2. Primary Ground Texture load karein
	var primary_tex_path = ""
	var dir = DirAccess.open("res://assets/textures")
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if not dir.current_is_dir() and fname.ends_with(".png"):
				if "terrain" in fname.lower() or "ground" in fname.lower() or "floor" in fname.lower() or "brick" in fname.lower():
					primary_tex_path = "res://assets/textures/" + fname
					break
			fname = dir.get_next()

	if primary_tex_path != "" and ResourceLoader.exists(primary_tex_path):
		default_ground_tex = load(primary_tex_path)

	# 3. Bermuda Map load aur mesh textures fix karein
	var map_path = "res://Bermuda_Mesh.glb"
	if not ResourceLoader.exists(map_path):
		map_path = "res://assets/map/Bermuda_Mesh.glb"

	if ResourceLoader.exists(map_path):
		var map_scene = load(map_path)
		if map_scene:
			var map_inst = map_scene.instantiate()
			add_child(map_inst)
			_apply_textures_and_physics(map_inst)

	# 4. Joystick UI
	if ResourceLoader.exists("res://Joystick.gd"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.set_script(load("res://Joystick.gd"))
		add_child(ui)

	# 5. Spawn Player safely above ground
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var player = player_scn.instantiate()
		player.position = Vector3(0, 15.0, 0)
		add_child(player)

func _apply_textures_and_physics(node: Node):
	if node is MeshInstance3D:
		# Ground Collision
		node.create_trimesh_collision()
		
		var mesh = node.mesh
		if mesh:
			for surface_idx in range(mesh.get_surface_count()):
				var mat = StandardMaterial3D.new()
				
				# Texture Assign
				if default_ground_tex:
					mat.albedo_texture = default_ground_tex
					mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
					mat.uv1_scale = Vector3(30, 30, 30) # Proper tiled map terrain
				else:
					# Agar texture miss ho toh realistic terrain green/dirt color set karein (white wash fix)
					mat.albedo_color = Color(0.28, 0.42, 0.22)
				
				mat.roughness = 0.9
				node.set_surface_override_material(surface_idx, mat)

	for child in node.get_children():
		_apply_textures_and_physics(child)
