tool
extends Node2D

export var unit_width = 1
export var unit_height = 1

export var spikes_on_top = true
export var spikes_on_right = false
export var spikes_on_left = false
export var spikes_on_bottom = false

var collision_shape
var spike_extent

# Called when the node enters the scene tree for the first time.
func _ready():
	if (unit_height > 0 && unit_width > 0):
		var wall = load("res://Wall.tscn").instance()
		wall.set_scale(Vector2(unit_width, unit_height))
		add_child(wall)
				
	var spike_scene = load("res://Spike.tscn")
	
	var spike_inst = spike_scene.instance()
	var collision_outline = spike_inst.get_node("CollisionShape2D").get_shape().get_points()
	var min_x = INF
	var max_x = -INF
	for pt in collision_outline:
		if (pt.x > max_x):
			max_x = pt.x
		elif (pt.x < min_x):
			min_x = pt.x
	spike_extent = (max_x - min_x) / 2
	
	var center_offset = Vector2(unit_width * spike_extent, -unit_height * spike_extent)
				
	if (spikes_on_top):	
		for i in range(unit_width):
			var spike = spike_scene.instance()
			spike.position = Vector2((i*2+1) * spike_extent, (unit_height*2+1) * -spike_extent) - center_offset
			add_child(spike)
			
	if ((unit_height < 1 || unit_width < 1) && (spikes_on_left || spikes_on_right || spikes_on_bottom)):
		print("Spikes can only be placed on top unless unit height is at least 1 unit.")
		var x = 0
		1 / x	
						
	if (spikes_on_bottom):
		for i in range(unit_width):
			var spike = spike_scene.instance()
			spike.position = Vector2((i*2+1) * spike_extent, spike_extent) - center_offset
			spike.rotation = PI
			add_child(spike)
			
	if (spikes_on_left):
		for j in range(unit_height):
			var spike = spike_scene.instance()
			spike.position = Vector2(-spike_extent, (j*2+1) * -spike_extent) - center_offset
			spike.rotation = -PI/2
			add_child(spike)

	if (spikes_on_right):
		for j in range(unit_height):
			var spike = spike_scene.instance()
			spike.position = Vector2((unit_width*2+1) * spike_extent, (j*2+1) * -spike_extent) - center_offset
			spike.rotation = PI/2
			add_child(spike)

func to_int(boolean) -> int:
	if boolean: 
		return 1 
	else: 
		return 0
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
