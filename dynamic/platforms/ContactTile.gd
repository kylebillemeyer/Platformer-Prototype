tool

extends Node2D

export(float) var seconds_to_disappear = 1
export(float) var seconds_to_reappear = 3

export(int) var qunits_x = 1 setget set_qunits_x
export(int) var qunits_y = 1 setget set_qunits_y

onready var disappear_timer = $DisappearTimer
onready var reappear_timer = $ReappearTimer
var collision_shape

enum States { 
    IDLE,  # Init state, no contacts detected and disappear not yet triggered
    PRE_CONTACT,  # Body has entered area but not yet touched the ground
    CONTACTED,  # Body has made contact with the ground while still inside area
    DISSAPEARED  # Body has disappeared and reset timer begins
}

var state = States.IDLE

func get_body() -> Node:
    return get_node("StaticBody2D")

func _ready():
    pass
    
func _process(delta):
    if Engine.editor_hint:
        update()
    
func _draw():
    if state == States.DISSAPEARED:
        return
    
    var color
    if state == States.CONTACTED:
        color = Color.darkolivegreen
    else:
        color = Color.aquamarine
        
    var extents = calc_extents()
    draw_rect(Rect2(Vector2.ZERO, extents * 2), color, true)

func _on_RigidBody2D_body_entered(body):
    if body.get_name() == "Player" && state == States.IDLE:
        body.add_on_floor_callback(self)
        state =  States.PRE_CONTACT

func _on_Area2D_body_exited(body):
    if body.get_name() == "Player" && state ==  States.PRE_CONTACT:
        body.remove_on_floor_callback(self)
        state =  States.IDLE
        
func on_floor_callback(body):
    state = States.CONTACTED
    disappear_timer.start(seconds_to_disappear)
    update()

func _on_disappear_timeout():
    state = States.DISSAPEARED
    var d = $StaticBody2D/CollisionShape2D
    d.disabled = true
    reappear_timer.start(seconds_to_reappear)
    update()

func _on_ReappearTimer_timeout():
    state = States.IDLE
    $StaticBody2D/CollisionShape2D.disabled = false
    update()
        
func set_qunits_x(value: int) -> void:
    qunits_x = value
    init()
    
func set_qunits_y(value: int) -> void:
    qunits_y = value
    init()
    
func init():
    var extents = calc_extents()
    
    $Area2D.set_position(Vector2(extents.x, -8))
    $Area2D/CollisionShape2D.get_shape().set_extents(Vector2(extents.x, 8))
    
    $StaticBody2D.set_position(extents)
    $StaticBody2D/CollisionShape2D.get_shape().set_extents(extents)
    
func calc_extents() -> Vector2:
    return Vector2(qunits_x, qunits_y) * (Globals.quarter_grid_size / 2)
