extends Button

signal activated(button:Button)

func _input(_event: InputEvent) -> void:
	if is_hovered():
		if Input.is_action_pressed("mouse_left"):
			activated.emit(self)
