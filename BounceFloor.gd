tool
extends Node2D

export(int) var unit_width = 1
export(float) var launch_height = 600

var unit_width_extent = 25
var height = 5
var area
var collisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
    area = get_node("Area2D")
    collisionShape = get_node("Area2D/CollisionShape2D")
    
    var col_rect = collisionShape.get_shape()
    var ex = Vector2(unit_width * unit_width_extent - 10, height)
    col_rect.set_extents(ex)

func _draw():
    var extents = Vector2(unit_width_extent * unit_width, height)
    draw_rect(Rect2(area.get_position() - extents, extents * 2), Color.red, true)

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" && body.on_floor:
        # Adding the half the player height so the jump height is 
        # calculated from the players feet
        var launch_speed = sqrt(2 * (launch_height+body.player_extents.y) * body.gravity)
        body.launch(Vector2(0, -launch_speed))
