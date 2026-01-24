extends LineEdit

signal text_submit(textNode:LineEdit)
signal text_changed_sub(textNode:LineEdit)

func _input(_event: InputEvent) -> void:
	if is_editing():
		if Input.is_action_pressed("ui_text_submit"):
			text_submit.emit(self)


func _on_text_changed(_new_text: String) -> void:
	text_changed_sub.emit(self)
