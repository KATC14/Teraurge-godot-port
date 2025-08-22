extends Node


func check_for_showif(opt_parsed, full_string='empty'):
	# catch for option slash functions
	if not opt_parsed:
		return false

	var allowed = []
	for i in opt_parsed:
		var value
		if (i.find("showif") != -1):
			value = showif(i)

		#Unique to HIDEIF!! (REVERSED BOOLEAN)
		if (i.find("hideif") != -1):
			value = showif(i, full_string)
			value = not value

		allowed.append(value)
	# IF TRUE IN ARRAY -> HIDE (true)
	if allowed.find(true) == -1:
		pass# Do nothing
	else:
		return true

	#IF NO TRUE IN ARRAY -> UNHIDE (false)
	return false

func showif(logic, full_string='empty'):
	#VARIABLES
	#var diag_index
	var statement


	#SPLIT STRING TO VARIABLES
	#var loc = logic.find('//')
	#logic = logic.substr(loc+2)
	if not logic and logic == false:
		return false

	#LOGIC TO LOWERCASE
	logic = logic.to_lower()


	var s_logic = logic.split(".")
	statement = s_logic[1]
	var split1
	var split2
	#var split3
	#var split4
	if len(s_logic) >= 3: split1 = s_logic[2]
	if len(s_logic) >= 4: split2 = s_logic[3]
	#if len(s_logic) >= 5: split3 = s_logic[4]
	#if len(s_logic) >= 6: split4 = s_logic[5]

	#!
	#TRUE IS HIDDEN
	#FALSE IS UNHIDDEN
	#(for showif, reverse for hideif)
	#!

	match statement:
		#=====================================================================
		"clicked":
			#Hide if the option has been clicked previously
			#Hidden options must have a unique pointer in the current options list!

			#THIS MIGHT CAUSE PROBLEMS!! SHIT TESTING AND STRANGE CODE!!
			#Check showif censor and dialogue_functions for rest of the spaghetti.

			var fs_hash = full_string.md5_text()

			print('clicked char ', VarTests.character_name)
			print('clicked is it? ', VarTests.CLICKED_OPTIONS.has(VarTests.character_name))
			print('clicked full_string ', full_string)
			if VarTests.CLICKED_OPTIONS.has(VarTests.character_name):
				if VarTests.CLICKED_OPTIONS[VarTests.character_name].find(fs_hash) != -1:
					return false
				else:
					return true
			return false

			#TESTED: 2.12.2015
			#Works so far I guess. There might be rare problems with hash collision

		"debug":
			#Hide if debug mode is off

			if VarTests.debug_mode:
				return false
			else:
				return true

			#=====================================================================
		"note":
			#Will always hide the option
			return false
			#=====================================================================
#TODO add abilitiy to save game
#		"has_a_save":
			#Will show if if the player has a one or more savefiles

#			var SAVED_GAMES: Object = get_saved_games()
#			var how_many: int = 0

#			for key in SAVED_GAMES:
#				how_many += 1

#			if how_many > 0:
#				return false
#			else:
#				return true
			#=====================================================================
		"has_item":
			#has_item.(item name).(number of items, optional)


			var number_of_needed_items

			if split2:
				number_of_needed_items = int(split2)
			else:
				number_of_needed_items = 1

			#trace("number of items: " + count_instances(split1, ITEM_INVENTORY))

			if VarTests.ITEM_INVENTORY.count(split1) < number_of_needed_items:
				return true
			else:
				return false
			#=====================================================================

		"has_card":
			#has_card.(item name)

			if VarTests.CARD_INVENTORY.find(split1) == -1:
				return true
			else:
				return false
			#=====================================================================
		"has_flag":
			#has_flag.(flag name)

			if VarTests.FLAGS.find(split1) == -1:
				return true
			else:
				return false
			#=====================================================================
		"counter":
			#counter.(counter name).(minimum)

			#trace("counter: " + COUNTERS[split1] +" "+split2)

			print('counter is it working? ', VarTests.COUNTERS.has(split1))
			if VarTests.COUNTERS.has(split1):
				if VarTests.COUNTERS[split1] >= int(split2):
					return false
				else:
					return true
			else:
				return true

			#NOT TESTED
			#NOT TESTED
			#=====================================================================
		"has_stat":
			#has_stat.(stat name).(required amount)

			#THIS IS THE OLD STAT CHECK. HERE FOR COMPATIBILITY REASONS
			if VarTests.player_stats[split1] < int(split2):
				return true
			else:
				return false
			#=====================================================================
		"charisma", "will", "intelligence", "perception", "agility", "strength", "endurance":
			#(stat name).(required amount)
			print('has_stat stat ', VarTests.player_stats[statement])
			print('has_stat req ', int(split1))

			if VarTests.player_stats[statement] < int(split1):
				return true
			else:
				return false
			#=====================================================================
		"player_sex":
			#player_sex.(required gender)

			if VarTests.player_gender != split1:
				return true
			else:
				return false
			#=====================================================================
		"rape_filter_off":
			if VarTests.RAPE_FILTER:
				return true
			else:
				return false
			#=====================================================================
		"feral_filter_off":
			if VarTests.FERAL_FILTER:
				return true
			else:
				return false
			#=====================================================================
		"gore_filter_off":
			if VarTests.GORE_FILTER:
				return true
			else:
				return false
			#=====================================================================
		"time_filter":
			#time_filter.(more than time).(less than time)

			if int(split1) > int(split2):
				if VarTests.TIME > int(split1):
					return false
				if VarTests.TIME < int(split2):
					return false

			if VarTests.TIME > int(split1) && VarTests.TIME < int(split2):
				return false
			else:
				return true
		"has_discovered":
			if VarTests.DISCOVERED_LOCATIONS.find(split1) == -1:
				return true
			else:
				return false

			#TESTED: 2.6.2015
		"has_adats":
			if VarTests.player_A_money >= int(split1):
				return false
			else:
				return true
		"no_adats":
			if VarTests.player_A_money == 0:
				return false
			else:
				return true
		"has_krats":
			if VarTests.player_B_money >= int(split1):
				return false
			else:
				return true
		"no_krats":
			if VarTests.player_B_money == 0:
				return false
			else:
				return true
		"index_is":
			#trace ("current_index_is: "+  current_index)
			print('split1 ', split1)
			print('VarTests.current_index ', VarTests.current_index)
			print(VarTests.current_index, ' != ', split1, ' = ', VarTests.current_index != split1)
			if VarTests.current_index != split1:
				return true
			else:
				return false
			#=====================================================================
		_:
			return false
