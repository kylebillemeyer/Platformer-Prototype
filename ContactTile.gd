extends Node2D

export(float) var seconds_to_disappear = 1
export(float) var seconds_to_reappear = 3

var floor_body
var disappear_timer
var reapper_timer
var collision_shape
var state = 1

func _ready():
	floor_body = get_node("StaticBody2D")
	collision_shape = get_node("StaticBody2D/CollisionShape2D")
	disappear_timer = get_node("DisappearTimer")
	reapper_timer = get_node("ReappearTimer")
	
var t = 0
func _process(delta):
	t += delta
	if t > 1:
		t = 0
		state += 1
		state = state % 3
		print_debug(str(state))
		position += Vector2(1, 0)

func _on_RigidBody2D_body_entered(body):
	if body.get_name() == "Player" && body.on_floor:
		state = 1
		print_debug(str(state))
		disappear_timer.start(seconds_to_disappear)

func _on_disappear_timeout():
	state = 2
	print_debug(str(state))
	#remove_child(floor_body)
	reapper_timer.start(seconds_to_reappear)

func _on_ReappearTimer_timeout():
	state = 0
	print_debug(str(state))
	#add_child(floor_body)
	
func _draw():
	draw_rect(Rect2(25, 25, state*100, state*100), Color.white, true)
	if state < 2:
		var color
		if state == 0: 
			color = Color.aquamarine
		else:
			color = Color.darkolivegreen
			
		var extents = collision_shape.get_shape().get_extents()
		draw_rect(Rect2(-extents, extents * 2), color, true)
