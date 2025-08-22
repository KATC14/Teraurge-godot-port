extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var all_locations = VarTests.all_loc
	var distance = []
	var area:Area2D = VarTests.named_loc['sejan_witch_house']
	for i in all_locations:
		if i != area:
			var temp = area.position.distance_to(i.position)
			print(temp)
			distance.append(temp)
	#min()
