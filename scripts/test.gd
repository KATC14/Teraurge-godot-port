extends TextureRect


@export var can_draw = false:
	set(value):
		can_draw = value
		queue_redraw()
@export var loc_vec:Vector2 = Vector2(400, 400)
@export var loc_r:int = 20
@export var loc_c:Color = Color.FIREBRICK

func _draw() -> void:
	if can_draw:
		draw_circle(loc_vec, loc_r, loc_c)
