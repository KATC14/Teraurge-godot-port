extends Node


var player_heat_res     = VarTests.player_stats["heat_res"]
var player_cold_res     = VarTests.player_stats["cold_res"]
var player_impact_res   = VarTests.player_stats["impact_res"]
var player_slash_res    = VarTests.player_stats["slash_res"]
var player_pierce_res   = VarTests.player_stats["pierce_res"]
var player_magic_res    = VarTests.player_stats["magic_res"]
var player_bio_res      = VarTests.player_stats["bio_res"]

var player_charisma     = VarTests.player_stats['charisma']
var player_will         = VarTests.player_stats['will']
var player_intelligence = VarTests.player_stats['intelligence']
#var player_perception  = VarTests.player_stats['perception']
var player_agility      = VarTests.player_stats['agility']
var player_strength     = VarTests.player_stats['strength']
var player_endurance    = VarTests.player_stats['endurance']

func _ready() -> void:
	game_start()

func game_start() -> void: 
	# START THE GAME INTO THE INTRO
	# load items
	starting_inventory()
	starting_cards()
	VarTests.environment_name = "intro"
	#VarTests.character_name = "intro"
	#advance_time(0)
	#new_encounter()

func starting_inventory():
	var file = FileAccess.open("res://database/items/items.txt", FileAccess.READ)
	VarTests.ALL_ITEMS = file.get_as_text()

	VarTests.ITEM_INVENTORY = ["tshirt", "jeans", "shoes", "white_socks", "underwear"]
	for i in VarTests.ITEM_INVENTORY:
		equip_item(i)

func starting_cards():
	# load cards
	var file = FileAccess.open("res://database/cards/cards.txt", FileAccess.READ)
	VarTests.ALL_CARDS = file.get_as_text()

	VarTests.CARD_INVENTORY = ["kick", "kick", "body_tackle", "panicked_slap", "panicked_slap", "panicked_slap", "panicked_slap", "wrestle", "wrestle", "right_hook", "left_hook", "left_hook", "panicked_slap", "panicked_slap", "panicked_slap", "clumsy_kick", "clumsy_kick"]

# COLOR TRASNFORM BY TIME
# only figured this shit out by stumbling onto this https://amp.flylib.com/books/en/4.261.1.33/1/
# I dont think the website is displaying images right but the words are there
func tint(mc:TextureRect):
	var val = VarTests.ATMOSPHERIC_MULTIPLIER
	var a_tint = Color.BLACK
	# 28 — 60 / 100 + 20
	#newRed = oldRed * ra / 100 + rb
	a_tint.r = 1 - (mc.modulate.r * a_tint.r / 0.65 + val)
	a_tint.g = 1 - (mc.modulate.g * a_tint.g / 0.40 + val)
	a_tint.b = 1 - (mc.modulate.b * a_tint.b / 0.55 + val)

	var square = [a_tint.r, a_tint.g, a_tint.b].map(func(i): return sqrt(i) + .07)
	a_tint = Color(square[0], square[1], square[2])

	if a_tint.r > 1: a_tint = Color.WHITE
	if a_tint.r < 0.5: a_tint += Color(.05, .05, .05)
	if a_tint.r < 0.4: a_tint += Color(.07, .07, .07)
	if a_tint.r < 0.3: a_tint += Color(.15, .15, .15)

	mc.modulate = a_tint

func super_tint(object, e_color:Color, e_val):
	e_val = 1.244 - e_val

	e_color.r += ((1 - e_color.r) * e_val)
	e_color.g += ((1 - e_color.g) * e_val)
	e_color.b += ((1 - e_color.b) * e_val)

	var env_stats = LoadStats.parse_env_vars(LoadStats.read_env_stats(VarTests.environment_name))
	if MiscFunc.parse_stat('interior', env_stats) == 'yes':
		object.modulate = e_color

# PARSE STAT
func parse_stat(stat_name, stats, _case_sensitive=false)-> String:
	#if case_sensitive == false:
	#	stats = stats.toLowerCase

	#var searched_stat
	var statar_index = Utils.array_find(stats, stat_name)

	# commented out for misbehavior
	#if statar_index == -1:
	#	searched_stat = "0"
	#else:
	#	searched_stat = Utils.get_substring("%s:" % stat_name, "", stats[statar_index])
	#if stat_name == null:
	#	searched_stat = "0"

	if statar_index != -1:
		var found = stats[statar_index]
		if ':' in found:
			return found.split(':')[1].strip_edges()
	return "0"

# EQUIP ITEM
func equip_item(item):
	item = item.to_lower()
	# get item stats
	var item_string = Utils.get_substring("<%s" % item, "%s>" % item, VarTests.ALL_ITEMS.to_lower())
	var item_stats:Array = item_string.split(", ")

	var slot = parse_stat("slot", item_stats)

	var card   = parse_stat("card", item_stats)
	var card_n = int(parse_stat("card_n", item_stats))

	# if the item is same as equipped => remove
	if VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS[slot]] == item:

		unequip_item(item)
		#equip func stops
		return

	# boots exception
	if slot == "boots" || slot == "shoes":
		unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["shoes"]])
		unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["boots"]])

	# twohanded exception
	elif slot == "twohanded":
		unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["offhand"]])
		unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["mainhand"]])
		unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["twohanded"]])

	# twohanded exception
	elif slot == "offhand" || slot == "mainhand":
		unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS["twohanded"]])

	# if slot is occupied => remove current item and add new item
	unequip_item(VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS[slot]])
	VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS[slot]] = item

	# add item card to the start deck
	# add card(s) to the inventory and the deck
	if card:
		for i in range(card_n):
			VarTests.player_DECK.append(card)
			VarTests.CARD_INVENTORY.append(card)
		#var i = 0
		#while i < card_n:
		#	VarTests.player_DECK.append(card)
		#	VarTests.CARD_INVENTORY.append(card)
		#	i += 1

	player_heat_res     += int(parse_stat("heat_res", item_stats))
	player_cold_res     += int(parse_stat("cold_res", item_stats))
	player_impact_res   += int(parse_stat("impact_res", item_stats))
	player_slash_res    += int(parse_stat("slash_res", item_stats))
	player_pierce_res   += int(parse_stat("pierce_res", item_stats))
	player_magic_res    += int(parse_stat("magic_res", item_stats))
	player_bio_res      += int(parse_stat("bio_res", item_stats))

	player_charisma     += int(parse_stat("charisma", item_stats))
	player_will         += int(parse_stat("will", item_stats))
	player_intelligence += int(parse_stat("intelligence", item_stats))
	#player_perception   += int(parse_stat("perception", item_stats))
	player_agility      += int(parse_stat("agility", item_stats))
	player_strength     += int(parse_stat("strength", item_stats))
	player_endurance    += int(parse_stat("endurance", item_stats))

# UNEQUIP ITEM
func unequip_item(item):
	item = item.to_lower()
	if item == "empty" or item == "" or item == null:
		return

	# get item stats
	var item_string = Utils.get_substring("<%s" % item, "%s>" % item, VarTests.ALL_ITEMS.to_lower())
	# catch for nonexistent items
	if not item_string:
		return

	var item_stats = item_string.split(", ")

	var card = parse_stat("card", item_stats)
	var card_n = int(parse_stat("card_n", item_stats))

	# remove item card from the start deck
	#VarTests.player_DECK.splice(VarTests.player_DECK.indexOf(card), 1)

	# remove card(s) from the inventory and the deck
	if card != "":
		for i in range(card_n):
			VarTests.player_DECK.erase(card)
		for i in range(card_n):
			VarTests.CARD_INVENTORY.erase(card)
		#var i = 0
		#while i < card_n:
		#	var found = Utils.array_find(VarTests.player_DECK, card)
		#	if found != -1:
		#		VarTests.player_DECK.erase(found)
		#	found = Utils.array_find(VarTests.CARD_INVENTORY, card)
		#	if found != -1:
		#		VarTests.CARD_INVENTORY.erase(found)
		#	i += 1

	# remove item from the slot
	var slot = parse_stat("slot", item_stats)
	VarTests.ITEM_SLOTS[VarTests.SLOT_KEYS[slot]] = "empty"

	player_heat_res     -= int(parse_stat("heat_res", item_stats))
	player_cold_res     -= int(parse_stat("cold_res", item_stats))
	player_impact_res   -= int(parse_stat("impact_res", item_stats))
	player_slash_res    -= int(parse_stat("slash_res", item_stats))
	player_pierce_res   -= int(parse_stat("pierce_res", item_stats))
	player_magic_res    -= int(parse_stat("magic_res", item_stats))
	player_bio_res      -= int(parse_stat("bio_res", item_stats))

	player_charisma     -= int(parse_stat("charisma", item_stats))
	player_will         -= int(parse_stat("will", item_stats))
	player_intelligence -= int(parse_stat("intelligence", item_stats))
	#player_perception   -= int(parse_stat("perception", item_stats))
	player_agility      -= int(parse_stat("agility", item_stats))
	player_strength     -= int(parse_stat("strength", item_stats))
	player_endurance    -= int(parse_stat("endurance", item_stats))

# UNEQUIP ITEM
func remove_item(item):
	unequip_item(item)
	VarTests.ITEM_INVENTORY.erase(item)

var menulist = []
func menu_slide(source_object, camera, time=0.25):
	var tween
	if source_object.visible:
		tween = menu_slide_out(source_object, camera, time)
		if camera is not Vector2:
			camera.is_active    = true
	else:
		tween = menu_slide_in(source_object, camera, time)
		source_object.visible = true
		if camera is not Vector2:
			camera.is_active    = false
	menulist.erase(source_object)
	for i in menulist:
		menu_slide_out(i, camera)
	return tween

#MENU SLIDE IN
func menu_slide_in(source_object, camera, time=0.25):
	# DISABLE MAP CLICKING
	var cam_position = Vector2(640.0, 360.0)
	if camera is Vector2:
		cam_position += camera
	if camera is not Vector2:
		camera.is_active    = false
		cam_position = camera.position
		

	var vec_x = cam_position.x - (float(VarTests.stage_width) / 2)
	var vec_y = VarTests.stage_height + cam_position.y
	source_object.position = Vector2(vec_x, vec_y)
	vec_y = cam_position.y - (float(VarTests.stage_height) / 2)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(source_object, "position:y", vec_y, time)
	return tween

#MENU SLIDE OUT
func menu_slide_out(source_object, camera, time=0.25):
	var vec_y = 1080
	if camera is Vector2:
		vec_y += camera.y
	if camera is not Vector2:
		vec_y = VarTests.stage_height + camera.position.y

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(source_object, "position:y", vec_y, time)
	tween.finished.connect(func(): source_object.visible = false)
	return tween

# ADVANCE TIME
func advance_time(forward: int):
	while forward > 100:
		VarTests.DAYS += 1
		forward -= 100

	VarTests.TIME += forward
	if VarTests.TIME > 100:
		VarTests.TIME -= 100
		VarTests.DAYS += 1
	check_timers()

	# ATMOSPHERIC PERCENTAGE
	if VarTests.TIME - 50 < 0:
		VarTests.ATMOSPHERIC_MULTIPLIER = ((VarTests.TIME - 50) * -1) * 2.0 / 100
	else:
		VarTests.ATMOSPHERIC_MULTIPLIER = (VarTests.TIME - 50) * 2.0 / 100
	#advance_time_to = 0;
	turn_overmap_dial()

func turn_overmap_dial():
	var current_scene = get_tree().current_scene
	if current_scene.name == 'map':
		var overmap_dial = current_scene.get_node_or_null('%overmap_ui_dial')
		var sun_dial_lbl = current_scene.get_node_or_null('%sun_dial_lbl')

		overmap_dial.rotation_degrees = (-360 / 100.0) * VarTests.TIME
		sun_dial_lbl.text = str(VarTests.DAYS)

func check_timers():
	for timer in VarTests.TIMERS:
		var stimer = timer.split('.')

		if VarTests.DAYS == int(stimer[1]):
			VarTests.TIMERS.erase(timer)
			for trigger in stimer[2].split('&'):
				DiagFunc.script_library(trigger)
