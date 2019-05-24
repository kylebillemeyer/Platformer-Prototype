tool
extends Node2D

# Declare member variables here. Examples:
export var unit_height = 3

var extent = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	if (unit_height > 1): 
		var wall = load("res://Wall.tscn").instance()
		wall.set_scale(Vector2(1, unit_height - 1))
		wall.set_position(Vector2(extent, -extent * (unit_height - 1)))
		add_child(wall)
	
	var spike = load("res://Spike.tscn").instance()
	spike.set_position(Vector2(extent, -extent * (2 * unit_height - 1)))
	add_child(spike)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _draw():
#	draw_circle(get_node("Camera2D").get_camera_screen_center(), 5, Color.white)
