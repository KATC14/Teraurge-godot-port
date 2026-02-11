extends Node2D

@onready var test = $TextureRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var t = Timer.new()
	t.one_shot = true
	add_child(t)
	t.wait_time = 5
	t.timeout.connect(shop_menu_slide_in.bind(test))
	t.start()
	var r = Timer.new()
	r.one_shot = true
	add_child(r)
	r.wait_time = 15
	r.timeout.connect(shop_menu_slide_out.bind(test))
	r.start()
	

# SHOP MENU SLIDE IN
func shop_menu_slide_in(source_object:TextureRect):
	print('slide')

	source_object.position.x = -source_object.size.x
	source_object.visible = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(source_object, "position:x", 0, 0.25)

# SHOP MENU SLIDE OUT
func shop_menu_slide_out(source_object:TextureRect):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(source_object, "position:x", -source_object.size.x, 0.25)
	tween.finished.connect(func(): 
		#VarTests.override_index = VarTests.shop_exit_pointer
		source_object.visible = false
		source_object.queue_free()
	)
