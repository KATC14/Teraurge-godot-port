extends Node2D

# combat
var random_tries = 40
var player_turn = true
var player_base_hitpoints = VarTests.player_hitpoints
var player_health = player_base_hitpoints
var enemy_health = 0
var enemy_hand  = []
var enemy_deck:Array = []

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

var enemy_res_heat    = 0
var enemy_res_cold    = 0
var enemy_res_impact  = 0
var enemy_res_slash   = 0
var enemy_res_pierce  = 0
var enemy_res_magic   = 0
var enemy_res_bio     = 0

@onready var sprite = $CanvasLayer/Control/sprite          # character_layer
var stats_file
@onready var card             = load("res://assets/images/combat/card.png")
@onready var turn_dial_enemy  = load("res://assets/images/combat/turn_dial_enemy.png")
@onready var turn_dial_player = load("res://assets/images/combat/turn_dial_player.png")



# combat vars
@onready var card_empty        = load("res://assets/images/combat/card_empty.png")
@onready var CanLay            = $CanvasLayer
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

@onready var player_stat_cha_lbl  = $CanvasLayer/Control3/player_combat_ui/player_stat_cha_control/Label
@onready var player_stat_cha_tex  = $CanvasLayer/Control3/player_combat_ui/player_stat_cha_control/TextureRect
@onready var player_stat_will_lbl = $CanvasLayer/Control3/player_combat_ui/player_stat_will_control/Label
@onready var player_stat_will_tex = $CanvasLayer/Control3/player_combat_ui/player_stat_will_control/TextureRect
@onready var player_stat_int_lbl  = $CanvasLayer/Control3/player_combat_ui/player_stat_int_control/Label
@onready var player_stat_int_tex  = $CanvasLayer/Control3/player_combat_ui/player_stat_int_control/TextureRect

@onready var player_stat_agi_lbl = $CanvasLayer/Control3/player_combat_ui/player_stat_agi_control/Label
@onready var player_stat_agi_tex = $CanvasLayer/Control3/player_combat_ui/player_stat_agi_control/TextureRect
@onready var player_stat_str_lbl = $CanvasLayer/Control3/player_combat_ui/player_stat_str_control/Label
@onready var player_stat_str_tex = $CanvasLayer/Control3/player_combat_ui/player_stat_str_control/TextureRect
@onready var player_stat_end_lbl = $CanvasLayer/Control3/player_combat_ui/player_stat_end_control/Label
@onready var player_stat_end_tex = $CanvasLayer/Control3/player_combat_ui/player_stat_end_control/TextureRect


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

func _ready() -> void:
	VarTests.map_active = false
	stats_file = LoadStats.read_char_stats(VarTests.character_name)

	player_combat_ui.visible = true
	enemy_combat_ui.visible  = true
	player_combat_ui.position.x = -player_combat_ui.size.x
	enemy_combat_ui.position.x  = VarTests.stage_width + enemy_combat_ui.size.x

	if VarTests.scene_character != VarTests.character_name:
		MiscFunc.make_character()
	randomize_hand('player')
	set_enemy_stats()
	reset_stats('player')
	reset_stats('enemy')
	refresh_combat_ui('start')
	combat_ui_in()

func _on_btn_turn_dial_pressed() -> void:
	if player_turn:
		player_turn = false
		turn_dail.disabled = true
		turn_dail.get_parent().texture = turn_dial_enemy
		change_turn_to("enemy")

func set_enemy_stats():
	var stat_spit    = stats_file.split('\n')
	combat_stats["enemy_heat_res"]   = int(MiscFunc.parse_stat('heat_res', stat_spit))
	combat_stats["enemy_cold_res"]   = int(MiscFunc.parse_stat('cold_res', stat_spit))
	combat_stats["enemy_impact_res"] = int(MiscFunc.parse_stat('impact_res', stat_spit))
	combat_stats["enemy_slash_res"]  = int(MiscFunc.parse_stat('slash_res', stat_spit))
	combat_stats["enemy_pierce_res"] = int(MiscFunc.parse_stat('pierce_res', stat_spit))
	combat_stats["enemy_magic_res"]  = int(MiscFunc.parse_stat('magic_res', stat_spit))
	combat_stats["enemy_bio_res"]    = int(MiscFunc.parse_stat('bio_res', stat_spit))

	combat_stats["enemy_charisma"]     = int(MiscFunc.parse_stat('charisma', stat_spit))
	combat_stats["enemy_will"]         = int(MiscFunc.parse_stat('will', stat_spit))
	combat_stats["enemy_intelligence"] = int(MiscFunc.parse_stat('intelligence', stat_spit))
	combat_stats["enemy_agility"]      = int(MiscFunc.parse_stat('agility', stat_spit))
	combat_stats["enemy_strength"]     = int(MiscFunc.parse_stat('strength', stat_spit))
	combat_stats["enemy_endurance"]    = int(MiscFunc.parse_stat('endurance', stat_spit))
	enemy_health                    = int(MiscFunc.parse_stat('hitpoints', stat_spit))

	enemy_deck = Utils.get_substring('<cards', 'cards>', stats_file).strip_edges().split('\n')

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

#COMBAT AI
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
	if not attacks_timer.is_connected("ready", attack.call):
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

	refresh_combat_ui('reset')

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
			enemy_health -= combat_stats["enemy_hitpoints_damage"]
			blink_red(sprite, 0.7)
			shake(sprite)
			floating_text(sprite, str(damage_to_hitpoints), "#FF0000", 35)

		# PLAYER DAMAGE EFFECTS
		if target == "player":
			player_health -= combat_stats["player_hitpoints_damage"]
			shake(player_health_lbl)
			floating_text(player_health_lbl, str(damage_to_hitpoints), "#FF0000", 35)

		# Check if target dies from the hitpoints damage
		refresh_combat_ui('damage')
	else:
		# CHARACTER NO DAMAGE
		if target == "enemy":
			shake(sprite)
			floating_text(sprite, "No damage!", '#FFFFFF', 25)

@warning_ignore("unused_parameter")
func refresh_combat_ui(where):
	player_stat_cha_lbl.text  = str(VarTests.player_stats["charisma"]     - combat_stats["player_charisma_used"])
	player_stat_will_lbl.text = str(VarTests.player_stats["will"]         - combat_stats["player_will_used"])
	player_stat_int_lbl.text  = str(VarTests.player_stats["intelligence"] - combat_stats["player_intelligence_used"])

	player_stat_agi_lbl.text  = str(VarTests.player_stats["agility"]      - combat_stats["player_agility_used"])
	player_stat_str_lbl.text  = str(VarTests.player_stats["strength"]     - combat_stats["player_strength_used"])
	player_stat_end_lbl.text  = str(VarTests.player_stats["endurance"]    - combat_stats["player_endurance_used"])
	player_health_lbl.text    = str(player_health)


	var stat_spit = stats_file.split('\n')
	enemy_stat_cha_lbl.text   = str(int(MiscFunc.parse_stat('charisma', stat_spit))     - combat_stats["enemy_charisma_used"])
	enemy_stat_will_lbl.text  = str(int(MiscFunc.parse_stat('will', stat_spit))         - combat_stats["enemy_will_used"])
	enemy_stat_int_lbl.text   = str(int(MiscFunc.parse_stat('intelligence', stat_spit)) - combat_stats["enemy_intelligence_used"])

	enemy_stat_agi_lbl.text   = str(int(MiscFunc.parse_stat('agility', stat_spit))      - combat_stats["enemy_agility_used"])
	enemy_stat_str_lbl.text   = str(int(MiscFunc.parse_stat('strength', stat_spit))     - combat_stats["enemy_strength_used"])
	enemy_stat_end_lbl.text   = str(int(MiscFunc.parse_stat('endurance', stat_spit))    - combat_stats["enemy_endurance_used"])
	enemy_health_lbl.text     = str(enemy_health)

	if player_health <= 0:
		combat_ui_out()
		#_on_change_index(VarTests.lose_index)# HERE GOES PLAYER DEATH
		return
	if enemy_health  <= 0:
		combat_ui_out()
		#_on_change_index(VarTests.win_index)
		return

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
			blink_red(player_stat_cha_tex, 0.6)
			red_pointer(player_stat_cha_tex)
		"knowledge":
			#shake(player_stat_will)
			blink_red(player_stat_will_tex, 0.6)
			red_pointer(player_stat_will_tex)
		"intelligence":
			#shake(player_stat_int)
			blink_red(player_stat_int_tex, 0.6)
			red_pointer(player_stat_int_tex)
		"agility":
			#shake(player_stat_agi)
			blink_red(player_stat_agi_tex, 0.6)
			red_pointer(player_stat_agi_tex)
		"strength":
			#shake(player_stat_str)
			blink_red(player_stat_str_tex, 0.6)
			red_pointer(player_stat_str_tex)
		"endurance":
			#shake(player_stat_end)
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
	if not timer_red.is_connected("timeout", blk_red):         timer_red.timeout.connect(blk_red.call)
	if not timer_normal.is_connected("timeout", blink_normal): timer_normal.timeout.connect(blink_normal.call)
	if not timer.is_connected("timeout", end):                 timer.timeout.connect(end)

	timer.start()
	timer_normal.start()


func red_pointer(source_object):
	var txt_box = Label.new()
	txt_box.text = '<'
	txt_box.add_theme_color_override("font_color", Color.RED)
	txt_box.add_theme_font_size_override('font_size', 30)

	txt_box.position.x = source_object.position.x
	txt_box.position.y = (source_object.position.y + (source_object.size.y / 2)) - (txt_box.size.y / 2) - 2


	txt_box.position.x = 84


	player_combat_ui.add_child(txt_box)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(txt_box, "modulate:a", 0, 1.2)
	tween.finished.connect(txt_box.queue_free)

func play_card(attacker, the_card, target):
	var card_stats = Utils.get_substring('<%s' % the_card, '%s>' % the_card, VarTests.ALL_CARDS).strip_edges()

	var c_cost = int(MiscFunc.parse_stat('charisma_cost',     card_stats.split('\n')))
	var i_cost = int(MiscFunc.parse_stat('intelligence_cost', card_stats.split('\n')))
	var w_cost = int(MiscFunc.parse_stat('knowledge_cost',    card_stats.split('\n')))
	var a_cost = int(MiscFunc.parse_stat('agility_cost',     card_stats.split('\n')))
	var s_cost = int(MiscFunc.parse_stat('strength_cost',    card_stats.split('\n')))
	var e_cost = int(MiscFunc.parse_stat('endurance_cost',   card_stats.split('\n')))
	var h_cost = int(MiscFunc.parse_stat('hitpoints_cost',   card_stats.split('\n')))

	var cannot_afford = false
	var c_left = combat_stats["%s_charisma"     % attacker] - combat_stats["%s_charisma_used"     % attacker]
	var w_left = combat_stats["%s_will"         % attacker] - combat_stats["%s_will_used"         % attacker]
	var i_left = combat_stats["%s_intelligence" % attacker] - combat_stats["%s_intelligence_used" % attacker]
	var a_left = combat_stats["%s_agility"      % attacker] - combat_stats["%s_agility_used"      % attacker]
	var s_left = combat_stats["%s_strength"     % attacker] - combat_stats["%s_strength_used"     % attacker]
	var e_left = combat_stats["%s_endurance"    % attacker] - combat_stats["%s_endurance_used"    % attacker]

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

	var damage_to_hitpoints = 0
	damage_to_hitpoints += resolve_damage(heat_dmg,   "heat",   target)
	damage_to_hitpoints += resolve_damage(cold_dmg,   "cold",   target)
	damage_to_hitpoints += resolve_damage(impact_dmg, "impact", target)
	damage_to_hitpoints += resolve_damage(slash_dmg,  "slash",  target)
	damage_to_hitpoints += resolve_damage(p_dmg,      "pierce", target)
	damage_to_hitpoints += resolve_damage(m_dmg,      "magic",  target)
	damage_to_hitpoints += resolve_damage(b_dmg,      "bio",    target)
	damage_to_hitpoints += h_dmg

	if attacker == "enemy":
		floating_text(sprite, the_card, '#FF9933', 25)
		attack_effect(sprite)
		damage(damage_to_hitpoints, "player")
	if attacker == "player":
		#Float text
		#Effect
		damage(damage_to_hitpoints, "enemy")
	refresh_combat_ui('play_card')
	return true

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

var repeat = 0
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
	txt_box.position.y = (source_object.position.y + (source_object.size.y / 2)) - (txt_box.size.y / 2)


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
	var fc #front character

	if attribute_cost > 0:
		effect_number = abs(attribute_cost)
		effect_color = Color.RED
		fc = 0
	if attribute_cost < 0:
		effect_number = abs(attribute_cost)
		effect_color = Color.GREEN
		fc = 0

	if attribute_cost != 0:
		if payer == "player":
			match attribute_stat:
				"charisma":     stat_float(player_stat_cha_lbl, str(fc + effect_number), effect_color, 24, payer)
				"will":         stat_float(player_stat_will_lbl, str(fc + effect_number), effect_color, 24, payer)
				"intelligence": stat_float(player_stat_int_lbl, str(fc + effect_number), effect_color, 24, payer)

				"agility":      stat_float(player_stat_agi_lbl, str(fc + effect_number), effect_color, 24, payer)
				"strength":     stat_float(player_stat_str_lbl, str(fc + effect_number), effect_color, 24, payer)
				"endurance":    stat_float(player_stat_end_lbl, str(fc + effect_number), effect_color, 24, payer)

		if payer == "enemy":
			match attribute_stat:
				"charisma":     stat_float(enemy_stat_cha_lbl, str(fc + effect_number), effect_color, 24, payer)
				"will":         stat_float(enemy_stat_will_lbl, str(fc + effect_number), effect_color, 24, payer)
				"intelligence": stat_float(enemy_stat_int_lbl, str(fc + effect_number), effect_color, 24, payer)

				"agility":      stat_float(enemy_stat_agi_lbl, str(fc + effect_number), effect_color, 24, payer)
				"strength":     stat_float(enemy_stat_str_lbl, str(fc + effect_number), effect_color, 24, payer)
				"endurance":    stat_float(enemy_stat_end_lbl, str(fc + effect_number), effect_color, 24, payer)

	return attribute_cost

# RESOLVE_DAMAGE
@warning_ignore("shadowed_variable")
func resolve_damage(damage, resistance_name, target):
	var actual_damage:int = 0

	var resistance = int(combat_stats["%s_%s_res" % [target, resistance_name]])

	if resistance < 0:
		#negative resistance amplified damage
		actual_damage = damage + (~(resistance)+1)
	else:
		#normal damage
		actual_damage =  damage - resistance

	if actual_damage < 0:
		actual_damage = 0

	#ADD RESISTANCE EFFECT
		#Damage number floating from resistance
		#If 0 then different color

	return actual_damage


func card_clicked(attacker, used_card, target):
	#used_card.visible = false
	var the_card = used_card.text.replace(' ', '_').to_lower()
	if play_card(attacker, the_card, target):
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
