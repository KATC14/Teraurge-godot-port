extends Node2D


@onready var CanLay           = $CanvasLayer
@onready var fade_in          = $CanvasLayer/TextureRect

@onready var sky              = $CanvasLayer/Control/sky_layer/sky       # sky
@onready var sky_blend        = $CanvasLayer/Control/sky_layer/sky_blend # sky_blend
@onready var clouds_a         = $CanvasLayer/Control/weather_layer/clouds_a
@onready var clouds_b         = $CanvasLayer/Control/weather_layer/clouds_b
@onready var env_Node         = $CanvasLayer/Control/env_Node        # background
@onready var env_mask_Node    = $CanvasLayer/Control/env_mask_Node   # background_mask
@onready var overlay          = $CanvasLayer/Control/atmosphere_layer/overlay# overlay
@onready var overlay_blend    = $CanvasLayer/Control/atmosphere_layer/overlay_blend# overlay_blend
@onready var sprite           = $CanvasLayer/Control/sprite          # character_layer
@onready var scene_picture    = $CanvasLayer/Control/scene_picture   # picture_layer

@onready var choicesDialog    = $CanvasLayer/PanelContainer
@onready var shakeTimer       = $CanvasLayer/Control3/Timer2

@onready var top_box = $CanvasLayer/dialogue_boxes/top_box
@onready var mid_box = $CanvasLayer/dialogue_boxes/mid_box
@onready var bot_box = $CanvasLayer/dialogue_boxes/bot_box

@onready var error            = $CanvasLayer/Panel2
@onready var error_label      = $CanvasLayer/Panel2/Label
@onready var error_button     = $CanvasLayer/Panel2/Button

# I wanted to use the draw feature to programmatically draw the dots :)
@onready var autocont_dots    = $CanvasLayer/autocont_dots

var bubble_tween
var stats_file
var opt_parsed

var dialogue_complete = true

var active_choice = 0
var text_index = 0
var last_character  = ""
var diag_file       = ""
var def_text_color = 'FFFFFF'
var def_bubble_color = '000000'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set_defaults()
	#get_tree().get_root().size_changed.connect(resize)
	#_on_start_combat()
	#$CanvasLayer/Camera2D.make_current()
	fade_in.texture = load("res://assets/images/menu_background.png")

	# TEMP
	VarTests.character_name = 'intro'
	VarTests.player_stats['will'] = 10
	# TEMP
	# intro fade in
	if VarTests.character_name == 'intro':
		var tween = create_tween()
		tween.tween_property(fade_in, "modulate:a", 0, 5)
		tween.finished.connect(func(): fade_in.visible = false)
	else:
		fade_in.visible = false

	VarTests.sprite = sprite
	_on_start_encounter(VarTests.character_name)

func _input(_event: InputEvent) -> void:
	# auto continue
	if Input.is_action_pressed("mouse_left") or Input.is_action_pressed("ui_accept"):
		#hurry_dialogue = true
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

# options clicks
func _on_panel_container_selected(index: Variant) -> void:
	choicesDialog.visible = false
	#dont_hurry = true
	choicesDialog.choices_list.get_children()[0].grab_focus()

	#print('sele choicesDialog.choices ', choicesDialog.choices)
	#print('sele index ', index)
	# real index search
	var found = choicesDialog.choices[index]
	var text  = found.substr(1)
	index     = opt_parsed[-1].find(text)

	var picked   = opt_parsed[0][index]
	var function = opt_parsed[1][index]
	#print('sele picked ', picked)
	#print('sele function ', function)

	if opt_parsed[2][index]:
		found = Utils.array_find(opt_parsed[2][index], 'hideif.clicked')
		#print('hide if ', opt_parsed[2][index])
		#print('found ', found)
		if found != -1:
			# indexs
			var idx = opt_parsed[0].filter(func(item): return item)
			#print('idx ', idx)
			# last index
			var multi_index = '%s#%s' % [VarTests.current_index, '#'.join(idx)]
			#print('idx multi_index ', multi_index)
			# picked option extra
			var opt_fmt = ' //'.join(opt_parsed[2][index])
			# picked option
			var opt = '%s //%s' % [opt_parsed[-1][index], opt_fmt]
			var formatted_string = '%s-%s-%s' % [multi_index, picked, opt]
			#print('fs_hash ', formatted_string)
			var fs_hash = formatted_string.md5_text()
			#print('fs_hash ', fs_hash)
			var clicked_hash_list = []

			if VarTests.CLICKED_OPTIONS.has(VarTests.character_name):
				clicked_hash_list.append(fs_hash)
			else:
				clicked_hash_list = VarTests.CLICKED_OPTIONS[VarTests.character_name]
				clicked_hash_list.append(fs_hash)
			VarTests.CLICKED_OPTIONS[VarTests.character_name] = clicked_hash_list

	if picked  : _on_change_index(picked)
	if function: $CanvasLayer/Panel.Logigier(function)

func make_options(packed_options, curated_list=false):
	opt_parsed = DiagParse.parse_options(packed_options)

	#print('opt_parsed ', opt_parsed)
	var allowed = []
	# TODO finish fixing md5 hash on hideif.clicked it needs the full string
	var value = MiscFunc.get_allowed(opt_parsed)
	for i in range(len(value)):
		#print(opt_parsed[2][i])
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
		#print('-a ', index)
		#print('cc ', index)
		#print('allowd substr ', allowed[index].substr(1))
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

# leave encounter
func _on_leave_encounter() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_start_encounter(character_name):
	print('started ', character_name)

	# check for alt character sprite
	VarTests.character_sprite = "character"
	if VarTests.CHANGED_CHARACTERS.has(character_name):
		VarTests.character_sprite = VarTests.CHANGED_CHARACTERS[character_name]

	# check for alt diag file
	diag_file = "diag"
	if VarTests.CHANGED_DIAGS.has(character_name):
		diag_file = VarTests.CHANGED_DIAGS[character_name]
	stats_file = LoadStats.read_char_stats(character_name)

	var default_env = MiscFunc.parse_stat('default_env', stats_file.split('\n'))
	if default_env == null:
		default_env = 'not_defined'

	# check for alt start index
	var index = "start"
	if VarTests.DINDEX.has(character_name):
		index = VarTests.DINDEX[character_name].strip_edges()

	VarTests.environment_name = default_env
	create_sky()
	create_weather()

	# index override
	if VarTests.override_index != "":
		index = VarTests.override_index
		VarTests.override_index = ""

	_on_change_environment()
	if VarTests.scene_character != VarTests.character_name:
		MiscFunc.make_character()
	_on_change_index(index)

func _on_create_picture(picture=false) -> void:
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
	if daig_parsed[1]:
		#TEMP
		#daig_parsed = ['before', 'You dash towards the nearest door. You reach for the door handle, but before you manage to touch it, an invisible force stops you. You\'re dragged back to the spot you started. "Look, I\'m sorry about all this, but please calm down. I\'m not going to hurt you." She taps the floor with her staff, and the force holding you disappears. ']
		#TEMP
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

		autocont_dots.position = Vector2(float(VarTests.stage_width) / 2, VarTests.stage_height * 0.87)
		autocont_dots.modulate = Color.TRANSPARENT

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(autocont_dots, "position:y", VarTests.stage_height * 0.85, 0.5)
		tween.parallel().tween_property(autocont_dots, "modulate:a", 0.8, 0.5)
		#tween.finished.connect(auto_cont_ellipses)

func _on_change_environment(new_env=null) -> void:
	scene_picture.visible = false
	if not new_env: new_env = 'env'
	var path = "res://database/environments/%s/%s" % [VarTests.environment_name, new_env]
	var env_stats = Utils.load_file('res://database/environments/%s/stats.txt' % VarTests.environment_name).split('\n')

	var found = MiscFunc.parse_stat('ambient', env_stats)
	if found != null:
		VarTests.ambient_strength = float(found)
	else:
		VarTests.ambient_strength = 0.2

	found = MiscFunc.parse_stat('ambient_color', env_stats)
	if found != '0':
		VarTests.env_ambient = Color.html(found)
	else:
		VarTests.env_ambient = Color.WHITE

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
	#env_Node.move_to_front()

	if FileAccess.file_exists("%s%s_mask.png" % [path, extension_block]):
		#var env_mask_image = Image.load_from_file(path)
		#env_mask_Node.texture = ImageTexture.create_from_image(env_mask_image)
		env_mask_Node.texture = load("%s%s_mask.png" % [path, extension_block])
		#env_mask_Node.move_to_front()
	#var camera_size = get_viewport().get_visible_rect().size
	#var width = round(camera_size.y / 9 * 16) # 16:9

func make_dialogue(speech:Array):
	var top = ''
	var mid = ''
	var bot = ''
	# clear active text
	top_box.text = ''
	mid_box.text = ''
	bot_box.text = ''

	# hides visable boxes
	top_box.visible = false
	mid_box.visible = false
	bot_box.visible = false
	# prep bbcode
	speech = speech.map(func(item): return item.replace('<br>', '[br]').replace('<b>', '[b]').replace('</b>', '[/b]').replace('-name-', VarTests.player_name).strip_edges())

	if len(speech) >= 1: top = speech[0]
	if len(speech) >= 2: mid = speech[1]
	if len(speech) >= 3: bot = speech[2]
	add_top_box(top, mid, bot)

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
	if (VarTests.has_story or diag_mid == "empty" and diag_bot):
		#SIZE
		print('spawn_top_box A')
		if (top_box.size.x > 600):
			#await get_tree().process_frame
			top_box.size.x = 600
		#await get_tree().process_frame
		top_box.size.y = 0
		top_box.position.x = 60
		top_box.position.y = (VarTests.stage_height / 2.5) - (top_box.size.y / 2)# + 20

	# only top exception
	elif (diag_mid == "empty" and diag_bot == ""):
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

	var spawn_top_box = func():
		dialogue_complete = false
		var tween1 = create_tween()
		if VarTests.has_story == true:
			print('spawn_top_box e')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(top_box, "position", Vector2(top_box.position.x - 40, top_box.position.y - 20), 0.8)
			#tween1.tween_callback()
			tween1.finished.connect(func(): dialogue_complete = true)
		elif diag_mid == "empty" and diag_bot == "":
			print('spawn_top_box ee')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(top_box, "position", Vector2(top_box.position.x - 40, top_box.position.y - 20), 0.8)
			tween1.finished.connect(func(): dialogue_complete = true)
		else:
			print('spawn_top_box eee')
			tween1.set_ease(Tween.EASE_OUT)
			tween1.set_trans(Tween.TRANS_BACK)
			tween1.tween_property(           top_box, "position:x", top_box.position.x - 200, 0.8)
			tween1.parallel().tween_property(top_box, "position:y", top_box.position.y - 60, 0.8)
			tween1.finished.connect(func(): dialogue_complete = true)

		#top_box.modulate = Color.TRANSPARENT
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(top_box, "modulate:a", 0.92, 0.2)

	if (diag_top != ""):
		spawn_top_box.call()


	#TIMER
	var temp_timer = Timer.new()
	temp_timer.one_shot = true
	add_child(temp_timer)

	var top_len = len(diag_top)
	if top_len == 0: top_len = 1
	var delay = float(top_len) / 100.0

	delay = delay * 2950
	# minimum timer
	if delay < 1000 and delay != 0: delay = 1000
	if diag_mid == "":                delay = 200
	temp_timer.wait_time = delay / 1000.0
	temp_timer.start()
	temp_timer.timeout.connect(add_mid_box.bind(diag_mid, diag_bot))


# Add dialogue speech bubble.
func add_mid_box(diag_mid, diag_bot):
	if diag_mid != "":
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
		animate_text_prep(diag_mid, diag_bot)
	else:
		print('add bot box a')
		add_bot_box(diag_bot)

# Add bottom text box.
func add_bot_box(diag_bot):
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

func animate_text_prep(diag_mid, diag_bot):
	var dialogue_timer = Timer.new()
	text_index = 0
	dialogue_iteration(dialogue_timer, diag_mid, diag_bot, len(diag_mid))

func _mid_box_size_clamp():
	if mid_box.size.x > 400:
		mid_box.autowrap_mode = 3
		mid_box.size.x = 400

func dialogue_iteration(dialogue_timer, diag_mid, diag_bot, diag_length):
	if diag_length <= text_index:
		print('dialogue iteration time out!')
		dialogue_timer.queue_free()
		add_bot_box(diag_bot)
		return

	mid_box.text += diag_mid[text_index]

	realign_dialogue()

	mid_box.size = mid_box.get_theme_font("normal_font").get_string_size(mid_box.text) - Vector2(100, 0)
	#await get_tree().process_frame
	mid_box.size.y = 0

	# CHARACTER DELAY
	var delay = speech_delay(diag_mid[text_index])
	if last_character == "." or last_character == "!":
		delay = 400
	if last_character == "?":
		delay = 800

	# TIMER
	if dialogue_timer not in get_children():
		add_child(dialogue_timer)
	dialogue_timer.wait_time = float(delay) / 1000
	dialogue_timer.start()

	last_character = diag_mid[text_index]
	text_index += 1
	if not dialogue_timer.is_connected("timeout", dialogue_iteration):
		dialogue_timer.timeout.connect(dialogue_iteration.bind(dialogue_timer, diag_mid, diag_bot, len(diag_mid)))

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

func _on_start_combat():
	get_tree().change_scene_to_file("res://scenes/combat.tscn")

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
	var sky_blend_cs     = get_blend(2)
	var overlay_cs       = get_blend(3)
	var overlay_blend_cs = get_blend(4)

	# NEW BLEND SYSTEM
	var alpha = (1.0 / (max_TIME - min_TIME)) * (VarTests.TIME - min_TIME)
	sky_blend_cs.modulate.a     = alpha
	overlay_blend_cs.modulate.a = alpha
	overlay_cs.modulate.a       = 1 - overlay_blend.modulate.a

func create_weather():
	# RANDOMIZE CLOUDS
	var rnumb:int
	rnumb = floor(randf()*(1+3))+1
	clouds_a.texture = load("res://assets/images/sky/clouds%s.png" % [rnumb])
	clouds_a.modulate.a = randf()

	rnumb = floor(randf()*(1+3))+1
	clouds_b.texture = load("res://assets/images/sky/clouds%s.png" % [rnumb])
	clouds_b.modulate.a = randf()
