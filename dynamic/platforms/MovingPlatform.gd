tool

extends Node2D

export(int) var qunits_x = 1 setget set_qunits_x
export(int) var qunits_y = 1 setget set_qunits_y
export(float) var move_speed = 100.0
export(bool) var show_path = false
export(bool) var there_and_back = true

var detector_height = 16
var joint_radius = 7.5
var track_line_thickness = 5
var path
var path_follow
var distance
var length
var body_to_anchor

enum States { 
    IDLE,  # No collisions detected, no body on platform
    PRE_CONTACT,  # Body entered detection area but is not on the floor (static body)
    CONTACTED  # Body is on the floor and should be moved along with the floor
}

var state = States.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
    path_follow = get_parent()
    path = path_follow.get_parent()
    if !("PathFollow" in path_follow.get_name()):
        print("A moving platform's parent must be named '*PathFollow*'")
    
    distance = path_follow.offset
    length = path.get_curve().get_baked_length()
    init()
    
func _process(delta):
    var pos = path_follow.position
    var pre_move_pos = Vector2(pos.x, pos.y)
    
    distance += move_speed * delta
    
    var unit_distances = fposmod(distance / length, 2.0)
    if unit_distances <= 1.0:
        path_follow.set_unit_offset(unit_distances)
    else: # 1.0 < x <= 2.0
        path_follow.set_unit_offset(2.0 - unit_distances)
    update()
    
    if state == States.CONTACTED:
        var move_offset = path_follow.position - pre_move_pos
        body_to_anchor.position += move_offset

func _draw():
    if show_path:
        var points = path.get_curve().tessellate()
        for i in points.size():
            var cur_joint_pos = to_local(points[i] - Vector2(0, track_line_thickness / 2))
            draw_circle(cur_joint_pos, joint_radius, Color.white)
            
            if i < (points.size() - 1):
                var next_joint_pos = to_local(points[i+1] - Vector2(0, track_line_thickness / 2))
                draw_line(cur_joint_pos, next_joint_pos, Color.whitesmoke, track_line_thickness, false)
    
    var extents = calc_extents()
    draw_rect(Rect2(-extents, 2 * extents), Color(215/255.0, 200/255.0, 0), true)
    draw_circle(Vector2.ZERO, joint_radius, Color.white)

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" && state == States.IDLE:
        state = States.PRE_CONTACT
        body.add_on_floor_callback(self)

func _on_Area2D_body_exited(body):
    if body.get_name() == "Player":
        state = States.IDLE
        
func on_floor_callback(body):
    state = States.CONTACTED
    body_to_anchor = body
    
func off_floor_callback(body):
    state = States.IDLE
    body_to_anchor = null
    
func set_qunits_x(value: int) -> void:
    qunits_x = value
    init()
    
func set_qunits_y(value: int) -> void:
    qunits_y = value
    init()
    
func init():
    var extents = calc_extents()
    
    $Area2D.set_position(Vector2(0, -detector_height / 2 - extents.y))
    $Area2D/CollisionShape2D.get_shape().set_extents(Vector2(extents.x, detector_height / 2))
    
    $StaticBody2D.set_position(Vector2.ZERO)
    $StaticBody2D/CollisionShape2D.get_shape().set_extents(extents)
    
func calc_extents() -> Vector2:
    return Vector2(qunits_x, qunits_y) * (Globals.quarter_grid_size / 2)
