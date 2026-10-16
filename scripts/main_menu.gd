extends Node2D


@onready var fade_in    = $CanvasLayer/TextureRect
@onready var CanLay     = $CanvasLayer
@onready var death_back = $CanvasLayer/TextureRect2
@onready var warn       = $CanvasLayer/Control
@onready var menu       = $CanvasLayer/Control2
@onready var vrsn_label = $CanvasLayer/Control2/Label

@onready var stn_menu    =  load("res://scenes/save_menu.tscn")
var settings

func _ready() -> void:
	VarTests.main_menu_active = true
	vrsn_label.text = str(VarTests.version)

	settings = stn_menu.instantiate()
	CanLay.add_child(settings)

	match VarTests.menu_state:
		'warning':
			warn.visible = true
			menu.visible = false
		'death':
			menu.visible        = false
			warn.visible        = false
			death_back.modulate = Color.TRANSPARENT
			death_back.visible  = true

			var death_fade_out = func():
				var tween_DI = create_tween()
				tween_DI.set_ease(Tween.EASE_IN)
				tween_DI.set_trans(Tween.TRANS_QUART)
				tween_DI.tween_property(death_back, "modulate:a", 0, 5)
				tween_DI.finished.connect(warning_end)

				var tween1 = create_tween()
				tween1.set_ease(Tween.EASE_IN)
				tween1.set_trans(Tween.TRANS_QUART)
				tween1.tween_property(fade_in, "modulate:a", 1, 4)

			var tween_DO = create_tween()
			tween_DO.set_ease(Tween.EASE_IN_OUT)
			tween_DO.set_trans(Tween.TRANS_BOUNCE)
			tween_DO.tween_property(death_back, "modulate:a", 1, 0.6)
			tween_DO.finished.connect(death_fade_out)
		_:
			warn.visible = false
			menu.visible = true

# MAIN MENU
func warning_end():
	MiscFunc.menu_slide(menu, Vector2.ZERO, 0.7)
	warn.visible = false

# warning fade
func _on_button_warning_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(warn, "position", Vector2(0, -100), 0.2)
	tween.parallel().tween_property(warn, "modulate:a", 0, 0.3)
	tween.finished.connect(warning_end)

func _on_button_new_game_pressed() -> void:
	var tween = MiscFunc.menu_slide(menu, Vector2.ZERO, 0.7)
	var ng_menu = $CanvasLayer/Control4

	ng_menu.visible = false
	var temp = func():
		MiscFunc.menu_slide(ng_menu, Vector2.ZERO, 0.8)
		menu.visible = false
	tween.finished.connect(temp.call)

func _on_button_load_pressed() -> void:
	var tween = MiscFunc.menu_slide(menu, Vector2.ZERO, 0.7)
	var temp = func():
		menu.visible = false
		MiscFunc.menu_slide(settings.get_node_or_null('load_menu'), Vector2.ZERO, 0.7)
	tween.finished.connect(temp.call)

func _on_button_devblog_pressed() -> void:
	OS.shell_open("http://teraurge.blogspot.com/")

func _on_button_patreon_pressed() -> void:
	OS.shell_open("http://www.patreon.com/meandraco")
