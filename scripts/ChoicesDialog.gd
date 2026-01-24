extends PanelContainer


# https://www.youtube.com/watch?v=AkrkcFhJcYs

signal SELECTED(index)
signal ENTER(index)
signal EXIT(index)

@onready var choices_list = $MarginContainer/ScrollContainer/VBoxContainer
@onready var choice_prefab = $MarginContainer/ScrollContainer/VBoxContainer/Button

var choices:
	set(value):
		choices = value
		initButtons()

# Called when the node enters the scene tree for the first time.
#func _ready():
#	choices_list.get_child(0).pressed.connect(onChoice.bind(0))
#	choices_list.get_child(0).mouse_entered.connect(onEntered.bind(choices, 0))
#	choices_list.get_child(0).mouse_exited.connect(onExited.bind(choices, 0))
#func _process(delta: float) -> void:

func initButtons():
	var button

	while choices_list.get_child_count() > 1:
		button = choices_list.get_child(choices_list.get_child_count() - 1)
		choices_list.remove_child(button)
		button.queue_free()

	for choice_index in range(choices.size()):
		if (choice_index == 0):
			choices_list.get_child(0).text = choices[choice_index]
			if not choices_list.get_child(choice_index).is_connected('pressed', onChoice):
				choices_list.get_child(choice_index).pressed.connect(onChoice.bind(choice_index))
				choices_list.get_child(choice_index).mouse_entered.connect(onEntered.bind(choices, choice_index))
				choices_list.get_child(choice_index).mouse_exited.connect(onExited.bind(choices, choice_index))
		else:
			choices_list.add_child(choice_prefab.duplicate())
			choices_list.get_child(choice_index).text = choices[choice_index]
			choices_list.get_child(choice_index).pressed.connect(onChoice.bind(choice_index))
			choices_list.get_child(choice_index).mouse_entered.connect(onEntered.bind(choices, choice_index))
			choices_list.get_child(choice_index).mouse_exited.connect(onExited.bind(choices, choice_index))

func onChoice(choice_index):
	SELECTED.emit(choice_index)
@warning_ignore("shadowed_variable")
func onEntered(choices, choice_index):
	ENTER.emit(choices, choice_index)
@warning_ignore("shadowed_variable")
func onExited(choices, choice_index):
	EXIT.emit(choices, choice_index)
