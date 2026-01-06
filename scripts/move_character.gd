extends CharacterBody2D


var speed = 150
#var target = Vector2()
var click_position = Vector2()
@export var is_active = true
@export var call_locations = false
@export var can_move = false
@export var exposition:Vector2 = position:
	set(value):
		position = value

func get_distance(point1, point2):
	var x = point1.x - point2.x
	var y = point1.y - point2.y
	return sqrt(x * x + y * y)

@onready var player_speed = %player_speed

func map_collision_check(relative_x, relative_y):
	#TIMER
	player_speed.one_shot = true
	player_speed.wait_time = 0.05
	player_speed.start()
	#print('temp ', relative_x, ' ', relative_y)

	# CHECK COLLISION AROUND THE "target" moviclip (current location)
	# Return collision if a blip

	var origin = VarTests.map_target.position
	var point_list = []
	var min_dist = 9999
	var closest_index: int = 0

	# OFFSET TARGET LIST
	origin += Vector2(relative_x, relative_y)

	for mc in adjacent_blips:
		point_list.append(mc.position)

	# CREATE DISTANCE LIST
	var index: int = 0
	for point in point_list:
		if get_distance(origin, point) < min_dist:
			min_dist = get_distance(origin, point)
			closest_index = index
		index += 1
	for i in adjacent_blips:
		color_blips(i)

	var new_loc = adjacent_blips[closest_index]
	#print(new_loc)
	VarTests.map_target = new_loc
	blips_ready()

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
func blips_ready():
	call_locations = false
	can_move = false
	#var all_locations = VarTests.all_loc
	#print(all_locations)
	var area = VarTests.map_target
	#print('temp s ', area.position)
	var deltaX
	var deltaY
	var dist
	var rangee = 30
	adjacent_blips = []

	for i:Area2D in VarTests.all_loc:
		var c = i.position
		var s = area.position
		#var c1 = i
		#var s1 = area
		deltaX = (c.x + i.scale.x / 2.0) - (s.x + area.scale.x / 2.0)
		deltaY = (c.y + i.scale.y / 2.0) - (s.y + area.scale.y / 2.0) # rounded distance
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

func _process(_delta: float) -> void:
	if is_active:
		#if Input.is_action_pressed("mouse_left"):
		#	click_position = get_global_mouse_position()
		#if Input.is_action_just_released('mouse_left'):
		#	velocity = Vector2.ZERO
		#if position.distance_to(click_position) > 3:
		#	target = (click_position - position).normalized()
		#	velocity = target * speed
		#	move_and_slide()

		var up     = Input.is_action_pressed("ui_up")
		var left   = Input.is_action_pressed("ui_left")
		var down   = Input.is_action_pressed("ui_down")
		var right  = Input.is_action_pressed("ui_right")
		if Input.is_action_pressed("mouse_left"):
			click_position = get_global_mouse_position()
			click_position -= VarTests.map_target.position + Vector2(10, 8)

			if can_move and player_speed.is_stopped():
				map_collision_check(click_position.x, click_position.y)
		if up or left or down or right:
			var input_dir = Input.get_vector("key_a", "key_d", "key_w", "key_s")
			if can_move and player_speed.is_stopped():
				map_collision_check((input_dir * speed).x, (input_dir * speed).y)
			#print(input_dir * speed)
		#	velocity = input_dir * speed
		#	move_to_front()
		#	move_and_slide()
	if call_locations:
		blips_ready.call_deferred()
