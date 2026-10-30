extends Node3D

func _ready():
	print("Game Loading with New Embedded Map...")

	# Daylight & Sky
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

	# 207MB Bermuda Map Load
	var map_path = "res://assets/map/Bermuda_Map.glb"
	if ResourceLoader.exists(map_path):
		var map_scn = load(map_path)
		if map_scn:
			var map_inst = map_scn.instantiate()
			add_child(map_inst)
			_add_collisions(map_inst)
			print("New 207MB map successfully loaded!")

	# Joystick UI
	if ResourceLoader.exists("res://Joystick.gd"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.set_script(load("res://Joystick.gd"))
		add_child(ui)

	# Spawn Player
	var player_scn = load("res://Player.tscn")
	if player_scn:
		var p = player_scn.instantiate()
		p.position = Vector3(0, 15.0, 0)
		add_child(p)

# Sabhi surfaces par solid collision create karein
func _add_collisions(node: Node):
	if node is MeshInstance3D:
		node.create_trimesh_collision()
	for c in node.get_children():
		_add_collisions(c)
