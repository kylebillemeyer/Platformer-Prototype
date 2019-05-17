tool
extends Node2D

export var unit_width = 1

var spike_width = 40
var collision_shape

# Called when the node enters the scene tree for the first time.
func _ready():
	var spike_scene = load("res://Spike.tscn")
	var is_even = unit_width % 2 == 0
	
	for i in range(unit_width - 1):
		var spike = spike_scene.instance()
		
		# lay each spike next each other such that the left portion of the left most spike is at parent position 0
		# and each successive spike is lined next to it on the right
		spike.position.x = i * spike_width
		# shift the current spike left by 1/2 the width of all spikes such that the center spike is at parent position 0
		spike.position.x -= (spike_width * unit_width / 2)
		
		add_child(spike)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	for c in get_children():
		var shape = c.get_node("CollisionShape2D")
		if shape:
			var tri_points = PoolVector2Array(Array())
			for p in shape.get_shape().get_points():
				var translated = c.position + p
				tri_points.append(translated)
			draw_colored_polygon(tri_points, Color.white)
