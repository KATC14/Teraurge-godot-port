extends Node2D


@onready var CanLay           = $CanvasLayer
@onready var fade_in          = $CanvasLayer/TextureRect

@onready var sky              = $CanvasLayer/Control/sky_layer/sky       # sky
@onready var sky_blend        = $CanvasLayer/Control/sky_layer/sky_blend # sky_blend
@onready var clouds_a         = $CanvasLayer/Control/weather_layer/clouds_a
@onready var clouds_b         = $CanvasLayer/Control/weather_layer/clouds_b
@onready var env_Node         = $CanvasLayer/Control/env_Node        # background
@onready var env_mask_Node    = $CanvasLayer/Control/env_mask_Node   # background_mask
@onready var atmosphere_layer = $CanvasLayer/Control/atmosphere_layer
#@onready var overlay          = $CanvasLayer/Control/atmosphere_layer/overlay# overlay
#@onready var overlay_blend    = $CanvasLayer/Control/atmosphere_layer/overlay_blend# overlay_blend
@onready var character_layer  = $CanvasLayer/Control/character_layer# character_layer
var sprite#@onready            = $CanvasLayer/Control/character_layer/sprite          # character_layer
@onready var scene_picture    = $CanvasLayer/Control/scene_picture   # picture_layer

@onready var choicesDialog    = $CanvasLayer/PanelContainer

@onready var top_box          = $CanvasLayer/dialogue_boxes/top_box
@onready var mid_box          = $CanvasLayer/dialogue_boxes/mid_box
@onready var bot_box          = $CanvasLayer/dialogue_boxes/bot_box

# index error 
@onready var error            = $CanvasLayer/error_label
@onready var error_label      = $CanvasLayer/error_label/Label
@onready var error_button     = $CanvasLayer/error_label/Button

# I wanted to use the draw feature to programmatically draw the dots :)
@onready var autocont_dots    = $CanvasLayer/autocont_dots

var bubble_tween
var stats_file
var opt_parsed
var daig_parsed

@onready var dialogue_timer = %dialogue_timer
var dialogue_complete = false
var hurry_dialogue = false

var active_choice = 0
var text_index = 0
var last_character  = ""
var def_text_color = 'FFFFFF'
var def_bubble_color = '000000'


# combat
var random_tries           = 40
var player_turn           = true
var player_base_hitpoints = VarTests.player_hitpoints
var player_health         = player_base_hitpoints
var enemy_health          = 0
var enemy_hand            = []
var enemy_deck:Array      = []
var tooltip:Control

var combat_stats = {
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
	"player_agility":      VarTests.player_stats["agility"],
	"player_strength":     VarTests.player_stats["strength"],
	"player_endurance":    VarTests.player_stats["endurance"],

	"player_charisma_used":     0,
	"player_will_used":         0,
	"player_intelligence_used": 0,
	"player_agility_used":      0,
	"player_strength_used":     0,
	"player_endurance_used":    0,
	"player_hitpoints_damage":  0,

	"enemy_heat_res":   0,
	"enemy_cold_res":   0,
	"enemy_impact_res": 0,
	"enemy_slash_res":  0,
	"enemy_pierce_res": 0,
	"enemy_magic_res":  0,
	"enemy_bio_res":    0,

	"enemy_charisma":      0,
	"enemy_will":          0,
	"enemy_intelligence":  0,
	"enemy_agility":       0,
	"enemy_strength":      0,
	"enemy_endurance":     0,
	"enemy_charisma_used":      0,
	"enemy_will_used":          0,
	"enemy_intelligence_used":  0,
	"enemy_agility_used":       0,
	"enemy_strength_used":      0,
	"enemy_endurance_used":     0,
	"enemy_hitpoints_damage":   0,
}

@onready var card             = load("res://assets/images/combat/card.png")
@onready var turn_dial_enemy  = load("res://assets/images/combat/turn_dial_enemy.png")
@onready var turn_dial_player = load("res://assets/images/combat/turn_dial_player.png")

# combat vars
@onready var card_empty        = load("res://assets/images/combat/card_empty.png")
@onready var player_combat_ui  = %player_combat_ui
@onready var enemy_combat_ui   = %enemy_combat_ui
@onready var attacks_timer     = %attacks_timer


@onready var turn_dail         = %turn_dail
@onready var player_health_lbl = %player_health_lbl
@onready var enemy_health_lbl  = %enemy_health_lbl

@onready var btn_card_1 = %btn_card_1
@onready var btn_card_2 = %btn_card_2
@onready var btn_card_3 = %btn_card_3
@onready var btn_card_4 = %btn_card_4
@onready var btn_card_5 = %btn_card_5
@onready var btn_card_6 = %btn_card_6
@onready var btn_card_7 = %btn_card_7


@onready var player_stat_cha_control  = %player_stat_cha_control
@onready var player_stat_will_control = %player_stat_will_control
@onready var player_stat_int_control  = %player_stat_int_control
@onready var player_stat_agi_control  = %player_stat_agi_control
@onready var player_stat_str_control  = %player_stat_str_control
@onready var player_stat_end_control  = %player_stat_end_control

@onready var player_res_heat   = %player_res_heat
@onready var player_res_cold   = %player_res_cold
@onready var player_res_impact = %player_res_impact
@onready var player_res_slash  = %player_res_slash
@onready var player_res_pierce = %player_res_pierce
@onready var player_res_magic  = %player_res_magic
@onready var player_res_bio    = %player_res_bio


@onready var enemy_stat_cha_lbl   = %enemy_stat_cha
@onready var enemy_stat_will_lbl  = %enemy_stat_will
@onready var enemy_stat_int_lbl   = %enemy_stat_int
@onready var enemy_stat_agi_lbl   = %enemy_stat_agi
@onready var enemy_stat_str_lbl   = %enemy_stat_str
@onready var enemy_stat_end_lbl   = %enemy_stat_end

@onready var enemy_res_heat    = %enemy_res_heat
@onready var enemy_res_cold    = %enemy_res_cold
@onready var enemy_res_impact  = %enemy_res_impact
@onready var enemy_res_slash   = %enemy_res_slash
@onready var enemy_res_pierce  = %enemy_res_pierce
@onready var enemy_res_magic   = %enemy_res_magic
@onready var enemy_res_bio     = %enemy_res_bio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_in.texture = load("res://assets/images/menu_background.png")

	# TEMP
	#VarTests.character_name = 'intro'
	# TEMP

	# intro fade in
	if VarTests.character_name == 'intro':
		var tween = create_tween()
		tween.tween_property(fade_in, "modulate:a", 0, 5)
		tween.finished.connect(func(): fade_in.visible = false)
	else:
		fade_in.visible = false

	VarTests.map_active = false
	start_encounter(VarTests.character_name)

func _input(_event: InputEvent) -> void:
	if VarTests.debug_screen_visible:
		return
	# auto continue
	if Input.is_action_pressed("mouse_left") or Input.is_action_pressed("ui_accept"):
		reveal_dialogue_click()
		if dialogue_complete and VarTests.auto_continue_pointer != '':
			change_index(VarTests.auto_continue_pointer)

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

# options clicks
func _on_panel_container_selected(index: Variant) -> void:
	choicesDialog.visible = false
	choicesDialog.choices_list.get_child(0).grab_focus()

	#print('sele choicesDialog.choices ', choicesDialog.choices)
	#print('sele index ', index)
	# real index search
	var found = choicesDialog.choices[index]
	var text  = found.substr(1)
	index     = opt_parsed[-1].find(text)

	var picked   = opt_parsed[0][index]
	var function = opt_parsed[1][index]

	var formatted_string = Utils.hash_diag(opt_parsed, daig_parsed, index)
	var fs_hash = formatted_string.md5_text()

	# check of character is in hash list already
	if not VarTests.CLICKED_OPTIONS.has(VarTests.character_name):
		VarTests.CLICKED_OPTIONS[VarTests.character_name] = []

	VarTests.CLICKED_OPTIONS[VarTests.character_name].append(fs_hash)

	
	if picked  :
		#print('picked ', picked)
		change_index(picked)
	if function:
		var logic_func = DiagFunc.Logigier(index, function)
		logic_logic(logic_func, function)

func make_options(packed_options):
	opt_parsed = DiagParse.parse_options(packed_options)

	#print('opt_parsed ', opt_parsed)
	var allowed = []
	var value = Showif.get_allowed(opt_parsed[2], [opt_parsed, daig_parsed])
	#print('values ', value)
	#print('range 2 ', range(len(value)))
	for i in range(len(value)):
		if not value[i]:
			var item = opt_parsed[-1][i]
			if item.to_lower() == '(return)' or item.to_lower() == '(back)':
				item = '◁──'
			else:
				item = '-' + item
			allowed.append(item)
		#var options = opt_parsed[-1]
	#print('allowed', allowed)
	choicesDialog.choices = allowed

# leave encounter
func leave_encounter() -> void:
	# catch for moving player to location when leaving to map
	VarTests.loc_name = VarTests.character_name
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func start_encounter(character_name):
	print('started ', character_name)

	# check for alt character sprite
	var character_sprite = "character"
	if VarTests.CHANGED_CHARACTERS.has(character_name):
		character_sprite = VarTests.CHANGED_CHARACTERS[character_name]

	# check for alt diag file
	VarTests.diag_file = "diag"
	if VarTests.CHANGED_DIAGS.has(character_name):
		VarTests.diag_file = VarTests.CHANGED_DIAGS[character_name]
	stats_file = LoadStats.read_char_stats(character_name)

	#var default_env = MiscFunc.parse_stat('default_env', stats_file.split('\n'))
	#if default_env == null:
	#	default_env = 'not_defined'

	# check for alt start index
	var index = "start"
	VarTests.last_index = "start"
	if VarTests.saved_indexs.has(character_name):
		index = VarTests.saved_indexs[character_name].strip_edges()

	#VarTests.environment_name = default_env
	create_sky()
	create_weather()

	# index override
	if VarTests.override_index != "":
		index = VarTests.override_index
		VarTests.override_index = ""

	change_environment()
	print('scene_character "', VarTests.scene_character, '"')
	print('character_name "', VarTests.character_name, '"')
	if VarTests.scene_character != VarTests.character_name:
		change_sprite(character_sprite)
		VarTests.scene_character = ''
	change_index(index)

func change_sprite(sprite_name=null) -> void:
	if not sprite_name:
		sprite_name = VarTests.character_sprite
	VarTests.character_sprite = sprite_name
	VarTests.scene_character = VarTests.character_name
	var path = "res://database/characters/%s/%s.png" % [VarTests.character_name, sprite_name]
	if FileAccess.file_exists(path):
		var over_sprite  = TextureRect.new()
		sprite           = TextureRect.new()
		#var picture_image = Image.load_from_file(path)
		#sprite.texture = ImageTexture.create_from_image(picture_image)
		sprite.texture = load(path)
		#sprite.modulate = Color.html('#a23f08')
		rescale_bitmapdata.call_deferred(sprite)
		over_sprite.add_child(sprite)
		character_layer.add_child(over_sprite)
		character_layer.move_to_front()

		# character overlays
		var min_TIME         = get_blend(0)
		var max_TIME         = get_blend(5)

		var os_overlay       = get_blend(3)
		var os_overlay_blend = get_blend(4)

		os_overlay_blend.modulate.a = (1/ (max_TIME - min_TIME))*(VarTests.TIME - min_TIME)
		os_overlay.modulate.a       = 1-os_overlay_blend.modulate.a
		#os_overlay.scale       = Vector2(0.50, 0.50)
		#os_overlay_blend.scale = Vector2(0.50, 0.50)
		os_overlay.position       = sprite.position
		os_overlay_blend.position = sprite.position

		# Glowfilter to compensate bad alpha multiplication
		#var oso  = TextureRect.new()
		#var osob = TextureRect.new()
		#oso.texture  = sprite.texture
		#osob.texture = sprite.texture

		#var os_overlay_mask       = TextureRect.new()
		#var os_overlay_blend_mask = TextureRect.new()

		# TINT
		MiscFunc.super_tint(over_sprite, VarTests.env_ambient, VarTests.ambient_strength)

		var env_vars = LoadStats.parse_env_vars(LoadStats.read_env_stats(VarTests.environment_name))
		var index = Utils.array_find(env_vars, 'interior')
		if env_vars[index].split(':')[-1] != 'yes':
			over_sprite.add_child(os_overlay)
			over_sprite.add_child(os_overlay_blend)

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

func create_picture(picture=false) -> void:
	#var picture_color = StyleBoxFlat.new()
	if not picture:
		scene_picture.visible = false
		#picture_color.bg_color = '000000FF'
		#top_box.add_theme_stylebox_override("fill", picture_color)
		#top_box.add_theme_stylebox_override("background", picture_color)
		#top_box.add_theme_stylebox_override("focus", picture_color)
		#top_box.add_theme_stylebox_override("normal", picture_color)
	else:
		var path = "res://database/characters/%s/pictures/%s.jpg" % [VarTests.character_name, picture]
		var path_f = "res://database/characters/%s/pictures/%s_f.jpg" % [VarTests.character_name, picture]
		if FileAccess.file_exists(path):
			var path_gate
			path_gate = path_f if VarTests.player_gender == 'female' else path

			#var picture_image = Image.load_from_file(path_gate)
			#scene_picture.texture = ImageTexture.create_from_image(picture_image)
			scene_picture.texture = load(path_gate)
			#scene_picture.move_to_front()
			scene_picture.visible = true
		#	picture_color.bg_color = '000000c8'
			#top_box.add_theme_stylebox_override("fill", picture_color)
			#top_box.add_theme_stylebox_override("background", picture_color)
			#top_box.add_theme_stylebox_override("focus", picture_color)
			#top_box.add_theme_stylebox_override("normal", picture_color)

# index error
func index_error(daig_error):
	if daig_error == null:
		error.visible = true
		error_label.text = 'ERROR: pointer: "%s" has no corresponding index.' % VarTests.current_index
		error_button.pressed.connect(func(): error.visible = false)
		choicesDialog.visible = true
		return true
	return false

func change_index(index):
	if VarTests.auto_continue_pointer:
		VarTests.auto_continue_pointer = ''

	var data = Utils.load_file('res://database/characters/%s/%s.txt' % [VarTests.character_name, VarTests.diag_file])
	daig_parsed = DiagParse.begin_parsing(data, index)
	print('daig_parsed ', daig_parsed)

	if index_error(daig_parsed):
		index = VarTests.last_index
		return null
	VarTests.current_index = index

	# CHECK IF INDEX HAS FUNCTIONS
	#print('daig_parsed[1] ', daig_parsed[1])
	if daig_parsed[1]:
		var infinite_block = Array(VarTests.last_dialogue_func.split(' '))
		var logic_func = DiagFunc.Logigier(index, daig_parsed[1])
		infinite_block.remove_at(0)
		# CHECK FOR INFINITE FUNCTION LOOP #1
		if len(infinite_block) >= 1 and infinite_block[1] == logic_func[1]:
			pass # fuckin pass ass hole
		else:
			logic_logic(logic_func, daig_parsed[1])

		# STOP INFINITE FUNCTION LOOP #2
		if len(infinite_block) >= 1 and infinite_block[1] == logic_func[1]:
			VarTests.last_dialogue_func = ''

	# dialogue
	if daig_parsed[2]:
		make_dialogue(daig_parsed[2].split('"'))

	# options
	if daig_parsed[3]:
		autocont_dots.visible = false
		make_options(daig_parsed[3])
	# AUTO CONTINUE SELECTION
	elif VarTests.auto_continue_pointer != '':
		autocont_dots.visible = true

		autocont_dots.position = Vector2(float(VarTests.stage_width) / 2, VarTests.stage_height * 0.87)
		autocont_dots.modulate = Color.TRANSPARENT

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(autocont_dots, "position:y", VarTests.stage_height * 0.85, 0.5)
		tween.parallel().tween_property(autocont_dots, "modulate:a", 0.8, 0.5)
		#tween.finished.connect(auto_cont_ellipses)

func logic_logic(logic_func, edge_case):# ?
		match logic_func[0]:
			"leave_encounter":    leave_encounter()
			"start_encounter":    start_encounter(logic_func[1])
			"change_sprite":      change_sprite(logic_func[1])
			"create_picture":     create_picture(logic_func[1])
			"remove_pic":         create_picture()
			"character_leave":    character_leave_anim(sprite)
			"character_return":   character_return_anim(sprite)
			"change_environment": change_environment(logic_func[1])
#TODO advance_time function
			"advance_time":       pass
			"change_diag":        change_diag(logic_func[1][0], logic_func[1][1])
			"change_index":       change_index(logic_func[1])
			"curated_list":
				print('dialogue curated_list!')
				change_index(Utils.curated_list(edge_case, logic_func[1]))
			"start_combat":       start_combat()
			"player_death":       player_death()
		if logic_func[2] != null:
			logic_logic(logic_func[2], edge_case)

func change_diag(diag, index) -> void:
	var data = Utils.load_file('res://database/characters/%s/%s.txt' % [VarTests.character_name, diag])
	var new_daig = DiagParse.begin_parsing(data, index)
	make_dialogue(new_daig[2])

func change_environment(new_env=null) -> void:
	scene_picture.visible = false
	if not new_env: new_env = VarTests.environment_name
	var path = ""
	var env_stats = Utils.load_file('res://database/environments/%s/stats.txt' % new_env).split('\n')

	var found = MiscFunc.parse_stat('ambient', env_stats)
	if found != "0": VarTests.ambient_strength = float(found)
	else:            VarTests.ambient_strength = 0.2

	found = MiscFunc.parse_stat('ambient_color', env_stats)
	if found != '0': VarTests.env_ambient = Color.html(found)
	else:            VarTests.env_ambient = Color.WHITE


	# MULTIPLE ENV LAYERS
	var layer_array: Array = []
	if VarTests.CHANGED_ENVIRONMENTS.has(VarTests.environment_name):
		var env_name = VarTests.CHANGED_ENVIRONMENTS[VarTests.environment_name]
		if env_name.find("-") != -1:
			layer_array = env_name.split("-")
		else:
			layer_array.append(env_name)
	else:
		layer_array.append("env")

	for i in layer_array.size():
		var layer_name:String = layer_array[i]

		# LOAD BACKGROUND PLATE
		if layer_name != "":
			# check if the file exists
			var switchout
			if FileAccess.file_exists('database/environments/%s/%s.png' % [VarTests.environment_name, layer_name]):
				switchout = layer_name
			else:
				switchout = 'env'
			path = 'database/environments/%s/%s' % [VarTests.environment_name, switchout]
		else:
			path = 'database/environments/%s/env' % [VarTests.environment_name]

	var extension_block = day_night(path)

	env_Node.texture = load("%s%s.png" % [path, extension_block])
	#env_Node.move_to_front()


	if VarTests.CHANGED_ENVIRONMENTS.has(VarTests.environment_name):
		# check if the file exists
		if FileAccess.file_exists("database/environments/%s/%s_mask.png" % [VarTests.environment_name, VarTests.CHANGED_ENVIRONMENTS[VarTests.environment_name]]):
			path = "database/environments/%s/%s" % [VarTests.environment_name, VarTests.CHANGED_ENVIRONMENTS[VarTests.environment_name]]
		else:
			path = "database/environments/%s/env" % [VarTests.environment_name]
	else:
		# DEFAULT env.png LOADING
		path = "database/environments/%s/env" % [VarTests.environment_name]

	extension_block = day_night(path)
	if FileAccess.file_exists("%s%s_mask.png" % [path, extension_block]):
		env_mask_Node.texture = load("%s%s_mask.png" % [path, extension_block])
		#env_mask_Node.move_to_front()
	#var camera_size = get_viewport().get_visible_rect().size
	#var width = round(camera_size.y / 9 * 16) # 16:9

func day_night(path):
	# DAY/NIGHT ENV
	var extension_block = ""
	# day
	if VarTests.TIME >=  25 && VarTests.TIME < 75:
		extension_block = ""
	# night
	else:
		if FileAccess.file_exists('%s%s_night.png' % [path, extension_block]):
			extension_block = "_night"
	return extension_block

func hide_dialogue_boxes(): ## My func.
	# hides visible boxes
	top_box.visible = false
	mid_box.visible = false
	bot_box.visible = false

func make_dialogue(speech:Array):
	hurry_dialogue = false
	var top = ''
	var mid = ''
	var bot = ''
	# clear active text
	top_box.text = ''
	mid_box.text = ''
	bot_box.text = ''
	bot_box.autowrap_mode = 0

	hide_dialogue_boxes()
	# prep bbcode
	speech = speech.map(func(item): return Utils.mass_repalce(item, {'<br>':'[br]', '<b>':'[b]', '</b>':'[/b]', '-name-':VarTests.player_name}).strip_edges())

	print('len(speech) ', len(speech))
	if len(speech) >= 1: top = speech[0]
	if len(speech) >= 2: mid = speech[1]
	if len(speech) >= 3: bot = speech[2]
	add_top_box(top, mid, bot)

func enable_dialogue_options(wh):
	print('enable_dialogue_options location ', wh)
	choicesDialog.modulate.a = 0
	choicesDialog.visible = true
	dialogue_complete = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(choicesDialog, "modulate:a", 1, 0.8)
	#tween.finished.connect(auto_cont_ellipses)

func reveal_dialogue_click():
	if choicesDialog.visible:
		return
	print('faster!')
	hurry_dialogue = true
	dialogue_timer.stop()
	dialogue_timer.timeout.emit()

# Add top text box.
func add_top_box(diag_top, diag_mid, diag_bot):
	#animate_text(top_box, diag_top)

	top_box.text = diag_top
	#top_box.add_theme_color_override('default_color', Color.html('#9a8e9e'))
	top_box.size = top_box.get_theme_font("normal_font").get_string_size(diag_top)

	if diag_top != '':
		top_box.visible = true
	#await get_tree().process_frame
	#top_box.position = Vector2(70, 100)

	# Story exception
	if VarTests.has_story or diag_mid == "" and diag_bot:
		#SIZE
		print('spawn_top_box A')
		if (top_box.size.x > 600):
			#await get_tree().process_frame
			top_box.size.x = 600
		top_box.size.y = 0
		top_box.position.x = 60
		top_box.position.y = (VarTests.stage_height / 2.5) - (top_box.size.y / 2)# + 20
	# only top exception
	elif diag_mid == "" and diag_bot == "":
		#SIZE
		print('spawn_top_box B')
		if (top_box.size.x > 600):
			top_box.size.x = 600
		#await get_tree().process_frame
		top_box.size.y = 0
		top_box.position.x = 60
		top_box.position.y = (VarTests.stage_height / 2.5) - (top_box.size.y / 2) + 20
	else:
		#SIZE
		print('spawn_top_box C')
		if top_box.size.x > 400:
			top_box.size.x = 400
		#await get_tree().process_frame
		top_box.size.y = 0
		top_box.position.x = 200 + 600 - top_box.size.x
		top_box.position.y = 60 + 20

	var temp = func():
		if diag_mid == "":
			dialogue_complete = true
		if dialogue_complete and VarTests.auto_continue_pointer == '':
			enable_dialogue_options('B')

	var spawn_top_box = func():
		dialogue_complete = false
		var tween1 = create_tween()
		if VarTests.has_story == true:
			print('spawn_top_box D')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(top_box, "position", Vector2(top_box.position.x - 40, top_box.position.y - 20), 0.8)
			#tween1.tween_callback()
			tween1.finished.connect(temp)
		elif diag_mid == "" and diag_bot == "":
			print('spawn_top_box E')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(top_box, "position", Vector2(top_box.position.x - 40, top_box.position.y - 20), 0.8)
			tween1.finished.connect(temp)
		else:
			print('spawn_top_box F')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(           top_box, "position:x", top_box.position.x - 200, 0.8)
			tween1.parallel().tween_property(top_box, "position:y", top_box.position.y - 60, 0.8)
			tween1.finished.connect(temp)

		#top_box.modulate = Color.TRANSPARENT
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(top_box, "modulate:a", 0.92, 0.2)

	if (diag_top != ""):
		spawn_top_box.call()


	# TIMER
	var top_len = len(diag_top)
	# catch for no top box
	if top_len == 0: top_len = 1
	var delay = float(top_len) / 100.0

	delay *= 2950
	# minimum timer
	if delay < 1000 and delay != 0: delay = 1000
	if diag_mid == "":              delay = 200
	# convert from milliseconds to seconds for code convertion from ActionScript to GDScript
	delay /=  1000.0
	dialogue_timer.wait_time = delay
	dialogue_timer.start()
	if diag_mid != "":
		#fade_in.visible = true
		#fade_in.modulate.a = 1
		if not dialogue_timer.timeout.is_connected(add_mid_box): dialogue_timer.timeout.connect(add_mid_box.bind(diag_mid, diag_bot))

# Add dialogue speech bubble.
func add_mid_box(diag_mid, diag_bot):
	# i dont think I can add this because I dont serperate create a new scene from changing dialogue file (change_diag)
	# create scene fade in
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(fade_in, "modulate:a", 0, 2)
	#tween.finished.connect(func(): fade_in.visible = false)

	var bg_color   = MiscFunc.parse_stat('bubble_color', stats_file.split('\n'))
	var font_color = MiscFunc.parse_stat('text_color', stats_file.split('\n'))
	if bg_color   == "0": bg_color   = def_bubble_color
	if font_color == "0": font_color = def_text_color

	bg_color   = Color.html(bg_color)
	font_color = Color.html(font_color)
	mid_box.add_theme_color_override("default_color", font_color)

	var diag_b_color = StyleBoxFlat.new()
	diag_b_color.bg_color = bg_color
	diag_b_color.border_color = bg_color
	diag_b_color.border_width_left   = 5
	diag_b_color.border_width_right  = 5
	diag_b_color.border_width_top    = 8
	diag_b_color.border_width_bottom = 8
	diag_b_color.set_corner_radius_all(5)

	mid_box.add_theme_stylebox_override("fill",       diag_b_color)
	mid_box.add_theme_stylebox_override("background", diag_b_color)
	mid_box.add_theme_stylebox_override("focus",      diag_b_color)
	mid_box.add_theme_stylebox_override("normal",     diag_b_color)

	#dialogue_bubble.x = over_sprite.x + over_sprite.width * 0.2 - dialogue_bubble.width - 20
	var sprite_pos = sprite.position.x
	#var sprite_img = sprite.size.x#texture.get_width()

	#await get_tree().process_frame
	mid_box.position.x = sprite_pos - mid_box.size.x - 20
	mid_box.position.y = VarTests.stage_height * 0.25
	#dialogue_bubble.size.y = 0
	#dialogue_bubble.size.x = VarTests.stage_width / 6.5

	mid_box.visible = true
	#var temp_timer = Timer.new()
	#temp_timer.one_shot = true
	#if temp_timer not in get_children():
	#	add_child(temp_timer)
	#dialogue_iteration(temp_timer, diag_mid, diag_bot, len(diag_mid))
	animate_text_prep(diag_mid, diag_bot)

# Add bottom text box.
func add_bot_box(diag_bot):
	print('diag com      ', dialogue_complete)
	print('auto          ', VarTests.auto_continue_pointer)
	print('diag com auto ', dialogue_complete and VarTests.auto_continue_pointer == '')
	if VarTests.auto_continue_pointer == '':
		enable_dialogue_options('A')
	if diag_bot != '':
		#bot_box.visible = true
		bot_box.text = diag_bot
		bot_box.size = bot_box.get_theme_font("normal_font").get_string_size(diag_bot)
		# bottom box (is ther not a better name for this?)
		#var bot_box = new_diag(diag_bot)

		if bot_box.size.x > 300:
			bot_box.autowrap_mode = 3
			bot_box.size.x = 300
		bot_box.visible = true

		#print('mid_box.position ', mid_box.position.x)
		var x_pos = mid_box.position.x + ((mid_box.size.x/2) * randf())

		if x_pos < sprite.position.x + bot_box.size.x * 0.6:
			x_pos = sprite.position.x - (bot_box.size.x * 0.8)
		#x_pos = x_pos / 1.3
		#print('size ', bot_box.size)

		var y_pos = mid_box.position.y + mid_box.size.y
		#print('x_pos ', x_pos)
		#print('y_pos ', y_pos)

		#await get_tree().process_frame
		bot_box.position = Vector2(x_pos, y_pos)
		#bot_box.position.x = x_pos
		#bot_box.position.y = y_pos

		#await get_tree().process_frame
		bot_box.size.y = 0
		bot_box.modulate = Color.TRANSPARENT

		var align_bot_box_a_bit = func():
			#print('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB')
			@warning_ignore("confusable_capture_reassignment")
			y_pos = mid_box.position.y + mid_box.size.y + 10
			var tween1 = create_tween()
			tween1.set_trans(Tween.TRANS_LINEAR)
			tween1.tween_property(bot_box, "position", Vector2(x_pos, y_pos), 1)

		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(bot_box, "position", Vector2(x_pos, y_pos + 10), 0.8)
		tween.parallel().tween_property(bot_box, "modulate:a", 0.92, 0.2)
		tween.finished.connect(align_bot_box_a_bit)


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

func _mid_box_size_clamp():
	if mid_box.size.x > 400:
		mid_box.autowrap_mode = 3
		mid_box.size.x = 400

func animate_text_prep(diag_mid, diag_bot):
	text_index = 0
	bot_box.visible = false
	# I wish I could just use visible_ratio...
	if     dialogue_timer.timeout.is_connected(add_mid_box): dialogue_timer.timeout.disconnect(add_mid_box)
	dialogue_iteration(diag_mid, diag_bot, len(diag_mid))

func dialogue_iteration(diag_mid, diag_bot, diag_length):
	if diag_length <= text_index:
		print('dialogue iteration time out!')
		dialogue_timer.stop()
		if diag_mid != "":
			dialogue_complete = true
		add_bot_box(diag_bot)
		return

	mid_box.text += diag_mid[text_index]

	realign_dialogue()

	mid_box.size = mid_box.get_theme_font("normal_font").get_string_size(mid_box.text) - Vector2(100, 0)
	#await get_tree().process_frame
	mid_box.size.y = 0

	# HURRY EXIT
	if hurry_dialogue:
		dialogue_timer.stop()
		mid_box.text = diag_mid
		mid_box.size = mid_box.get_theme_font("normal_font").get_string_size(mid_box.text) - Vector2(100, 0)
		realign_dialogue()
		add_bot_box(diag_bot)
		return

	# CHARACTER DELAY
	var delay = speech_delay(diag_mid[text_index])
	if last_character == "." or last_character == "!":
		delay = 400
	if last_character == "?":
		delay = 800

	# TIMER
	delay = float(delay) / 1000
	#print('delay ', delay)
	dialogue_timer.wait_time = delay
	#print('dialogue_timer.dialogue_timer ', dialogue_timer.wait_time)
	dialogue_timer.start()

	last_character = diag_mid[text_index]
	text_index += 1

	# start function loop
	if     dialogue_timer.timeout.is_connected(dialogue_iteration): dialogue_timer.timeout.disconnect(dialogue_iteration)
	if not dialogue_timer.timeout.is_connected(dialogue_iteration):
	#	print('aaaa')
	#	dialogue_timer.one_shot = false
		dialogue_timer.timeout.connect(dialogue_iteration.bind(diag_mid, diag_bot, len(diag_mid)))

# Realign dialogue speech bubble.
func realign_dialogue():
	#print('add bot box realign_dialogue')

	var x_pos = sprite.position.x - mid_box.size.x
	var y_pos = (float(VarTests.stage_height) / 4 * 1) - mid_box.size.y - top_box.size.y

	if x_pos < 400: x_pos = 400
	if y_pos < 20:  y_pos = 20

	if top_box.visible:
		y_pos = top_box.size.y + 30

	if bubble_tween and not bubble_tween.is_valid():
		mid_box.position = Vector2(x_pos, y_pos)
	bubble_tween = create_tween()
	bubble_tween.set_trans(Tween.TRANS_LINEAR)
	bubble_tween.tween_property(mid_box, "position", Vector2(x_pos, y_pos), 0.6)

func start_combat():
	hide_dialogue_boxes()
	player_combat_ui.visible = true
	enemy_combat_ui.visible  = true
	player_combat_ui.position.x = -player_combat_ui.size.x
	enemy_combat_ui.position.x  = VarTests.stage_width + enemy_combat_ui.size.x
	VarTests.in_combat = true
	
	var btn_cards = [btn_card_1, btn_card_2, btn_card_3, btn_card_4, btn_card_5, btn_card_6, btn_card_7]
	for i in btn_cards:
		i.get_parent().pressed.connect(_on_combat_button_pressed.bind(i))
		i.get_parent().mouse_entered.connect(_on_card_button_hover.bind(i))
		i.get_parent().mouse_exited.connect(_on_card_button_hover.bind(i, true))

	if VarTests.scene_character != VarTests.character_name:
		change_sprite()
	randomize_hand('player')
	set_enemy_stats()
	reset_stats('player')
	reset_stats('enemy')
	refresh_combat_ui()#'start'
	combat_ui_in()

# HIDE CHARACTER
func character_leave_anim(object:TextureRect) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(object, "position:x", object.position.x + 120, 0.6)
	tween.parallel().tween_property(object, "modulate:a", 0, 0.6)

# SHOW CHARACTER
func character_return_anim(object:TextureRect) -> void:
	object.modulate.a = 0
	# return to original position
	object.position.x = object.position.x - 120
	# move off screen
	object.position.x = object.position.x + VarTests.stage_width

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(object, "position:x", object.position.x - VarTests.stage_width, 0.6)
	tween.parallel().tween_property(object, "modulate:a", 1, 0.6)

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
	var overlay       = TextureRect.new()
	var overlay_blend = TextureRect.new()
	var shader = CanvasItemMaterial.new()
	shader.blend_mode = 3
	#print('overlay.material ', overlay.material)
	overlay.material = shader
	overlay_blend.material = shader

	#var sky              = sky_layer
	#var sky_blend        = sky_layer_blend

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
		sky.texture              = sky_s
		sky_blend.texture        = sky_n # into evening
		overlay.texture = overlay_s
		overlay_blend.texture = overlay_n
		min_TIME = 76
		max_TIME = 100

	if is_between(51, VarTests.TIME, 75):# DAY
		sky.texture              = sky_d
		sky_blend.texture        = sky_s # into sunset
		overlay.texture = overlay_d
		overlay_blend.texture = overlay_s
		min_TIME = 51
		max_TIME = 75

	if is_between(26, VarTests.TIME, 50): # MORNING
		sky.texture              = sky_d
		sky_blend.texture        = sky_d # into day
		overlay.texture = overlay_m
		overlay_blend.texture = overlay_d
		min_TIME = 26
		max_TIME = 50

	if is_between(0, VarTests.TIME, 25): # NIGHT
		sky.texture              = sky_n
		sky_blend.texture        = sky_d # into morning
		overlay.texture = overlay_n
		overlay_blend.texture = overlay_m
		min_TIME = 0
		max_TIME = 25



	# SKY BLENDING
	sky_blend.modulate.a     = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	overlay_blend.modulate.a = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	overlay.modulate.a       = 1 - overlay_blend.modulate.a


	if n == 0: return min_TIME
	if n == 1: return sky
	if n == 2: return sky_blend
	if n == 3: return overlay
	if n == 4: return overlay_blend
	if n == 5: return max_TIME

func create_sky():
	sky.visible        = true
	sky_blend.visible  = true

	var min_TIME      = get_blend(0)
	var max_TIME      = get_blend(5)

	#var sky           = get_blend(1)
	var sky_blend_cs  = get_blend(2)
	var overlay       = get_blend(3)
	var overlay_blend = get_blend(4)

	# NEW BLEND SYSTEM
	var alpha = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	sky_blend_cs.modulate.a     = alpha
	overlay_blend.modulate.a = alpha
	overlay.modulate.a       = 1 - overlay_blend.modulate.a
	print('overlay ', overlay)
	atmosphere_layer.add_child(overlay)
	atmosphere_layer.add_child(overlay_blend)

func create_weather():
	# RANDOMIZE CLOUDS
	var rnumb:int
	rnumb = floor(randf()*(1+3))+1
	clouds_a.texture = load("res://assets/images/sky/clouds%s.png" % [rnumb])
	clouds_a.modulate.a = randf()

	rnumb = floor(randf()*(1+3))+1
	clouds_b.texture = load("res://assets/images/sky/clouds%s.png" % [rnumb])
	clouds_b.modulate.a = randf()

# combat
func _on_btn_turn_dial_pressed() -> void:
	if player_turn:
		player_turn = false
		turn_dail.disabled = true
		turn_dail.get_parent().texture = turn_dial_enemy
		change_turn_to("enemy")

func set_enemy_stats():
	var stat_spit    = stats_file.split('\n')
	combat_stats["enemy_heat_res"]     = int(MiscFunc.parse_stat('heat_res', stat_spit))
	combat_stats["enemy_cold_res"]     = int(MiscFunc.parse_stat('cold_res', stat_spit))
	combat_stats["enemy_impact_res"]   = int(MiscFunc.parse_stat('impact_res', stat_spit))
	combat_stats["enemy_slash_res"]    = int(MiscFunc.parse_stat('slash_res', stat_spit))
	combat_stats["enemy_pierce_res"]   = int(MiscFunc.parse_stat('pierce_res', stat_spit))
	combat_stats["enemy_magic_res"]    = int(MiscFunc.parse_stat('magic_res', stat_spit))
	combat_stats["enemy_bio_res"]      = int(MiscFunc.parse_stat('bio_res', stat_spit))

	combat_stats["enemy_charisma"]     = int(MiscFunc.parse_stat('charisma', stat_spit))
	combat_stats["enemy_will"]         = int(MiscFunc.parse_stat('will', stat_spit))
	combat_stats["enemy_intelligence"] = int(MiscFunc.parse_stat('intelligence', stat_spit))
	combat_stats["enemy_agility"]      = int(MiscFunc.parse_stat('agility', stat_spit))
	combat_stats["enemy_strength"]     = int(MiscFunc.parse_stat('strength', stat_spit))
	combat_stats["enemy_endurance"]    = int(MiscFunc.parse_stat('endurance', stat_spit))
	
	enemy_health                       = int(MiscFunc.parse_stat('hitpoints', stat_spit))
	enemy_deck                         = Utils.get_substring('<cards', 'cards>', stats_file).split('\n')
	# remove \r\n
	enemy_deck                         = enemy_deck.map(func(item): return item.strip_edges())

func randomize_hand(who):
	var deck
	var hand = []

	if who == 'player': deck = VarTests.CARD_INVENTORY
	else:               deck = enemy_deck

	for i in range(7): hand.append(deck.pick_random())
	if who == 'player':
		hand = hand.map(func(item): return item.replace('_', ' '))
		btn_card_1.text = hand[0]
		btn_card_2.text = hand[1]
		btn_card_3.text = hand[2]
		btn_card_4.text = hand[3]
		btn_card_5.text = hand[4]
		btn_card_6.text = hand[5]
		btn_card_7.text = hand[6]
	else:
		enemy_hand = hand

# COMBAT AI
func combat_ai():
	randomize_hand("enemy")

	random_tries = 40
	var attack = func():
		if player_turn:
			attacks_timer.stop()
			return

		attacks_timer.wait_time = 900.0 / 1000.0

		var play_this_card = enemy_hand.pick_random()

		if random_tries <= 0 or player_health <= 0: # END TURN IF ALL TRIES GONE
			attacks_timer.stop()
			change_turn_to("player")
			return

		if not play_card("enemy", play_this_card, "player"):
			random_tries -= 1
			attacks_timer.wait_time = 0.01
			return

		random_tries -= 1
	if not attacks_timer.ready.is_connected(attack.call):
		print('is_connected?')
		attacks_timer.timeout.connect(attack.call)
	attacks_timer.start()

# RESET STATS
func reset_stats(player):
	combat_stats["%s_charisma_used"     % player] = 0
	combat_stats["%s_will_used"         % player] = 0
	combat_stats["%s_intelligence_used" % player] = 0

	combat_stats["%s_agility_used"      % player] = 0
	combat_stats["%s_strength_used"     % player] = 0
	combat_stats["%s_endurance_used"    % player] = 0

	combat_stats["%s_hitpoints_damage"  % player] = 0

	refresh_combat_ui()#'reset'

# CHANGE TURN TO
func change_turn_to(player):
	# CHARACTER TURN
	if player == "enemy":
		turn_dail.get_parent().texture = turn_dial_enemy
		reset_stats("enemy")
		player_turn = false
		VarTests.whos_turn = 'enemy'
		turn_dail.disabled = true
		combat_ai()
	# PLAYER TURN
	if player == "player":
		turn_dail.get_parent().texture = turn_dial_player
		player_turn = true
		VarTests.whos_turn = 'player'
		turn_dail.disabled = false
		reset_stats("player")

		var btn_cards = [btn_card_1, btn_card_2, btn_card_3, btn_card_4, btn_card_5, btn_card_6, btn_card_7]
		for i in btn_cards:
			i.get_parent().get_parent().texture = card
			i.get_parent().visible = true
		randomize_hand("player")

func damage(damage_to_hitpoints, target):
	if damage_to_hitpoints > 0:
		combat_stats["%s_hitpoints_damage" % target] = damage_to_hitpoints

		# CHARACTER DAMAGE EFFECTS
		if target == "enemy":
			#enemy_health -= combat_stats["enemy_hitpoints_damage"]
			blink_red(sprite, 0.7)
			shake(sprite)
			floating_text(sprite, str(damage_to_hitpoints), "#FF0000", 35)

		# PLAYER DAMAGE EFFECTS
		if target == "player":
			#player_health -= combat_stats["player_hitpoints_damage"]
			shake(player_health_lbl)
			floating_text(player_health_lbl, str(damage_to_hitpoints), "#FF0000", 35)

		# Check if target dies from the hitpoints damage
		refresh_combat_ui()#'damage'
	else:
		# CHARACTER NO DAMAGE
		if target == "enemy":
			shake(sprite)
			floating_text(sprite, "No damage!", '#FFFFFF', 25)

#@warning_ignore("unused_parameter")
func refresh_combat_ui():#where
	player_stat_cha_control.get_child(1).text  = str(VarTests.player_stats["charisma"]     - combat_stats["player_charisma_used"])
	player_stat_will_control.get_child(1).text = str(VarTests.player_stats["will"]         - combat_stats["player_will_used"])
	player_stat_int_control.get_child(1).text  = str(VarTests.player_stats["intelligence"] - combat_stats["player_intelligence_used"])

	player_stat_agi_control.get_child(1).text  = str(VarTests.player_stats["agility"]      - combat_stats["player_agility_used"])
	player_stat_str_control.get_child(1).text  = str(VarTests.player_stats["strength"]     - combat_stats["player_strength_used"])
	player_stat_end_control.get_child(1).text  = str(VarTests.player_stats["endurance"]    - combat_stats["player_endurance_used"])
	player_health_lbl.text    = str(player_health)
	
	player_res_heat.text   = str(VarTests.player_stats["heat_res"])
	player_res_cold.text   = str(VarTests.player_stats["cold_res"])
	player_res_impact.text = str(VarTests.player_stats["impact_res"])
	player_res_slash.text  = str(VarTests.player_stats["slash_res"])
	player_res_pierce.text = str(VarTests.player_stats["pierce_res"])
	player_res_magic.text  = str(VarTests.player_stats["magic_res"])
	player_res_bio.text    = str(VarTests.player_stats["bio_res"])

	var stat_spit = stats_file.split('\n')
	enemy_stat_cha_lbl.text   = str(int(MiscFunc.parse_stat('charisma', stat_spit))     - combat_stats["enemy_charisma_used"])
	enemy_stat_will_lbl.text  = str(int(MiscFunc.parse_stat('will', stat_spit))         - combat_stats["enemy_will_used"])
	enemy_stat_int_lbl.text   = str(int(MiscFunc.parse_stat('intelligence', stat_spit)) - combat_stats["enemy_intelligence_used"])

	enemy_stat_agi_lbl.text   = str(int(MiscFunc.parse_stat('agility', stat_spit))      - combat_stats["enemy_agility_used"])
	enemy_stat_str_lbl.text   = str(int(MiscFunc.parse_stat('strength', stat_spit))     - combat_stats["enemy_strength_used"])
	enemy_stat_end_lbl.text   = str(int(MiscFunc.parse_stat('endurance', stat_spit))    - combat_stats["enemy_endurance_used"])
	enemy_health_lbl.text     = str(enemy_health)
	
	enemy_res_heat.text   = str(combat_stats["enemy_heat_res"])
	enemy_res_cold.text   = str(combat_stats["enemy_cold_res"])
	enemy_res_impact.text = str(combat_stats["enemy_impact_res"])
	enemy_res_slash.text  = str(combat_stats["enemy_slash_res"])
	enemy_res_pierce.text = str(combat_stats["enemy_pierce_res"])
	enemy_res_magic.text  = str(combat_stats["enemy_magic_res"])
	enemy_res_bio.text    = str(combat_stats["enemy_bio_res"])


# COMBAT UI IN
func combat_ui_in():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(player_combat_ui, "position:x", 0, 1)

	var vec_x = VarTests.stage_width - enemy_combat_ui.size.x
	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_BOUNCE)
	tween1.tween_property(enemy_combat_ui, "position:x", vec_x, 1)

#COMBAT UI OUT
func combat_ui_out():
	var change_vis = func():
		player_combat_ui.visible = false
		enemy_combat_ui.visible = false

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(player_combat_ui, "position:x", -player_combat_ui.size.x, 1)
	tween.parallel().tween_property(player_combat_ui, "modulate:a", 0, 1)
	tween.finished.connect(change_vis.call)

	var vec_x = VarTests.stage_width + enemy_combat_ui.size.x
	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_BOUNCE)
	tween1.tween_property(enemy_combat_ui, "position:x", vec_x, 1)
	tween1.parallel().tween_property(enemy_combat_ui, "modulate:a", 0, 1)
	tween1.finished.connect(change_vis.call)

func not_enough_stat(stat):
	if not player_turn: return
	match stat:
		"charisma":
			#shake(player_stat_cha)
			var player_stat_cha_tex = player_stat_cha_control.get_child(0)
			blink_red(player_stat_cha_tex, 0.6)
			red_pointer(player_stat_cha_tex)
		"knowledge":
			#shake(player_stat_will)
			var player_stat_will_tex = player_stat_will_control.get_child(0)
			blink_red(player_stat_will_tex, 0.6)
			red_pointer(player_stat_will_tex)
		"intelligence":
			#shake(player_stat_int)
			var player_stat_int_tex = player_stat_int_control.get_child(0)
			blink_red(player_stat_int_tex, 0.6)
			red_pointer(player_stat_int_tex)
		"agility":
			#shake(player_stat_agi)
			var player_stat_agi_tex = player_stat_agi_control.get_child(0)
			blink_red(player_stat_agi_tex, 0.6)
			red_pointer(player_stat_agi_tex)
		"strength":
			#shake(player_stat_str)
			var player_stat_str_tex = player_stat_str_control.get_child(0)
			blink_red(player_stat_str_tex, 0.6)
			red_pointer(player_stat_str_tex)
		"endurance":
			#shake(player_stat_end)
			var player_stat_end_tex = player_stat_end_control.get_child(0)
			blink_red(player_stat_end_tex, 0.6)
			red_pointer(player_stat_end_tex)

func blink_red(object, time):
	var red = Color(1.3, 1.0, 1.0)
	object.modulate = red

	var timer              = Timer.new() # time * 1000
	var timer_red          = Timer.new() # 50
	var timer_normal       = Timer.new() # 50
	timer.wait_time        = time# * 1000.0
	timer_red.wait_time    = 50.0 / 1000.0
	timer_normal.wait_time = 50.0 / 1000.0

	var blk_red = func():
		object.modulate = red
		timer_red.stop()
		timer_normal.start()
	var blink_normal = func():
		object.modulate = Color.WHITE
		timer_normal.stop()
		timer_red.start()
	var end = func():
		object.modulate = Color.WHITE
		timer_red.stop()
		timer_normal.stop()
		timer.stop()

		if object == sprite:
			MiscFunc.super_tint(sprite, VarTests.env_ambient, 0.4)
	if timer        not in get_children(): add_child(timer)
	if timer_red    not in get_children(): add_child(timer_red)
	if timer_normal not in get_children(): add_child(timer_normal)
	if not timer_red.timeout.is_connected(blk_red):          timer_red.timeout.connect(blk_red.call)
	if not timer_normal.timeout.is_connected(blink_normal):  timer_normal.timeout.connect(blink_normal.call)
	if not timer.timeout.is_connected(end):                  timer.timeout.connect(end)

	timer.start()
	timer_normal.start()


func red_pointer(source_object):
	var txt_box = Label.new()
	txt_box.text = '<'	
	txt_box.add_theme_color_override("font_color", Color.RED)
	txt_box.add_theme_font_size_override('font_size', 30)

	txt_box.position.x = source_object.position.x
	txt_box.position.y = (source_object.position.y + (source_object.size.y / 2)) - (txt_box.size.y / 2) - 10


	txt_box.position.x = 84


	player_combat_ui.add_child(txt_box)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(txt_box, "modulate:a", 0, 1.2)
	tween.finished.connect(txt_box.queue_free)

func play_card(attacker, the_card, target):
	var card_stats = Utils.get_substring('<%s' % the_card, '%s>' % the_card, VarTests.ALL_CARDS).strip_edges()

	# COST
	var c_cost = int(MiscFunc.parse_stat('charisma_cost',     card_stats.split('\n')))
	var i_cost = int(MiscFunc.parse_stat('intelligence_cost', card_stats.split('\n')))
	var w_cost = int(MiscFunc.parse_stat('knowledge_cost',    card_stats.split('\n')))
	var a_cost = int(MiscFunc.parse_stat('agility_cost',     card_stats.split('\n')))
	var s_cost = int(MiscFunc.parse_stat('strength_cost',    card_stats.split('\n')))
	var e_cost = int(MiscFunc.parse_stat('endurance_cost',   card_stats.split('\n')))
	var h_cost = int(MiscFunc.parse_stat('hitpoints_cost',   card_stats.split('\n')))
	#refresh_combat_ui() # Check if player dies from the hitpoints cost
	# COST

	# CHECK IF YOU CAN PAY THE COST
	var cannot_afford = false
	var c_left = combat_stats["%s_charisma"     % attacker] - combat_stats["%s_charisma_used"     % attacker]
	var w_left = combat_stats["%s_will"         % attacker] - combat_stats["%s_will_used"         % attacker]
	var i_left = combat_stats["%s_intelligence" % attacker] - combat_stats["%s_intelligence_used" % attacker]
	var a_left = combat_stats["%s_agility"      % attacker] - combat_stats["%s_agility_used"      % attacker]
	var s_left = combat_stats["%s_strength"     % attacker] - combat_stats["%s_strength_used"     % attacker]
	var e_left = combat_stats["%s_endurance"    % attacker] - combat_stats["%s_endurance_used"    % attacker]
	# CHECK IF YOU CAN PAY THE COST

	if c_cost > c_left:
		not_enough_stat("charisma")
		cannot_afford = true
	if w_cost > w_left:
		not_enough_stat("will")
		cannot_afford = true
	if i_cost > i_left:
		not_enough_stat("intelligence")
		cannot_afford = true

	if a_cost > a_left:
		not_enough_stat("agility")
		cannot_afford = true
	if s_cost > s_left:
		not_enough_stat("strength")
		cannot_afford = true
	if e_cost > e_left:
		not_enough_stat("endurance")
		cannot_afford = true
	if cannot_afford:# STOP PLAYING THE CARD IF NOT ENOUGH STATS
		return false

	# DAMAGE
	combat_stats["%s_charisma_used"     % attacker] += apply_attribute_cost(attacker, c_cost, "charisma")
	combat_stats["%s_will_used"         % attacker] += apply_attribute_cost(attacker, w_cost, "will")
	combat_stats["%s_intelligence_used" % attacker] += apply_attribute_cost(attacker, i_cost, "intelligence")

	combat_stats["%s_agility_used"      % attacker] += apply_attribute_cost(attacker, a_cost, "agility")
	combat_stats["%s_strength_used"     % attacker] += apply_attribute_cost(attacker, s_cost, "strength")
	combat_stats["%s_endurance_used"    % attacker] += apply_attribute_cost(attacker, e_cost, "endurance")
	combat_stats["%s_hitpoints_damage"  % attacker] += apply_attribute_cost(attacker, h_cost, "hitpoints")

	var h_dmg = int(MiscFunc.parse_stat('hitpoints_dmg', card_stats.split('\n')))

	var heat_dmg   = int(MiscFunc.parse_stat('heat_dmg', card_stats.split('\n')))
	var cold_dmg   = int(MiscFunc.parse_stat('cold_dmg', card_stats.split('\n')))
	var impact_dmg = int(MiscFunc.parse_stat('impact_dmg', card_stats.split('\n')))
	var slash_dmg  = int(MiscFunc.parse_stat('slash_dmg', card_stats.split('\n')))
	var p_dmg      = int(MiscFunc.parse_stat('pierce_dmg', card_stats.split('\n')))
	var m_dmg      = int(MiscFunc.parse_stat('magic_dmg', card_stats.split('\n')))
	var b_dmg      = int(MiscFunc.parse_stat('bio_dmg', card_stats.split('\n')))
	# DAMAGE

	# RESOLVE DAMAGE
	var damage_to_hitpoints = 0
	# calculate against resistances
	damage_to_hitpoints += resolve_damage(heat_dmg,   "heat",   target)
	damage_to_hitpoints += resolve_damage(cold_dmg,   "cold",   target)
	damage_to_hitpoints += resolve_damage(impact_dmg, "impact", target)
	damage_to_hitpoints += resolve_damage(slash_dmg,  "slash",  target)
	damage_to_hitpoints += resolve_damage(p_dmg,      "pierce", target)
	damage_to_hitpoints += resolve_damage(m_dmg,      "magic",  target)
	damage_to_hitpoints += resolve_damage(b_dmg,      "bio",    target)
	damage_to_hitpoints += h_dmg
	# calculate against resistances

	# APPLY DAMAGE
	if attacker == "enemy":
		floating_text(sprite, the_card, '#FF9933', 25)
		attack_effect(sprite)
		damage(damage_to_hitpoints, "player")
	if attacker == "player":
		# Float text
		# Effect
		damage(damage_to_hitpoints, "enemy")
	# APPLY DAMAGE
	refresh_hitpoints()
	refresh_combat_ui()#'play_card'
	return true

# REFRESH HITPOINTS
func refresh_hitpoints():
	enemy_health  -= combat_stats["enemy_hitpoints_damage"]
	#recalculate_stats()
	player_health -= combat_stats["player_hitpoints_damage"]

	# win/lose/player death
	if player_health <= 0:
		VarTests.in_combat = false
		combat_ui_out()
		change_index(VarTests.lose_index)# HERE GOES PLAYER DEATH
		return
	if enemy_health  <= 0:
		VarTests.in_combat = false
		combat_ui_out()
		change_index(VarTests.win_index)
		return

# ATTACK EFFECT
func attack_effect(object):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(object, "position:x", object.position.x-20, 0.1)
	var move_back = func():
		var tween1 = create_tween()
		tween1.set_ease(Tween.EASE_IN_OUT)
		tween1.set_trans(Tween.TRANS_BACK)
		tween1.tween_property(object, "position:x", VarTests.stage_width - (object.size.x * 0.5), 0.2)
	tween.finished.connect(move_back)

# SHAKE EFFECT
func shake(clip):
	# internal used for shake effect
	var randomRange = func (minn, maxx):
		return (minn + randf() * (maxx - minn))

	var tween = create_tween()
	var shake_duration = 20.0 / 1000.0
	var shake_count = 10
	var tempX = clip.position.x
	var tempY = clip.position.y

	# scale commented out for misbehaviour with sprite scale
	for i in shake_count:
		#var rrange = randomRange.call(9.6, 10.4) / 10
		tween.tween_property(clip, "position", clip.position + Vector2(randomRange.call(-2, 2), randomRange.call(-2, 2)), shake_duration)
		#tween.parallel().tween_property(clip, "scale", Vector2(rrange, rrange), shake_duration)
		tween.finished.connect(func():
			clip.position.x = tempX
			clip.position.y = tempY
			#clip.scale = 1
			)

# FLOATING TEXT
func floating_text(source_object, txt, color, size):
	var txt_box = Label.new()
	txt = '%s%s' % [txt[0].to_upper(), txt.substr(1,-1)]
	txt_box.text = txt.replace('_', ' ')
	txt_box.add_theme_color_override("font_color", Color.html(color))
	txt_box.add_theme_font_size_override('font_size', 20)
	
	

	txt_box.position.x = (source_object.position.x + ((source_object.size.x * 0.5) / 2)) - (txt_box.size.x/2)
	txt_box.position.y = (source_object.position.y + ((source_object.size.y / 6) * 1))
	CanLay.add_child(txt_box)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(txt_box, "position:y", 0, 3)

	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_IN)
	tween1.set_trans(Tween.TRANS_EXPO)
	tween1.tween_property(txt_box, "modulate:a", 0, 3)
	tween1.finished.connect(txt_box.queue_free)

func stat_float(source_object, txt, color, size, side):
	var txt_box = Label.new()
	txt_box.text = txt
	txt_box.add_theme_color_override("font_color", color)
	txt_box.add_theme_font_size_override('font_size', 20)

	var x_disp = 0

	txt_box.position.x = source_object.position.x + 50
	txt_box.position.y = (source_object.position.y + (source_object.size.y / 2)) - (txt_box.size.y / 2) - 5


	if side == "player":
		txt_box.position.x = 80
		x_disp = 120
		player_combat_ui.add_child(txt_box)
	if side == "enemy":
		txt_box.position.x = VarTests.stage_width - 80 - txt_box.size.x
		x_disp = (VarTests.stage_width - 80) - 70
		enemy_combat_ui.add_child(txt_box)


	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(txt_box, "position:x", x_disp, 3)

	var tween1 = create_tween()
	tween1.set_ease(Tween.EASE_IN)
	tween1.set_trans(Tween.TRANS_EXPO)
	tween1.tween_property(txt_box, "modulate:a", 0, 3)
	tween1.finished.connect(txt_box.queue_free)

func apply_attribute_cost(payer, attribute_cost, attribute_stat):

	var effect_number
	var effect_color

	if attribute_cost > 0:
		effect_number = abs(attribute_cost)
		effect_color = Color.RED
	if attribute_cost < 0:
		effect_number = abs(attribute_cost)
		effect_color = Color.GREEN

	if attribute_cost != 0:
		if payer == "player":
			match attribute_stat:
				"charisma":     stat_float(player_stat_cha_control.get_child(1), str(effect_number), effect_color, 24, payer)
				"will":         stat_float(player_stat_will_control.get_child(1), str(effect_number), effect_color, 24, payer)
				"intelligence": stat_float(player_stat_int_control.get_child(1), str(effect_number), effect_color, 24, payer)

				"agility":      stat_float(player_stat_agi_control.get_child(1), str(effect_number), effect_color, 24, payer)
				"strength":     stat_float(player_stat_str_control.get_child(1), str(effect_number), effect_color, 24, payer)
				"endurance":    stat_float(player_stat_end_control.get_child(1), str(effect_number), effect_color, 24, payer)

		if payer == "enemy":
			match attribute_stat:
				"charisma":     stat_float(enemy_stat_cha_lbl, str(effect_number), effect_color, 24, payer)
				"will":         stat_float(enemy_stat_will_lbl, str(effect_number), effect_color, 24, payer)
				"intelligence": stat_float(enemy_stat_int_lbl, str(effect_number), effect_color, 24, payer)

				"agility":      stat_float(enemy_stat_agi_lbl, str(effect_number), effect_color, 24, payer)
				"strength":     stat_float(enemy_stat_str_lbl, str(effect_number), effect_color, 24, payer)
				"endurance":    stat_float(enemy_stat_end_lbl, str(effect_number), effect_color, 24, payer)

	return attribute_cost

# RESOLVE_DAMAGE
@warning_ignore("shadowed_variable")
func resolve_damage(damage, resistance_name, target):
	var actual_damage:int = 0

	var resistance = int(combat_stats["%s_%s_res" % [target, resistance_name]])

	if resistance < 0:
		# negative resistance amplified damage
		actual_damage = damage + (~(resistance)+1)
	else:
		# normal damage
		actual_damage =  damage - resistance

	if actual_damage < 0:
		actual_damage = 0

	return actual_damage


func card_clicked(attacker, used_card, target):
	var the_card = used_card.text.replace(' ', '_').to_lower()
	if play_card(attacker, the_card, target):
		used_card.get_parent().visible = false
		used_card.get_parent().get_parent().texture = card_empty

func _on_card_button_hover(button, leave:bool=false):
	if leave:
		tooltip.queue_free()
	else:
		tooltip = load("res://scenes/tool_tip.tscn").instantiate()
		var the_card = button.text.replace(' ', '_')
		var card_stats = Utils.get_substring('<%s' % the_card, '%s>' % the_card, VarTests.ALL_CARDS)#.strip_edges()

		tooltip.get_node("Label").text = Utils.mass_repalce(card_stats, {'\t':'', '\r':'', ':':': '})
		CanLay.add_child(tooltip)
		tooltip.move_to_front()

func _on_combat_button_pressed(button) -> void:
	card_clicked('player', button, 'enemy')

# PLAYER DEATH
func player_death():
	#start_music("misc/player_death", 100, 0, 0, "no_loop")
	VarTests.menu_state = 'death'
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
