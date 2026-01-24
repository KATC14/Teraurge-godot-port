extends Node

var debug_menu
var debug_index:GridContainer
var debug_index_activated = false

func _ready() -> void:
	debug_validator_loaded(load_file("res://database/debug_functions_plz.txt"))
	# TEMP forced debug
	#VarTests.debug_mode = false

func _process(_delta: float) -> void:
	if debug_index_activated:
		# catch for scene change
		if not debug_index:
			readd_debug_index()
		debug_index.move_to_front()

		var character_text = "characters/%s/%s.txt" % [VarTests.character_name, VarTests.diag_file]
		var index_text     = VarTests.current_index
		if not VarTests.character_name: character_text = 'FILE'
		if not VarTests.current_index:  index_text     = 'INDEX'

		debug_index.get_child(0).text = character_text
		debug_index.get_child(1).text = index_text

func _input(_event: InputEvent) -> void:
	# debug functions
	if VarTests.debug_mode and not VarTests.main_menu_active and Input.is_action_pressed("Ctrl"):
		# debug menu
		if Input.is_action_just_pressed("key_d"):
			if not VarTests.debug_screen_visable:
				VarTests.debug_screen_visable = true
				debug_menu = load("res://scenes/debug_screen.tscn").instantiate()
				debug_menu.move_to_front()
				get_tree().current_scene.add_child(debug_menu)
			else:
				VarTests.debug_screen_visable = false
				debug_menu.queue_free()
		# debug index
		if Input.is_action_just_pressed("key_c"):
			if not debug_index_activated:
				debug_index_activated = true
				readd_debug_index()
			else:
				debug_index_activated = false
				debug_index.queue_free()
		# debug leave
		if Input.is_action_just_pressed("key_q"):
			if not VarTests.map_active:
				get_tree().change_scene_to_file("res://scenes/map.tscn")
		# debug win
		if Input.is_action_just_pressed("key_w"):
			if VarTests.in_combat:
				get_tree().current_scene.play_card("player", "debug_win", "enemy")
				#get_tree().current_scene.refresh_combat_ui()
		# debug lose
		if Input.is_action_just_pressed("key_l"):
			if VarTests.in_combat:
				get_tree().current_scene.play_card("player", "debug_lose", "enemy")
				#get_tree().current_scene.refresh_combat_ui()

func readd_debug_index():
	debug_index = load("res://scenes/debug_index.tscn").instantiate()
	debug_index.move_to_front()

	var node = get_tree().current_scene.get_child(0)
	# catch for mad being active 
	# moves node to child of camera for postioning and movement with carmera
	if VarTests.map_active: node = node.get_child(1).get_child(0)
	node.add_child(debug_index)

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

func items(dict:Dictionary) -> Array:
	var data = []
	for i in range(len(dict.keys())):
		data.append([dict.keys()[i], dict.values()[i]])
	return data

func mass_repalce(text, reps):
	for i in items(reps):
		text = text.replace(i[0], i[1])
	return text

func array_zip(ary) -> Array:
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
