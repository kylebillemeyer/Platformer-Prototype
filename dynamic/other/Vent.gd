tool
extends Node2D

export var qunits_x := 1 setget set_qunits_x
export var qunits_y := 1 setget set_qunits_y

func _ready():
    reset_dimensions()
    
func _draw():
    var extents = calc_extents()
    var offset = Vector2(0, -extents.y * 2) # anchor is bottom left, drawing is top left oriented
    draw_rect(Rect2(offset, extents * 2), Color(1.0, 1.0, 1.0, 0.2))
    
func reset_dimensions():
    var extents = calc_extents()
    $Area2D.position = Vector2(extents.x, -extents.y) # orient at bottom left pixel
    $Area2D/CollisionShape2D.get_shape().set_extents(extents)
    
func calc_extents() -> Vector2:
    return Vector2(qunits_x, qunits_y) * (Globals.quarter_grid_size / 2)
    
func set_qunits_x(value: int) -> void:
    qunits_x = value
    reset_dimensions()
    
func set_qunits_y(value: int) -> void:
    qunits_y = value
    reset_dimensions()

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player":
        body.external_impulse = Vector2(0, -body.whirling_fall_speed * 2)

func _on_Area2D_body_exited(body):
    if body.get_name() == "Player":
        body.external_impulse = Vector2.ZERO
