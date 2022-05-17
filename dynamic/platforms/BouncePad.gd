tool
extends Node2D

export(int) var qunits_x = 1 setget set_qunits_x
export(float) var launch_height = 600

var launch_guard_enabled

# Called when the node enters the scene tree for the first time.
func _ready():
    init()
    
func _draw():
    var extents = calc_extents()
    draw_rect(Rect2(Vector2.ZERO, extents * 2), Color.red, true)

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" && !launch_guard_enabled:
        launch_guard_enabled = true
        body.add_on_floor_callback(self)
        
func _on_Area2D_body_exited(body):
    launch_guard_enabled = false
    body.remove_on_floor_callback(self)
        
func on_floor_callback(body):
    # Adding the half the player height so the jump height is 
    # calculated from the players feet
    var launch_speed = sqrt(2 * (launch_height + Globals.player_extents.y) * Globals.gravity)
    body.velocity = Vector2(0, -launch_speed)
    
func set_qunits_x(value: int) -> void:
    qunits_x = value
    init()
    
func init():
    var extents = calc_extents()
    
    $Area2D.set_position(extents)
    $Area2D/CollisionShape2D.get_shape().set_extents(extents)
    
func calc_extents():
    return Vector2(qunits_x, 1) * (Globals.quarter_grid_size / 2)
