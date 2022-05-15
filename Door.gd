tool

extends Node2D

var shape
var room
var offset

signal door_triggered

func _ready():
    offset = Vector2(0.0, -Globals.grid_size / 4.0)
    
    var area = get_node("Area2D")
    area.set_position(offset)

    shape = get_node("Area2D/CollisionShape2D").get_shape()
    shape.set_extents(Vector2(Globals.half_grid_size * 1.25, Globals.half_grid_size * 1.5))
    
func _process(delta):
    if Engine.editor_hint:
        update()

func _draw():
    var extents = shape.get_extents()
    draw_rect(Rect2(-extents + offset, 2 * extents), Color.aqua, true)

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player":
        emit_signal("door_triggered")
