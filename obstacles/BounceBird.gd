extends Node2D

var jump_reduction_factor = 1

var shape

func _ready():
    shape = get_node("Area2D/CollisionShape2D")

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" and body.velocity.y >= 0:
        var launch_point_y = shape.global_position.y - shape.get_shape().get_extents().x
        body.global_position = Vector2(body.position.x, launch_point_y)
        
        var launch_velocity = -Globals.initial_jump_velocity * jump_reduction_factor
        body.launch(Vector2(body.velocity.x, launch_velocity))
        
        queue_free()
