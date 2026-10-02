extends Node2D

var stats_parsed
@onready var grid = $BoxContainer/GridContainer
@onready var light = $BoxContainer/Control/Button

func _input(_event: InputEvent) -> void:
	# debug functions
	if VarTests.debug_mode and not VarTests.main_menu_active and Input.is_action_pressed("Ctrl"):
		# debug menu
		if Input.is_action_just_released("key_d"):
			var theme = light.get_theme_stylebox("normal")
			theme.bg_color = '00ff00'
			light.add_theme_stylebox_override("normal", theme)
		if Input.is_action_just_pressed("key_d"):
			var theme = light.get_theme_stylebox("normal")
			theme.bg_color = 'ff0000'
			light.add_theme_stylebox_override("normal", theme)
			test()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Vector2.ZERO == Vector2(0, 0))
	VarTests.DISCOVERED_LOCATIONS.append('taodal')
	#print(VarTests.DISCOVERED_LOCATIONS)
	# taodal_entrance sejan_forest sejan_beach_driftwood
	var loc_name = 'sejan_forest'
	var stats_file = LoadStats.read_env_stats(loc_name)
	stats_parsed = DiagParse.begin_parsing(stats_file, 'encounters')
	#print('stats_parsed ', stats_parsed)
func test():
	#print('stats_parsed ', stats_parsed)
	if stats_parsed:
		var found = stats_parsed[0].find('curated_list')
		#print(found)
		if found != -1:
			#print('stats_parsed[2] ', stats_parsed[2])
			#print()
			var options_parsed = DiagParse.parse_options(stats_parsed[2])
			#print('options_parsed ', options_parsed)

			var index
			var index1
			var curated_list = stats_parsed[0].split(' ')[1]
			curated_list = "weighted"
			# CURATED LIST MODIFIER
			if curated_list == "random":
				index = randi_range(0, len(options_parsed[0])-1)
			# not used I guess?
			if curated_list == "weighted":
				var weight = range(len(options_parsed[0]))
				#weight.reverse()
				var rng = RandomNumberGenerator.new()
				#rng.randfn()
				index =  rng.rand_weighted(weight)

				weight = range(len(options_parsed[0]))
				weight.reverse()
				index1 = choice(weight)
				
				#print(allowed[3][index])
			if curated_list == "prioritized":
				index = 0

			var values = Showif.get_allowed(options_parsed[2])
			print('values  ', values[index])
			print('values1 ', values[index1])
			print()
			if not values[index]:
				print_rich('index  [color=red]%s[/color]' % options_parsed[3][index])
			if not values[index1]:
				print_rich('index1 [color=red]%s[/color]' % options_parsed[3][index1])
			print()
			print()
			#print()
				#if values.find(true) == -1:
					#var label = Label.new()
					#label.text = options_parsed[3][index]
					#grid.add_child(label)
func choice(population):
	var list_weights = []
	var weight_limit = 0
	var list_i = 0
	while list_i < len(population):
		var ium = (list_i+1) * 10

		weight_limit += ium
		list_weights.append(ium)
		list_i += 1

	list_weights.reverse()
	var random_weight = round(randf() * (weight_limit-1))
	var weight_i = 0
	var weight_iter = list_weights[0]

	while weight_iter < random_weight:
		weight_i += 1
		weight_iter += list_weights[weight_i]

	return weight_i
func choice1():
	var a = 'false'
	if a:
		print('huh')
