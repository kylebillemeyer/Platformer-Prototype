tool

extends Node2D

export(int) var qunits_x = 1 setget set_qunits_x
export(int) var qunits_y = 1 setget set_qunits_y

func _ready():
    init()

func _process(delta):
    if Engine.editor_hint:
        update()
        
func init():
    var extents = calc_extents()
    
    var body = $Body.set_position(extents)
    
    var collisionShape = $Body/CollisionShape2D
    collisionShape.get_shape().set_extents(extents)
        
func _draw():
    var extents = calc_extents()
    var quarter_height = extents.y / 2
    draw_rect(Rect2(0, 0, extents.x * 2, extents.y), Color.blue, true)
    draw_rect(Rect2(0, extents.y, extents.x * 2, extents.y), Color(0.0, 0.0, 1.0, .25), true)
    
func calc_extents():
    return Vector2(qunits_x, qunits_y) * (Globals.quarter_grid_size / 2)
    
func set_qunits_x(value: int) -> void:
    qunits_x = value
    init()
    
func set_qunits_y(value: int) -> void:
    qunits_y = value
    init()
    
func activate():
    $Body
