extends Node3D

var tex_ground: Texture2D
var tex_wall: Texture2D
var tex_road: Texture2D
var tex_container: Texture2D

func _ready():
	# Sky & Daylight
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
	sun.light_energy = 1.2
	add_child(sun)

	# Textures load karein
	_load_core_textures()

	# Map load karein
	var map_path = "res://Bermuda_Mesh.glb"
	if not ResourceLoader.exists(map_path):
		map_path = "res://assets/map/Bermuda_Mesh.glb"

	if ResourceLoader.exists(map_path):
		var map_scn = load(map_path)
		if map_scn:
			var map_inst = map_scn.instantiate()
			add_child(map_inst)
			_apply_textures_recursive(map_inst)

	# UI Joystick
	if ResourceLoader.exists("res://Joystick.gd"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.set_script(load("res://Joystick.gd"))
		add_child(ui)

	# Player Spawn
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var p = player_scn.instantiate()
		p.position = Vector3(0, 15.0, 0)
		add_child(p)

func _load_core_textures():
	tex_ground = _load_img("res://assets/textures/Terrain_Ground_01_D.png")
	tex_wall = _load_img("res://assets/textures/concrete_wall_01A_D.png")
	tex_road = _load_img("res://assets/textures/BrickRoad_01.png")
	tex_container = _load_img("res://assets/textures/Cargo_container_v1.png")

func _load_img(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		return ImageTexture.create_from_image(img)
	return null

func _apply_textures_recursive(node: Node):
	if node is MeshInstance3D:
		# Ground collision enable
		node.create_trimesh_collision()
		
		var m = node.mesh
		if m:
			var n_name = node.name.to_lower()
			for s in range(m.get_surface_count()):
				var mat = StandardMaterial3D.new()
				mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
				
				# Mesh type ke mutabiq direct texture force-bind
				if "road" in n_name:
					if tex_road: mat.albedo_texture = tex_road
					mat.uv1_scale = Vector3(10, 10, 10)
				elif "container" in n_name:
					if tex_container: mat.albedo_texture = tex_container
				elif "wall" in n_name or "fence" in n_name or "house" in n_name or "building" in n_name:
					if tex_wall: mat.albedo_texture = tex_wall
					mat.uv1_scale = Vector3(3, 3, 3)
				else:
					# Zameen / Terrain
					if tex_ground:
						mat.albedo_texture = tex_ground
						mat.uv1_scale = Vector3(40, 40, 40)
					else:
						mat.albedo_color = Color(0.3, 0.45, 0.25)
				
				node.set_surface_override_material(s, mat)

	for c in node.get_children():
		_apply_textures_recursive(c)
