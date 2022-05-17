extends Node2D

var attached_player

func _ready():
    pass
    
func _process(delta):
    if attached_player:
        global_position = attached_player.global_position - Vector2(0, Globals.half_grid_size)
    
func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" and body.velocity.y >= 0:
        var anchor_point = global_position + Vector2(0, Globals.half_grid_size)
        body.whirling(anchor_point)
        
        attached_player = body
        body.connect("jumped", self, "detach")
        
func detach():
    attached_player = null
