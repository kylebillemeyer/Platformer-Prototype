extends Node2D

export(String) var next_level_path

var active = true

var shape
var room
var offset

func _ready():
	offset = Vector2(0.0, -Globals.grid_size / 4.0)
	
	var area = get_node("Area2D")
	area.set_position(offset)

	shape = get_node("Area2D/CollisionShape2D").get_shape()
	shape.set_extents(Vector2(Globals.half_grid_size * 1.25, Globals.half_grid_size * 1.5))
	room = find_parent("Room")
	
func _process(delta):
	pass

func _draw():
	var extents = shape.get_extents()
	draw_rect(Rect2(-extents + offset, 2 * extents), Color.aqua, true)

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player" && active:
		if room:
			room.change_level(next_level_path)
		else:
			print("Can't find a scene called 'Room' in ascendant tree. Cannot change levels.")

func _on_Area2D_body_exited(body):
	active = true
