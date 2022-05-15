tool
extends Node2D

export(int) var qunits_x = 1 setget set_qunits_x

var extents

func _ready():
	init()
	
func init():
	extents = Vector2(qunits_x, 1) * (Globals.quarter_grid_size / 2)
	
	var body = get_node("Area2D")
	body.set_position(extents)
	
	var collisionShape = get_node("Area2D/CollisionShape2D")
	collisionShape.get_shape().set_extents(extents)

func _process(delta):
	if Engine.editor_hint:
		update()
	
func _draw():
	for x in range(qunits_x):
		var points = PoolVector2Array()
		points.push_back(Vector2(x, 1) * Globals.quarter_grid_size)
		points.push_back(Vector2(x + 1, 1) * Globals.quarter_grid_size)
		points.push_back(Vector2(x + .5, 0) * Globals.quarter_grid_size)
		
		draw_polygon(points, [Color.blue])


func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		body.kill()
	
func set_qunits_x(value: int) -> void:
	qunits_x = value
	init()
