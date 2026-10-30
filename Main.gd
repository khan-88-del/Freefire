extends Node3D

var loaded_textures: Dictionary = {}

func _ready():
	print("Game initialize ho raha hai...")

	# Daylight & Sky
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.65, 0.95)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.85, 0.85)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.3
	add_child(sun)

	# Textures memory me preload karein
	_preload_textures()

	# Map load karein
	var map_path = "res://Bermuda_Mesh.glb"
	if not ResourceLoader.exists(map_path):
		map_path = "res://assets/map/Bermuda_Mesh.glb"

	if ResourceLoader.exists(map_path):
		var map_scene = load(map_path)
		if map_scene:
			var map_inst = map_scene.instantiate()
			add_child(map_inst)
			_setup_map_nodes(map_inst)
			print("Map successfully loaded with full textures and collisions!")

	# Joystick UI load karein
	if ResourceLoader.exists("res://Joystick.gd"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.set_script(load("res://Joystick.gd"))
		add_child(ui)

	# Spawn Player
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var player = player_scn.instantiate()
		player.position = Vector3(0, 5.0, 0)
		add_child(player)
		print("Player spawned safely on ground!")

func _preload_textures():
	var dir = DirAccess.open("res://assets/textures")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and not file_name.ends_with(".import"):
				var full_path = "res://assets/textures/" + file_name
				var tex = load(full_path)
				if tex is Texture2D:
					var clean_key = file_name.get_basename().to_lower()
					loaded_textures[clean_key] = tex
			file_name = dir.get_next()
	print("Total loaded textures: ", loaded_textures.size())

func _setup_map_nodes(node: Node):
	if node is MeshInstance3D:
		# 1. Physics collision create karein
		node.create_trimesh_collision()
		
		# 2. Material aur textures apply karein
		var mesh = node.mesh
		if mesh:
			for surface_idx in range(mesh.get_surface_count()):
				var mat = node.get_surface_override_material(surface_idx)
				if not mat:
					mat = mesh.surface_get_material(surface_idx)
				
				if mat is StandardMaterial3D:
					mat = mat.duplicate()
				else:
					mat = StandardMaterial3D.new()

				# Matching texture dhundhein node ya material ke naam se
				var assigned_tex = _find_matching_texture(node.name)
				if assigned_tex:
					mat.albedo_texture = assigned_tex
					mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
					node.set_surface_override_material(surface_idx, mat)

	for child in node.get_children():
		_setup_map_nodes(child)

func _find_matching_texture(node_name: String) -> Texture2D:
	var n_lower = node_name.to_lower()
	for key in loaded_textures.keys():
		if key in n_lower or n_lower in key:
			return loaded_textures[key]
	
	# Fallback terrain / ground texture
	for key in loaded_textures.keys():
		if "terrain" in key or "ground" in key:
			return loaded_textures[key]
			
	return null
