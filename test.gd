extends Node2D

var text_index
var bubble_tween
var hurry_dialogue
var last_character
var dialogue_complete
var character_bg_color      = Color('000000')
var character_font_color    = Color('FFFFFF')
@onready var dialogue_timer = %dialogue_timer
@onready var sprite         = $CanvasLayer/Control/character_layer/sprite# sprite

@onready var top_box        = $CanvasLayer/dialogue_boxes/top_box
@onready var mid_box        = $CanvasLayer/dialogue_boxes/mid_box
@onready var bot_box        = $CanvasLayer/dialogue_boxes/bot_box

@onready var timerr         = $CanvasLayer/Timer
@onready var timerr_time    = $CanvasLayer/Label

var first = ["","Oh my gods! Not again!", "At first, it looks like a woman with thickly powdered skin wearing some costume, but the way she wags her tail and moves her inhumanly thin legs convince you otherwise.<br><br>A long, thin tongue snaps from the bottom of what you thought was a mask. Suddenly it hits you, you are in front of some non-human monster."]
var second = ["You dash towards the nearest door. You reach for the door handle, but before you manage to touch it, an invisible force stops you. You're dragged back to the spot you started.", "Look, I'm sorry about all this, but please calm down. I'm not going to hurt you.", "She taps the floor with her staff, and the force holding you disappears."]
var third = ["", "Calm down! It's okay! C'mon! We are just going to talk. You're safe!<br><br>Take deep breaths.", ""]
func _process(delta: float) -> void:
	timerr_time.text = str(timerr.time_left)

func _ready() -> void:
	make_dialogue(first)
	timerr.start()

func _mid_box_size_clamp():
	if mid_box.size.x > 400:
		mid_box.autowrap_mode = 3
		mid_box.size.x = 400

func make_dialogue(speech:Array):
	hurry_dialogue = false
	var top = ''
	var mid = ''
	var bot = ''
	# clear active text
	top_box.size.x = 17
	mid_box.size.x = 17
	bot_box.size.x = 17
	top_box.text = ''
	mid_box.text = ''
	bot_box.text = ''
	bot_box.autowrap_mode = 0
	mid_box.autowrap_mode = 0

	size_hack()

	hide_dialogue_boxes()
	# prep bbcode
	speech = speech.map(func(item): return Utils.mass_replace(item, {'<br>':'\n', '<b>':'[b]', '</b>':'[/b]', '-name-':VarTests.player_name}).strip_edges())

	print('len(speech) ', len(speech))
	if len(speech) >= 1: top = speech[0]
	if len(speech) >= 2: mid = speech[1]
	if len(speech) >= 3: bot = speech[2]
	add_top_box(top, mid, bot)

func hide_dialogue_boxes(): ## My func.
	# hides visible boxes
	top_box.visible = false
	mid_box.visible = false
	bot_box.visible = false

func size_hack():
	# hacky ass way or forcing the stupid box to the right size
	var tempp = func():
		for i in [top_box, mid_box, bot_box]:
			i.size.y = 0
	var a = Timer.new()
	add_child(a)
	a.one_shot = true
	a.wait_time = 0.001
	a.timeout.connect(tempp)
	a.start()
	#a.timeout.emit()


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
		#if dialogue_complete and VarTests.auto_continue_pointer == '':
		#	enable_dialogue_options('B')

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
	# I dont think I can add this because I dont serperate create a new scene from changing dialogue file (change_diag)
	# create scene fade in
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(fade_in, "modulate:a", 0, 2)
	#tween.finished.connect(func(): fade_in.visible = false)

	mid_box.add_theme_color_override("default_color", character_font_color)

	var diag_b_color = StyleBoxFlat.new()
	diag_b_color.bg_color = character_bg_color
	diag_b_color.border_color = character_bg_color
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
	mid_box.position.x = sprite_pos * 0.2 - mid_box.size.x - 20
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
	#if VarTests.auto_continue_pointer == '':
	#	enable_dialogue_options('A')
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

func animate_text_prep(diag_mid, diag_bot):
	text_index = 0
	bot_box.visible = false
	# I wish I could just use visible_ratio...
	var dialogue_timer_new = Timer.new()
	dialogue_timer_new.autostart = true
	dialogue_timer_new.one_shot = true
	add_child(dialogue_timer_new)
	if     dialogue_timer.timeout.is_connected(add_mid_box): dialogue_timer.timeout.disconnect(add_mid_box)
	bot_box.text = ''
	dialogue_iteration(diag_mid, diag_bot, len(diag_mid), dialogue_timer_new)


func dialogue_iteration(diag_mid, diag_bot, diag_length, dialogue_timer_new):
	if diag_length <= text_index:
		print('dialogue iteration time out!')
		dialogue_timer_new.stop()
		dialogue_timer_new.queue_free()
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
		text_index = 0
		dialogue_timer_new.stop()
		dialogue_timer_new.queue_free()
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
	dialogue_timer_new.wait_time = delay
	#print('dialogue_timer.dialogue_timer ', dialogue_timer.wait_time)
	dialogue_timer_new.start()

	last_character = diag_mid[text_index]
	text_index += 1

	# start function loop
	if not dialogue_timer_new.timeout.is_connected(dialogue_iteration):
		dialogue_timer_new.timeout.connect(dialogue_iteration.bind(diag_mid, diag_bot, len(diag_mid), dialogue_timer_new))

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

var again = 0
func _on_timer_timeout() -> void:
	if again == 0:
		again = 1
		make_dialogue(second)
	elif again == 1:
		timerr.stop()
		make_dialogue(third)
