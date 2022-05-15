tool
extends Node2D

export(float) var shot_loop_wait_time = 1.5
export(int) var bullet_speed = 500

var shape
var timer
var room

var bullet_scene = preload("res://Bullet.tscn")

func _ready():
    shape = get_node("StaticBody2D/CollisionShape2D")
    shape.get_shape().set_extents(Vector2.ONE * Globals.half_grid_size)
    
    timer = get_node("Timer")
    timer.set_wait_time(shot_loop_wait_time)
    room = find_parent("Room")
    
func _process(delta):
    if Engine.editor_hint:
        pass#update()
    
func fire():
    if Engine.editor_hint or not room:
        return
        
    var outer_extents = shape.get_shape().get_extents()
    
    var bullet = bullet_scene.instance()
    bullet.global_position = global_position + Transform2D(rotation, Vector2(0, 0)) * Vector2(0, -outer_extents.y) 
    bullet.velocity = Transform2D(rotation, Vector2(0, 0)) * Vector2(0, -bullet_speed)
    bullet.origin_id = shape.get_parent().get_instance_id()
    
    # Warning, must be in room. This code is just for testing in partial scenes.
    # Bullets will not be cleaned up if they are not attached to a room, which will lead
    # to memory issues.
    if room:
        room.add_child(bullet)
    else:
        add_child(bullet)

func _draw():
    var outer_extents = shape.get_shape().get_extents()
    draw_rect(Rect2(-outer_extents, 2 * outer_extents), Color(.6, .6, .6), true)
    
    var inner_extents = outer_extents * .7
    draw_rect(Rect2(Vector2(-inner_extents.x, -outer_extents.y), 2 * inner_extents), Color.black, true) 
    
    draw_circle(Vector2(0,0), 5, Color.white)

func _on_Timer_timeout():
    fire()
