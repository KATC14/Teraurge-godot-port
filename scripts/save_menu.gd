extends Control

@onready var save_load         = $save_load_menu
@onready var pause_menu        = $pause_menu
@onready var save_choices_map  = $save_load_menu/PanelContainer
@onready var save_name_label   = $save_load_menu/TextEdit2
@onready var save_delete_label = $save_load_menu/TextEdit3

@onready var save_choices_mm  = $load_menu/PanelContainer
@onready var load_name_label  =  $load_menu/TextEdit2
@onready var load_menu        =  $load_menu
var CanLay
var saves
var selected_save

func _ready() -> void:
	CanLay = get_parent()

func _on_button_pause_new_game_pressed() -> void:
	var new_tex = TextureRect.new()
	new_tex.texture = load("res://assets/images/menu_background.png")

	# cover camera
	var camera = CanLay.get_node_or_null('Camera2D')
	if camera:
		camera = camera.position
	else:
		camera = Vector2(640.0, 360.0)

	var stage = Vector2(float(VarTests.stage_width), float(VarTests.stage_height))
	var vec = camera - (stage / 2)
	new_tex.position = vec
	CanLay.add_child(new_tex)
	#new_tex.move_to_front()

	var ng_menu = load("res://scenes/new_game.tscn").instantiate()
	ng_menu.visible = false
	CanLay.add_child(ng_menu)
	MiscFunc.menu_slide(ng_menu, pause_menu.position, 0.7)

func load_saves(save_menu) -> void:
	var json_string = Utils.load_file('saves.json')
	var json = JSON.new()
	json.parse(json_string)
	saves = json.data['saved_games']

	save_menu.choices = saves.keys()

func _on_button_pause_save_load_pressed() -> void:
	MiscFunc.menu_slide(save_load, pause_menu.position)
	MiscFunc.menulist.append(save_load)

	save_load.move_to_front()
	load_saves(save_choices_map)

func save_selected(index: Variant, label:TextEdit, save_choices, second_one:TextEdit=null) -> void:
	selected_save = save_choices.choices[index]
	label.editable = true
	label.text = selected_save
	label.editable = false
	if second_one:
		second_one.text = selected_save

func _on_save_selected_mm(index: Variant) -> void:
	save_selected(index, load_name_label, save_choices_mm)
# :)
func _on_save_selected_map(index: Variant) -> void:
	save_selected(index, save_delete_label, save_choices_map, save_name_label)

func _on_button_save_pressed() -> void:
	var save_name = save_name_label.text
	var new = []
	new += save_choices_map.choices
	new.append(save_name)
	save_choices_map.choices = new

	# lol the consequences of changing the save formating
	var map_loc = func(loc_index):
		var map_file = Utils.load_file("res://database/maps/default_data.txt").replace('][', '\n')
		for map_blip in map_file.split('\n'):
			var data_out = map_blip.replace('[', '').replace(']', '').split('|')

			if loc_index == Vector2(float(data_out[0]), float(data_out[1])):
				return map_file.split('\n').find(map_blip)

	var save_dict = {
		"RAPE_FILTER":  VarTests.RAPE_FILTER,
		"FERAL_FILTER": VarTests.FERAL_FILTER,
		"GORE_FILTER":  VarTests.GORE_FILTER,

		"player_name":   VarTests.player_name,
		"player_gender": VarTests.player_gender,

		"player_heat_res":   VarTests.player_stats["heat_res"],
		"player_cold_res":   VarTests.player_stats["cold_res"],
		"player_impact_res": VarTests.player_stats["impact_res"],
		"player_slash_res":  VarTests.player_stats["slash_res"],
		"player_pierce_res": VarTests.player_stats["pierce_res"],
		"player_magic_res":  VarTests.player_stats["magic_res"],
		"player_bio_res":    VarTests.player_stats["bio_res"],

		"player_charisma":     VarTests.player_stats["charisma"],
		"player_will":         VarTests.player_stats["will"],
		"player_intelligence": VarTests.player_stats["intelligence"],

		"player_agility":   VarTests.player_stats["agility"],
		"player_strength":  VarTests.player_stats["strength"],
		"player_endurance": VarTests.player_stats["endurance"],


		"player_base_hitpoints":   VarTests.player_base_hitpoints,
		"player_hitpoints":        VarTests.player_hitpoints,
		"player_hitpoints_damage": VarTests.player_hitpoints_damage,

		"player_A_money": VarTests.player_A_money,
		"player_B_money": VarTests.player_B_money,

		"ITEM_SLOTS":     VarTests.ITEM_SLOTS,
		"ITEM_INVENTORY": VarTests.ITEM_INVENTORY,
		"CARD_INVENTORY": VarTests.CARD_INVENTORY,
		"player_DECK":    VarTests.player_DECK,

		"CHANGED_ENCOUNTERS":   VarTests.CHANGED_ENCOUNTERS,
		"CHANGED_CHARACTERS":   VarTests.CHANGED_CHARACTERS,
		"CHANGED_DIAGS":        VarTests.CHANGED_DIAGS,
		"CHANGED_SHOPS":        VarTests.CHANGED_SHOPS,
		"CHANGED_ENVIRONMENTS": VarTests.CHANGED_ENVIRONMENTS,

		"RESTOCK_TIMESTAMPS":   VarTests.RESTOCK_TIMESTAMPS,
		"CLICKED_OPTIONS":      VarTests.CLICKED_OPTIONS,
		"DINDEX":               VarTests.saved_indexs,
		"FLAGS":                VarTests.FLAGS,
		"COUNTERS":             VarTests.COUNTERS,
		"TIMERS":               VarTests.TIMERS,
		"DISCOVERED_LOCATIONS": VarTests.DISCOVERED_LOCATIONS,

		"TIME": VarTests.TIME,
		"DAYS": VarTests.DAYS,
		
		"game_version":          VarTests.version,

		"target_index":          map_loc.call(VarTests.loc_index),
		"previous_target_index": map_loc.call(VarTests.last_loc_index)
	}
	var json_string = Utils.load_file('saves.json')
	var json = JSON.new()
	json.parse(json_string)
	json.data['saved_games'][save_name] = save_dict

	var file = FileAccess.open("saves.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(json.data))
	file.close()

func _on_button_load_pressed() -> void:
	var sec_save = saves[selected_save]

	VarTests.RAPE_FILTER  = sec_save["RAPE_FILTER"]
	VarTests.FERAL_FILTER = sec_save["FERAL_FILTER"]
	VarTests.GORE_FILTER  = sec_save["GORE_FILTER"]

	VarTests.player_name   = sec_save["player_name"]
	VarTests.player_gender = sec_save["player_gender"]

	VarTests.player_stats["heat_res"]   = sec_save["player_heat_res"]
	VarTests.player_stats["cold_res"]   = sec_save["player_cold_res"]
	VarTests.player_stats["impact_res"] = sec_save["player_impact_res"]
	VarTests.player_stats["slash_res"]  = sec_save["player_slash_res"]
	VarTests.player_stats["pierce_res"] = sec_save["player_pierce_res"]
	VarTests.player_stats["magic_res"]  = sec_save["player_magic_res"]
	VarTests.player_stats["bio_res"]    = sec_save["player_bio_res"]

	VarTests.player_stats["charisma"]     = sec_save["player_charisma"]
	VarTests.player_stats["will"]         = sec_save["player_will"]
	VarTests.player_stats["intelligence"] = sec_save["player_intelligence"]

	VarTests.player_stats["agility"]   = sec_save["player_agility"]
	VarTests.player_stats["strength"]  = sec_save["player_strength"]
	VarTests.player_stats["endurance"] = sec_save["player_endurance"]


	VarTests.player_base_hitpoints   = sec_save["player_base_hitpoints"]
	VarTests.player_hitpoints        = sec_save["player_hitpoints"]
	VarTests.player_hitpoints_damage = sec_save["player_hitpoints_damage"]

	VarTests.player_A_money = sec_save["player_A_money"]
	VarTests.player_B_money = sec_save["player_B_money"]

	VarTests.ITEM_SLOTS     = sec_save["ITEM_SLOTS"]
	VarTests.ITEM_INVENTORY = sec_save["ITEM_INVENTORY"]
	VarTests.CARD_INVENTORY = sec_save["CARD_INVENTORY"]
	VarTests.player_DECK    = sec_save["player_DECK"]

	VarTests.CHANGED_ENCOUNTERS   = sec_save["CHANGED_ENCOUNTERS"]
	VarTests.CHANGED_CHARACTERS   = sec_save["CHANGED_CHARACTERS"]
	VarTests.CHANGED_DIAGS        = sec_save["CHANGED_DIAGS"]
	VarTests.CHANGED_SHOPS        = sec_save["CHANGED_SHOPS"]
	VarTests.CHANGED_ENVIRONMENTS = sec_save["CHANGED_ENVIRONMENTS"]

	VarTests.RESTOCK_TIMESTAMPS   = sec_save["RESTOCK_TIMESTAMPS"]
	VarTests.CLICKED_OPTIONS      = sec_save["CLICKED_OPTIONS"]
	VarTests.saved_indexs         = sec_save["DINDEX"]
	VarTests.FLAGS                = sec_save["FLAGS"]
	VarTests.COUNTERS             = sec_save["COUNTERS"]

	VarTests.TIMERS               = sec_save["TIMERS"]
	VarTests.DISCOVERED_LOCATIONS = sec_save["DISCOVERED_LOCATIONS"]

	VarTests.TIME = sec_save["TIME"]
	VarTests.DAYS = int(sec_save["DAYS"])

	VarTests.version = sec_save["game_version"]

	# lol the consequences of changing the save formating
	var map_loc = func(loc_index):
		var map_file = Utils.load_file("res://database/maps/default_data.txt").replace('][', '\n')
		var map_size = map_file.split('\n')
		var target = map_size[abs(loc_index) - 1].split('|')
		return Vector2(int(target[0]), int(target[1]))

	VarTests.map_target = map_loc.call(sec_save["target_index"])
	VarTests.last_coords = map_loc.call(sec_save["previous_target_index"])



	var current_scene = get_tree().current_scene.name
	print('A? ', current_scene)
	if current_scene == 'map':
		var blips = get_parent().get_node_or_null('blips')
		print('blips', blips)
		blips.visible = false
		save_load.visible = false
		pass#create_discovered_locations()
	#else:
	#	get_tree().change_scene_to_file("res://scenes/map.tscn")


func _on_button_delete_pressed() -> void:
	if selected_save:
		save_delete_label.text = ''
		var json_string = Utils.load_file('saves.json')
		var json = JSON.new()
		json.parse(json_string)
		json.data['saved_games'].erase(selected_save)

		var file = FileAccess.open("saves.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(json.data))
		file.close()

func _on_button_back_pressed() -> void:
	MiscFunc.menu_slide(get_parent().get_node_or_null('Control2'), Vector2.ZERO, 0.3)
	var tween = MiscFunc.menu_slide(load_menu, Vector2.ZERO, 0.3)
	tween.finished.connect(func(): load_menu.visible = false)

# hacky way to add saves to main menu load screen
func _on_load_menu_visibility_changed() -> void:
	if load_menu.visible:
		load_saves(save_choices_mm)
