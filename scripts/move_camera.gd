extends Camera2D

#func _ready() -> void:
#	make_current()
var dragging
@export  var is_active = true

func _input(event:InputEvent):
	# zoom ability might or might be disabled
	if event is InputEventMouseButton:
		if Input.is_action_just_released('mouse_wheel_up'):
			zoom.x += 0.25
			zoom.y += 0.25
		elif Input.is_action_just_released('mouse_wheel_down') and zoom.x > 1 and zoom.y > 1:
			zoom.x -= 0.25
			zoom.y -= 0.25
	if is_active:
		if event is InputEventMouseButton:
			if Input.is_action_pressed("mouse_left"):
				dragging = true
			else:
				dragging = false
		elif event is InputEventMouseMotion and dragging:
			position -= event.relative
			if position.x <= 640:  position.x = 640
			if position.y <= 360:  position.y = 360

			if position.x >= 7552: position.x = 7552
			if position.y >= 7832: position.y = 7832
