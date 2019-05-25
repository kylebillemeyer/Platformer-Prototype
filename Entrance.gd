extends Node2D

export(String) var next_level_path

var activated = false

var shape
var room

func _ready():
	shape = get_node("Area2D/CollisionShape2D").get_shape()
	room = find_parent("Room")
	
func _process(delta):
	pass

func _draw():
	var extents = shape.get_extents()
	draw_rect(Rect2(-extents, 2 * extents), Color.aqua, true)

func _on_Area2D_body_entered(body):
	# The activated flag is used to make sure the player spawning doesn't invoke a collision.
	# The door will only become 'active' once the player has left the area2d.
	if (body.get_name() == "Player" && activated):
		if room:
			room.change_level(next_level_path)
		else:
			print("Can't find a scene called 'Room' in ascendant tree. Cannot change levels.")

func _on_Area2D_body_exited(body):
	activated = true
