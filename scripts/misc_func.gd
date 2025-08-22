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


func get_allowed(the_array, full_str='empty'):
	var ret_array = []
	for i in range(len(the_array[0])):
		var value = Showif.check_for_showif(the_array[2][i], full_str)
		ret_array.append(value)
	return ret_array

func super_tint(object, e_color:Color, e_val):
	e_val = 1 - e_val
	
	var r = e_color.r
	var g = e_color.g
	var b = e_color.b
	#object.modulate = Color(r, g, b)

	var redMultiplier   = r + ((1 - r) * e_val)
	var greenMultiplier = g + ((1 - g) * e_val)
	var blueMultiplier  = b + ((1 - b) * e_val)
	# this is correct?
	object.modulate = Color(redMultiplier, greenMultiplier, blueMultiplier)

# PARSE STAT
func parse_stat(stat_name, stats, _case_sensitive=false):
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
	if statar_index == -1:
		return null
	else:
		var found = stats[statar_index]
		if ':' in found:
			return found.split(':')[1].strip_edges()
		elif found:
			return found.split(stat_name)[1].strip_edges()

# EQUIP ITEM
func equip_item(item):
	item = item.to_lower()
	# get item stats
	var item_string = Utils.get_substring("<%s" % item, "%s>" % item, VarTests.ALL_ITEMS.to_lower())
	var item_stats:Array = item_string.split("\n")

	var slot = parse_stat("slot", item_stats)

	var card = parse_stat("card", item_stats)
	var card_n= int(parse_stat("card_n", item_stats))

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
		#	VarTests.player_DECK.push(card)
		#	VarTests.CARD_INVENTORY.push(card)
		#	i += 1

	player_heat_res		+= int(parse_stat("heat_res", item_stats))
	player_cold_res		+= int(parse_stat("cold_res", item_stats))
	player_impact_res	+= int(parse_stat("impact_res", item_stats))
	player_slash_res	+= int(parse_stat("slash_res", item_stats))
	player_pierce_res	+= int(parse_stat("pierce_res", item_stats))
	player_magic_res	+= int(parse_stat("magic_res", item_stats))
	player_bio_res		+= int(parse_stat("bio_res", item_stats))

	player_charisma		+= int(parse_stat("charisma", item_stats))
	player_will			+= int(parse_stat("will", item_stats))
	player_intelligence	+= int(parse_stat("intelligence", item_stats))
	#player_perception	+= int(parse_stat("perception", item_stats))
	player_agility		+= int(parse_stat("agility", item_stats))
	player_strength		+= int(parse_stat("strength", item_stats))
	player_endurance	+= int(parse_stat("endurance", item_stats))

#UNEQUIP ITEM
func unequip_item(item):
	item = item.to_lower()
	if item == "empty" or item == "" or item == null:
		return

	# get item stats
	var item_string = Utils.get_substring("<%s" % item, "%s>" % item, VarTests.ALL_ITEMS.to_lower())

	var item_stats = item_string.split("\n")

	var card = parse_stat("card", item_stats)
	var card_n = int(parse_stat("card_n", item_stats))

	# remove item card from the start deck
	#VarTests.player_DECK.splice(VarTests.player_DECK.indexOf(card), 1)

	#remove card(s) from the inventory and the deck
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

	player_heat_res		-= int(parse_stat("heat_res", item_stats))
	player_cold_res		-= int(parse_stat("cold_res", item_stats))
	player_impact_res	-= int(parse_stat("impact_res", item_stats))
	player_slash_res	-= int(parse_stat("slash_res", item_stats))
	player_pierce_res	-= int(parse_stat("pierce_res", item_stats))
	player_magic_res	-= int(parse_stat("magic_res", item_stats))
	player_bio_res		-= int(parse_stat("bio_res", item_stats))

	player_charisma		-= int(parse_stat("charisma", item_stats))
	player_will			-= int(parse_stat("will", item_stats))
	player_intelligence	-= int(parse_stat("intelligence", item_stats))
	#player_perception	-= int(parse_stat("perception", item_stats))
	player_agility		-= int(parse_stat("agility", item_stats))
	player_strength		-= int(parse_stat("strength", item_stats))
	player_endurance	-= int(parse_stat("endurance", item_stats))
