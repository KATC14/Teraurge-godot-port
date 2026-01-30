#@tool
extends Sprite2D

@export var redraw = null:
	set(value):
		redraw = value
		queue_redraw()

func _draw() -> void:
	if redraw:
		draw_circle(Vector2(0, 0), 145, Color(0.0, 1.0, 1.0, 0.588))
	var color = Color.GREEN
	if redraw == 'on_discovered':
		color = Color("ff3300ff")
	if redraw == 'discovered' or redraw == 'on_discovered':
		var points = [
			# x pos, y pos
			Vector2(0, -145), # top point
			Vector2(145, 0),  # right point
			Vector2(0, 145),  # bottom point
			Vector2(-145, 0), # left point
		]
		draw_colored_polygon(points, color)
		#var number = -520
		#draw_arc(Vector2.ZERO, 145, deg_to_rad(number + 70), deg_to_rad(360 - 200 + number), 50, Color.RED)
	if redraw == 'on_top':
		draw_circle(Vector2(0, 0), 115, Color("ff3300ff"))
