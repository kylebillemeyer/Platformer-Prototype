extends KinematicBody2D

# Declare member variables here. Examples:
export var wall_jump_height = 1000
export var rocket_jump_height = 1000
export var booster_fall_speed = 100
export var drop_speed = 20

var run_speed
var velocity
var on_floor = false
var on_wall = false
var wall_jump_on_cooldown = false
var rocket_jump_on_cooldown = false
var rocket_timer
var collisionShape
var jump_clock = 0
var start_jump_clock = false
var launch_velocity # if set, will launch the player using this velocity once they hit the floor

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2()
	rocket_timer = get_node("Rocket Cooldown Timer")
	collisionShape = get_node("CollisionShape2D")
	
	# Adding the player width to account for the fact that
	# we want to make jump width from players right edge upon
	# starting jump and the player's left edge upon landing. 
	run_speed = (Globals.jump_width + (2 * Globals.player_extents.x)) / Globals.jump_and_return_time
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	
	if (start_jump_clock):
		jump_clock += delta
	
	if (Input.is_action_pressed("move_down")):
		velocity.y += (Globals.gravity + drop_speed) * delta 
	else:
		velocity.y += Globals.gravity * delta
		
	if on_floor:
		wall_jump_on_cooldown = false
		
		if launch_velocity:
			velocity = launch_velocity
	
	if Input.is_action_pressed("move_right"):
		velocity.x += run_speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= run_speed
		
	var jump = Input.is_action_just_pressed("jump")
	var rocket = Input.is_action_just_pressed("rocket_jump")
	var boosters = Input.is_action_pressed("boosters")
	
	# normal ground jump
	if jump && on_floor:
		velocity.y = -Globals.initial_jump_velocity
		jump_clock = position.x
		start_jump_clock = true
	# wall jump
	elif jump && on_wall && !wall_jump_on_cooldown:
		velocity.y = -wall_jump_height
		wall_jump_on_cooldown = true
	# rocket boost
	elif rocket && !rocket_jump_on_cooldown:
		#velocity.y = -rocket_jump_height
		rocket_jump_on_cooldown = true
		rocket_timer.start()
	# boosters
	elif boosters && velocity.y > booster_fall_speed && !on_floor:
		#velocity.y = booster_fall_speed
		pass
	
	var gt = get_global_transform()
	var motion = velocity * delta
	var result = Physics2DTestMotionResult.new()
	var collision = Physics2DServer.body_test_motion(get_rid(), gt, velocity * delta, true, 0.08, result)
	
	if (collision && result.get_collider().get_collision_layer() == 16): # hit wall object
		velocity = velocity.bounce(result.get_collision_normal())
		wall_jump_on_cooldown = false
		gt[2] += velocity * delta
		set_global_transform(gt)
	elif (collision):
		on_floor = are_feet_on_floor(result)
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		on_floor = false
		gt[2] += velocity * delta
		set_global_transform(gt)
		
func are_feet_on_floor(collisionResult) -> bool:
	var bottom_left = global_position + Vector2(-Globals.player_extents.x, Globals.player_extents.y)
	var bottom_center = global_position + Vector2(0, Globals.player_extents.y)
	var bottom_right = global_position + Globals.player_extents
	
	var space_state = get_world_2d().get_direct_space_state()
	var bot_left_cast_result = space_state.intersect_ray(bottom_left, bottom_left + Vector2(0, 1), [self])
	var bot_center_cast_result = space_state.intersect_ray(bottom_center, bottom_center + Vector2(0, 1), [self])
	var bot_right_cast_result = space_state.intersect_ray(bottom_right, bottom_right + Vector2(0, 1), [self])
	
	var left_hit = did_ray_hit_floor(bot_left_cast_result)
	var center_hit = did_ray_hit_floor(bot_center_cast_result)
	var right_hit = did_ray_hit_floor(bot_right_cast_result)
	
	return left_hit || center_hit || right_hit
		
func did_ray_hit_floor(cast_result) -> bool:
	return cast_result && cast_result["collider"].get_collision_layer() == 4
		
func _draw():
	draw_rect(Rect2(Globals.player_extents * -1, Globals.player_extents * 2), Color.violet, true)
	
func _on_wall_detector_entered(body):
	#print_debug("enter: " + body.get_name())
	on_wall = true

func _on_wall_detector_exited(body):
	#print_debug("exit: " + body.get_name())
	on_wall = false
	
func _on_rocket_cooldown_timeout():
	rocket_jump_on_cooldown = false
	
func launch_when_on_floor(init_velocity):
	launch_velocity = init_velocity

func cancel_launch():
	launch_velocity = null
	
func kill():
	# this code relies on the parent node being a room node
	var room = get_parent().reset_level()
	