extends Node


signal leave_encounter
signal start_encounter(character_name)
signal change_sprite
signal create_picture(picture)
signal change_environment(new_env)
signal advance_time(forward)
signal change_diag(diag_file, index)
signal change_index(index)
signal curated_list(index)
signal start_combat
signal player_death


# DIALOGUE LOGIC HANDLER#================================================================================
func Logigier(index, logic: String):
	if logic.contains(','):
		for funk in logic.split(","):
			VarTests.last_index = index
			script_library(funk.strip_edges())
	else:
		print('logic 1 ', logic)
		script_library(logic.strip_edges())

func script_library(logic: String):
	var diag_file
	var s_index

	#VARIABLES
	var next_index: String = ""
	#var statement: String
	var slogic: Array

	#print('logic ', logic)
	#SPLIT STRING TO VARIABLES
	slogic = logic.split(" ")
	#print('slogic ', slogic)

	#EXTRA VARIABLES
	#var counter_match: int
	#var old_counter: String
	#var new_counter: String
	#var counter_number: int
	#var a_limit: int

	#EXECUTE LOGIC BASED ON VARIABLESS
	match slogic[0]:
		"pic":
			#story (story image)
			VarTests.has_story = true
			create_picture.emit(slogic[1])
			print('picture is here')
		"remove_pic":
			VarTests.has_story = false
			create_picture.emit()
		"change_sprite":
			VarTests.character_sprite = slogic[1]
			change_sprite.emit()
		"hide_character", "hide_sprite":
			VarTests.character_sprite.visible = false
		"change_default_sprite":
			#change_default_sprite (character) (sprite)
			VarTests.CHANGED_CHARACTERS[slogic[1]] = slogic[2]
		"magic":
			#change_default_sprite (character) (sprite)
			VarTests.ex_magic = true
# TODO add in sound
#		"play_sound":
			#play_sound (sound) (volume)
#			play_sound(slogic[1], Number(slogic[2]))
#		"play_contsound":
			#play_contsound (sound) (volume) (channel 1-2) (fade out) (fade in)
#			start_continuous_sound(slogic[1], Number(slogic[2]), int(slogic[3]), Number(slogic[4]), Number(slogic[5]))
#		"stop_contsound":
			#stop_contsound (channel 1-2) (fade out)
#			stop_contsound_2(slogic[1], slogic[2])
#		"start_music":
			#start_music (music) (volume) (fade out) (fade in) (no_loop)
#			start_music(slogic[1], Number(slogic[2]), Number(slogic[3]), Number(slogic[4]), slogic[5])
#		"stop_music":
			#start_music (fade out)
#			stop_music(Number(slogic[1]))
			#stop_music()
#		"change_env_sounds":
			#change_env_sounds (sound.volume-sound.volume)
#			var forced_audio_string:String = "<SOUNDS\n" + slogic[1] + "\nSOUNDS>"
#			forced_audio_string = forced_audio_string.replace('-', "\n")
#			load_env_sounds(forced_audio_string)
# Immediately changes the diag file
		"change_diag_file":
			#change_diag_file (file) (pointer)
			#VarTests.CHANGED_DIAGS[character_name] = slogic[1]
			diag_file = slogic[1]
			#IF CURRENT CHARACTER
			VarTests.has_story = false # important to set if exiting from a story section
#			advance_time.emit(0)#TODO add advance time function
			if slogic[2].strip_edges() != "":
				s_index = slogic[2].strip_edges()
			else:
				s_index = VarTests.last_index
			#load_dialogue_start()
			change_diag.emit(diag_file, s_index)
			#return "skip_dialogue_breaker"
# changes to the current default diag file
		"change_to_default_diag":
			#change_to_default_diag (pointer)
			if VarTests.CHANGED_DIAGS.has(VarTests.character_name):
				diag_file = VarTests.CHANGED_DIAGS[VarTests.character_name]
			else:
				diag_file = "diag"
			#IF CURRENT CHARACTER
			VarTests.has_story = false #important to set if exiting from a story section
			advance_time.emit(0)
			if slogic[1].strip_edges() != "":
				s_index = slogic[1].strip_edges()
			else:
				s_index = VarTests.last_index
			#load_dialogue_start()
			return [diag_file, s_index]
			#return "skip_dialogue_breaker"
#Changes the default diag file for the character
		"change_default_diag_file":
			#change_default_diag_file (character) (file)
			VarTests.CHANGED_DIAGS[slogic[1]] = slogic[2]
		"change_character":
			#change_character (new character)
			VarTests.character_name = slogic[1]
			#character_stats_loading()
			#override_index = VarTests.last_index
			#return "skip_dialogue_breaker"
		"change_environment":
			#change_environment (new environment)
			VarTests.environment_name = slogic[1]
			#change_env_load()
		"end_encounter":
			#end_conversation
			#if encounter is "blocking" push player to an earlier blip
		#	if get_substring("blocking:", "\r\n", VarTests.ENVIROMENT_STATS).strip_edges() == "yes":
		#		map_target = previous_map_target as MovieClip
			#VarTests.has_story = false #important to set if exiting from a story section
			#stage.focus = this
			leave_encounter.emit()
		"start_combat":
			#start_combat (lose_index) (win_index)
			#VarTests.has_story = false
			#VarTests.picture = ""
			#construct_scene()
			VarTests.lose_index = slogic[1]
			VarTests.win_index = slogic[2]
			#interface_layer.removeChild(dialogue_ui)
			start_combat.emit()
			#return "skip_dialogue_breaker"
# deprecated
#		"combat_damage":
			#combat_damage (character/player)(damage hitpoints)

#			if slogic[1] == "character":
#				character_hitpoints_damage += int(slogic[2])
#			else:
#				player_hitpoints_damage += int(slogic[2])
#		"combat_heal":
			#combat_heal (character/player)(damage hitpoints)

#			if slogic[1] == "character":
#				if character_hitpoints_damage > character_base_hitpoints:
#					character_hitpoints_damage = character_base_hitpoints
#				character_hitpoints_damage -= int(slogic[2])
#			else:
#				if player_hitpoints_damage > player_base_hitpoints:
#					player_hitpoints_damage = player_base_hitpoints
#				player_hitpoints_damage -= int(slogic[2])
#			if player_hitpoints_damage < 0:
#				player_hitpoints_damage = 0
		"save_index":
			#save_index (saved_index)
			#saves a conversation index
			VarTests.saved_indexs[VarTests.character_name] = slogic[1]
		"save_index_by_character":
			#save_index_by_character (character) (saved_index)
			#saves a conversation index for a specific character
			VarTests.saved_indexs[slogic[1]] = slogic[2]
		"start_encounter":
			#start_encounter (place) (character) (optional index)
			VarTests.has_story = false #important to set if exiting from a story section
			VarTests.environment_name = slogic[1]
			VarTests.character_name = slogic[2]
			if len(slogic) >= 4:
				VarTests.override_index = slogic[3]
			start_encounter.emit(slogic[2])
		"set_flag", "add_flag":
			#add_flag (flag name)
			var flaggys1: Array = slogic[1].split("-")
			for flag1 in flaggys1:
				if VarTests.FLAGS.find(flag1) == -1:
					VarTests.FLAGS.append(flag1)
		"remove_flag":
			#remove_flag (flag name)
			var flaggys2: Array = slogic[1].split("-")
			for flag2 in flaggys2:
				if VarTests.FLAGS.find(flag2) != -1:
					VarTests.FLAGS.remove_at(VarTests.FLAGS.find(flag2) + 1)
		"check_flag":
			#check_flag (flag name) (no flag pointer) (has flag pointer)
			if VarTests.FLAGS.find(slogic[1]) != -1:
				next_index = slogic[3]
			else:
				next_index = slogic[2]
			print('cf next_index ', next_index)
			print('cf next_index ', slogic)
			change_index.emit(next_index)
		"check_item":
			#check_flag (item name) (no flag pointer) (has flag pointer)
			if VarTests.ITEM_INVENTORY.find(slogic[1]) != -1:
				next_index = slogic[3]
			else:
				next_index = slogic[2]
		"check_stat":
			#check_stat (stat name) (number-number-number) (pointer1-pointer2-pointer2-pointer2)
			var stat_fences: Array = slogic[2].split("-")
			var pointer_goals: Array = slogic[3].split("-")
			var pointer_i: int = 0
			while VarTests.player_stats[slogic[1]] >= stat_fences[pointer_i]:
				pointer_i += 1
			next_index = pointer_goals[pointer_i]
		"give_card":
			#give_card (card name)
			VarTests.CARD_INVENTORY.append(slogic[1])
		"remove_card":
			#remove_card (card name)
			if VarTests.CARD_INVENTORY.find(slogic[1]) != -1:
				VarTests.CARD_INVENTORY.remove_at(VarTests.CARD_INVENTORY.find(slogic[1]) + 1)
		"give_item":
			#give_item (item name) (number of items)
			if len(slogic) == 3:
				var num_items:int = int(slogic[2])
				var add_items:int = 0
				while add_items < num_items:
					VarTests.ITEM_INVENTORY.append(slogic[1])
					add_items += 1
			else:
				VarTests.ITEM_INVENTORY.append(slogic[1])
		"remove_item":
			#remove_item (item name)
			if VarTests.ITEM_INVENTORY.find(slogic[1]) != -1:
				VarTests.ITEM_INVENTORY.remove_at(VarTests.ITEM_INVENTORY.find(slogic[1]) + 1)
		"give_money":
			# give_money adats/krats (amount)
			# check if the amount is a counter
			if int(slogic[2]):
				if VarTests.COUNTERS.has(slogic[2]):
					slogic[2] = VarTests.COUNTERS[slogic[2]]
				else:
					print("ERROR: give_money: specified counter not found")
			if slogic[1] == "adats":
				VarTests.player_A_money += int(slogic[2])
			if slogic[1] == "krats":
				VarTests.player_B_money += int(slogic[2])
		"take_money":
			#take_money adats/krats (amount)
			#check if the amount is a counter
			if int(slogic[2]):
				if VarTests.COUNTERS.find(slogic[1]) != -1 and VarTests.COUNTERS.find(slogic[1]) < 1:
					slogic[2] = VarTests.COUNTERS[slogic[1]]
				else:
					print("ERROR: give_money: specified counter not found")
			if slogic[1] == "adats":
				if VarTests.player_A_money <= int(slogic[2]):
					VarTests.player_A_money = 0
				else:
					VarTests.player_A_money -= int(slogic[2])
			if slogic[1] == "krats":
				if VarTests.player_B_money <= int(slogic[2]):
					VarTests.player_B_money = 0
				else:
					VarTests.player_B_money -= int(slogic[2])
		"sex_gate", "gender_gate", "sex_branch":
			#sex_branch (male pointer) (female pointer)
			if VarTests.player_gender == "male":
				next_index = slogic[1]
			if VarTests.player_gender == "female":
				next_index = slogic[2]
			change_index.emit(next_index)
		"rape_filter":
			#rape_filter (pointer1) (pointer2)
			if VarTests.RAPE_FILTER:
				next_index = slogic[1]
			else:
				next_index = slogic[2]
			change_index.emit(next_index)
		"feral_filter":
			#feral_filter (pointer1) (pointer2)
			if VarTests.FERAL_FILTER:
				next_index = slogic[1]
			else:
				next_index = slogic[2]
			change_index.emit(next_index)
		"gore_filter":
			#gore_filter (pointer1) (pointer2)
			if VarTests.GORE_FILTER:
				next_index = slogic[1]
			else:
				next_index = slogic[2]
			change_index.emit(next_index)
		"day_night_gate":
			#day_night_gate (day pointer) (night pointer)
			if VarTests.TIME >=  25 and VarTests.TIME < 75:
				#day
				next_index = slogic[1]
			else:
				#night
				next_index = slogic[2]
			print('dng next_index ', next_index)
			change_index.emit(next_index)
		"morn_day_eve_night_gate":
			#day_night_gate (morning pointer) (day pointer) (evening pointer) (night pointer)
			if VarTests.TIME >=  15 and VarTests.TIME < 30:
				#morning
				next_index = slogic[1]
			if VarTests.TIME >=  30 and VarTests.TIME < 70:
				#day
				next_index = slogic[2]
			if VarTests.TIME >=  70 and VarTests.TIME < 85:
				#evening
				next_index = slogic[3]
			if VarTests.TIME >=  85 || VarTests.TIME < 15:
				#night
				next_index = slogic[4]
			change_index.emit(next_index)
		"advance_time":
			#advance_time (time amount)
			advance_time.emit(int(slogic[1]))
		"advance_time_to":
			#advance_time (specified time)
			#IF "TIME" IS NOT A NUMBER
			match slogic[1]:
				"morning": slogic[1] = "28"
				"noon":    slogic[1] = "45"
				"evening": slogic[1] = "73"
				"night":   slogic[1] = "95"
			if slogic[1] == "0": logic[1] = "99"
			#Stops the normal process for the fade in/out
			#IF "TIME" IS A NUMBER
			if int(slogic[1]) != 0:
				if VarTests.TIME >= int(slogic[1]):
					slogic[1] = String((100 - VarTests.TIME) + int(slogic[1]))
				else:
					slogic[1] = String(int(slogic[1]) - VarTests.TIME)
			#advance_time_to = int(slogic[1])
			advance_time.emit(int(slogic[1]))
		"chance":
			#chance (percentage) (lose_pointer) (win_pointer)
			var randnum = randf() * 100
			if randnum < int(slogic[1]):
				next_index = slogic[3]
			else:
				next_index = slogic[2]
		"random_pointer":
			#random_pointer (pointer)-(pointer)-(pointer)-(pointer)-(pointer)...
			var random_pointers: Array = slogic[1].split("-")
			var r_pointer: String = random_pointers.pick_random()
			print('r_pointer ', r_pointer)
			change_index.emit(r_pointer)
		"discover_location":
			#discover_location (location)
			if VarTests.DISCOVERED_LOCATIONS.find(slogic[1]) == -1:
				VarTests.DISCOVERED_LOCATIONS.append(slogic[1])

		"remove_location":
			#remove_location (location)
			var found = VarTests.DISCOVERED_LOCATIONS.find(slogic[1])
			if found != -1:
				VarTests.DISCOVERED_LOCATIONS.remove_at(found + 1)
#TODO add ability for encounters to move player to location
#		"set_map_location":
			#set_map_location (location)
#			map_target = blips.getChildByName(slogic[1]) as MovieClip
#			previous_map_target = map_target as MovieClip
		"add_encounter":
			#add_encounter (location) (character)
			#REMOVE REMOVING
			if VarTests.CHANGED_ENCOUNTERS.has("%s.removed" % [slogic[1]]):
				var the_array: Array = VarTests.CHANGED_ENCOUNTERS["%s.removed" % [slogic[1]]]
				var found = the_array.find(slogic[2])
				if found != -1:
					the_array.remove_at(found + 1)
			#ADD ADDING
			if VarTests.CHANGED_ENCOUNTERS.has("%s.added" % [slogic[1]]):
				VarTests.CHANGED_ENCOUNTERS["%s.added" % [slogic[1]]] = [slogic[2]]
			else:
				VarTests.CHANGED_ENCOUNTERS["%s.added" % [slogic[1]]].append(slogic[2])
		"remove_encounter":
			#remove_encounter (location) (character)
			# REMOVE ADDING
			if VarTests.CHANGED_ENCOUNTERS.has("%s.added" % [slogic[1]]):
				var the_array: Array = VarTests.CHANGED_ENCOUNTERS["%s.added" % [slogic[1]]]
				var found = the_array.find(slogic[2])
				if found != -1:
					the_array.remove_at(found + 1)
			# ADD REMOVING
			if not VarTests.CHANGED_ENCOUNTERS.has("%s.removed" % [slogic[1]]):
				VarTests.CHANGED_ENCOUNTERS["%s.removed" % [slogic[1]]] = [slogic[2]]
			else:
				VarTests.CHANGED_ENCOUNTERS["%s.removed" % [slogic[1]]].append(slogic[2])
		"counter":
			#counter (counter name) (+/-) (number)
			#Adds or subtracts the counter
			print('counter ', VarTests.COUNTERS.has(slogic[1]))
			if VarTests.COUNTERS.has(slogic[1]):
				print('the counter ', VarTests.COUNTERS[slogic[1]])
				VarTests.COUNTERS[slogic[1]] = int(VarTests.COUNTERS[slogic[1]]) + int("%s%s" % [slogic[2], slogic[3]])
				print('the counter after ', VarTests.COUNTERS[slogic[1]])
				print('blank')
			else:
				VarTests.COUNTERS[slogic[1]] = 0
				VarTests.COUNTERS[slogic[1]] = int(VarTests.COUNTERS[slogic[1]]) + int("%s%s" % [slogic[2], slogic[3]])
				print('counter dddd ', int(VarTests.COUNTERS[slogic[1]]))
				print('counter cccc ', int("%s%s" % [slogic[2], slogic[3]]))
				print('counter tttt ', slogic[2])
				print('counter qqqq ', slogic[3])
				print('the counter add ', int(VarTests.COUNTERS[slogic[1]]) + int("%s%s" % [slogic[2], slogic[3]]))
				print('the set counter ', VarTests.COUNTERS[slogic[1]])
				print()
		"check_counter":
			#check_counter (counter name) (activation limit) (fail index) (check index)
			#Checks the counter
			if VarTests.COUNTERS.find(slogic[1]) != -1:
				if VarTests.COUNTERS[slogic[1]] >= slogic[2]:
					next_index = slogic[4]
				else:
					next_index = slogic[3]
			else: #IF NO COUNTER TREAT IT AS 0
				if 0 >= slogic[2]:
					next_index = slogic[4]
				else:
					next_index = slogic[3]
			#TEST THIS!!
		"remove_counter":
			#remove_counter.(counter name)
			var found = VarTests.COUNTERS.find(slogic[1])
			if found >= slogic[2]:
				VarTests.COUNTERS.remove_at(found + 1)
			#TEST THIS!!!
		"set_counter":
			#set_counter (counter name) (set number)
			#Adds or subtracts the counter


			if VarTests.COUNTERS.find(slogic[1]) != -1:

				VarTests.COUNTERS[slogic[1]] = int(slogic[2])
			else:
				VarTests.COUNTERS.append(slogic[1])
				VarTests.COUNTERS[slogic[1]] = int(slogic[2])
			#TEST THIS !!
		"check_discovery":
			#check_discovery.(place name).(not discovered index).(discovered index)
			#Checks for discovered location and steers conversation based on it

			if VarTests.DISCOVERED_LOCATIONS.find(slogic[1]) != -1:
				next_index = slogic[3]
			else:
				next_index = slogic[2]
			#should work ^

			#TESTED 2.6.2015
#TODO add shop
#		"start_shop":
			#start_shop (shop pointer) (pointer when exiting shop)

			#next_pointer = slogic[1]
#			s_index = slogic[1]
#			shop_exit_pointer = slogic[2]

			#START SHOP
#			start_shop()
#		"close_shop":
			#close_shop.(shop exit index)
			#Can be used to exit the shop to an alternative exit index
#			shop_exit_pointer = slogic[1]
#			close_shop_menu()
#		"disable_shop":
			#disable_shop.(next index)
			#Disables the shop screen and darkens it
#			disable_shop()
#			next_index = slogic[1]
#		"enable_shop":
			#enable_shop.(next index)
			#Enables the shop screen and removes darkening
#			enable_shop()
#			next_index = slogic[1]
#		"revert_last_shop_item":
			#revert_last_shop_item.(next index)
			#Reverts last handled shop item

#			revert_last_shop_item()
#			next_index = slogic[1]
		"player_death":
			#Player is killed and game opens the death screen
			player_death.emit()
#TODO add charater leave
#TODO add character return
#		"character_leave":
			#The present character will use a "leave_effect" tween and hide after dialouge bubble is completed.
#			character_leaves = true
#		"character_return":
			#character_return (sprite name)
			#The present character will change to the specified sprite and use a "return_effect" tween when the scene is created.
#			VarTests.character_sprite = slogic[1]
#			character_returns = true
#			scene_character = ""
		"add_timer":
			#add_timer (timer name) (days) trigger: (function & function)

			var timer_split: Array = logic.split("trigger:")

			#trace("TIMER ADDED: " + slogic[1] + "." + int(VarTests.DAYS+int(slogic[2])) + "." + timer_split[1]).strip_edges()
			var composite_timer:String = slogic[1] + "." + int(VarTests.DAYS+int(slogic[2])) + "." + timer_split[1].strip_edges()


			if VarTests.TIMERS.find(composite_timer) == -1:
				VarTests.TIMERS.append(composite_timer)
#deprecated
#		"hub_location":
			#hub_location
			#creates hub location buttons from the dialogue choices
#			hub_location = true
		#"curated_list":
			#curated_list (random/weighted/prioritized)
			#creates hub location buttons from the dialogue choices
		#	if curated_list == "":
		#		curated_list = slogic[1]
		#	else:
		#		curated_list_next = slogic[1]
		"curated_list":
			print()
			curated_list.emit(slogic[1])
		"auto_continue":
			#auto_continue (next index)
			# auto_continue hides the player responses and continues the dialogue with a mouse click.

			VarTests.auto_continue_pointer = slogic[1]
		"change_default_env_background":
			#change_default_env_background (environment name) (env name)
			change_environment.emit(slogic[2])
			VarTests.CHANGED_ENVIRONMENTS[slogic[1]] = slogic[2]
		"add_default_env_layer":
			#add_default_env_layer (environment name) (env name)
			change_environment.emit()

			if VarTests.CHANGED_ENVIRONMENTS.has(slogic[1]):
				VarTests.CHANGED_ENVIRONMENTS[slogic[1]] += "-"+slogic[2]
			else:
				VarTests.CHANGED_ENVIRONMENTS[slogic[1]] = "env-" + slogic[2]
			change_environment.emit(slogic[2])
		"test_func":
			leave_encounter.emit()
		_:
			# TODO add in error_message
			print("ERROR: Dialogue function: \"" + logic + "\" is not a valid scripting function.")
#			error_message("ERROR: Dialogue function: \"" + logic + "\" is not a valid scripting function.")
	return next_index
