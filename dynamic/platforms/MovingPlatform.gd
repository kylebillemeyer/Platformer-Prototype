extends Node2D

# test
export(int) var unit_width = 1
export(float) var move_speed = 100.0
export(bool) var show_path = false

var width_per_unit = 50
var height_per_unit = 25
var detector_height = 10
var joint_radius = 7.5
var track_line_thickness = 5
var path
var path_follow
var plat_collision
var distance
var body_to_anchor

#States:
#	0 -> No collisions detected, no body on platform
#	1 -> Body entered detection area but is not on the floor (static body)
#		-> 0 if body leaves detection area while not on the floor
#		-> 2 if body lands on the floor
#	2 -> Body is on the floor and should be moved along with the floor
#		-> 1 if body moves off the floor
var state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    path_follow = get_parent()
    path = path_follow.get_parent()
    if !("PathFollow" in path_follow.get_name()):
        print("A moving platform's parent must be named '*PathFollow*'")
        
    var platform = StaticBody2D.new()
    platform.position = Vector2(0, height_per_unit / 2.0)
    platform.set_collision_layer_bit(0, false)
    platform.set_collision_layer_bit(2, true)
    platform.set_collision_mask_bit(0, true)
    plat_collision = CollisionShape2D.new()
    var plat_shape = RectangleShape2D.new()
    plat_shape.set_extents(Vector2(unit_width * width_per_unit / 2.0, height_per_unit / 2.0))
    plat_collision.set_shape(plat_shape)
    platform.add_child(plat_collision)
    add_child(platform)
    
    var detector = Area2D.new()
    detector.position = Vector2(0, -detector_height)
    detector.connect("body_entered", self, "_on_Area2D_body_entered")
    detector.connect("body_exited", self, "_on_Area2D_body_exited")
    detector.set_collision_layer_bit(0, false)
    detector.set_collision_layer_bit(19, true)
    detector.set_collision_mask_bit(0, true)
    var detector_collision = CollisionShape2D.new()
    var detector_shape = RectangleShape2D.new()
    detector_shape.set_extents(Vector2(unit_width * width_per_unit / 2.0, detector_height / 2.0))
    detector_collision.set_shape(detector_shape)
    detector.add_child(detector_collision)
    add_child(detector)
    
    distance = path_follow.offset

func update_extents(collision):
    var shape = collision.get_shape()
    var extents = shape.get_extents()
    shape.set_extents(Vector2(extents.x * unit_width, extents.y))
    
func _process(delta):
    var pos = path_follow.position
    var pre_move_pos = Vector2(pos.x, pos.y)
    
    distance += move_speed * delta
    path_follow.set_offset(distance)
    update()
    
    if state == 2:
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
    
    var extents = plat_collision.get_shape().get_extents()
    draw_rect(Rect2(Vector2(-extents.x, 0), 2 * extents), Color(215/255.0, 200/255.0, 0), true)
    draw_circle(Vector2(0, -joint_radius / 2), joint_radius, Color.white)

func _on_Area2D_body_entered(body):
    if body.get_name() == "Player" && state == 0:
        state = 1
        body.add_on_floor_callback(self)

func _on_Area2D_body_exited(body):
    if body.get_name() == "Player":
        state = 0
        
func on_floor_callback(body):
    state = 2
    body_to_anchor = body
    
func off_floor_callback(body):
    state = 1
    body_to_anchor = null
