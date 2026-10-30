extends CanvasLayer

signal move_vector(vec: Vector2)
signal camera_rotate(relative: Vector2)

var touch_id_stick: int = -1
var touch_id_cam: int = -1
var base_pos: Vector2 = Vector2(250, 520)
var current_pos: Vector2 = Vector2(250, 520)
var radius: float = 110.0

func _ready():
	queue_redraw()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().size.x * 0.45 and touch_id_stick == -1:
				touch_id_stick = event.index
				base_pos = event.position
				current_pos = event.position
				queue_redraw()
			elif event.position.x >= get_viewport().size.x * 0.45 and touch_id_cam == -1:
				touch_id_cam = event.index
		else:
			if event.index == touch_id_stick:
				touch_id_stick = -1
				current_pos = base_pos
				emit_signal("move_vector", Vector2.ZERO)
				queue_redraw()
			elif event.index == touch_id_cam:
				touch_id_cam = -1

	elif event is InputEventScreenDrag:
		if event.index == touch_id_stick:
			var diff = event.position - base_pos
			if diff.length() > radius:
				diff = diff.normalized() * radius
			current_pos = base_pos + diff
			emit_signal("move_vector", diff / radius)
			queue_redraw()
		elif event.index == touch_id_cam:
			emit_signal("camera_rotate", event.relative)

func _draw():
	# Outer border ring
	draw_circle(base_pos, radius, Color(0.1, 0.1, 0.1, 0.45))
	draw_arc(base_pos, radius, 0, TAU, 32, Color(1, 1, 1, 0.7), 4.0)
	# Inner Thumb Knob
	draw_circle(current_pos, radius * 0.38, Color(1, 0.85, 0.1, 0.85))
