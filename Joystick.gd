extends CanvasLayer

signal move_vector(vec: Vector2)
signal camera_rotate(relative: Vector2)

var touch_origin: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var last_touch_pos: Vector2 = Vector2.ZERO

func _ready():
	layer = 128
	
	# Full-screen touch control base
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)

	# Left side visible movement panel
	var stick_base = ColorRect.new()
	stick_base.name = "StickBase"
	stick_base.color = Color(0, 0, 0, 0.4)
	stick_base.position = Vector2(80, 420)
	stick_base.size = Vector2(220, 220)
	stick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stick_base)

	var knob = ColorRect.new()
	knob.name = "Knob"
	knob.color = Color(1.0, 0.8, 0.0, 0.8)
	knob.position = Vector2(140, 480)
	knob.size = Vector2(100, 100)
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(knob)

func _input(event):
	var scr_w = get_viewport().get_visible_rect().size.x

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < scr_w * 0.45:
				is_dragging = true
				touch_origin = event.position
				_update_stick(event.position)
			else:
				last_touch_pos = event.position
		else:
			if event.position.x < scr_w * 0.45:
				is_dragging = false
				emit_signal("move_vector", Vector2.ZERO)
				_reset_stick()

	elif event is InputEventScreenDrag:
		if event.position.x < scr_w * 0.45 and is_dragging:
			var diff = event.position - touch_origin
			if diff.length() > 90.0:
				diff = diff.normalized() * 90.0
			_update_stick(touch_origin + diff)
			emit_signal("move_vector", diff / 90.0)
		elif event.position.x >= scr_w * 0.45:
			var delta = event.position - last_touch_pos
			last_touch_pos = event.position
			emit_signal("camera_rotate", delta)

func _update_stick(pos: Vector2):
	var k = get_node_or_null("Control/Knob")
	if k:
		k.position = pos - (k.size / 2.0)

func _reset_stick():
	var k = get_node_or_null("Control/Knob")
	if k:
		k.position = Vector2(140, 480)
