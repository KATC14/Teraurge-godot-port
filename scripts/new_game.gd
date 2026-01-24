extends Control


@onready var char_name        = $Control3/TextEdit

@onready var button_female    = $Control/Button
@onready var button_male      = $Control/Button2
@onready var player_doll      = $Control/TextureRect2

func style_setter(node, node_1, style):
	node.add_theme_stylebox_override("pressed",       style)
	node.add_theme_stylebox_override("hover_pressed", style)
	node.add_theme_stylebox_override("hover",         style)
	node.add_theme_stylebox_override("normal",        style)

	node_1.add_theme_stylebox_override("pressed",       StyleBoxEmpty.new())
	node_1.add_theme_stylebox_override("hover_pressed", StyleBoxEmpty.new())
	node_1.add_theme_stylebox_override("hover",         StyleBoxEmpty.new())
	node_1.add_theme_stylebox_override("normal",        StyleBoxEmpty.new())

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

# NEW_GAME
func _on_button_start_game_pressed() -> void:
	print('new game')
	VarTests.player_name = char_name.text

	var label_char = %label_charisma
	var label_will = %label_will
	var label_inte = %label_intelligence
	var label_agil = %label_agility
	var label_stre = %label_strength
	var label_endu = %label_endurance

	VarTests.player_stats['charisma']     = int(label_char.text)
	VarTests.player_stats['will']         = int(label_will.text)
	VarTests.player_stats['intelligence'] = int(label_inte.text)

	VarTests.player_stats['agility']      = int(label_agil.text)
	VarTests.player_stats['strength']     = int(label_stre.text)
	VarTests.player_stats['endurance']    = int(label_endu.text)

	VarTests.main_menu_active = false
	VarTests.character_name = "intro"
	MiscFunc.game_start()
	get_tree().change_scene_to_file("res://scenes/dialogue.tscn")

func _on_filter_button_pressed(button) -> void:
	var target_button
	var button_name = button.name
	var children = button.get_parent().get_children()
	for i in children:
		var test = func(item_name:String):
			if item_name.find('off') != -1:
				return item_name.replace('off', 'on')
			else:
				return item_name.replace('on', 'off')
		if i.name == test.call(button_name):
			target_button = i

	if button_name == 'filter_rape_off':  VarTests.RAPE_FILTER  = true
	if button_name == 'filter_rape_on':   VarTests.RAPE_FILTER  = false
	if button_name == 'filter_feral_off': VarTests.FERAL_FILTER = true
	if button_name == 'filter_feral_on':  VarTests.FERAL_FILTER = false
	if button_name == 'filter_gore_off':  VarTests.GORE_FILTER  = true
	if button_name == 'filter_gore_on':   VarTests.GORE_FILTER  = false

	var temp = StyleBoxTexture.new()
	temp.texture = load("res://assets/images/new_game/button_%s.png" % [button_name])
	button.add_theme_stylebox_override("pressed",       temp)
	button.add_theme_stylebox_override("hover_pressed", temp)
	button.add_theme_stylebox_override("hover",         temp)
	button.add_theme_stylebox_override("normal",        temp)

	var empty = StyleBoxEmpty.new()
	target_button.add_theme_stylebox_override("pressed",       empty)
	target_button.add_theme_stylebox_override("hover_pressed", empty)
	target_button.add_theme_stylebox_override("hover",         empty)
	target_button.add_theme_stylebox_override("normal",        empty)

func _on_stat_buttons_pressed(button:Button, label:Label) -> void:
	var label_base = %avalible_points
	if button.name == 'up_button':
		if int(label_base.text) > 0 and int(label.text) < 10:
			label_base.text = str(int(label_base.text) - 2)
			label.text = str(int(label.text) + 2)
	elif button.name == 'down_button':
		if int(label.text) > 4:
				label_base.text = str(int(label_base.text) + 2)
				label.text = str(int(label.text) - 2)
