tool
extends Node2D

export var units = Vector2(1, 1)

var body
var collisionShape
var extent_x
var extent_y


# Called when the node enters the scene tree for the first time.
func _ready():
	body = get_node("StaticBody2D")
	collisionShape = get_node("StaticBody2D/CollisionShape2D")
	
	extent_x = units.x * Globals.player_extents.x
	extent_y = units.y * Globals.player_extents.y
	collisionShape.set_position(Vector2(extent_x, extent_y)) 
	collisionShape.get_shape().set_extents(Vector2(extent_x, extent_y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	draw_rect(Rect2(0, 0, extent_x * 2, extent_y * 2), Color.gray, true)
