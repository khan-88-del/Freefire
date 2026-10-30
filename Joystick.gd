extends CanvasLayer

signal move_vector(vec: Vector2)
signal camera_rotate(relative: Vector2)

var touch_id_stick: int = -1
var touch_id_cam: int = -1

var stick_center: Vector2 = Vector2(280, 800)
var stick_knob: Vector2 = Vector2(280, 800)
var radius: float = 140.0
var knob_radius: float = 55.0

func _ready():
	layer = 100
	_update_positions()

func _update_positions():
	var v_size = get_viewport().get_visible_rect().size
	stick_center = Vector2(v_size.x * 0.16, v_size.y * 0.75)
	stick_knob = stick_center
	queue_redraw()

func _input(event):
	var v_size = get_viewport().get_visible_rect().size

	if event is InputEventScreenTouch:
		if event.pressed:
			# Left Half: Touch par Joystick move hoga
			if event.position.x < v_size.x * 0.45 and touch_id_stick == -1:
				touch_id_stick = event.index
				stick_center = event.position
				stick_knob = event.position
				queue_redraw()
			# Right Half: Camera swipe
			elif event.position.x >= v_size.x * 0.45 and touch_id_cam == -1:
				touch_id_cam = event.index
		else:
			if event.index == touch_id_stick:
				touch_id_stick = -1
				_update_positions()
				emit_signal("move_vector", Vector2.ZERO)
			elif event.index == touch_id_cam:
				touch_id_cam = -1

	elif event is InputEventScreenDrag:
		if event.index == touch_id_stick:
			var diff = event.position - stick_center
			if diff.length() > radius:
				diff = diff.normalized() * radius
			stick_knob = stick_center + diff
			emit_signal("move_vector", diff / radius)
			queue_redraw()
		elif event.index == touch_id_cam:
			emit_signal("camera_rotate", event.relative)

func _draw():
	# Outer Joystick Ring
	draw_circle(stick_center, radius, Color(0.0, 0.0, 0.0, 0.35))
	draw_arc(stick_center, radius, 0, TAU, 32, Color(1.0, 1.0, 1.0, 0.8), 5.0)
	# Inner Active Knob
	draw_circle(stick_knob, knob_radius, Color(1.0, 0.8, 0.0, 0.85))
	draw_arc(stick_knob, knob_radius, 0, TAU, 24, Color(1.0, 1.0, 1.0, 0.9), 3.0)
