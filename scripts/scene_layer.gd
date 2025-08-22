extends CanvasLayer


@onready var sky_layer:TextureRect        = $sky_layer       # sky_layer 
@onready var weather_layer:TextureRect    = $weather_layer   # weather_layer 
@onready var env_Node:TextureRect         = $env_Node        # background_layer 
@onready var env_mask_Node:TextureRect    = $env_mask_Node   # background_mask_layer
@onready var atmosphere_layer:TextureRect = $atmosphere_layer# atmosphere_layer
@onready var sprite:TextureRect           = $sprite          # character_layer
@onready var scene_picture:TextureRect    = $scene_picture   # picture_layer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
