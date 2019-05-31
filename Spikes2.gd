tool
extends Node2D

export var unit_width = 5

var collision_shape
var spike_extent

# Called when the node enters the scene tree for the first time.
func _ready():
	var spike_scene = load("res://Spike.tscn")
	var spike_inst = spike_scene.instance()
	var collision_outline = spike_inst.get_node("CollisionShape2D").get_shape().get_points()
	var min_x = 3.402823e+38
	var max_x = -2.802597e-45
	for pt in collision_outline:
		if (pt.x > max_x):
			max_x = pt.x
		elif (pt.x < min_x):
			min_x = pt.x
	spike_extent = (max_x - min_x) / 2
	
	for i in unit_width:
		var spike = spike_scene.instance()
		spike.position = Vector2(1, 0) * spike_extent * (2 * i)	
		add_child(spike)

func _draw():
	for c in get_children():
		if ("Spike" in c.get_name()):
			var shape = c.get_node("CollisionShape2D")
			if shape:
				var tri_points = PoolVector2Array(Array())
				for p in shape.get_shape().get_points():
					var transformed = c.get_transform() * p
					tri_points.append(transformed)
				draw_colored_polygon(tri_points, Color.white)
	
	#draw_circle(get_node("Camera2D").get_camera_screen_center(), 5, Color.black)
