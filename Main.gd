extends Node3D

func _ready():
	print("Bermuda Map Scene Loaded Successfully!")
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.1, 0.12, 0.15, 1.0)
	env.environment = env_res
	add_child(env)
