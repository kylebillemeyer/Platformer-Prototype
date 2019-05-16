extends Node2D

# Declare member variables here. Examples:
export var extent = 100
export var walk_speed = 2

var path_follow
var distance = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var curve = Curve2D.new()
	curve.add_point(global_position)
	curve.add_point(global_position + Vector2(extent, 0))
	curve.add_point(global_position - Vector2(extent, 0))
	curve.add_point(global_position)
	
	var path = get_node("Path2D")
	path.set_curve(curve)
	
	path_follow = get_node("Path2D/PathFollow2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	distance += walk_speed + delta
	path_follow.set_offset(distance)
