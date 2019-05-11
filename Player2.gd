extends KinematicBody2D

# Declare member variables here. Examples:
export var run_speed = 400
export var jump_height = 1000
export var wall_jump_height = 1000
export var g = 20
var screen_size
var velocity = Vector2()
var on_wall = false
var wall_jump_on_cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	velocity = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	velocity.y += g
	
	if is_on_floor():
		wall_jump_on_cooldown = false
	
	if Input.is_action_pressed("move_right"):
		velocity.x += run_speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= run_speed
		
	var jump = Input.is_action_just_pressed("jump")
	
	# normal ground jump
	if jump && is_on_floor():
		velocity.y = -jump_height
	# wall jump
	elif jump && on_wall && !wall_jump_on_cooldown:
		velocity.y = -wall_jump_height
		wall_jump_on_cooldown = true
	
	#move_and_collide(velocity * delta)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func _on_wall_detector_entered(body):
	#print_debug("enter: " + body.get_name())
	on_wall = true

func _on_wall_detector_exited(body):
	#print_debug("exit: " + body.get_name())
	on_wall = false