extends Node2D

@onready var stn_menu     = load("res://scenes/save_menu.tscn")
@onready var blips = $CanvasLayer/blips

@onready var CanLay     = $CanvasLayer
var settings

func _ready() -> void:
	var json_string = Utils.load_file('saves.json')
	var json = JSON.new()
	json.parse(json_string)
	print(json.data['saved_games'])
