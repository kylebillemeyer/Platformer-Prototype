extends Node2D

# Declare member variables here. Examples:
export(int) var unit_radius = 3
export(float) var spacing = 0
export(bool) var rotate_clockwise = false
export(float) var starting_angle = 0
export(float) var rotations_per_second = 1
export(float) var flame_radius = 25
export(String) var include_predicate

var bullet_scene
var pred

func _ready():
    if include_predicate:
        pred = load("res://" + include_predicate + ".tscn").instance()
        
    var offset_normal = Vector2(1, 0)
    
    var width_per_unit = 2 * flame_radius
    
    for i in unit_radius:
        if !include_predicate || pred.invoke(i):
            var area = Area2D.new()
            var col = CollisionShape2D.new()
            var shape = CircleShape2D.new()
            shape.set_radius(flame_radius)
            col.set_shape(shape)
            area.add_child(col)
            area.set_name("Flame " + str(i))
            area.set_collision_layer_bit(0, false)
            area.set_collision_layer_bit(19, true)
            area.set_collision_mask_bit(0, true)
            area.connect("body_entered", self, "_on_flame_entered")
            
            area.position = offset_normal * (width_per_unit + spacing) * i
            add_child(area)
        
func _process(delta):
    rotation = rotation + (rotations_per_second * 2 * PI * delta)
        
func _draw():
    for c in get_children():
        if "Flame" in c.get_name():
            draw_circle(c.get_position(), flame_radius, Color.orange)
        
func _on_flame_entered(body):
    if body.get_name() == "Player":
        body.kill()
