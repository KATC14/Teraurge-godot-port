extends Node

var tooltip
var saved_index = 'start'
var characters

@onready var gender_button  = $CanvasLayer/stats_control/Control/Button
@onready var flags_box      = $CanvasLayer/flags_control/PanelContainer
@onready var inventory_box  = $CanvasLayer/inventory_control/PanelContainer
@onready var characters_box = $CanvasLayer/characters_control/PanelContainer

@onready var player_name = $CanvasLayer/stats_control/Control2/VBoxContainer3/Control/ColorRect/LineEdit
@onready var money_krats = $CanvasLayer/stats_control/Control2/VBoxContainer/Control/ColorRect/LineEdit
@onready var money_adats = $CanvasLayer/stats_control/Control2/VBoxContainer2/Control/ColorRect/LineEdit

# stats
@onready var charisma     = $CanvasLayer/stats_control/Control/VBoxContainer/Control/ColorRect/LineEdit
@onready var will         = $CanvasLayer/stats_control/Control/VBoxContainer2/Control/ColorRect/LineEdit
@onready var intelligence = $CanvasLayer/stats_control/Control/VBoxContainer3/Control/ColorRect/LineEdit
#@onready var perception = $CanvasLayer/stats_control/Control/VBoxContainer4/Control/ColorRect/LineEdit
@onready var agility      = $CanvasLayer/stats_control/Control/VBoxContainer5/Control/ColorRect/LineEdit
@onready var strength     = $CanvasLayer/stats_control/Control/VBoxContainer6/Control/ColorRect/LineEdit
@onready var endurance    = $CanvasLayer/stats_control/Control/VBoxContainer7/Control/ColorRect/LineEdit

func _ready() -> void:
	characters = DirAccess.open("res://database/characters/").get_directories()
	var stupid = ['']
	stupid.append_array(characters)
	characters_box.choices = stupid
	#TEMP
	VarTests.player_stats['charisma'] = 8
	VarTests.player_stats['will']     = 8
	#TEMP
	# set stats
	player_name.text = VarTests.player_name
	money_krats.text = str(VarTests.player_A_money)
	money_krats.text = str(VarTests.player_B_money)

	charisma.text     = str(VarTests.player_stats['charisma'])
	will.text         = str(VarTests.player_stats['will'])
	intelligence.text = str(VarTests.player_stats['intelligence'])
	#perception.text  = VarTests.player_stats['perception']  
	agility.text      = str(VarTests.player_stats['agility'])
	strength.text     = str(VarTests.player_stats['strength'])
	endurance.text    = str(VarTests.player_stats['endurance'])

func _on_gender_pressed() -> void:
	if gender_button.text == 'male':
		gender_button.text = 'female'
		VarTests.player_gender = gender_button.text
	else:
		gender_button.text = 'male'
		VarTests.player_gender = gender_button.text


func _on_stats_save_pressed() -> void:
	VarTests.player_name    = player_name.text
	VarTests.player_A_money = int(money_krats.text)
	VarTests.player_B_money = int(money_krats.text)

	VarTests.player_stats['charisma']     = int(charisma.text)
	VarTests.player_stats['will']         = int(will.text)
	VarTests.player_stats['intelligence'] = int(intelligence.text)
	#VarTests.player_stats['perception']   = perception.text
	VarTests.player_stats['agility']      = int(agility.text)
	VarTests.player_stats['strength']     = int(strength.text)
	VarTests.player_stats['endurance']    = int(endurance.text)


func _on_character_selected(index: Variant) -> void:
	VarTests.character_name = characters[index-1]
	get_tree().change_scene_to_file("res://scenes/dialogue.tscn")

func _on_tooltip_hover(array, index):
	tooltip = load("res://scenes/tool_tip.tscn").instantiate()

	var character_indexes:Dictionary = VarTests.saved_indexs
	if character_indexes.has(array[index]):
		saved_index = character_indexes[array[index]]
	else:
		saved_index = 'start'
	tooltip.get_node("Label").text = 'Saved index: %s' % [saved_index]
	tooltip.visible = true
	self.add_child(tooltip)
	tooltip.move_to_front()

func _on_tooltip_exit(_array, _index):
	tooltip.visible = false
	tooltip.queue_free()
