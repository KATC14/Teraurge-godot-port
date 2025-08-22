extends Control


@onready var char_name  = $Control3/TextEdit
# NEW_GAME
func style_setter(node, node_1, style):
	node.add_theme_stylebox_override("pressed",       style)
	node.add_theme_stylebox_override("hover_pressed", style)
	node.add_theme_stylebox_override("hover",         style)
	node.add_theme_stylebox_override("normal",        style)

	node_1.add_theme_stylebox_override("pressed",       StyleBoxEmpty.new())
	node_1.add_theme_stylebox_override("hover_pressed", StyleBoxEmpty.new())
	node_1.add_theme_stylebox_override("hover",         StyleBoxEmpty.new())
	node_1.add_theme_stylebox_override("normal",        StyleBoxEmpty.new())

@onready var button_female = $Control/Button
@onready var button_male   = $Control/Button2
@onready var player_doll   = $Control/TextureRect2
func _on_button_female_pressed() -> void:
	player_doll.texture = load("res://database/items/graphics/default_f/default_f.png")
	if char_name.text == 'John': char_name.text = 'Jane'
	VarTests.player_gender = 'female'

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_female.png")
	style_setter(button_female, button_male, temp)
func _on_button_male_pressed() -> void:
	player_doll.texture = load("res://database/items/graphics/default_m/default_m.png")
	if char_name.text == 'Jane': char_name.text = 'John'
	VarTests.player_gender = 'male'

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_male.png")
	style_setter(button_male, button_female, temp)

func _on_button_start_game_pressed() -> void:
	print('new game')
	VarTests.player_name = char_name.text
	VarTests.player_stats['charisma']     = int(label_char.text)
	VarTests.player_stats['will']         = int(label_will.text)
	VarTests.player_stats['intelligence'] = int(label_inte.text)

	VarTests.player_stats['agility']      = int(label_agil.text)
	VarTests.player_stats['strength']     = int(label_stre.text)
	VarTests.player_stats['endurance']    = int(label_endu.text)
	starting_cards()
	# load cards
	VarTests.ALL_CARDS = load("res://database/cards/cards.txt")
	# load items
	VarTests.ALL_ITEMS = load("res://database/items/items.txt")

	VarTests.ITEM_INVENTORY.append("tshirt")
	VarTests.ITEM_INVENTORY.append("jeans")
	VarTests.ITEM_INVENTORY.append("shoes")
	VarTests.ITEM_INVENTORY.append("white_socks")
	VarTests.ITEM_INVENTORY.append("underwear")
	for i in VarTests.ITEM_INVENTORY:
		MiscFunc.equip_item(i)

	VarTests.character_name = 'intro'
	get_tree().change_scene_to_file("res://scenes/dialogue.tscn")

func starting_cards():
	VarTests.CARD_INVENTORY = ["kick", "kick", "body_tackle", "panicked_slap", "panicked_slap", "panicked_slap", "panicked_slap", "wrestle", "wrestle", "right_hook", "left_hook", "left_hook", "panicked_slap", "panicked_slap", "panicked_slap", "clumsy_kick", "clumsy_kick"]
	return

	# deprecated system? ignore unreachable code
	@warning_ignore("unreachable_code")
	var player_charisma     = VarTests.player_stats['charisma']
	var player_will         = VarTests.player_stats['will']
	var player_intelligence = VarTests.player_stats['intelligence']

	var player_agility      = VarTests.player_stats['agility']
	var player_strength     = VarTests.player_stats['strength']
	var player_endurance    = VarTests.player_stats['endurance']
	#CHARISMA CARDS
	match player_charisma:
		1: pass
		#2: pass
		#3: pass
		#4: pass

	#WILL CARDS
	match player_will:
		1: VarTests.CARD_INVENTORY.append_array(["panicked_slap", "panicked_slap", "panicked_slap", "panicked_slap", "panicked_slap", "panicked_slap"])
		#2: VarTests.CARD_INVENTORY.append_array(["panicked_slap", "panicked_slap", "panicked_slap"])
		#3: VarTests.CARD_INVENTORY.append_array(["panicked_slap", "headbutt"])
		#4: VarTests.CARD_INVENTORY.append_array(["bite", "headbutt"])

	#INTELLIGENCE CARDS
	match player_intelligence:
		1: VarTests.player_hand_size = 4
		#2: VarTests.player_hand_size = 5
		#3: VarTests.player_hand_size = 6
		#4: VarTests.player_hand_size = 8

	#AGILITY CARDS
	match player_agility:
		1: VarTests.CARD_INVENTORY.append_array(["quick_punch"])
		#2: VarTests.CARD_INVENTORY.append_array(["quick_punch", "quick_punch", "quick_punch"])
		#3: VarTests.CARD_INVENTORY.append_array(["quick_punch", "quick_punch", "quick_punch", "quick_punch", "quick_punch"])
		#4: VarTests.CARD_INVENTORY.append_array(["quick_punch", "quick_punch", "quick_punch", "quick_punch", "quick_punch", "quick_punch", "quick_punch", "quick_punch", "quick_punch"])

	if player_agility == 2 and player_strength == 2:
		VarTests.CARD_INVENTORY.append_array(["kick", "kick"])

	#STRENGTH CARDS
	match player_strength:
		1: VarTests.CARD_INVENTORY.append_array(["punch"])
		#2: VarTests.CARD_INVENTORY.append_array(["punch", "punch"])
		#3:
		#	VarTests.CARD_INVENTORY.append_array(["punch", "punch", "punch"])
		#	if player_agility >= 2: VarTests.CARD_INVENTORY.append_array(["shove", "shove"])
		#4:
		#	VarTests.CARD_INVENTORY.append_array(["punch", "punch", "punch", "punch", "heavy_punch"])
		#	if player_agility >= 2: VarTests.CARD_INVENTORY.append_array(["shove", "shove", "shove"])

	#ENDURANCE CARDS
	match player_endurance:
		1: VarTests.player_base_hitpoints = 32
		#2:
		#	VarTests.player_base_hitpoints = 40
		#	VarTests.CARD_INVENTORY.append_array(["recovery"])
		#3:
		#	VarTests.player_base_hitpoints = 44
		#	VarTests.CARD_INVENTORY.append_array(["recovery", "recovery"])
		#4:
		#	VarTests.player_base_hitpoints = 46
		#	VarTests.CARD_INVENTORY.append_array(["recovery", "recovery", "recovery"])
	#recovery at 3 and 4 endurance
	VarTests.player_DECK = ["punch"]

# filters
@onready var filter_rape_off  = $Control2/Button
@onready var filter_feral_off = $Control2/Button2
@onready var filter_gore_off  = $Control2/Button3

@onready var filter_rape_on   = $Control2/Button4
@onready var filter_feral_on  = $Control2/Button5
@onready var filter_gore_on   = $Control2/Button6

func _on_button_filter_rape_off_pressed() -> void:
	VarTests.RAPE_FILTER  = true

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_filter_rape_off.png")
	style_setter(filter_rape_off, filter_rape_on, temp)
func _on_button_filter_rape_on_pressed() -> void:
	VarTests.RAPE_FILTER  = false

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_filter_rape_on.png")
	style_setter(filter_rape_on, filter_rape_off, temp)

func _on_button_filter_feral_off_pressed() -> void:
	VarTests.FERAL_FILTER = true

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_filter_feral_off.png")
	style_setter(filter_feral_off, filter_feral_on, temp)
func _on_button_filter_feral_on_pressed() -> void:
	VarTests.FERAL_FILTER = false

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_filter_feral_on.png")
	style_setter(filter_feral_on, filter_feral_off, temp)

func _on_button_filter_gore_off_pressed() -> void:
	VarTests.GORE_FILTER  = true

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_filter_gore_off.png")
	style_setter(filter_gore_off, filter_gore_on, temp)
func _on_button_filter_gore_on_pressed() -> void:
	VarTests.GORE_FILTER  = false

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_filter_gore_on.png")
	style_setter(filter_gore_on, filter_gore_off, temp)

@onready var label_base = $Control3/Label2
@onready var label_char = $Control3/Control/Label
@onready var label_will = $Control3/Control2/Label
@onready var label_inte = $Control3/Control3/Label
@onready var label_agil = $Control3/Control4/Label
@onready var label_stre = $Control3/Control5/Label
@onready var label_endu = $Control3/Control6/Label

func stat_change(node, dir):
	if dir == 'up':
		if int(label_base.text) > 0 and int(node.text) < 10:
			label_base.text = str(int(label_base.text) - 2)
			node.text = str(int(node.text) + 2)
	elif dir == 'down':
		if int(node.text) > 4:
				label_base.text = str(int(label_base.text) + 2)
				node.text = str(int(node.text) - 2)
# stats
func _on_button_stat_char_pressed_left() -> void:
	stat_change(label_char, 'down')
func _on_button_stat_char_pressed_right() -> void:
	stat_change(label_char, 'up')

func _on_button_stat_will_pressed_left() -> void:
	stat_change(label_will, 'down')
func _on_button_stat_will_pressed_right() -> void:
	stat_change(label_will, 'up')

func _on_button_stat_inte_pressed_left() -> void:
	stat_change(label_inte, 'down')
func _on_button_stat_inte_pressed_right() -> void:
	stat_change(label_inte, 'up')

func _on_button_stat_agil_pressed_left() -> void:
	stat_change(label_agil, 'down')
func _on_button_stat_agil_pressed_right() -> void:
	stat_change(label_agil, 'up')

func _on_button_stat_stre_pressed_left() -> void:
	stat_change(label_stre, 'down')
func _on_button_stat_stre_pressed_right() -> void:
	stat_change(label_stre, 'up')

func _on_button_stat_endu_pressed_left() -> void:
	stat_change(label_endu, 'down')
func _on_button_stat_endu_pressed_right() -> void:
	stat_change(label_endu, 'up')
