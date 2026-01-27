extends Node

signal loc_move

@onready var CanLay      = $CanvasLayer
#@onready var map        = $CanvasLayer/TextureRect
@onready var disco_cont = $CanvasLayer/Control
@onready var disco_msg  = $CanvasLayer/Control/Label
@onready var camera     = $CanvasLayer/Camera2D

@onready var sun_dial_lbl = $CanvasLayer/Camera2D/Control/Label
@onready var cam_con      = $CanvasLayer/Camera2D/Control
@onready var new_game     = load("res://scenes/new_game.tscn")


@onready var chr_menu    = $CanvasLayer/Control3
@onready var chr_name    = $CanvasLayer/Control3/Label
@onready var hit_point   = $CanvasLayer/Control3/Label2
@onready var chr_menu_c  = $CanvasLayer/Control3/Control/Label
@onready var chr_menu_w  = $CanvasLayer/Control3/Control/Label2
@onready var chr_menu_i  = $CanvasLayer/Control3/Control/Label3
@onready var chr_menu_a  = $CanvasLayer/Control3/Control/Label4
@onready var chr_menu_s  = $CanvasLayer/Control3/Control/Label5
@onready var chr_menu_e  = $CanvasLayer/Control3/Control/Label6

@onready var resist_h    = $CanvasLayer/Control3/Control2/Label
@onready var resist_c    = $CanvasLayer/Control3/Control2/Label2
@onready var resist_i    = $CanvasLayer/Control3/Control2/Label3
@onready var resist_s    = $CanvasLayer/Control3/Control2/Label4
@onready var resist_p    = $CanvasLayer/Control3/Control2/Label5
@onready var resist_m    = $CanvasLayer/Control3/Control2/Label6
@onready var resist_b    = $CanvasLayer/Control3/Control2/Label7


var deck_minimum_size  = 16
@onready var dck_menu  = $CanvasLayer/Control4
@onready var dck_label = $CanvasLayer/Control4/Label
@onready var dck_menu_available_cards = $CanvasLayer/Control4/PanelContainer
@onready var dck_menu_equiped_cards   = $CanvasLayer/Control4/PanelContainer2

@onready var inv_menu    = $CanvasLayer/Control2
@onready var inventory   = $CanvasLayer/Control2/PanelContainer
@onready var player_doll = $CanvasLayer/Control2/Control/TextureRect

@onready var mannequin = $CanvasLayer/Control2/Control/TextureRect/TextureRect  # mannequin
@onready var underwear = $CanvasLayer/Control2/Control/TextureRect/TextureRect1 # underwear
@onready var socks     = $CanvasLayer/Control2/Control/TextureRect/TextureRect2 # socks
@onready var shoes     = $CanvasLayer/Control2/Control/TextureRect/TextureRect3 # shoes
@onready var boots     = $CanvasLayer/Control2/Control/TextureRect/TextureRect4 # boots
@onready var legs      = $CanvasLayer/Control2/Control/TextureRect/TextureRect5 # legs
@onready var torso     = $CanvasLayer/Control2/Control/TextureRect/TextureRect6 # torso
@onready var head      = $CanvasLayer/Control2/Control/TextureRect/TextureRect7 # head
@onready var hands     = $CanvasLayer/Control2/Control/TextureRect/TextureRect8 # hands

@onready var mainhand  = $CanvasLayer/Control2/Control/TextureRect/TextureRect9 # mainhand
@onready var offhand   = $CanvasLayer/Control2/Control/TextureRect/TextureRect10# offhand
@onready var sidearm   = $CanvasLayer/Control2/Control/TextureRect/TextureRect11# sidearm
@onready var twohand   = $CanvasLayer/Control2/Control/TextureRect/TextureRect12# twohanded

@onready var stn_menu    = $CanvasLayer/Control5
@onready var save_load   = $CanvasLayer/Control6

# thank you Mige, I would have not figured this out myself
@onready var blip = load("res://scenes/blip_draw.tscn")
var tooltip:Control

var map_data = "res://database/maps/default_data.txt"
var ATMOSPHERIC_MULTIPLIER = 1
var advance_time_to = 0
var location
var discovery_popup_active = false
var can_move = false
var adjacent_blips = []
var all_loc:Dictionary

func _ready() -> void:
	sun_dial_lbl.text = str(VarTests.DAYS)
	#VarTests.CARD_INVENTORY = [
	#	"kick", "kick", "body_tackle", "panicked_slap", "panicked_slap", 
	#	"panicked_slap", "panicked_slap", "wrestle", "wrestle", "right_hook", 
	#	"left_hook", "left_hook", "panicked_slap", "panicked_slap", "panicked_slap", 
	#	"clumsy_kick", "clumsy_kick"
	#]
	#VarTests.player_DECK = ["panicked_slap"]
	#VarTests.ALL_ITEMS = Utils.load_file("res://database/items/items.txt")
	#VarTests.ALL_CARDS = Utils.load_file("res://database/cards/cards.txt")
	#VarTests.ITEM_INVENTORY.append("tshirt")
	#VarTests.ITEM_INVENTORY.append("jeans")
	#VarTests.ITEM_INVENTORY.append("test_boots")
	#VarTests.ITEM_INVENTORY.append("white_socks")
	#VarTests.ITEM_INVENTORY.append("underwear")
	#for i in VarTests.ITEM_INVENTORY:
	#	MiscFunc.equip_item(i)

	#parse_equiped_cards()
	VarTests.map_active = true
	create_locations()
	create_discovered_locations()

func _input(_event: InputEvent) -> void:
	if tooltip and tooltip.visible:
		# camera.position.x half the screen
		# camera.position.x + (VarTests.stage_width * 2)
		@warning_ignore("integer_division")
		tooltip.pos_xy  = Vector2(camera.position.x + (VarTests.stage_width / 2), camera.position.y - (VarTests.stage_height / 2))
	if Input.is_action_pressed("mouse_left"):
		if inv_menu.visible:
			shape_test.call_deferred()
	# wasd/keyboard movment
	# check for if discover pop up is open
	if not discovery_popup_active:
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
		if can_move and (down_left or down_right or up_left or up_right):
				map_collision_check(input_dir.x * 150, input_dir.y * 150)

		# wasd/arrow keys
		var up    = Input.is_action_pressed("ui_up")
		var left  = Input.is_action_pressed("ui_left")
		var down  = Input.is_action_pressed("ui_down")
		var right = Input.is_action_pressed("ui_right")
		# (not ctrl) catch for debug funcions being off to stop player from moving
		if not Input.is_action_pressed("Ctrl") and can_move and (up or left or down or right):
			input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			map_collision_check(input_dir.x * 150, input_dir.y * 150)

# this is why you mused monospaced fonts
#func custom_join(sep, values:Array) -> String:
#	if not values[1][0] or not values[1][-1]:
#		sep = ''
#	return '%s%s%*s' % [values[1][0], sep, len(values[1][-1])+values[0], values[1][-1]]

func create_item_description(item:String):
	var item_string0 = Utils.get_substring("<%s" % item, "%s>" % item, VarTests.ALL_ITEMS.to_lower())

	# this took entrirely to long to figure out
	#var item_string:Array = Utils.get_substring("<%s" % item, "%s>" % item, VarTests.ALL_ITEMS.to_lower()).replace('\t', '').split('\n')
	#var item_string2 = item_string.map(func(item_split): return len(item_split.strip_edges().split(':')[0]))

	#var item_string4 = item_string2.map(func(item_split): 
	#	if item_string2.max() - item_split == item_string2.max():
	#		return 0
	#	return item_string2.max() - item_split +1
	#)

	#var item_string5 = item_string.map(func(item_split): return item_split.strip_edges().split(':'))

	#var newarray = Utils.array_zip([item_string4, item_string5]).map(func(item_split): return custom_join(':', item_split))
	return Utils.mass_repalce(item_string0, {'\t':'', '\r':'', ':':': '})

func _on_tooltip_hover(array, index, item=false):
	if not item:
		item = create_item_description(unformat(array[index])[1])
	tooltip = load("res://scenes/tool_tip.tscn").instantiate()
	tooltip.get_node("Label").text = str(item)
	# catch for resetting size of tooltip
	tooltip.get_child(0).size = Vector2.ZERO
	CanLay.add_child(tooltip)
	tooltip.move_to_front()

func _on_tooltip_exit(_array, _index):
	if tooltip: tooltip.queue_free()

var menulist = []
func movement(source_object, time=0.25):
	if source_object.visible:
		menu_slide_out(source_object, time)
		discovery_popup_active = false
		camera.is_active    = true
	else:
		menu_slide_in(source_object, time)
		source_object.visible = true
		discovery_popup_active = true
		camera.is_active    = false
	menulist.erase(source_object)
	for i in menulist:
		menu_slide_out(i)

#MENU SLIDE IN
func menu_slide_in(source_object, time=0.25):
	#DISABLE MAP CLICKING
	discovery_popup_active = true
	camera.is_active    = false

	var vec_x = camera.position.x - (float(VarTests.stage_width) / 2)
	var vec_y = VarTests.stage_height + camera.position.y
	source_object.position = Vector2(vec_x, vec_y)
	vec_y = camera.position.y - (float(VarTests.stage_height) / 2)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(source_object, "position:y", vec_y, time)
	return tween

#MENU SLIDE OUT
func menu_slide_out(source_object, time=0.25):
	var vec_y = VarTests.stage_height + camera.position.y

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(source_object, "position:y", vec_y, time)
	tween.finished.connect(func(): source_object.visible = false)
	return tween

func _on_advance_time(forward):
	while forward > 100:
		VarTests.DAYS += 1
		forward -= 100
	VarTests.TIME = VarTests.TIME + forward
	if VarTests.TIME > 100:
		VarTests.TIME = VarTests.TIME - 100
		VarTests.DAYS += 1
	#trace("day: "+DAYS+" time: "+TIME) #DEBUG
#	check_timers()#TODO check_timers game.gd

	# ATMOSPHERIC PERCENTAGE
	if (VarTests.TIME - 50) < 0:
		ATMOSPHERIC_MULTIPLIER = ((VarTests.TIME - 50) * -1) * 2 / 100
	else:
		ATMOSPHERIC_MULTIPLIER = (VarTests.TIME - 50) * 2 / 100
	advance_time_to = 0
#	turn_overmap_dial()#TODO time display turn_overmap_dial game.gd

func make_collision(x, y, r) -> Node2D:#, loc_name
	var instance: Node2D = blip.instantiate()
	instance.position = Vector2(x, y)
	instance.scale = Vector2(r, r) / 10 * 1.1
	CanLay.get_node("blips").add_child(instance)

	return instance

func create_locations() -> void:
	var map_file = Utils.load_file(map_data).replace('][', '\n')
	#[2147.25|3157.6|15|blip_place|sejan_witch_house]
	#    0     1      2     3             4
	#    x     y      r     ?          loc_name
	var map_size = len(map_file.split('\n'))
	for i in map_size:
		var data_out = map_file.split('\n')[i].replace('[', '').replace(']', '').split('|')
		var x = float(data_out[0])
		var y = float(data_out[1])
		var r = float(data_out[2])
		var loc_name = data_out[4]

		#print(loc_name, ' ', Vector2(x, y))
		# debug colors
		#var color
		#match data_out[3]:
		#	"blip":           color = "#f0f00071"
		#	"blip_named":     color = "#f000f071"
		#	"blip_encounter": color = "#00f0f071"
		#	"blip_place":     color = "#f0000071"
		#	"blip_special":   color = "#0000f071"

		var area:Area2D = make_collision(x, y, r)#, loc_name
		area.input_event.connect(loc_move.emit.bind(area))
		#area.body_entered.connect(load_blip.bind(loc_name))#, area
		#area.body_exited.connect(func(_body): area_exited = true)
		# pass on blips that are not used to keep same map format
		match data_out[3]:
			# normal blip
			"blip":           all_loc[area] = loc_name
			# named blip (no idea why this is any more special then blip_encounter)
			"blip_named":     all_loc[area] = loc_name
			# random encounter
			"blip_encounter": all_loc[area] = loc_name
			# named location
			"blip_place":     all_loc[area] = loc_name
		# for loop ended (why is there no else on a fo rloop like python or a finally)
		if i == map_size-1:
			# catch for leaving a location gotten to by debug or somehow missing a location name
			
			if not VarTests.loc_name or not all_loc.values().has(VarTests.loc_name):
				VarTests.loc_name = 'sejan_witch_house'
			# why godot you are so much python but are mussing some amazing stuff
			# like            for i, x in Dictionary.items()
			# or              for i (x, y) in [('a', ('1', '2')), ('b', ('3', '4'))]
			# and cant forget for i, x in zip(list, list):
			# move player to loaction
			VarTests.map_target = reverse_loc_lookup(VarTests.loc_name)
			# move camera to node left
			camera.position = VarTests.map_target.position
			blips_ready(VarTests.map_target)
			can_move = true

func reverse_loc_lookup(loc_name):
	for items in Utils.items(all_loc):
		# items[0] key
		# items[1] value
		if items[1] == loc_name:
			return items[0]

func create_discovered_locations():
	for i in VarTests.DISCOVERED_LOCATIONS:
		var loc_area:Node2D = reverse_loc_lookup(i)
		var con:Control = loc_area.get_child(-1)
		if not con.mouse_entered.is_connected(_on_tooltip_hover):
			con.mouse_entered.connect(_on_tooltip_hover.bind(null, null, VarTests.loc_name))
			con.mouse_exited.connect(_on_tooltip_exit.bind(null, null))
		color_blips(loc_area)

func discover_location(loc_name):
	if all_loc.values().has(loc_name):
		if not VarTests.DISCOVERED_LOCATIONS.has(loc_name):
			VarTests.DISCOVERED_LOCATIONS.append(loc_name)
			create_discovered_locations()

func evaluate_blip(loc_name):
	print('loc_name ', loc_name)
	VarTests.environment_name = loc_name
	var stats_file = LoadStats.read_env_stats(loc_name)
	#print('stats_file ', stats_file)

	# catch for 'instance1037'??? location
	if not stats_file:
		return

	var result    = LoadStats.parse_env_vars(stats_file)
	if Utils.array_find(result, '{encounters') != -1:
		if Utils.array_find(result, 'discoverable') != -1:
			# location revisit
			if VarTests.DISCOVERED_LOCATIONS.has(loc_name):
				var def_msg = Utils.array_find(result, 'default_message')
				if def_msg != -1:
					var text = result[def_msg].split(':')[-1]
					discovery_popup(text, loc_name)
			else:
				# location first time visit
				var dic_msg = Utils.array_find(result, 'dicovery_message')
				if dic_msg != -1:
					var text = result[dic_msg].split(':')[-1]
					discovery_popup(text, loc_name)
		else:
			get_encounter(stats_file)

# EValuatE Encounter
func get_encounter(stats_file):
	print('eevee')
	var stats_parsed = DiagParse.begin_parsing(stats_file, 'encounters')
	#print('stats_parsed ', stats_parsed)
	if stats_parsed:
		var options_parsed = DiagParse.parse_options(stats_parsed[2])
		print('options_parsed ', options_parsed)
		if stats_parsed[0].find('curated_list') != -1:
			var index = Utils.curated_list(stats_parsed, stats_parsed[0].split(' ')[1])
			print('index?? ', index)
			if index:
				var logic_func = DiagFunc.Logigier('', index)
				match logic_func[0]:
					"start_encounter":    start_encounter(logic_func[1])

func start_encounter(loc):
	VarTests.character_name = loc
	get_tree().change_scene_to_file("res://scenes/dialogue.tscn")

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

	var new_loc = adjacent_blips[closest_index]
	VarTests.map_target = new_loc
	evaluate_blip(all_loc[new_loc])
	blips_ready(new_loc)

func color_blips(blip_loc:Area2D):
	var temp:Sprite2D = blip_loc.get_node("Sprite2D")
	var child = temp.get_parent().get_child(0)

	# the child.modulate.a is a invisible Sprite2D used to determine movment
	# hide blips
	temp.redraw = null
	child.modulate.a = 0
	# adjacent blips
	if blip_loc in adjacent_blips:
		temp.redraw = 'adjacent_blips'
		child.modulate.a = 1
	# discovered locations
	if all_loc[blip_loc] in VarTests.DISCOVERED_LOCATIONS:
		temp.redraw = 'discovered'
		child.modulate.a = 1
	# at blip
	if blip_loc == VarTests.map_target:
		temp.redraw = 'on_top'
		# at discovered location
		if all_loc[blip_loc] in VarTests.DISCOVERED_LOCATIONS:
			temp.redraw = 'on_discovered'
		child.modulate.a = 1

func blips_ready(target):
	can_move = false
	var deltaX
	var deltaY
	var dist
	var rangee = 30
	adjacent_blips = []

	for i in all_loc.keys():
		var c = i.position
		var s = target.position
		#var c1 = i
		#var s1 = area
		deltaX = (c.x + i.scale.x / 2.0) - (s.x + target.scale.x / 2.0)
		deltaY = (c.y + i.scale.y / 2.0) - (s.y + target.scale.y / 2.0) # rounded distance
		dist = sqrt((deltaX * deltaX) + (deltaY * deltaY)) # DISTANCE CHECKING

		if dist <= rangee:
			adjacent_blips.append(i)
		color_blips(i)
	can_move = true

# mouse movement
func _on_blip_move(_viewport: Node, _event: InputEvent, _shape_idx: int, node:Area2D) -> void:
	# check for if discover pop up is not open
	if not discovery_popup_active:
		if Input.is_action_pressed("mouse_left"):
			var moved_loc = node.get_node("Sprite2D")
			# only allow adjacent blips
			var click_position = Vector2()
			if moved_loc.get_parent().get_child(0).modulate.a == 1:
				click_position = node.position
				click_position -= VarTests.map_target.position# + Vector2(10, 8)

				if can_move:
					map_collision_check(click_position.x, click_position.y)

func discovery_popup(text, loc_name):
	disco_cont.move_to_front()
	disco_cont.visible     = true
	discovery_popup_active = true
	camera.is_active       = false

	var vec_x = camera.position.x - (float(VarTests.stage_width) / 2)
	var vec_y = camera.position.y - (float(VarTests.stage_height) / 2)

	location            = loc_name
	disco_msg.text      = text
	disco_cont.position = Vector2(vec_x, vec_y)
	discover_location(loc_name)

func _on_discovery_popup_pass():
	disco_cont.visible     = false
	discovery_popup_active = false
	camera.is_active       = true

func _on_discovery_popup_enter():
	disco_cont.visible = false
	start_encounter(location)

func _on_button_mouse_entered() -> void:
	if not (chr_menu.visible or dck_menu.visible or inv_menu.visible or stn_menu.visible):
		discovery_popup_active = true
		camera.is_active    = false

func _on_button_mouse_exited() -> void:
	if not (chr_menu.visible or dck_menu.visible or inv_menu.visible or stn_menu.visible):
		discovery_popup_active = false
		camera.is_active    = true

func _on_button_chr_pressed() -> void:
	movement(chr_menu)
	menulist.append(chr_menu)
	chr_menu.move_to_front()

	chr_name.text   = VarTests.player_name
	hit_point.text  = "%s/%s" % [VarTests.player_hitpoints, VarTests.player_hitpoints + VarTests.player_hitpoints_damage]
	chr_menu_c.text = str(VarTests.player_stats["charisma"])
	chr_menu_w.text = str(VarTests.player_stats["will"])
	chr_menu_i.text = str(VarTests.player_stats["intelligence"])
	chr_menu_a.text = str(VarTests.player_stats["agility"])
	chr_menu_s.text = str(VarTests.player_stats["strength"])
	chr_menu_e.text = str(VarTests.player_stats["endurance"])
	resist_h.text   = str(VarTests.player_stats["heat_res"])
	resist_c.text   = str(VarTests.player_stats["cold_res"])
	resist_i.text   = str(VarTests.player_stats["impact_res"])
	resist_s.text   = str(VarTests.player_stats["slash_res"])
	resist_p.text   = str(VarTests.player_stats["pierce_res"])
	resist_m.text   = str(VarTests.player_stats["magic_res"])
	resist_b.text   = str(VarTests.player_stats["bio_res"])

func _on_button_dck_pressed() -> void:
	movement(dck_menu)
	menulist.append(dck_menu)

	dck_menu.move_to_front()

func _on_button_inv_pressed() -> void:
	movement(inv_menu)
	menulist.append(inv_menu)
	var items = count_items(VarTests.ITEM_INVENTORY)

	inventory.choices = items[1].map(func(item): return item.replace('_', ' '))
	refresh_equipped_items()
	inv_menu.move_to_front()

func inv_change(item):
	var found = VarTests.ITEM_SLOTS.find(item)
	if found != -1:
		MiscFunc.unequip_item(item)
	else:
		MiscFunc.equip_item(item)
	refresh_equipped_items()

# 1x white socks -> ["1x", "white_socks"]
func unformat(formatted):
	var rawmatted:Array = formatted.split(' ', true, 1)
	return rawmatted.map(func(item): return item.replace(' ', '_'))

func _on_button_inv_item_pressed(index) -> void:
	inv_change(unformat(inventory.choices[index])[1])

func refresh_equipped_items():
	#GENDER SPECIFIER
	var g_specifier
	if VarTests.player_gender == "female":
		g_specifier = "_f"
	else:
		g_specifier = "_m"

	var slots = [
		mannequin, underwear, socks, shoes, boots, legs, 
		torso, head, hands, mainhand, offhand, sidearm, twohand
	]
	var doll = "res://database/items/graphics/default%s/default%s.png" % [g_specifier, g_specifier]
	player_doll.texture = load(doll)

	var item_tex
	for i in range(13):
		if VarTests.ITEM_SLOTS[i] != 'empty':
			var path = 'res://database/items/graphics/default%s/%s%s' % [g_specifier, VarTests.ITEM_SLOTS[i], g_specifier]
			if FileAccess.file_exists('%s.png' % path):
				var path1 = '%s_tucked.png' % [path]
				# boots exception
				if FileAccess.file_exists(path1) and VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["boots"]] != "empty":
					item_tex = load(path1)
				else:
					item_tex = load('%s.png' % [path])
				slots[i].visible = true
				slots[i].texture = item_tex
		else:
			slots[i].visible = false

func _on_button_stn_pressed() -> void:
	movement(stn_menu)
	menulist.append(stn_menu)

	stn_menu.move_to_front()

func parse_equiped_cards():
	var card_count = count_items(VarTests.player_DECK)
	dck_label.text = "%s/%s" % [card_count[0], deck_minimum_size]
	dck_menu_equiped_cards.choices = card_count[-1]

	card_count = count_items(VarTests.CARD_INVENTORY)
	dck_menu_available_cards.choices = card_count[-1]

func _on_dck_cards_available(index):
	var card = unformat(dck_menu_available_cards.choices[index])[1]
	var player_card_count = count_items(VarTests.player_DECK)
	var player_what_cards = VarTests.player_DECK.count(card)
	var house_what_cards  = VarTests.CARD_INVENTORY.count(card)

	# ERROR player_card_count[0] allowed to go one over deck_minimum_size
	# fixed by removing = not fixing because it does the same ingame
	if player_card_count[0] <= deck_minimum_size and player_what_cards < house_what_cards:
			VarTests.player_DECK.append(card)

			player_card_count = count_items(VarTests.player_DECK)
			dck_menu_equiped_cards.choices = player_card_count[-1]
			dck_label.text = "%s/%s" % [player_card_count[0], deck_minimum_size]
	# catch for not being able to remove the last card
	if len(VarTests.player_DECK) > 0:
		dck_menu_equiped_cards.visible = true

func _on_dck_cards_equiped(index):
	if index < len(dck_menu_equiped_cards.choices):
		var card = dck_menu_equiped_cards.choices[index]

		VarTests.player_DECK.erase(unformat(card)[1])
	# catch for not being able to remove the last card
	if len(VarTests.player_DECK) == 0:
		dck_menu_equiped_cards.visible = false

	var card_count = count_items(VarTests.player_DECK)
	dck_label.text = "%s/%s" % [card_count[0], deck_minimum_size]
	dck_menu_equiped_cards.choices = card_count[-1]

func count_items(deck):
	var unique_items = []
	for i in deck:
		if i not in unique_items:
			unique_items.append(i)
	var many = []
	for i in unique_items:
		many.append([i, deck.count(i)])
	var formatted = []
	var count = 0
	for i in many:
		var card = i[0]
		var amount = int(i[1])
		count += amount
		formatted.append('%sx %s' % [amount, card])
	return [count, formatted]

func is_clicked(event):
	if event is InputEventMouseButton:
		if event.button_mask == 1:
			return true
	return false

# shapes is an array because I want it to break on the first shape it uses
# this fixes overlapping hitboxes
var shapes = []
func shape_test():
	#shapes.reverse()
	for shape in shapes:
		print(shape, ' clicked')
		var item = VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS[shape]]
		inv_change(item)
		break
	shapes = []

func _on_twohand_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('twohand clicked')
		shapes.append("twohand")

func _on_sidearm_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('sidearm clicked')
		shapes.append("sidearm")

func _on_offhand_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('offhand clicked')
		shapes.append("offhand")

func _on_mainhand_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('mainhand clicked')
		shapes.append("mainhand")

#func _on_hand_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
#	if is_clicked(event):
#		print('hand clicked')
#		var item = VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["hand"]]
#		inv_change(item)

func _on_head_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('head clicked')
		shapes.append("head")

func _on_torso_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('torso clicked')
		shapes.append("torso")

func _on_legs_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('legs clicked')
		shapes.append("legs")

func _on_boots_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('boots clicked')
		shapes.append("boots")

func _on_shoes_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('shoes clicked')
		shapes.append("shoes")

func _on_socks_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('socks clicked')
		shapes.append('socks')

func _on_underwear_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_clicked(event):
		print('underwear clicked')
		shapes.append('underwear')

func _on_button_pause_new_game_pressed() -> void:
	var new_tex = TextureRect.new()
	new_tex.texture = load("res://assets/images/menu_background.png")
	#cover camera
	var vec_x = camera.position.x - (float(VarTests.stage_width) / 2)
	var vec_y = camera.position.y - (float(VarTests.stage_height) / 2)
	new_tex.position = Vector2(vec_x, vec_y)
	CanLay.add_child(new_tex)
	#new_tex.move_to_front()

	var ng_menu = new_game.instantiate()
	ng_menu.visible = false
	CanLay.add_child(ng_menu)
	movement(ng_menu, 0.7)

func _on_button_pause_save_load_pressed() -> void:
	movement(save_load)
	menulist.append(save_load)

	save_load.move_to_front()

@warning_ignore("unused_parameter")
func _on_save_selected(index: Variant) -> void:
	pass # Replace with function body.

func _on_button_save_pressed() -> void:
	pass # Replace with function body.

func _on_button_load_pressed() -> void:
	pass # Replace with function body.

func _on_button_delete_pressed() -> void:
	pass # Replace with function body.
