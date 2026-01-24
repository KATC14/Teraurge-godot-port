#@tool
extends Sprite2D

@export var redraw = null:
	set(value):
		redraw = value
		queue_redraw()

func _draw() -> void:
	if redraw:
		draw_circle(Vector2(0, 0), 130, Color.AQUA)
	var color = Color.GREEN
	if redraw == 'on_discovered':
		color = Color.RED
	if redraw == 'discovered' or redraw == 'on_discovered':
		var points = [
			# x pos, y pos
			Vector2(0, -130), # top point
			Vector2(130, 0),  # right point
			Vector2(0, 130),  # bottom point
			Vector2(-130, 0), # left point
		]
		draw_colored_polygon(points, color)
	if redraw == 'on_top':
		draw_circle(Vector2(0, 0), 100, Color.RED)
