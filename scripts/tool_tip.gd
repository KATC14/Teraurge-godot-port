extends Control


@onready var tooltip = $Label
@export var width  = VarTests.stage_width
@export var height = 0

func _input(_event: InputEvent) -> void:
	var mouse_pos = get_global_mouse_position()

	# PLACEMENT
	tooltip.position.y = mouse_pos.y  - 10 - tooltip.size.y
	tooltip.position.x = mouse_pos.x + 20
	#print('width ', width)
	#print()
	#print((tooltip.position.x + tooltip.size.x))

	if (tooltip.position.x + tooltip.size.x) > width:
		#print(tooltip.position.x)
		tooltip.position.x -= (tooltip.size.x + 20)
	# hack for making it stay on the left of the visable area
	## will not work if area changes
	#if (tooltip.position.x + tooltip.size.x) > width:
	#	tooltip.position.x = width
	# stay below top of screen
	if tooltip.position.y < height:
		tooltip.position.y = height
	#print(tooltip.position.y)
	#print(tooltip.position.x)
