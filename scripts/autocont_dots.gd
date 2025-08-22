extends Sprite2D

var vec_postion:Array = [-55, 15]

func _draw() -> void:
	var color_back = Color.html('#000000')
	var color_fore = Color.html('#333333')

	var vec  = vect_overlap(vec_postion[0], vec_postion[1])
	draw_circle(vec[0], 18, color_back)
	draw_circle(vec[1], 10, color_fore)

	var vec_postion1 = vec_postion[0] + 51
	var vec1 = vect_overlap(vec_postion1, vec_postion[1])
	draw_circle(vec1[0], 18, color_back)
	draw_circle(vec1[1], 10, color_fore)

	var vec_postion2 = vec_postion[0] + 104
	var vec2 = vect_overlap(vec_postion2, vec_postion[1])
	draw_circle(vec2[0], 18, color_back)
	draw_circle(vec2[1], 10, color_fore)

func vect_overlap(x, y):
	var x1 = x + 0.1
	var y1 = y + 0.2
	return [Vector2(x, y), Vector2(x1, y1)]
