extends Node


func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	return f.get_as_text()



func get_substring(start, end, data:String):
	data = data.to_lower()
	var start_index = data.find(start) + len(start)
	var end_index = data.substr(start_index).find(end) - 1

	# IF SUBSTRING NOT FOUNG RETURN NOTHING
	if start_index == -1 and end_index == -1:
		return ""

	if start_index == -1:
		start_index = 0

	if end_index == -1 or end_index == 0:
		end_index = len(data)

	# commented out for misbehavior
	#if end_index < start_index:
	#	var full_string_chopped = data.substr(start_index, len(data))
	#	end_index = full_string_chopped.find(end) - 1 + start_index

	#if end_index < start_index:
	#	end_index = len(data)

	return data.substr(start_index, end_index).strip_edges()

func array_find(clean_chunk:Array, item) -> int:
	for i:int in range(len(clean_chunk)):
		if item in clean_chunk[i]:
			return i
	return -1

func items(dict:Dictionary):
	var data = []
	for i in range(len(dict.keys())):
		data.append([dict.keys()[i], dict.values()[i]])
	return data


func array_zip(ary):
	var ary_lens = []
	for i in ary:
		ary_lens.append(len(i))

	for i in range(len(ary)):
		while len(ary[i]) < ary_lens.max():
			ary[i].append(null)

	var test = []
	for i in range(ary_lens.max()):
		var test1 = []
		for x in ary:
			test1.append(x[i])
		test.append(test1)
	return test
