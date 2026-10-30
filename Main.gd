extends Node3D

var texture_cache: Dictionary = {}

func _ready():
	# 1. Lighting aur Sky
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.68, 0.98)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.85, 0.85)
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.2
	add_child(sun)

	# 2. Textures load karein
	_load_textures()

	# 3. Bermuda Map load karein
	var map_path = "res://Bermuda_Mesh.glb"
	if not ResourceLoader.exists(map_path):
		map_path = "res://assets/map/Bermuda_Mesh.glb"

	if ResourceLoader.exists(map_path):
		var map_scene = load(map_path)
		if map_scene:
			var map_inst = map_scene.instantiate()
			add_child(map_inst)
			_apply_correct_materials(map_inst)
			print("Map successfully mapped with real PNG textures!")

	# 4. Joystick UI
	if ResourceLoader.exists("res://Joystick.gd"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.set_script(load("res://Joystick.gd"))
		add_child(ui)

	# 5. Spawn Player safely on ground
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var player = player_scn.instantiate()
		player.position = Vector3(0, 10.0, 0)
		add_child(player)

func _load_textures():
	var dir = DirAccess.open("res://assets/textures")
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if not dir.current_is_dir() and not fname.ends_with(".import"):
				var ext = fname.get_extension().to_lower()
				if ext in ["png", "jpg", "jpeg"]:
					var t = load("res://assets/textures/" + fname)
					if t is Texture2D:
						# Clean key jaise 'container_a', 'brickroad_01', 'concrete_wall'
						var key = fname.get_basename().to_lower()
						texture_cache[key] = t
			fname = dir.get_next()
	print("Cached texture count: ", texture_cache.size())

func _apply_correct_materials(node: Node):
	if node is MeshInstance3D:
		# Physics collision har surface ke liye (zameen, building, roof)
		node.create_trimesh_collision()
		
		var mesh = node.mesh
		if mesh:
			for s_idx in range(mesh.get_surface_count()):
				var original_mat = mesh.surface_get_material(s_idx)
				var mat_name = ""
				if original_mat:
					mat_name = original_mat.resource_name.to_lower()
				
				var node_name = node.name.to_lower()
				var matched_tex = _match_texture(mat_name, node_name)
				
				if matched_tex:
					var new_mat = StandardMaterial3D.new()
					new_mat.albedo_texture = matched_tex
					new_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
					
					# Agar zameen ya road ho toh tiling set karein
					if "terrain" in mat_name or "terrain" in node_name or "ground" in mat_name or "road" in mat_name:
						new_mat.uv1_scale = Vector3(15, 15, 15)
					else:
						new_mat.uv1_scale = Vector3(1, 1, 1)
					
					node.set_surface_override_material(s_idx, new_mat)

	for child in node.get_children():
		_apply_correct_materials(child)

func _match_texture(mat_name: String, node_name: String) -> Texture2D:
	# 1. Exact / sub-string match check
	for key in texture_cache.keys():
		if key in mat_name or (mat_name != "" and mat_name in key):
			return texture_cache[key]
		if key in node_name or node_name in key:
			return texture_cache[key]

	# 2. Smart Category Matching
	var combined = mat_name + "_" + node_name

	if "container" in combined:
		for k in texture_cache.keys():
			if "container" in k: return texture_cache[k]
			
	if "wall" in combined or "fence" in combined:
		for k in texture_cache.keys():
			if "wall" in k or "fence" in k: return texture_cache[k]

	if "indoor" in combined or "floor" in combined:
		for k in texture_cache.keys():
			if "indoor" in k or "floor" in k: return texture_cache[k]

	if "road" in combined:
		for k in texture_cache.keys():
			if "road" in k or "brick" in k: return texture_cache[k]

	if "terrain" in combined or "ground" in combined or "grass" in combined:
		for k in texture_cache.keys():
			if "terrain" in k or "ground" in k: return texture_cache[k]

	if "metal" in combined or "dam" in combined or "roof" in combined:
		for k in texture_cache.keys():
			if "metal" in k or "dam" in k: return texture_cache[k]

	return null
