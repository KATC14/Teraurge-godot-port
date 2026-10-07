extends Node2D
@onready var CanLay      = $CanvasLayer
@onready var blip = load("res://scenes/blip_draw.tscn")
func _ready() -> void:
	var target: Area2D = blip.instantiate()
	target.position = Vector2(100, 100)
	target.scale = Vector2(10, 10) / 10 * 1.1
	var target_temp:Sprite2D = target.get_node("Sprite2D")
	var child_temp = target_temp.get_parent().get_child(0)

	target_temp.redraw = 'adjacent_blips'
	child_temp.modulate.a = 1
	CanLay.get_node("blips").add_child(target)



	var instance: Area2D = blip.instantiate()
	instance.name = 'instance'
	instance.monitoring = true
	instance.position = target.position
	instance.position -= Vector2(21, 21)
	instance.scale = target.scale * 8
	var temp:Sprite2D = instance.get_node("Sprite2D")
	var child = temp.get_parent().get_child(0)

	temp.redraw = 'adjacent_blips'
	child.modulate.a = 1
	CanLay.get_node("blips").add_child(instance)
