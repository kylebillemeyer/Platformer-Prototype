extends Node2D

export(String) var next_level_path

var active = true

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
	if body.get_name() == "Player" && active:
		if room:
			room.change_level(next_level_path)
		else:
			print("Can't find a scene called 'Room' in ascendant tree. Cannot change levels.")

func _on_Area2D_body_exited(body):
	active = true
