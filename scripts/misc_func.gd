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
func tint(mc:TextureRect):
	var val = VarTests.ATMOSPHERIC_MULTIPLIER
	#var a_tint: Color = Color.WHITE
	var r = 1
	var g = 1
	var b = 1

	r *= (0.65 * val)
	g *= (0.55 * val)
	b *= (0.40 * val)

	r += -40 * val
	g += -25 * val
	b += -18 * val

	r = r / 255
	g = g / 255
	b = b / 255
	r = abs(r)
	g = abs(g)
	b = abs(b)

	print(r, ' ', g, ' ', b, ' ')
	print(mc)
	mc.modulate = Color(r, g, b)
	print(mc.modulate)
	print()

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
