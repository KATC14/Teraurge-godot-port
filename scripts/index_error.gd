extends TextureRect


#func _process(delta: float) -> void:
#	queue_redraw()

@export var end     = 780
@export var radius  = 30
@export var width  = 1
@export var y_level = 20
func _draw() -> void:
	var clr = Color.RED
	# start
	draw_arc(Vector2(0, y_level), radius, deg_to_rad(90), deg_to_rad(360 - 90), 100, clr, width)
	# lines
	draw_line(Vector2(0, -radius + y_level), Vector2(end, -radius + y_level), clr, width)
	draw_line(Vector2(0,  radius + y_level), Vector2(end,  radius + y_level), clr, width)
	# end
	draw_arc(Vector2(end, y_level), radius, deg_to_rad(-90), deg_to_rad(360 - 270), 100, clr, width)
