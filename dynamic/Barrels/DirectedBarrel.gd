extends Node2D

export var launch_speed := 1000
export var distance_before_gravity := INF

var delay_sec = .2

enum State { IDLE, DELAYING }

var state = State.IDLE
var player: KinematicBody2D
var elapsed_time := 0.0

func _ready():
    pass 
    
func _process(delta) -> void:
    if state == State.DELAYING:
        elapsed_time += delta
        
        if elapsed_time > delay_sec:
            state = State.IDLE
            elapsed_time = 0
            
            if is_equal_approx(rotation, 0.0):
                player.jump(Vector2.UP.rotated(rotation) * launch_speed)
            else:
                player.launch(Vector2.UP.rotated(rotation) * launch_speed, distance_before_gravity)

func _on_Area2D_body_entered(body: Node) -> void:
    if body.get_name() == "Player":
        player = body as KinematicBody2D
        player.anchored($"Anchor Point")
        state = State.DELAYING
