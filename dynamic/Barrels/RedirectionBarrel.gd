extends Node2D

export var starting_angle := 0.0 setget set_starting_angle
export var ending_angle := 0.0 setget set_ending_angle
export var rotation_speed := deg2rad(360) setget set_rotation_speed
export var launch_speed := 1000
export var distance_before_gravity := INF

enum State { IDLE, ROTATING }

var state = State.IDLE
var player: KinematicBody2D

func _ready():
    pass 
    
func _process(delta) -> void:
    if state == State.ROTATING:
        rotation = min(rotation + rotation_speed * delta, ending_angle)
        
        if is_equal_approx(rotation, ending_angle):
            state = State.IDLE
            player.launch(Vector2.UP.rotated(rotation) * launch_speed, distance_before_gravity)

func _on_Area2D_body_entered(body: Node) -> void:
    if body.get_name() == "Player":
        player = body as KinematicBody2D
        player.anchored($"Anchor Point")
        state = State.ROTATING

func set_starting_angle(degrees: float) -> void:
    starting_angle = deg2rad(degrees)

func set_ending_angle(degrees: float) -> void:
    ending_angle = deg2rad(degrees)
    
func set_rotation_speed(degrees_per_sec: float) -> void:
    rotation_speed = deg2rad(degrees_per_sec)
