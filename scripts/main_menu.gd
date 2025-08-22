extends CanvasLayer


@onready var fade_in    = $TextureRect
@onready var death_back = $TextureRect2
@onready var warn       = $Control
@onready var menu       = $Control2
@onready var load_menu  = $Control3
@onready var vrsn_label = $Control2/Label
@onready var save_label = $Control3/Label
@onready var new_game   = load("res://scenes/new_game.tscn")

@onready var choicesDialog = $Control3/PanelContainer

var saves

func _ready() -> void:
	vrsn_label.text = str(VarTests.version)
	if VarTests.menu_state == 'warning':
		warn.visible = true
		menu.visible = false
	elif VarTests.menu_state == 'death':
		menu.visible        = false
		warn.visible        = false
		death_back.modulate = Color.TRANSPARENT
		death_back.visible  = true

		var death = func():
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_QUART)
			tween.tween_property(death_back, "modulate:a", 0, 5)
			tween.finished.connect(warning_end)

			var tween1 = create_tween()
			tween1.set_ease(Tween.EASE_IN)
			tween1.set_trans(Tween.TRANS_QUART)
			tween1.tween_property(fade_in, "modulate:a", 1, 4)

		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(death_back, "modulate:a", 1, 0.6)
		tween.finished.connect(death)
	else:
		warn.visible = false
		menu.visible = true

# TWEENS
func menu_tween_up(node):
	node.position.y = 720
	node.modulate = Color.TRANSPARENT
	node.visible = true
	var tween = create_tween()
	tween.tween_property(node, "position", Vector2(0, 0), 0.7)
	tween.parallel().tween_property(node, "modulate:a", 255, 0.5)
	return tween

func menu_tween_down(node):
	node.position.y = 0
	var tween = create_tween()
	tween.tween_property(node, "position", Vector2(0, 720), 0.5)
	tween.parallel().tween_property(node, "modulate:a", 0, 0.7)
	return tween

# MAIN MENU
func warning_end():
	menu_tween_up(menu)
	warn.visible = false

# warning fade
func _on_button_warning_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(warn, "position", Vector2(0, -100), 0.2)
	tween.parallel().tween_property(warn, "modulate:a", 0, 0.3)
	tween.finished.connect(warning_end)

func _on_button_new_game_pressed() -> void:
	var tween = menu_tween_down(menu)
	var ng_menu = new_game.instantiate()
	ng_menu.visible = false
	add_child(ng_menu)
	var temp = func():
		menu.visible = false
		ng_menu.position.y = 720
		ng_menu.visible = true
		var tween1 = create_tween()
		tween1.tween_property(ng_menu, "position", Vector2(0, 0), 0.7)
	tween.finished.connect(temp.call)

func _on_button_load_pressed() -> void:
	saves = ['save 1', 'save 2']
	choicesDialog.visible = true
	choicesDialog.choices = saves
	var tween = menu_tween_down(menu)
	var temp = func():
		menu.visible = false
		menu_tween_up(load_menu)
	tween.finished.connect(temp.call)

func _on_button_devblog_pressed() -> void:
	OS.shell_open("http://teraurge.blogspot.com/")

func _on_button_patreon_pressed() -> void:
	OS.shell_open("http://www.patreon.com/meandraco")

# MM LOAD MENU
func _on_panel_container_selected(index: Variant) -> void:
	pass # Replace with function body.
	var save = saves[index]
	print('save index ', index)
	print('save ', save)
	save_label.text = save

func _on_button_mm_load_pressed() -> void:
	pass # Replace with function body.

func _on_button_mm_delete_pressed() -> void:
	pass # Replace with function body.

func _on_button_mm_back_pressed() -> void:
	menu_tween_up(menu)
	var tween = menu_tween_down(load_menu)
	tween.finished.connect(func(): load_menu.visible = false)
