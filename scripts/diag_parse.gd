extends Node


func clean_diag(data):
	var re = RegEx.new()
	var re1 = RegEx.new()
	re.compile('>>.*')
	re1.compile('[\r\t]')

	data = re.sub(data, '', true)
	data = re1.sub(data, '', true)
	data = '||\n%s' % data
	var data1:Array = data.split('||')
	data1.map(func(item):
		item = item.strip_edges()
		if item != '':
			return item
	)
	return data1

func get_chunk(file:Array, start_index:String):
	var found = Utils.array_find(file, '{%s' % start_index)
	if found != -1:
		return file[found].strip_edges()
	return

func index_position(chunk, index):
	if chunk != null:
		var temp = chunk.split('\n')
		for i in range(len(temp)):
			if index in temp[i]:
				return i
		return -1
	else:
		return null


func parse_options(opt_array) -> Array[Array]:
	var index = []
	var function = []
	var options = []
	var clicfunc = []
	for i in opt_array:
		if i.substr(1).find(']') == -1:
			i = '[%s] %s' % [i, i]
		var temp = i.substr(1).split(']')
		options.append(temp[1].split('//')[0].strip_edges())
		if '|' in temp[0]:
			var temp1 = temp[0].split('|')
			if temp1[0].strip_edges():
				index.append(temp1[0].strip_edges())
			else:
				index.append(false)
			function.append(temp1[1].strip_edges())
		else:
			function.append(false)
			index.append(temp[0].strip_edges())
		var temp2:Array = temp[1].strip_edges().split('//')
		if len(temp2) > 1:
			temp2.remove_at(0)
			var optfunc = []
			for x in temp2:
				optfunc.append(x.strip_edges())
			clicfunc.append(optfunc)
		else:
			clicfunc.append(false)
	return [index, function, clicfunc, options]

func parse_chunk(chunk):
	var data = chunk.split('{')
	#data1 = []
	var indfunc = []
	var diagopt = []
	for i in data:
		if i and i != '\n':
			var temp = i.split('}')
			indfunc.append(temp[0].strip_edges())
			diagopt.append(temp[1].strip_edges())
	var index    = []
	var function = []
	for i in indfunc:
		if '|' in i:
			var temp = i.split('|')
			index.append(temp[0].strip_edges())
			function.append(temp[1].strip_edges())
		else:
			index.append(i.strip_edges())
			function.append(false)
	var dialogue = []
	var options  = []
	for i in diagopt:
		var temp = i.split('\n')
		if len(temp) <= 1:
			for x in temp:
				dialogue.append(x)
		else:
			# fix for environment file
			if temp[0].begins_with('['):
				dialogue.append(false)
			else:
				dialogue.append(temp[0])
			for x in range(Utils.array_find(temp, '['), len(temp)):
				options.append(temp[x].strip_edges())
	return [index, function, dialogue, options]

func begin_parsing(data, start_index):
	var diag_file:Array = clean_diag(data)
	var chunk = get_chunk(diag_file, start_index)
	var pos = index_position(chunk, '{%s' % start_index)
	if pos != null:
		var parsed = parse_chunk(chunk)
		return [parsed[0], parsed[1][pos], parsed[2][pos], parsed[3]]
	else:
		return null
