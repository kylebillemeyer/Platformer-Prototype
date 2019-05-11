extends Path2D

# Declare member variables here. Examples:
export var extents = 100
export var walk_speed = 100

var path
var path_distance = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	path = get_node("PathFollow2D")
	
	var curve = Curve2D.new()	
	curve.add_point(global_position)
	curve.add_point(global_position + Vector2(extents, 0))
	curve.add_point(global_position + Vector2(-extents, 0))
	curve.add_point(global_position)
	set_curve(curve)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path_distance += walk_speed * delta
	path.set_offset(path_distance)
	
