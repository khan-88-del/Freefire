extends CanvasLayer

signal move_vector(vec: Vector2)
signal camera_rotate(relative: Vector2)

var touch_id_stick: int = -1
var touch_id_cam: int = -1
var stick_center: Vector2 = Vector2(220, 850)
var stick_radius: float = 120.0
var stick_current: Vector2 = Vector2.ZERO

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Left side: Joystick
			if event.position.x < get_viewport().size.x * 0.4 and touch_id_stick == -1:
				touch_id_stick = event.index
				stick_center = event.position
				stick_current = event.position
				queue_redraw()
			# Right side: Camera Swipe
			elif event.position.x >= get_viewport().size.x * 0.4 and touch_id_cam == -1:
				touch_id_cam = event.index
		else:
			if event.index == touch_id_stick:
				touch_id_stick = -1
				stick_current = stick_center
				emit_signal("move_vector", Vector2.ZERO)
				queue_redraw()
			elif event.index == touch_id_cam:
				touch_id_cam = -1

	elif event is InputEventScreenDrag:
		if event.index == touch_id_stick:
			var diff = event.position - stick_center
			if diff.length() > stick_radius:
				diff = diff.normalized() * stick_radius
			stick_current = stick_center + diff
			emit_signal("move_vector", diff / stick_radius)
			queue_redraw()
		elif event.index == touch_id_cam:
			emit_signal("camera_rotate", event.relative)

func _draw():
	if touch_id_stick != -1:
		draw_circle(stick_center, stick_radius, Color(1, 1, 1, 0.2))
		draw_circle(stick_current, stick_radius * 0.4, Color(1, 0.8, 0.2, 0.7))
