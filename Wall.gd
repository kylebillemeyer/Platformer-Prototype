tool
extends StaticBody2D

# Declare member variables here. Examples:
var collisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	collisionShape = get_node("CollisionShape2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var extents = collisionShape.get_shape().get_extents()
	draw_rect(Rect2(-extents, extents * 2), Color.gray, true)