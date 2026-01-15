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
	print('environment_name ', environment_name)
	var path = 'res://database/environments/%s/stats.txt' % environment_name
	print('file path ', FileAccess.file_exists(path))
	if not FileAccess.file_exists(path):
		return

	var stat_file = Utils.load_file(path)
	return stat_file.to_lower()
