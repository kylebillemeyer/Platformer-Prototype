extends Node2D

func _ready():
    pass

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" and body.velocity.y >= 0:
        var anchor_point = global_position + Vector2(0, Globals.half_grid_size)
        body.hooked(anchor_point)
