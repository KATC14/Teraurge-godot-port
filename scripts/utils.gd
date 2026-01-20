extends Node

var debug

func _ready() -> void:
	debug_validator_loaded(load_file("res://database/debug_functions_plz.txt"))
	# TEMP forced debug
	VarTests.debug_mode = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Ctrl"):
		# debug menu
		if Input.is_action_just_pressed("key_d"):
			if not VarTests.debug_screen_visable:
				VarTests.debug_screen_visable = true
				debug = load("res://scenes/debug_screen.tscn").instantiate()
				get_tree().current_scene.add_child(debug)
			else:
				VarTests.debug_screen_visable = false
				debug.queue_free()
		# debug index
		if Input.is_action_just_pressed("key_c"):
			pass
		# debug leave
		if Input.is_action_just_pressed("key_q"):
			if not VarTests.map_active:
				get_tree().change_scene_to_file("res://scenes/map.tscn")
		# debug win
		if Input.is_action_just_pressed("key_w"):
			# if in_combat:
			pass
		# debug lose
		if Input.is_action_just_pressed("key_l"):
			# if in_combat:
			pass

func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	return f.get_as_text()

func debug_validator_loaded(debug_val_loaded:String) -> void:
	if(debug_val_loaded.strip_edges() == "I want the debug functions, but I recognize that when I use these tools designed for content creation, I might very likely break the dialogue scripting and render quest lines incompletable and/or break my savegame. I will not send bug reports to meandraco.gamedev@gmail.com when I use the debug tools because Meandraco doesn't want to spend hours looking for bugs that are caused by irresponsible use of the debug tools."):
		VarTests.debug_mode = true

func get_substring(start, end, data:String):
	data = data.to_lower()
	var start_index = data.find(start) + len(start)
	var end_index = data.substr(start_index).find(end) - 1

	# IF SUBSTRING NOT FOUNG RETURN NOTHING
	if start_index == -1 and end_index == -1:
		return ""

	if start_index == -1:
		start_index = 0

	if end_index == -1 or end_index == 0:
		end_index = len(data)

	# commented out for misbehavior
	#if end_index < start_index:
	#	var full_string_chopped = data.substr(start_index, len(data))
	#	end_index = full_string_chopped.find(end) - 1 + start_index

	#if end_index < start_index:
	#	end_index = len(data)

	return data.substr(start_index, end_index).strip_edges()

func array_find(clean_chunk:Array, item) -> int:
	for i:int in range(len(clean_chunk)):
		if item in clean_chunk[i]:
			return i
	return -1

func items(dict:Dictionary):
	var data = []
	for i in range(len(dict.keys())):
		data.append([dict.keys()[i], dict.values()[i]])
	return data


func array_zip(ary):
	var ary_lens = []
	for i in ary:
		ary_lens.append(len(i))

	for i in range(len(ary)):
		while len(ary[i]) < ary_lens.max():
			ary[i].append(null)

	var test = []
	for i in range(ary_lens.max()):
		var test1 = []
		for x in ary:
			test1.append(x[i])
		test.append(test1)
	return test
