extends KinematicBody2D

enum States { IDLE, HELD, THROWN }

var radius := 20
var gravity_factor = .7
var velocity := Vector2.ZERO
var state = States.IDLE
var player

# Called when the node enters the scene tree for the first time.
func _ready():
    process_priority = 1
    $CollisionShape2D.get_shape().set_radius(radius)

func _physics_process(delta):
    print(velocity)
    if state == States.IDLE or state == States.THROWN:
        velocity.y += (Globals.gravity * gravity_factor * delta)
        #velocity = move_and_slide(velocity, Vector2(0, -1))
        velocity = move_and_slide(velocity, Vector2.UP)
        if is_on_floor():
            velocity = Vector2.ZERO
    elif state == States.HELD:
        var offset = Vector2(player.hold_offset.x * player.facing, player.hold_offset.y)
        self.global_position = player.global_position + offset

func _draw():
    draw_circle(Vector2.ZERO, radius, Color.black)
    
func interact(player: Node2D):
    self.state = States.HELD
    self.player = player
    $CollisionShape2D.disabled = true
    player.hold(self)
    
func throw(wtf: Vector2):
    self.state = States.THROWN
    self.player = null
    self.velocity = wtf
    $CollisionShape2D.disabled = false

func _on_FloorDetector_body_entered(body):
    pass
