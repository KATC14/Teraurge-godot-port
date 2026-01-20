extends Node

signal loc_start
signal loc_move

@onready var CanLay      = $CanvasLayer
#@onready var map        = $CanvasLayer/TextureRect
@onready var disco_cont = $CanvasLayer/Control
@onready var disco_msg  = $CanvasLayer/Control/Label
@onready var camera     = $CanvasLayer/Camera2D
@onready var character  = $CanvasLayer/CharacterBody2D

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
@onready var blip = load("res://scenes/blip.tscn")

var map_data = "res://database/maps/default_data.txt"
var ATMOSPHERIC_MULTIPLIER = 1
var advance_time_to = 0
var location

var tooltip
var tooltip_hovered = false

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
	create_dicovered_locations()

func _input(_event: InputEvent) -> void:
	if tooltip_hovered:
		# camera.position.x half the screen
		# camera.position.x + (VarTests.stage_width * 2)
		@warning_ignore("integer_division")
		var vec_x = camera.position.x + (VarTests.stage_width / 2)
		@warning_ignore("integer_division")
		var vec_y = camera.position.y - (VarTests.stage_height / 2)
		tooltip.width  = vec_x
		tooltip.height = vec_y
	if Input.is_action_pressed("mouse_left"):
		if inv_menu.visible:
			shape_test.call_deferred()

func _on_tooltip_hover(array, index):
	tooltip_hovered = true
	tooltip = load("res://scenes/tool_tip.tscn").instantiate()
	print('tooltip_hover ', array)
	tooltip.get_node("Label").text = str(index)
	tooltip.visible = true
	CanLay.add_child(tooltip)
	tooltip.move_to_front()

func _on_tooltip_exit(_array, _index):
	tooltip_hovered = false
	tooltip.visible = false
	tooltip.queue_free()

var menulist = []
func movement(source_object, time=0.25):
	if source_object.visible:
		menu_slide_out(source_object, time)
		character.is_active = true
		camera.is_active    = true
	else:
		menu_slide_in(source_object, time)
		source_object.visible = true
		character.is_active = false
		camera.is_active    = false
	menulist.erase(source_object)
	for i in menulist:
		menu_slide_out(i)

#MENU SLIDE IN
func menu_slide_in(source_object, time=0.25):
	#DISABLE MAP CLICKING
	character.is_active = false
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
	VarTests.TIME = VarTests.TIME + forward;
	if VarTests.TIME > 100:
		VarTests.TIME = VarTests.TIME - 100;
		VarTests.DAYS += 1
	#trace("day: "+DAYS+" time: "+TIME); #DEBUG
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
	CanLay.add_child(instance)

	return instance

func create_locations() -> void:
	var map_file = Utils.load_file(map_data).replace('][', '\n')
	#[2147.25|3157.6|15|blip_place|sejan_witch_house]
	#    0     1      2     3             4
	#    x     y      r     ?          loc_name
	var maxx = map_file.split('\n').size()
	for i in map_file.split('\n').size():
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
		VarTests.all_loc.append(area)
		match data_out[3]:
			"blip":           pass
			"blip_named":     pass
			"blip_encounter": pass
			#"blip_place":     pass
			"no_name":        pass
			_:
				VarTests.named_loc[loc_name] = area
		if i == maxx-1:
			VarTests.map_target = VarTests.named_loc['sejan_witch_house']
			loc_start.emit(VarTests.all_loc, VarTests.map_target)
			character.can_move = true

func create_dicovered_locations():
	for i in VarTests.DISCOVERED_LOCATIONS:
		var instance = VarTests.named_loc[i]
		var sprite: Sprite2D = instance.get_node("Sprite2D")
		sprite.modulate = Color.html('#00FFFF')

func discover_location(loc_name):
	if VarTests.named_loc.has(loc_name):
		if not VarTests.DISCOVERED_LOCATIONS.has(loc_name):
			VarTests.DISCOVERED_LOCATIONS.append(loc_name)
			create_dicovered_locations()

func parse_env_vars(stats_file):
	#opt_array = re.sub('>>.*', '', opt_array)
	var re = RegEx.new()
	re.compile('[\r\t]')
	stats_file = re.sub(stats_file, '', true)
	var thespt:Array = stats_file.split('\n')

	var wanted = [
		'interior', 'ambient_color', 'ambient', 
		'discoverable', 'dicovery_message', 'default_message'
	]

	var result = []
	for i in wanted:
		for x in thespt.filter(func(item): if i in item: return item):
			result.append(x)
	var thing = result.map(func (item): return item)

	return thing

func _on_load_blip(loc_name):
	print('loc_name ', loc_name)
	var stats_file = LoadStats.read_env_stats(loc_name)
	#print('stats_file ', stats_file)

	# catch for 'instance1037'??? location
	if not stats_file:
		return

	var result    = parse_env_vars(stats_file)
	#print(result)
	var disco     = Utils.array_find(result, 'discoverable')
	print('disco ', disco)
	if disco != -1:
		# location revisit
		if VarTests.DISCOVERED_LOCATIONS.has(loc_name):
			var def_msg = Utils.array_find(result, 'default_message')
			print('def_msg ', def_msg)
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
		env_encounter(stats_file)

func env_encounter(stats_file):
	var stats_parsed = DiagParse.begin_parsing(stats_file, 'encounters')
	print('stats_parsed ', stats_parsed)
	if stats_parsed:
		var options_parsed = DiagParse.parse_options(stats_parsed[2])
		var found = stats_parsed[0].find('curated_list')
		if found != -1:
			# parses out same structure tree but with only allowed values
			var allowed = []
			var first   = []
			var second  = []
			var third   = []
			var forth   = []
			var value = Showif.get_allowed(options_parsed)
			for i in range(len(value)):
				if not value[i]:
					first.append(options_parsed[0][i])
					second.append(options_parsed[1][i])
					third.append(options_parsed[2][i])
					forth.append(options_parsed[3][i])
			allowed.append(first)
			allowed.append(second)
			allowed.append(third)
			allowed.append(forth)
			print('random allowed ', allowed)

			var index
			var curated_list = stats_parsed[0].split(' ')[1]
			if curated_list == "random":
				index = randi_range(0, len(allowed[0])-1)
				print('random len ', len(allowed[0])-1)
			if curated_list == "weighted":
				pass
			if curated_list == "prioritized": index = 0
			print('random index ', index)
			print('random 1 ', allowed[0][index]) # option index
			print('random 2 ', allowed[1][index]) # index func
			print('random 3 ', allowed[2][index]) # option func
			print('random 4 ', allowed[3][index]) # diag text
			#print('random value ', value)
			print()
		#get_tree().change_scene_to_file("res://scenes/dialogue.tscn")

func discovery_popup(text, loc_name):
	disco_cont.move_to_front()
	disco_cont.visible  = true
	character.is_active = false
	camera.is_active    = false

	var vec_x = camera.position.x - (float(VarTests.stage_width) / 2)
	var vec_y = camera.position.y - (float(VarTests.stage_height) / 2)

	location            = loc_name
	disco_msg.text      = text
	disco_cont.position = Vector2(vec_x, vec_y)
	discover_location(loc_name)

func _on_discovery_popup_pass():
	disco_cont.visible  = false
	character.is_active = true
	camera.is_active    = true

func _on_discovery_popup_enter():
	disco_cont.visible = false
	VarTests.character_name = location
	get_tree().change_scene_to_file("res://scenes/dialogue.tscn")

func _on_button_mouse_entered() -> void:
	if not (chr_menu.visible or dck_menu.visible or inv_menu.visible or stn_menu.visible):
		character.is_active = false
		camera.is_active    = false

func _on_button_mouse_exited() -> void:
	if not (chr_menu.visible or dck_menu.visible or inv_menu.visible or stn_menu.visible):
		character.is_active = true
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

	inventory.choices = items[1]
	refresh_equipped_items()
	inv_menu.move_to_front()

func inv_change(item):
	var found = VarTests.ITEM_SLOTS.find(item)
	if found != -1:
		MiscFunc.unequip_item(item)
	else:
		MiscFunc.equip_item(item)
	refresh_equipped_items()

# 1x tshirt -> ["1x", "tshirt"]
func unformat(formatted):
	return formatted.split(' ')

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
