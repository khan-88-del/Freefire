extends Node3D

func _ready():
	print("Initializing Game World...")

	# 1. Daylight & Sky Setup
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

	# 2. Map Load and Automatic Collision Generation
	var map_path = "res://Bermuda_Mesh.glb"
	if not ResourceLoader.exists(map_path):
		map_path = "res://assets/map/Bermuda_Mesh.glb"

	if ResourceLoader.exists(map_path):
		var map_scene = load(map_path)
		if map_scene:
			var map_inst = map_scene.instantiate()
			add_child(map_inst)
			_generate_collisions(map_inst)
			print("Map loaded with full ground collisions!")

	# 3. Joystick UI
	if ResourceLoader.exists("res://Joystick.gd"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.set_script(load("res://Joystick.gd"))
		add_child(ui)

	# 4. Spawn Player safely on ground
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var player = player_scn.instantiate()
		player.position = Vector3(0, 5.0, 0)
		add_child(player)
		print("Player spawned safely on ground!")

# Function to recursively add collision to all ground meshes
func _generate_collisions(node: Node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
	for child in node.get_children():
		_generate_collisions(child)
