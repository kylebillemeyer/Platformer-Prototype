extends Node2D

export var ending_angle := 0.0 setget set_ending_angle
export var rotation_speed := deg2rad(360) setget set_rotation_speed
export var path_follow_speed := 600.0
export var jump_height := 64 * 8
export var distance_before_gravity := 0

enum State { IDLE, ROTATING, HOLDING }

var state = State.IDLE
var player: KinematicBody2D
var path_follow: PathFollow2D

func _ready():
    var parent = get_parent()
    if parent and parent.get_class() == "PathFollow2D":
        path_follow = parent as PathFollow2D
    
func _process(delta) -> void:
    if path_follow:
        path_follow.set_offset(path_follow.get_offset() + path_follow_speed * delta)
        
    if state == State.ROTATING:
        var rot = rotation
        rotation = min(rotation + rotation_speed * delta, ending_angle)
        
        if is_equal_approx(rotation, ending_angle):
            state = State.HOLDING
        
    var jump_pressed = Input.is_action_just_pressed("jump")
    if state == State.HOLDING and jump_pressed:
        state = State.IDLE
        var launch_speed = sqrt(2 * Globals.gravity * jump_height)
        
        # if the barrel is pointed up, let the player impact their lateral movement
        if is_equal_approx(rotation, 0.0):
            player.jump(Vector2.UP.rotated(rotation) * launch_speed)
        else:
            player.launch(Vector2.UP.rotated(rotation) * launch_speed, distance_before_gravity)

func _on_Area2D_body_entered(body: Node) -> void:
    if body.get_name() == "Player":
        state = State.ROTATING
        player = body as KinematicBody2D
        player.anchored($"Anchor Point")

func set_ending_angle(degrees: float) -> void:
    ending_angle = deg2rad(degrees)
    
func set_rotation_speed(degrees_per_sec: float) -> void:
    rotation_speed = deg2rad(degrees_per_sec)
