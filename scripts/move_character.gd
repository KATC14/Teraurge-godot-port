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

func _ready() -> void:
	position = Vector2(2155.25, 3164.6)#2147.25, 3147.6
	click_position = position
	move_to_front.call_deferred()

func get_distance(point1, point2):
	var x = point1.x - point2.x
	var y = point1.y - point2.y
	return sqrt(x * x + y * y)

func map_collision_check(relative_x, relative_y):
	#print('temp ', relative_x, ' ', relative_y)

	# CHECK COLLISION AROUND THE "target" moviclip (current location)
	# Return collision if a blip

	var origin = VarTests.map_target.position
	var point_list = []
	var min_dist = 9999
	var closest_index: int = 0

	# OFFSET TARGET LIST
	origin += Vector2(relative_x, relative_y)
	#print(origin)

	#print(adjacent_blips)
	for mc in adjacent_blips:
		point_list.append(mc.position)

	# CREATE DISTANCE LIST
	var index: int = 0
	for point in point_list:
		#print(get_distance(origin, point))
		if get_distance(origin, point) < min_dist:
			min_dist = get_distance(origin, point)
			closest_index = index
			#print(closest_index)
		index += 1
	for i in adjacent_blips:
		var temp:Sprite2D = i.get_node("Sprite2D")
		temp.modulate = Color.TRANSPARENT

	var new_loc = adjacent_blips[closest_index]
	#print(new_loc)
	var sprite:Sprite2D = new_loc.get_node("Sprite2D")
	sprite.modulate = Color.ORANGE_RED
	VarTests.map_target = new_loc
	blips_ready()

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
	var rangee = 60
	adjacent_blips = []



	var collision_dummy:Area2D = area.duplicate()
	#collision_dummy.visible = false
	$'..'.add_child(collision_dummy)

	collision_dummy.scale = area.scale + Vector2(1.2, 1.2)
	var ggg:Sprite2D = collision_dummy.get_node("Sprite2D")
	ggg.modulate = Color.TRANSPARENT
	collision_dummy.position = area.position - Vector2(5, 5)

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
			# this is fucking stupid
			await get_tree().process_frame
			if i.overlaps_area(collision_dummy):
				var sprite:Sprite2D = i.get_node("Sprite2D")
				sprite.modulate = Color.GREEN
				adjacent_blips.append(i)
	can_move = true
	#collision_dummy.queue_free()

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
		if up or left or down or right:
			var input_dir = Input.get_vector("key_a", "key_d", "key_w", "key_s")
			if can_move:
				map_collision_check((input_dir * speed).x, (input_dir * speed).y)
			#print(input_dir * speed)
		#	velocity = input_dir * speed
		#	move_to_front()
		#	move_and_slide()
	if call_locations:
		blips_ready.call_deferred()
