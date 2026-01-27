extends Node


func read_char_stats(character_name):
	var path = 'res://database/characters/%s/stats.txt' % character_name
	if not FileAccess.file_exists(path):
		return

	var stat_file = Utils.load_file(path)
	return stat_file.to_lower()
	#var default_env
	#var text_color = 'FFFFFF'
	#var bubble_color = '000000'

	#for line in stat_file.split('\n'):
	#	if line.contains('default_env'): default_env  = line.split(':')[1].strip_edges()
	#	if line.contains('text_color'): text_color   = line.split(':')[1].strip_edges()
	#	if line.contains('bubble_color'): bubble_color = line.split(':')[1].strip_edges()
	#return [default_env, text_color, bubble_color]

func read_env_stats(environment_name):
	var path = 'res://database/environments/%s/stats.txt' % environment_name
	if not FileAccess.file_exists(path):
		return

	var stat_file = Utils.load_file(path)
	return stat_file.to_lower()

func parse_env_vars(stats_file):
	#opt_array = re.sub('>>.*', '', opt_array)
	var re = RegEx.new()
	re.compile('[\r\t]')
	stats_file = re.sub(stats_file, '', true)
	var thespt:Array = stats_file.split('\n')

	var wanted = [
		'interior', 'ambient_color', 'ambient', 
		'discoverable', 'dicovery_message', 'default_message', '{encounters'
	]

	var result = []
	for i in wanted:
		for x in thespt.filter(func(item): if i in item: return item):
			result.append(x)

	return result#.map(func (item): return item)
