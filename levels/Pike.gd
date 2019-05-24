extends Node2D

# Declare member variables here. Examples:
export var unit_height = 3

var extent = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	if (unit_height > 1): 
		var wall = load("res://Wall.tscn").instance()
		wall.set_scale(Vector2(1, unit_height - 1))
		wall.set_position(Vector2(extent, extent * (unit_height - 1)))
		add_child(wall)
	
	var spike = load("res://Spike.tscn").instance()
	spike.set_position(Vector2(extent, unit_height * 2 - extent))
	add_child(spike)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
