extends Control


@onready var tooltip = $Label
@export var pos_xy = Vector2(VarTests.stage_width, 0)

func _input(_event: InputEvent) -> void:
	var mouse_pos = get_global_mouse_position()

	# PLACEMENT
	tooltip.position.y = mouse_pos.y  - 10 - tooltip.size.y
	tooltip.position.x = mouse_pos.x + 20
	# SIZE
	tooltip.size = Vector2.ZERO
	#print('be ', tooltip.size)
	tooltip.size = Vector2(len(tooltip.text) if tooltip.size.x > 150 else 150, tooltip.size.y)
	#print('af ', tooltip.size)
	#print()
	if (tooltip.position.x + tooltip.size.x) > pos_xy.x:
		tooltip.position.x -= (tooltip.size.x + 20)
	if tooltip.position.x < 0:
		tooltip.position.x = 0
	# hack for making it stay on the left of the visible area
	## will not work if area changes
	#if (tooltip.position.x + tooltip.size.x) > width:
	#	tooltip.position.x = width
	# stay below top of screen
	if tooltip.position.y < pos_xy.y:
		tooltip.position.y = pos_xy.y
