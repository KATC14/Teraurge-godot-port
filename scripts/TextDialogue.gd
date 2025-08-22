extends PanelContainer


@onready var choices_list = $MarginContainer/ScrollContainer/VBoxContainer
@onready var choice_prefab = $MarginContainer/ScrollContainer/VBoxContainer/Label

var choices:
	set(value):
		choices = value
		initLabel()

func initLabel():
	var label

	while choices_list.get_child_count() > 1:
		label = choices_list.get_child(choices_list.get_child_count() - 1)
		choices_list.remove_child(label)
		label.queue_free()

	for choice_index in range(choices.size()):
		if (choice_index == 0):
			choices_list.get_child(0).text = choices[choice_index]
		else:
			choices_list.add_child(choice_prefab.duplicate())
			choices_list.get_child(choice_index).text = choices[choice_index]
