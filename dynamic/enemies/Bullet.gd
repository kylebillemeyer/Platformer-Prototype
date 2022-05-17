extends Node2D

# Declare member variables here. Examples:
export var velocity = Vector2(0, 0)

var shape
var room
var origin_id

# Called when the node enters the scene tree for the first time.
func _ready():
    shape = get_node("Area2D/CollisionShape2D").get_shape()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    global_position += velocity * delta
    
    if room:
        var room_rect = Rect2(room.get_global_position(), Vector2(room.width, room.height))
        if (!room_rect.has_point(global_position)):
            queue_free()
    
func _draw():
    draw_circle(Vector2(0,0), shape.get_radius(), Color.orange)
    
func set_room(r):
    room = r
    
func set_origin_id(id):
    origin_id = id
    
func _on_Area2D_body_entered(body):
    if body.get_instance_id() == origin_id:
        pass
    elif body.get_name() == "Player":
        body.kill()
    else:
        queue_free()
