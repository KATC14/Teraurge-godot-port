extends Button

signal activated(button:Button)

func _pressed() -> void:
	activated.emit(self)
