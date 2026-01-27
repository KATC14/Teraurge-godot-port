extends Button

signal activated(button:Button, label:Label)

func _pressed() -> void:
	#if is_hovered():
	var children = get_parent().get_children()#.map(func(child): if child is Label: return child)
	for i in children:
		if i is Button:
			children.erase(i)
	activated.emit(self, children[0])
