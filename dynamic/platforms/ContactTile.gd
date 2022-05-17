extends Node2D

export(float) var seconds_to_disappear = 1
export(float) var seconds_to_reappear = 3

var floor_body
var disappear_timer
var reapper_timer
var collision_shape

#States:
#	0 -> Init state, no contacts detected and disappear not yet triggered
#	1 -> Body has entered area but not yet touched the ground
#		-> 0 if body leaves area without contact
#		-> 2 if body makes ground contact
#	2 -> Body has made contact with the ground while still inside area
#		3 -> countdown to disappear finishes
#	3 -> Body has disappeared and reset timer begins
#		0 -> reset to init state after reappear timer finishes
var state = 0

func get_body() -> Node:
    return get_node("StaticBody2D")

func _ready():
    floor_body = get_node("StaticBody2D")
    collision_shape = get_node("StaticBody2D/CollisionShape2D")
    disappear_timer = get_node("DisappearTimer")
    reapper_timer = get_node("ReappearTimer")

func _on_RigidBody2D_body_entered(body):
    if body.get_name() == "Player" && state == 0:
        body.add_on_floor_callback(self)
        state = 1

func _on_Area2D_body_exited(body):
    if body.get_name() == "Player" && state == 1:
        body.remove_on_floor_callback(self)
        state = 0
        
func on_floor_callback(body):
    state = 2
    disappear_timer.start(seconds_to_disappear)
    update()

func _on_disappear_timeout():
    state = 3
    remove_child(floor_body)
    reapper_timer.start(seconds_to_reappear)
    update()

func _on_ReappearTimer_timeout():
    state = 0
    add_child(floor_body)
    update()
    
func _draw():
    if state < 3:
        var color
        if state == 2: 
            color = Color.darkolivegreen
        else:
            color = Color.aquamarine
            
        var extents = collision_shape.get_shape().get_extents()
        draw_rect(Rect2(-extents, extents * 2), color, true)
