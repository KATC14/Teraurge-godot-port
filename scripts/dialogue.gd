extends Node2D


@onready var fade_in          = $CanvasLayer/TextureRect

@onready var sky_layer        = $CanvasLayer/Control/sky_layer       # sky_layer 
@onready var sky_layer_blend  = $CanvasLayer/Control/sky_layer_blend # sky_layer 
@onready var weather_layer    = $CanvasLayer/Control/weather_layer   # weather_layer 
@onready var env_Node         = $CanvasLayer/Control/env_Node        # background_layer 
@onready var env_mask_Node    = $CanvasLayer/Control/env_mask_Node   # background_mask_layer
@onready var atmosphere_layer = $CanvasLayer/Control/atmosphere_layer# atmosphere_layer
@onready var sprite           = $CanvasLayer/Control/sprite          # character_layer
@onready var scene_picture    = $CanvasLayer/Control/scene_picture   # picture_layer

@onready var choicesDialog    = $CanvasLayer/PanelContainer
@onready var shakeTimer       = $CanvasLayer/Control3/Timer2

@onready var caption_top      = $CanvasLayer/Control2/RichTextLabel
@onready var dialogue_bubble  = $CanvasLayer/Control2/RichTextLabel2
@onready var caption_bot      = $CanvasLayer/Control2/RichTextLabel3

@onready var error            = $CanvasLayer/Panel2
@onready var error_label      = $CanvasLayer/Panel2/Label
@onready var error_button     = $CanvasLayer/Panel2/Button

@onready var autocont_dots    = $CanvasLayer/Sprite2D

var bubble_tween
var stats_file
var env_ambient
var ambient_strength
var opt_parsed

var can_continue_dialogue = true
var character_leaves      = false
var dialogue_complete     = false
var hurry_dialogue        = false
var dont_hurry            = false

var text_index = 0
var scene_character = ""
var last_character  = ""
var diag_file       = ""
var def_text_color = 'FFFFFF'
var def_bubble_color = '000000'


# combat vars
@onready var card_empty        = load("res://assets/images/combat/card_empty.png")
@onready var CanLay            = $CanvasLayer
@onready var player_combat_ui  = $CanvasLayer/Control3/Control
@onready var enemy_combat_ui   = $CanvasLayer/Control3/Control2
@onready var attacks_timer     = $CanvasLayer/Control3/Timer


@onready var turn_dail         = $CanvasLayer/Control3/Control/Control2/TextureRect/Button
@onready var player_health_lbl = $CanvasLayer/Control3/Control/Label
@onready var enemy_health_lbl  = $CanvasLayer/Control3/Control2/Label

@onready var btn_card_1 = %btn_card_1
@onready var btn_card_2 = %btn_card_2
@onready var btn_card_3 = %btn_card_3
@onready var btn_card_4 = %btn_card_4
@onready var btn_card_5 = %btn_card_5
@onready var btn_card_6 = %btn_card_6
@onready var btn_card_7 = %btn_card_7


@onready var player_res_heat   = %player_res_heat
@onready var player_res_cold   = %player_res_cold
@onready var player_res_impact = %player_res_impact
@onready var player_res_slash  = %player_res_slash
@onready var player_res_pierce = %player_res_pierce
@onready var player_res_magic  = %player_res_magic
@onready var player_res_bio    = %player_res_bio


@onready var player_stat_cha_control  = %player_stat_cha_control
@onready var player_stat_will_control = %player_stat_will_control
@onready var player_stat_int_control  = %player_stat_int_control

@onready var player_stat_agi_control  = %player_stat_agi_control
@onready var player_stat_str_control  = %player_stat_str_control
@onready var player_stat_end_control  = %player_stat_end_control



@onready var enemy_res_heat_lbl   = %enemy_res_heat
@onready var enemy_res_cold_lbl   = %enemy_res_cold
@onready var enemy_res_impact_lbl = %enemy_res_impact
@onready var enemy_res_slash_lbl  = %enemy_res_slash
@onready var enemy_res_pierce_lbl = %enemy_res_pierce
@onready var enemy_res_magic_lbl  = %enemy_res_magic
@onready var enemy_res_bio_lbl    = %enemy_res_bio


@onready var enemy_stat_cha_lbl   = %enemy_stat_cha
@onready var enemy_stat_will_lbl  = %enemy_stat_will
@onready var enemy_stat_int_lbl   = %enemy_stat_int

@onready var enemy_stat_agi_lbl   = %enemy_stat_agi
@onready var enemy_stat_str_lbl   = %enemy_stat_str
@onready var enemy_stat_end_lbl   = %enemy_stat_end

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_defaults()
	#get_tree().get_root().size_changed.connect(resize)
	#_on_start_combat()
	#$CanvasLayer/Camera2D.make_current()
	fade_in.texture = load("res://assets/images/menu_background.png")
	if VarTests.character_name == 'intro':
		var tween = create_tween()
		tween.tween_property(fade_in, "modulate:a", 0, 5)
		tween.finished.connect(func(): fade_in.visible = false)
	else:
		fade_in.visible = false
	dialogue_complete = true
	# TEMP
	#VarTests.character_name = 'braq_m'# witch braq_m
	#VarTests.ALL_CARDS = Utils.load_file("res://database/cards/cards.txt")
	#stats_file = Utils.load_file("res://database/characters/braq_m/stats.txt")
	#VarTests.CARD_INVENTORY = [
	#	"kick", "kick", "body_tackle", "panicked_slap", "panicked_slap",
	#	"panicked_slap", "panicked_slap", "wrestle", "wrestle", "right_hook",
	#	"left_hook", "left_hook", "panicked_slap", "panicked_slap", "panicked_slap",
	#	"clumsy_kick", "clumsy_kick"
	#]
	# TEMP
	_on_start_encounter(VarTests.character_name)

var active_choice = 0
func _input(_event: InputEvent) -> void:
	# auto continue
	if Input.is_action_pressed("mouse_left") or Input.is_action_pressed("ui_accept"):
		hurry_dialogue = true
		if dialogue_complete and VarTests.auto_continue_pointer != '':
			var index = VarTests.auto_continue_pointer
			VarTests.auto_continue_pointer = ''
			_on_change_index(index)

	# button focus using arrow keys and wasd
	if Input.is_action_pressed("ui_up"):
		if active_choice > 0:
			active_choice -= 1

		var btn:Button = choicesDialog.choices_list.get_children()[active_choice]
		btn.grab_focus()
	if Input.is_action_pressed("ui_down"):
		if active_choice < len(choicesDialog.choices_list.get_children())-1:
			active_choice += 1

		var btn:Button = choicesDialog.choices_list.get_children()[active_choice]
		btn.grab_focus()

#func resize():
#	var camera_size = get_viewport().get_visible_rect().size
#	VarTests.stage_width  = camera_size.x
#	VarTests.stage_height = camera_size.y
#	autocont_dots.position = Vector2(VarTests.stage_width/2, VarTests.stage_height*0.87)
#	var size = Vector2(VarTests.stage_width, VarTests.stage_height)
#	env_Node.size = size
#	env_mask_Node.size = size
#	scene_picture.size = size

#func set_defaults():
#	var camera_size = get_viewport().get_visible_rect().size
#	VarTests.stage_width  = camera_size.x
#	VarTests.stage_height = camera_size.y
#	var size = Vector2(VarTests.stage_width, VarTests.stage_height)
#	env_Node.size = size
#	env_mask_Node.size = size
#	scene_picture.size = size

# DIALOGUE CHOICE SELECTION CLICK
# options clicks
func _on_panel_container_selected(index: Variant) -> void:
	choicesDialog.visible = false
	dont_hurry = true
	choicesDialog.choices_list.get_children()[0].grab_focus()

	print('sele choicesDialog.choices ', choicesDialog.choices)
	print('sele index ', index)
	# real index search
	var found = choicesDialog.choices[index]
	var text  = found.substr(1)
	index     = opt_parsed[-1].find(text)

	var picked   = opt_parsed[0][index]
	var function = opt_parsed[1][index]
	print('sele picked ', picked)
	print('sele function ', function)

	if opt_parsed[2][index]:
		found = Utils.array_find(opt_parsed[2][index], 'hideif.clicked')
		print('hide if ', opt_parsed[2][index])
		print('found ', found)
		if found != -1:
			# indexs
			var idx = opt_parsed[0].filter(func(item): return item)
			print('idx ', idx)
			# last index
			var multi_index = '%s#%s' % [VarTests.current_index, '#'.join(idx)]
			print('idx multi_index ', multi_index)
			# picked option extra
			var opt_fmt = ' //'.join(opt_parsed[2][index])
			# picked option
			var opt = '%s //%s' % [opt_parsed[-1][index], opt_fmt]
			var formatted_string = '%s-%s-%s' % [multi_index, picked, opt]
			print('fs_hash ', formatted_string)
			var fs_hash = formatted_string.md5_text()
			print('fs_hash ', fs_hash)
			var clicked_hash_list = []

			if VarTests.CLICKED_OPTIONS.has(VarTests.character_name):
				clicked_hash_list.append(fs_hash)
			else:
				clicked_hash_list = VarTests.CLICKED_OPTIONS[VarTests.character_name]
				clicked_hash_list.append(fs_hash)
			VarTests.CLICKED_OPTIONS[VarTests.character_name] = clicked_hash_list

	if picked  : _on_change_index(picked)
	if function: $CanvasLayer/Panel.Logigier(function)

func _on_change_diag(diag, index) -> void:
	var data = Utils.load_file('res://database/characters/%s/%s.txt' % [VarTests.character_name, diag])
	var daig_parsed = DiagParse.begin_parsing(data, index)
	make_dialogue(daig_parsed[1])

#leave encounter
func _on_leave_encounter() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_curated_list(index):
	print('curated_list index ', index)
	print('curated_list current_index ', VarTests.current_index)
	var data = Utils.load_file('res://database/characters/%s/%s.txt' % [VarTests.character_name, diag_file])
	var daig_parsed = DiagParse.begin_parsing(data, VarTests.current_index)
	make_options(daig_parsed[2], index)

func make_options(packed_options, curated_list=false):
	opt_parsed = DiagParse.parse_options(packed_options)

	print('opt_parsed ', opt_parsed)
	var allowed = []
	# TODO finish fixing md5 hash on hideif.clicked it needs the full string
	var value = MiscFunc.get_allowed(opt_parsed)
	for i in range(len(value)):
		print(opt_parsed[2][i])
		#print('value ', value)
		# TODO I think this was testing related to reversing hideif.clicked so I could click it unsure
		if opt_parsed[2][i]:
			var fuck = Utils.array_find(opt_parsed[2][i], 'hideif.clicked')
			if fuck != -1:
				value[i] = not value[i]
		if not value[i]:
			var item = opt_parsed[-1][i]
			if item.to_lower() == '(return)' or item.to_lower() == '(back)':
				item = '◁──'
			else:
				item = '-' + item
			allowed.append(item)
		#var options = opt_parsed[-1]
	#print('allowed', allowed)
	#print('is curated_list true? ', curated_list)
	# catch for curated list
	if curated_list:
		var index
		if curated_list == "random":
			index = randi_range(0, len(allowed)-1)
		if curated_list == "weighted":
			pass
		if curated_list == "prioritized": index = 0
		print('-a ', index)
		print('cc ', index)
		print('allowd substr ', allowed[index].substr(1))
		# make sure ish that the correct index is picked
		if index <= len(allowed) and opt_parsed[-1][index] == allowed[index].substr(1):
			_on_change_index(allowed[index].substr(1))
	# catch for random pointer
	#if opt_parsed[1]:
	#	var index = Utils.array_find(opt_parsed[1], 'random_pointer')
	#	if index != -1:
	#		print('opt_parsed[1] index ', opt_parsed[1][index])
	#		$CanvasLayer/Panel.Logigier(opt_parsed[1][index])
	#		return
	choicesDialog.choices = allowed

func index_error(daig_parsed):
	if daig_parsed == null:
		error.visible = true
		error_label.text = 'ERROR: pointer: "%s" has no corresponding index.' % VarTests.current_index
		error_button.pressed.connect(func(): error.visible = false)
		choicesDialog.visible = true
		return true
	return false

func _on_change_index(index):
	var data = Utils.load_file('res://database/characters/%s/%s.txt' % [VarTests.character_name, diag_file])
	var daig_parsed = DiagParse.begin_parsing(data, index)
	if index_error(daig_parsed): return null
	VarTests.current_index = index

	# functions
	if daig_parsed[0]:
		$CanvasLayer/Panel.Logigier(daig_parsed[0])

	# dialogue
	# top bubble bottom
	if daig_parsed[1]:
		make_dialogue(daig_parsed[1].split('"'))

	# options
	if daig_parsed[2]:
		autocont_dots.visible = false
		choicesDialog.modulate = Color.TRANSPARENT
		choicesDialog.visible = true

		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(choicesDialog, "modulate:a", 1, 0.8)
		#tween.finished.connect(auto_cont_ellipses)
		make_options(daig_parsed[2])
	# AUTO CONTINUE SELECTION
	elif VarTests.auto_continue_pointer != '':
		autocont_dots.visible = true
		#var auto_cont_ellipses = func():
		#	can_continue_dialogue = true
		#	dialogue_complete = true

		autocont_dots.position = Vector2(float(VarTests.stage_width) / 2, VarTests.stage_height * 0.87)
		autocont_dots.modulate = Color.TRANSPARENT

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(autocont_dots, "position:y", VarTests.stage_height * 0.85, 0.5)
		tween.parallel().tween_property(autocont_dots, "modulate:a", 0.8, 0.5)
		#tween.finished.connect(auto_cont_ellipses)

func _on_change_sprite() -> void:
	make_character()
func rescale_bitmapdata(obj):
	var objscale = 1

	if VarTests.stage_height == 1080: objscale = 0.75
	if VarTests.stage_height == 720:  objscale = 0.50

	obj.scale = Vector2(objscale, objscale)
	# TextureRect 1280 - ( 894 * 0.5)
	# Sprite2D    1280 - ((894 * 0.5) / 2)
	var math_x = VarTests.stage_width  - (obj.size.x  * objscale)
	#var math_y = VarTests.stage_height - (obj.size.y * objscale)
	# texture width * by the offset lowering the value because its .5 or .75
	obj.position = Vector2(math_x, 0)
	
func make_character() -> void:
	print('a ', VarTests.character_sprite)
	print('b ', scene_character)
	scene_character = VarTests.character_name
	var path = "res://database/characters/%s/%s.png" % [VarTests.character_name, VarTests.character_sprite]
	if FileAccess.file_exists(path):
		#var picture_image = Image.load_from_file(path)
		#sprite.texture = ImageTexture.create_from_image(picture_image)
		sprite.texture = load(path)
		MiscFunc.super_tint(sprite, env_ambient, ambient_strength)
		#sprite.modulate = Color.html('#a23f08')
		rescale_bitmapdata.call_deferred(sprite)
		sprite.move_to_front()

func _on_start_encounter(character_name):
	print('started ', character_name)
	choicesDialog.visible    = false
	sky_layer.visible        = false
	sky_layer_blend.visible  = false
	weather_layer.visible    = false
	#env_Node.visible         = false
	#env_mask_Node.visible    = false
	#atmosphere_layer.visible = false
	#sprite.visible           = false
	scene_picture.visible    = false

	#Set character sprite
	VarTests.character_sprite = "character"
	if VarTests.CHANGED_CHARACTERS.has(character_name):
		VarTests.character_sprite = VarTests.CHANGED_CHARACTERS[character_name]

	#check diag file
	diag_file = "diag"
	if VarTests.CHANGED_DIAGS.has(character_name):
		diag_file = VarTests.CHANGED_DIAGS[character_name]
	stats_file = LoadStats.read_char_stats(character_name)
	#stats_file = LoadStats.read_env_stats(character_name)
	var default_env = MiscFunc.parse_stat('default_env', stats_file.split('\n'))
	if default_env == null:
		default_env = 'not_defined'

	#check start index
	var index = "start"
	if VarTests.DINDEX.has(character_name):
		index = VarTests.DINDEX[character_name].strip_edges()

	VarTests.environment_name = default_env
	#text_color = stats_file[1]
	#var bubble_color = stats_file[2]

	create_sky()
	# index override
	if VarTests.override_index != "":
		index = VarTests.override_index
		VarTests.override_index = ""
	_on_change_environment()
	if scene_character != VarTests.character_name:
		make_character()
	_on_change_index(index)

func _on_create_picture(picture=false) -> void:
	var picture_color = StyleBoxFlat.new()
	if not picture:
		scene_picture.visible = false
		picture_color.bg_color = '000000FF'
		caption_top.add_theme_stylebox_override("fill", picture_color)
		caption_top.add_theme_stylebox_override("background", picture_color)
		caption_top.add_theme_stylebox_override("focus", picture_color)
		caption_top.add_theme_stylebox_override("normal", picture_color)
	else:
		var path = "res://database/characters/%s/pictures/%s.jpg" % [VarTests.character_name, picture]
		var path_f = "res://database/characters/%s/pictures/%s_f.jpg" % [VarTests.character_name, picture]
		if FileAccess.file_exists(path):
			var path_gate
			path_gate = path_f if VarTests.player_gender == 'female' else path

			#var picture_image = Image.load_from_file(path_gate)
			#scene_picture.texture = ImageTexture.create_from_image(picture_image)
			scene_picture.texture = load(path_gate)
			scene_picture.move_to_front()
			scene_picture.visible = true
			picture_color.bg_color = '000000c8'
			caption_top.add_theme_stylebox_override("fill", picture_color)
			caption_top.add_theme_stylebox_override("background", picture_color)
			caption_top.add_theme_stylebox_override("focus", picture_color)
			caption_top.add_theme_stylebox_override("normal", picture_color)

func _on_change_environment(new_env=null) -> void:
	if not new_env: new_env = 'env'
	var path = "res://database/environments/%s/%s" % [VarTests.environment_name, new_env]
	var env_stats = Utils.load_file('res://database/environments/%s/stats.txt' % VarTests.environment_name).split('\n')
	print(env_stats)

	var found = MiscFunc.parse_stat('ambient', env_stats)
	if found != null:
		ambient_strength = float(found)
	else:
		ambient_strength = 0.2

	found = MiscFunc.parse_stat('ambient_color', env_stats)
	if found != null:
		env_ambient = Color.html(found)
	else:
		env_ambient = Color.WHITE

	#DAY/NIGHT ENV
	var extension_block = ""
	if VarTests.TIME >=  25 && VarTests.TIME < 75:
		# day
		extension_block = ""
	else:
		# night
		if FileAccess.file_exists('%s%s_night.png' % [path, extension_block]):
			extension_block = "_night"

	#var env_image = Image.load_from_file("res://database/environments/%s/%s.png" % [VarTests.environment_name, new_env])
	#env_Node.texture = ImageTexture.create_from_image(env_image)
	env_Node.texture = load("%s%s.png" % [path, extension_block])
	env_Node.move_to_front()

	if FileAccess.file_exists("%s%s_mask.png" % [path, extension_block]):
		#var env_mask_image = Image.load_from_file(path)
		#env_mask_Node.texture = ImageTexture.create_from_image(env_mask_image)
		env_mask_Node.texture = load("%s%s_mask.png" % [path, extension_block])
		env_mask_Node.move_to_front()
	#var camera_size = get_viewport().get_visible_rect().size
	#var width = round(camera_size.y / 9 * 16) # 16:9

func make_dialogue(speech:Array):
	var top    = ''
	var bubble = ''
	var bot    = ''
	print('speech len ', len(speech))

	can_continue_dialogue = false
	hurry_dialogue        = false
	dialogue_complete     = false

	caption_top.visible      = false
	dialogue_bubble.visible  = false
	caption_bot.visible      = false

	caption_top.text     = ''
	dialogue_bubble.text = ''
	caption_bot.text     = ''

	#caption_top.fit_content     = true
	dialogue_bubble.fit_content = true
	#caption_bot.fit_content     = true
	speech = speech.map(func(item): return item.replace('<br>', '\n').replace('<b>', '[b]').replace('</b>', '[/b]').replace('-name-', VarTests.player_name).strip_edges())

	if len(speech) >= 1:
		top    = speech[0]

	if len(speech) >= 2:
		bubble = speech[1]

	if len(speech) >= 3:
		bot    = speech[2]
	add_top_box(top, bubble, bot)

	#if len(speech) >= 1:
	#	add_top_box(top, bubble, bot)
	#if len(speech) >= 2:
	#	add_dialogue_bubble(bubble, bot)
	#if len(speech) >= 3:
	#	add_bot_box(bot)

#Add top text box.
func add_top_box(top, bubble, bot):
	caption_top.text = top
	#caption_top.add_theme_color_override('default_color', Color.html('#9a8e9e'))
	caption_top.size = caption_top.get_theme_font("normal_font").get_string_size(top)

	if top != '':
		caption_top.visible = true
	#await get_tree().process_frame
	#caption_top.position = Vector2(70, 100)

	#Story exception
	if (VarTests.has_story or bubble == "empty" and bot):
		#SIZE
		print('spawn_top_box A')
		if (caption_top.size.x > 600):
			await get_tree().process_frame
			caption_top.size.x = 600
		await get_tree().process_frame
		caption_top.size.y = 0
		caption_top.position.x = 60
		caption_top.position.y = (VarTests.stage_height / 2.5) - (caption_top.size.y / 2) + 20

	#only top exception
	elif (bubble == "empty" and bot == ""):
		#SIZE
		print('spawn_top_box B')
		if (caption_top.size.x > 600):
			caption_top.size.x = 600
		await get_tree().process_frame
		caption_top.size.y = 0
		caption_top.position.x = 60
		caption_top.position.y = (VarTests.stage_height / 2.5) - (caption_top.size.y / 2) + 20

	else:
		#SIZE
		print('spawn_top_box C')
		if caption_top.size.x > 400:
			caption_top.size.x = 400
		await get_tree().process_frame
		caption_top.size.y = 0
		caption_top.position.x = 200 + 600 - caption_top.size.x
		caption_top.position.y = 60 + 20

	var spawn_top_box = func():
		dialogue_complete = false
		var tween1 = create_tween()
		if VarTests.has_story == true:
			print('spawn_top_box e')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(caption_top, "position", Vector2(caption_top.position.x - 40, caption_top.position.y - 20), 0.8)
			#tween1.tween_callback()
			tween1.finished.connect(func(): dialogue_complete = true)
		elif bubble == "empty" and bot == "":
			print('spawn_top_box ee')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(caption_top, "position", Vector2(caption_top.position.x - 40, caption_top.position.y - 20), 0.8)
			tween1.finished.connect(func(): dialogue_complete = true)
		else:
			print('spawn_top_box eee')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(caption_top, "position", Vector2(caption_top.position.x - 200, caption_top.position.y - 60), 0.8)
			tween1.finished.connect(func(): dialogue_complete = true)

		#caption_top.modulate = Color.TRANSPARENT
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(caption_top, "modulate:a", 0.92, 0.2)

	if (top != ""):
		spawn_top_box.call()


	#TIMER
	var temp_timer = Timer.new()
	temp_timer.one_shot = true
	add_child(temp_timer)

	var top_len = len(top)
	if top_len == 0: top_len = 1
	var delay = float(top_len) / 100.0
	print('delay ', delay)
	print('delay ', (delay * 2950) / 1000)

	delay = delay * 2950
	# minimum timer
	if delay < 1000 and delay != 0: delay = 1000
	if bubble == "":                delay = 200
	temp_timer.wait_time = delay / 1000.0
	temp_timer.start()
	temp_timer.timeout.connect(add_dialogue_bubble.bind(bubble, bot))

#Add dialogue speech bubble.
func add_dialogue_bubble(bubble, bot):
	var bg_color   = MiscFunc.parse_stat('bubble_color', stats_file.split('\n'))
	var font_color = MiscFunc.parse_stat('text_color', stats_file.split('\n'))
	if bg_color   == null: bg_color   = def_bubble_color
	if font_color == null: font_color = def_text_color

	bg_color   = Color.html(bg_color)
	font_color = Color.html(font_color)
	dialogue_bubble.add_theme_color_override("default_color", font_color)

	var diag_b_color = StyleBoxFlat.new()
	diag_b_color.bg_color = bg_color
	diag_b_color.border_color = bg_color
	diag_b_color.border_width_left   = 5
	diag_b_color.border_width_right  = 5
	diag_b_color.border_width_top    = 8
	diag_b_color.border_width_bottom = 8
	diag_b_color.set_corner_radius_all(5)

	dialogue_bubble.add_theme_stylebox_override("fill",       diag_b_color)
	dialogue_bubble.add_theme_stylebox_override("background", diag_b_color)
	dialogue_bubble.add_theme_stylebox_override("focus",      diag_b_color)
	dialogue_bubble.add_theme_stylebox_override("normal",     diag_b_color)

	#dialogue_bubble.x = over_sprite.x + over_sprite.width * 0.2 - dialogue_bubble.width - 20
	var sprite_pos = sprite.position.x
	var sprite_img = sprite.size.x#texture.get_width()

	await get_tree().process_frame
	dialogue_bubble.position.x = sprite_pos + sprite_img * 0.2 - dialogue_bubble.size.x - 20
	dialogue_bubble.position.y = VarTests.stage_height * 0.25
	#dialogue_bubble.size.y = 0
	#dialogue_bubble.size.x = VarTests.stage_width / 6.5

	if bubble != "":
		dialogue_bubble.visible = true
		slow_text(bubble, bot)
	else:
		print('add bot box a')
		add_bot_box(bot)

# Add bottom text box.
func add_bot_box(bot):
	print('AAAAAAAAAAAAAAAAAAAAAAAAAA')
	#print(bot)
	# Character hide function
	if character_leaves == true:
		#character_leave_anim(VarTests.character_sprite)
		#attack_effect(VarTests.character_sprite)
		character_leaves = false

	caption_bot.text = bot
	caption_bot.size = caption_bot.get_theme_font("normal_font").get_string_size(bot)
	#await get_tree().process_frame
	#caption_bot.add_theme_color_override('default_color', Color.html('#9a8e9e'))

	# size
	print('caption_bot size ', caption_bot.size)
	if caption_bot.size.x > 300:
		await get_tree().process_frame
		caption_bot.size.x = 300

	# FORCED CRASH
	if VarTests.ex_magic == true:
		while(444 == 444):
			# crash here
			get_tree().quit()


	var spawn_bot_box = func():
		caption_bot.visible = true
		print('dialogue_bubble.position ', dialogue_bubble.position.x)
		var x_pos = dialogue_bubble.position.x + ((dialogue_bubble.size.x/2) * randf())

		if x_pos < sprite.position.x + caption_bot.size.x*0.6:
			x_pos = sprite.position.x - (caption_bot.size.x*0.8)
		#x_pos = x_pos / 1.3
		print('x_pos ', x_pos)
		print('size ', caption_bot.size)

		var y_pos = dialogue_bubble.position.y + dialogue_bubble.size.y

		await get_tree().process_frame
		caption_bot.position.x = x_pos
		caption_bot.position.y = y_pos

		#await get_tree().process_frame
		caption_bot.size.y = 0
		caption_bot.modulate = Color.TRANSPARENT

		var align_bot_box_a_bit = func():
			print('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB')
			@warning_ignore("confusable_capture_reassignment")
			y_pos = dialogue_bubble.position.y + dialogue_bubble.size.y + 10
			var tween1 = create_tween()
			tween1.set_trans(Tween.TRANS_LINEAR)
			tween1.tween_property(caption_bot, "position", Vector2(x_pos, y_pos), 1)

		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(caption_bot, "position", Vector2(x_pos, y_pos + 10), 0.8)
		tween.parallel().tween_property(caption_bot, "modulate:a", 0.92, 0.2)
		tween.finished.connect(align_bot_box_a_bit)

	if bot != "":
		spawn_bot_box.call()

# Speech delay library.
func speech_delay(character):
	var d = 0
	match character:
		" ":
			d = 80
			if last_character == "-":
				d = 400
		",": d = 140
		"-": d = 200
		_:   d = 40
	return d

func slow_text(bubble, bot):
	print('bubble ', bubble)
	var dialogue_length = len(bubble)
	text_index = 0

	var dialogue_timer = Timer.new()
	dialogue_iteration(dialogue_timer, dialogue_length, bubble, bot)

#var fuck = false
func dialogue_iteration(dialogue_timer, dialogue_length, bubble, bot):
	#print('fuck ', text_index, ' ', bubble, ' ', bubble[text_index])
	if dialogue_length <= text_index:
		print('amount of time!')
		dialogue_timer.queue_free()
		#if fuck:
		#	fuck = false
		#	return
		print('add bot box b')
		add_bot_box(bot)
		return

	dialogue_bubble.text += bubble[text_index]
	#dialogue_bubble.size = dialogue_bubble.get_theme_font("normal_font").get_string_size(dialogue_bubble.text) + Vector2(25, 0)
	if dialogue_bubble.size.x > 400:
		dialogue_bubble.size.x = 400

	realign_dialogue()

	print('hurry_dialogue ', hurry_dialogue)
	if hurry_dialogue:
		dialogue_bubble.text = bubble
		text_index = dialogue_length
		#dialogue_timer.stop()
	#await get_tree().process_frame
	dialogue_bubble.size = dialogue_bubble.get_theme_font("normal_font").get_string_size(dialogue_bubble.text) - Vector2(100, 0)
	await get_tree().process_frame
	dialogue_bubble.size.y = 0
	#dialogue_bubble.size = dialogue_bubble.get_theme_font("normal_font").get_string_size(dialogue_bubble.text) + Vector2(25, 0)

	# HURRY EXIT
	if hurry_dialogue:
		#fuck = true
		print('add bot box c')
		realign_dialogue()
		add_bot_box(bot)
		return

	# CHARACTER DELAY
	var delay = speech_delay(bubble[text_index])
	if last_character == "." or last_character == "!":
		delay = 400
	if last_character == "?":
		delay = 800

	# TIMER
	if dialogue_timer not in get_children():
		add_child(dialogue_timer)
	dialogue_timer.wait_time = float(delay) / 1000
	dialogue_timer.start()
	#Add to character counter

	#dialogue_timer.disconnect("timeout", f.bind(f).call)
	last_character = bubble[text_index]
	text_index += 1
	if not dialogue_timer.is_connected("timeout", dialogue_iteration):
		dialogue_timer.timeout.connect(dialogue_iteration.bind(dialogue_timer, dialogue_length, bubble, bot))


#Realign dialogue speech bubble.
func realign_dialogue():
	print('add bot box realign_dialogue')

	var x_pos = sprite.position.x - dialogue_bubble.size.x
	var y_pos = (float(VarTests.stage_height) / 4 * 1) - dialogue_bubble.size.y - caption_top.size.y

	if x_pos < 400: x_pos = 400
	if y_pos < 20:  y_pos = 20

	if caption_top.visible:
		y_pos = caption_top.size.y + 30

	if bubble_tween:
		if not bubble_tween.is_valid():
			print('QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ')
			await get_tree().process_frame
			dialogue_bubble.position.x = x_pos
			await get_tree().process_frame
			dialogue_bubble.position.y = y_pos
	bubble_tween = create_tween()
	bubble_tween.set_trans(Tween.TRANS_LINEAR)
	bubble_tween.tween_property(dialogue_bubble, "position", Vector2(x_pos, y_pos - 2), 0.6)

func _on_start_combat():
	caption_top.visible      = false
	dialogue_bubble.visible  = false
	caption_bot.visible      = false
	choicesDialog.visible    = false
	scene_picture.visible    = false

	player_combat_ui.visible = true
	enemy_combat_ui.visible  = true
	player_combat_ui.position.x = -player_combat_ui.size.x
	enemy_combat_ui.position.x  = VarTests.stage_width + enemy_combat_ui.size.x

	# sets every thing inside the other file
	CombatScript.set_env(sprite, stats_file, env_ambient, caption_top, dialogue_bubble, caption_bot, choicesDialog, scene_picture,
		CanLay, player_combat_ui, enemy_combat_ui, attacks_timer, turn_dail, player_health_lbl, enemy_health_lbl, 
		btn_card_1, btn_card_2, btn_card_3, btn_card_4, btn_card_5, btn_card_6, btn_card_7, 
		player_res_heat, player_res_cold, player_res_impact, player_res_slash, player_res_pierce, player_res_magic, player_res_bio, 
		player_stat_cha_control, player_stat_will_control, player_stat_int_control, player_stat_agi_control, player_stat_str_control, player_stat_end_control, 
		enemy_res_heat_lbl, enemy_res_cold_lbl, enemy_res_impact_lbl, enemy_res_slash_lbl, enemy_res_pierce_lbl, enemy_res_magic_lbl, enemy_res_bio_lbl, 
		enemy_stat_cha_lbl, enemy_stat_will_lbl, enemy_stat_int_lbl, enemy_stat_agi_lbl, enemy_stat_str_lbl, enemy_stat_end_lbl
	)
	CombatScript.randomize_hand('player')
	CombatScript.set_enemy_stats()
	CombatScript.reset_stats('player')
	CombatScript.reset_stats('enemy')
	CombatScript.refresh_combat_ui('start')
	CombatScript.combat_ui_in()

func _on_btn_turn_dial_pressed() -> void:
	if CombatScript.player_turn:
		CombatScript.player_turn = false
		turn_dail.disabled = true
		turn_dail.get_parent().texture = CombatScript.turn_dial_enemy
		CombatScript.change_turn_to("enemy")

func card_clicked(attacker, used_card, target):
	#used_card.visible = false
	var the_card = used_card.text.replace(' ', '_').to_lower()
	if CombatScript.play_card(attacker, the_card, target):
		used_card.get_parent().visible = false
		used_card.get_parent().get_parent().texture = card_empty

func _on_btn_card_1_pressed() -> void:
	card_clicked('player', btn_card_1, 'enemy')

func _on_btn_card_2_pressed() -> void:
	card_clicked('player', btn_card_2, 'enemy')

func _on_btn_card_3_pressed() -> void:
	card_clicked('player', btn_card_3, 'enemy')

func _on_btn_card_4_pressed() -> void:
	card_clicked('player', btn_card_4, 'enemy')

func _on_btn_card_5_pressed() -> void:
	card_clicked('player', btn_card_5, 'enemy')

func _on_btn_card_6_pressed() -> void:
	card_clicked('player', btn_card_6, 'enemy')

func _on_btn_card_7_pressed() -> void:
	card_clicked('player', btn_card_7, 'enemy')

# PLAYER DEATH
func _on_player_death():
	#start_music("misc/player_death", 100, 0, 0, "no_loop")
	VarTests.menu_state = 'death'
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# IS BETWEEN FUNCTION
func is_between(minn: int, value_int: int, maxx: int):
	if value_int <= maxx and value_int >= minn:
		return true
	else:
		return false

func get_blend(n:int):
	var sky_d = load("res://assets/images/sky/sky_day.jpg")
	var sky_n = load("res://assets/images/sky/sky_night.jpg")
	var sky_s = load("res://assets/images/sky/sky_sundown.jpg")

	#var sky              = sky_layer
	#var sky_blend        = sky_layer_blend
	var overlay          = TextureRect.new()
	var overlay_blend    = TextureRect.new()

	#var sky_shader          = ShaderMaterial.new()
	#var sky_blend_shader    = ShaderMaterial.new()
	#sky_shader.shader       = load("res://shaders/multiply.gdshader")
	#sky_blend_shader.shader = load("res://shaders/multiply.gdshader")
	#overlay.material        = sky_shader
	#overlay_blend.material  = sky_blend_shader

	#overlay.blendMode = "multiply"
	#overlay_blend.blendMode = "multiply"

	# OVERLAYS
	var overlay_d = load("res://assets/images/sky/overlay_day.jpg")
	var overlay_n = load("res://assets/images/sky/overlay_night.jpg")
	var overlay_s = load("res://assets/images/sky/overlay_sundown.jpg")
	var overlay_m = load("res://assets/images/sky/overlay_morning.jpg")

	var min_TIME = 0
	var max_TIME = 0

	if is_between(76, VarTests.TIME, 100):# EVENING
		sky_layer.texture              = sky_s
		sky_layer_blend.texture        = sky_n # into evening
		overlay.texture = overlay_s
		overlay_blend.texture = overlay_n
		min_TIME = 76
		max_TIME = 100

	if is_between(51, VarTests.TIME, 75):# DAY
		sky_layer.texture              = sky_d
		sky_layer_blend.texture        = sky_s # into sunset
		overlay.texture = overlay_d
		overlay_blend.texture = overlay_s
		min_TIME = 51
		max_TIME = 75

	if is_between(26, VarTests.TIME, 50): # MORNING
		sky_layer.texture              = sky_d
		sky_layer_blend.texture        = sky_d # into day
		overlay.texture = overlay_m
		overlay_blend.texture = overlay_d
		min_TIME = 26
		max_TIME = 50

	if is_between(0, VarTests.TIME, 25): # NIGHT
		sky_layer.texture              = sky_n
		sky_layer_blend.texture        = sky_d # into morning
		overlay.texture = overlay_n
		overlay_blend.texture = overlay_m
		min_TIME = 0
		max_TIME = 25



	# SKY BLENDING
	sky_layer_blend.modulate.a = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	overlay_blend.modulate.a   = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	overlay.modulate.a         = 1 - overlay_blend.modulate.a


	if n == 0: return min_TIME
	if n == 1: return sky_layer
	if n == 2: return sky_layer_blend
	if n == 3: return overlay
	if n == 4: return overlay_blend
	if n == 5: return max_TIME

func create_sky():
	sky_layer.visible        = true
	sky_layer_blend.visible  = true

	var min_TIME      = get_blend(0)
	var max_TIME      = get_blend(5)

	get_blend(1)#var sky           = 
	var sky_blend     = get_blend(2)
	var overlay       = get_blend(3)
	var overlay_blend = get_blend(4)

	#overlay.blendMode       = "multiply"
	#overlay_blend.blendMode = "multiply"

	# NEW BLEND SYSTEM
	var alpha = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	sky_blend.modulate.a     = alpha
	overlay_blend.modulate.a = alpha
	overlay.modulate.a       = 1 - overlay_blend.modulate.a

	# remove old
	#while(sky_layer.numChildren > 0):
	#	sky_layer.removeChildAt(0)

	#while(atmosphere_layer.numChildren > 0):
	#	atmosphere_layer.removeChildAt(0)

	# Add to scene
	#sky_layer.addChild(sky)      # SKY
	#sky_layer.addChild(sky_blend)# SKY BLENDING

	#atmosphere_layer.addChild(overlay)      # OVERLAY
	#atmosphere_layer.addChild(overlay_blend)# OVERLAY BLEND
