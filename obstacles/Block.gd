tool
extends Node2D

export(int) var qunits_x = 1 setget set_qunits_x
export(int) var qunits_y = 1 setget set_qunits_y

var extents

func _ready():
	init()
	
func _process(delta):
	if Engine.editor_hint:
		update()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, extents * 2), Color.gray, true)
	
func set_qunits_x(value: int) -> void:
	qunits_x = value
	init()
	
func set_qunits_y(value: int) -> void:
	qunits_y = value
	init()
	
func init():
	extents = Vector2(qunits_x, qunits_y) * (Globals.quarter_grid_size / 2)
	
	var body = get_node("Body")
	body.set_position(extents)
	
	var collisionShape = get_node("Body/CollisionShape2D")
	collisionShape.get_shape().set_extents(extents)
