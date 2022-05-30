extends Node2D

var jump_factor := 1.0
var player_danger := false

onready var path_follow = get_parent()
onready var path = path_follow.get_parent()
onready var distance = path_follow.offset
onready var length = path.get_curve().get_baked_length()
    
func _process(delta):
    var unit_distances = fposmod(distance / length, 2.0)
    if unit_distances <= 1.0:
        path_follow.set_unit_offset(unit_distances)
    else: # 1.0 < x <= 2.0
        path_follow.set_unit_offset(2.0 - unit_distances)
    update()

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" and body.velocity.y >= 0:
        
        if player_danger:
            body.kill()
        else:
            var shape = $Body/CollisionShape2D
            var launch_point_x = body.global_position.x
            var launch_point_y = shape.global_position.y - shape.get_shape().extents.y
            var launch_point = Vector2(launch_point_x, launch_point_y)
            var launch_vel = Vector2(body.velocity.x, -Globals.initial_jump_velocity * jump_factor)
            body.jump(launch_point, launch_vel)
            
            queue_free()

func _on_DangerDetectorFront_body_entered(body):
    player_danger = true

func _on_DangerDetectorBack_body_entered(body):
    player_danger = true
