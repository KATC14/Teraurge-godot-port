extends CharacterBody2D

signal load_blip

#var target = Vector2()
var click_position = Vector2()
@export var is_active = true
@export var can_move = false
@export var exposition:Vector2 = position:
	set(value):
		position = value

func get_distance(point1, point2):
	var x = point1.x - point2.x
	var y = point1.y - point2.y
	return sqrt(x * x + y * y)

func map_collision_check(relative_x, relative_y):
	# CHECK COLLISION AROUND THE "target" moviclip (current location)
	# Return collision if a blip

	var origin = VarTests.map_target.position
	var point_list = []
	var min_dist = 9999
	var closest_index: int = 0

	# OFFSET TARGET LIST
	origin += Vector2(relative_x, relative_y)

	for mc:Area2D in adjacent_blips:
		point_list.append(mc.position)

	# CREATE DISTANCE LIST
	var index: int = 0
	for point in point_list:
		if get_distance(origin, point) < min_dist:
			min_dist = get_distance(origin, point)
			closest_index = index
		index += 1
	for i:Area2D in adjacent_blips:
		color_blips(i)

	var new_loc = adjacent_blips[closest_index]
	VarTests.map_target = new_loc
	var rev_serch_idx = VarTests.named_loc.values().find(new_loc)
	# catch for unnamed location
	if rev_serch_idx != -1:
		var found = VarTests.named_loc.keys()[rev_serch_idx]
		load_blip.emit(found)
	_on_blips_ready(VarTests.all_loc, new_loc)

func color_blips(blip):
	var temp:Sprite2D = blip.get_node("Sprite2D")
	if blip in VarTests.named_loc.values():
		var index = VarTests.named_loc.values().find(blip)
		var found = VarTests.named_loc.keys()[index]
		if found in VarTests.DISCOVERED_LOCATIONS:
			temp.modulate = Color.BLUE
		else:
			temp.modulate = Color.TRANSPARENT
	else:
		temp.modulate = Color.TRANSPARENT

var adjacent_blips = []
func _on_blips_ready(container, target):
	can_move = false
	var deltaX
	var deltaY
	var dist
	var rangee = 30
	adjacent_blips = []

	for i:Area2D in container:
		var c = i.position
		var s = target.position
		#var c1 = i
		#var s1 = area
		deltaX = (c.x + i.scale.x / 2.0) - (s.x + target.scale.x / 2.0)
		deltaY = (c.y + i.scale.y / 2.0) - (s.y + target.scale.y / 2.0) # rounded distance
		dist = sqrt((deltaX * deltaX) + (deltaY * deltaY)) # DISTANCE CHECKING
		#print(dist <= rangee, ' ', i.overlaps_area(collision_dummy), ' ', collision_dummy.get_overlapping_areas())

		if dist <= rangee:
			color_blips(i)
			var local_blips:Sprite2D = i.get_node("Sprite2D")
			var cur_loc:Sprite2D     = VarTests.map_target.get_node("Sprite2D")
			local_blips.modulate     = Color.GREEN
			cur_loc.modulate         = Color.ORANGE_RED
			adjacent_blips.append(i)
	can_move = true

# mouse movement
func _on_blip_move(_viewport: Node, _event: InputEvent, _shape_idx: int, node:Area2D) -> void:
	# check for if discover pop up is open
	if is_active:
		if Input.is_action_pressed("mouse_left"):
			var moved_loc = node.get_node("Sprite2D")
			# only allow adjacent blips
			if moved_loc.modulate == Color.GREEN:
				click_position = node.position
				click_position -= VarTests.map_target.position# + Vector2(10, 8)

				if can_move:
					map_collision_check(click_position.x, click_position.y)

# wasd/keyboard movment
func _input(_event: InputEvent) -> void:
	# check for if discover pop up is open
	if is_active:
		# strange numpad keys
		var center = Input.is_action_pressed("numpad_center")

		var up_left    = Input.is_action_pressed("numpad_diagonal_up_left")
		var down_left  = Input.is_action_pressed("numpad_diagonal_down_left")
		var up_right   = Input.is_action_pressed("numpad_diagonal_up_right")
		var down_right = Input.is_action_pressed("numpad_diagonal_down_right")

		if center:
			map_collision_check(0, 0)
		var input_dir
		if up_left:    input_dir = Vector2(-1.0, -1.0)
		if up_right:   input_dir = Vector2(1.0, -1.0)
		if down_left:  input_dir = Vector2(-1.0, 1.0)
		if down_right: input_dir = Vector2(1.0, 1.0)
		if down_left or down_right or up_left or up_right:
			if can_move:
				map_collision_check(input_dir.x * 150, input_dir.y * 150)

		# wasd/arrow keys
		var up    = Input.is_action_pressed("ui_up")
		var left  = Input.is_action_pressed("ui_left")
		var down  = Input.is_action_pressed("ui_down")
		var right = Input.is_action_pressed("ui_right")
		if up or left or down or right:
			input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			if can_move:
				map_collision_check(input_dir.x * 150, input_dir.y * 150)
