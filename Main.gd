extends Node3D

@onready var camera = $Camera3D

var touch_points = {}
var sensitivity = 0.005
var move_speed = 0.5

func _ready():
	var env = WorldEnvironment.new()
	var env_res = Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.12, 0.15, 0.2, 1.0)
	env.environment = env_res
	add_child(env)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
			
	elif event is InputEventScreenDrag:
		# Single touch swipe: Camera idhar-udhar ghumane ke liye
		if touch_points.size() <= 1:
			camera.rotation.y -= event.relative.x * sensitivity
			camera.rotation.x -= event.relative.y * sensitivity
			camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(85), deg_to_rad(85))
		
		# Two touch swipe: Map me aage/peeche/upar move karne ke liye
		elif touch_points.size() >= 2:
			var forward = -camera.global_transform.basis.z
			var right = camera.global_transform.basis.x
			camera.global_position += (right * -event.relative.x + forward * -event.relative.y) * 0.1
