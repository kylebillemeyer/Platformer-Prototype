extends KinematicBody2D

# Declare member variables here. Examples:
export var wall_jump_height := 1000
export var rocket_jump_height := 1000
export var booster_fall_speed := 100
export var drop_speed := 20

var facing := 1
var walk_speed: float
var whirling_lateral_speed: float
var whirling_fall_speed: float
var velocity: Vector2
var external_impulse := Vector2.ZERO
var on_floor := false
var on_wall := false
var wall_jump_on_cooldown := false
var rocket_jump_on_cooldown := false
var rocket_timer: Timer
var collisionShape: CollisionShape2D
var on_floor_callback_body_queue = []
var off_floor_callback_body_queue = []
var state = PlayerState.IDLE
var anchor: Node2D
var last_position: Vector2
var distance_before_gravity: float
var launch_distance_travelled := 0.0
var interactables = []
var throwable: Node2D
var hold_offset: Vector2
var throw_velocity = Vector2(1500, -250)

enum PlayerState { 
    IDLE, 
    WALKING,
    RUNNING,
    JUMPING, # player is hurtling through the air mobile. gravity applies
    LAUNCHED, # player is hurtling through the air. immoble. gravity applies
    HOOKED,  # hanging from a hook-like object, immoble, but can jump
    WHIRLING, # hanging from a whirly. slowly falling. can move laterally or jump
    ANCHORED # player is immoble and can't be seen
    HOLDING, # player is holding a throwable object
}

signal jumped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    process_priority = 0
    velocity = Vector2()
    rocket_timer = get_node("Rocket Cooldown Timer")
    collisionShape = get_node("CollisionShape2D")
    collisionShape.get_shape().set_extents(Globals.player_extents)
    
    # Adding the player width to account for the fact that
    # we want to make jump width from players right edge upon
    # starting jump and the player's left edge upon landing. 
    walk_speed = (Globals.jump_width + (2 * Globals.player_extents.x)) / Globals.jump_and_return_time
    whirling_lateral_speed = walk_speed * Globals.whirling_lateral_move_factor
    whirling_fall_speed = walk_speed * Globals.whirling_fall_factor
    
    hold_offset = .25 * Vector2(Globals.player_extents.x, -Globals.player_extents.y)
        
func _draw():
    draw_rect(Rect2(Globals.player_extents * -1, Globals.player_extents * 2), Color.violet, true)
    draw_circle(.5 * Vector2(Globals.player_extents.x * facing, -Globals.player_extents.y), 10, Color.red)
    
func _physics_process(delta: float) -> void:
    match state:
        PlayerState.IDLE, PlayerState.WALKING, PlayerState.RUNNING:
            handle_fall(delta)
            handle_on_floor_callbacks()
            handle_run()
            handle_move_laterally()
            handle_interact()
            handle_jump()
        PlayerState.WHIRLING:
            handle_fall(delta)
            handle_on_floor_callbacks()
            handle_move_laterally()
            handle_jump()
        PlayerState.JUMPING:
            handle_throw()
            handle_fall(delta)
            handle_on_floor_callbacks()
            handle_move_laterally()
        PlayerState.LAUNCHED:
            handle_fall(delta)
            handle_distance_traveled()
            handle_on_floor_callbacks()
        PlayerState.HOOKED:
            handle_jump()
        PlayerState.ANCHORED:
            global_position = anchor.global_position
        PlayerState.HOLDING:
            handle_throw()
            handle_fall(delta)
            handle_on_floor_callbacks()
            handle_run()
            handle_move_laterally()
            handle_jump()
    
    last_position = global_position
            
    var adjusted_vel = velocity + external_impulse
    
    var gt = get_global_transform()
    var motion = velocity * delta
    var result = Physics2DTestMotionResult.new()
    var collision = Physics2DServer.body_test_motion(get_rid(), gt, adjusted_vel * delta, true, 0.08, result)
    
    if (collision && result.get_collider().get_collision_layer() == 16): # hit wall object
        velocity = velocity.bounce(result.get_collision_normal())
        wall_jump_on_cooldown = false
        gt[2] += adjusted_vel * delta
        set_global_transform(gt)
    elif (collision):
        on_floor = are_feet_on_floor()
        velocity = move_and_slide(adjusted_vel, Vector2(0, -1))
        if throwable:
            state = PlayerState.HOLDING
        else:
            state = PlayerState.IDLE
    else:
        on_floor = false
        gt[2] += adjusted_vel * delta
        set_global_transform(gt)
        
    if !on_floor:
        handle_off_floor_callbacks()
        
    update()
    
func handle_fall(delta) -> void:
    if state == PlayerState.LAUNCHED and launch_distance_travelled > distance_before_gravity:
        velocity.y += Globals.gravity * delta
    elif state == PlayerState.WHIRLING:
        velocity.y = whirling_fall_speed
    else:
        var wtf = Globals.gravity
        velocity.y += Globals.gravity * delta
        
func handle_run() -> void:
    if Input.is_action_pressed("run"):
        state = PlayerState.RUNNING
    elif on_floor:
        state = PlayerState.IDLE
    else:
        state = PlayerState.JUMPING
    
func handle_move_laterally() -> void:
    var move_right = Input.is_action_pressed("move_right")
    var move_left = Input.is_action_pressed("move_left")
    
    var speed = walk_speed
    if state == PlayerState.WHIRLING:
        speed = whirling_lateral_speed
    elif state == PlayerState.RUNNING:
        speed = walk_speed * Globals.run_factor
    elif state == PlayerState.JUMPING and Input.is_action_pressed("run"):
        speed = walk_speed * Globals.run_factor
            
    if move_right and not move_left:
        velocity.x = speed
        facing = 1
    elif move_left and not move_right:
        velocity.x = -speed
        facing = -1
    else:
        velocity.x = 0
        
    if state == PlayerState.IDLE:
        state = PlayerState.WALKING
                  
func handle_jump():
    var jump_pressed = Input.is_action_just_pressed("jump")
    
    if not jump_pressed:
        return
    
    # Launch point is player feet
    var launch_point = global_position + Vector2(0, Globals.player_extents.y)
    
    # hook jump
    if [PlayerState.HOOKED, PlayerState.WHIRLING].find(state) > -1:
        jump(launch_point, Vector2(velocity.x, -Globals.initial_jump_velocity * Globals.hook_jump_factor))
        # ground jump
    else:
        jump(launch_point, Vector2(velocity.x, -Globals.initial_jump_velocity))
        
func handle_interact():
    if not interactables.size():
        return
    
    if Input.is_action_pressed("interact"):
        interactables[0].interact(self)
        interactables.remove(0)
        
func handle_throw():
    if throwable and not Input.is_action_pressed("interact"):
        throwable.throw(throw_velocity * Vector2(facing, 1))
        throwable = null
        
        if on_floor:
            state = PlayerState.IDLE
        else:
            state = PlayerState.JUMPING
        
func are_feet_on_floor() -> bool:
    var results = shoot_rays_from_feet()
    
    for r in results:
        if did_ray_hit_floor(r):
            return true
    
    return false
    
func shoot_rays_from_feet():
    var bottom_left = global_position + Vector2(-Globals.player_extents.x, Globals.player_extents.y)
    var bottom_center = global_position + Vector2(0, Globals.player_extents.y)
    var bottom_right = global_position + Globals.player_extents
    
    var space_state = get_world_2d().get_direct_space_state()
    var bot_left_cast_result = space_state.intersect_ray(bottom_left, bottom_left + Vector2(0, 1), [self])
    var bot_center_cast_result = space_state.intersect_ray(bottom_center, bottom_center + Vector2(0, 1), [self])
    var bot_right_cast_result = space_state.intersect_ray(bottom_right, bottom_right + Vector2(0, 1), [self])
    
    return [bot_left_cast_result, bot_center_cast_result, bot_right_cast_result]
        
func did_ray_hit_floor(cast_result) -> bool:
    return cast_result && cast_result["collider"].get_collision_layer() == 4
    
func did_ray_hit_one_way_platform(cast_result) -> bool:
    return cast_result && cast_result["collider"].get_collision_layer() == 16
    
func _on_wall_detector_entered(body):
    #print_debug("enter: " + body.get_name())
    on_wall = true

func _on_wall_detector_exited(body):
    #print_debug("exit: " + body.get_name())
    on_wall = false
    
func _on_rocket_cooldown_timeout():
    rocket_jump_on_cooldown = false
    
func add_on_floor_callback(body):
    on_floor_callback_body_queue.push_back(body)
    
func remove_on_floor_callback(body):
    on_floor_callback_body_queue.erase(body)

func add_off_floor_callback(body):
    off_floor_callback_body_queue.push_back(body)

func remove_off_floor_callback(body):
    off_floor_callback_body_queue.erase(body)

func handle_on_floor_callbacks():
    if on_floor:
        wall_jump_on_cooldown = false
        for c in on_floor_callback_body_queue:
            c.on_floor_callback(self)
            on_floor_callback_body_queue.pop_front()
        
func handle_off_floor_callbacks():
    for c in off_floor_callback_body_queue:
        c.off_floor_callback(self)
        off_floor_callback_body_queue.pop_front()
        
func handle_distance_traveled():
    var distance_traveled = last_position.distance_to(global_position)
    launch_distance_travelled += distance_traveled
    
func kill() -> void:
    # this code relies on the parent node being a room node
    var room = find_parent("Room*")
    room.reset_level()
    
func jump(launch_point: Vector2, velocity: Vector2) -> void:
    self.global_position = Vector2(0, -Globals.player_extents.y) + launch_point
    self.velocity = velocity
    self.state = PlayerState.JUMPING
    self.anchor = null
    self.visible = true
    emit_signal("jumped")

func launch(velocity: Vector2, distance_before_gravity: float) -> void:
    self.velocity = velocity
    self.state = PlayerState.LAUNCHED
    self.anchor = null
    self.visible = true
    self.distance_before_gravity = distance_before_gravity
    self.launch_distance_travelled = 0

func hooked(anchor_point: Vector2) -> void:
    hook_helper(anchor_point, PlayerState.HOOKED)

func whirling(anchor_point: Vector2) -> void:
    hook_helper(anchor_point, PlayerState.WHIRLING)

func hook_helper(anchor_point: Vector2, state) -> void:
    var player_offset = Vector2(0, Globals.player_extents.y / 2)
    self.global_position = anchor_point + player_offset
    self.velocity = Vector2.ZERO
    self.state = state
    self.anchor = null
    self.visible = true
    
func anchored(anchor: Node2D) -> void:
    self.state = PlayerState.ANCHORED
    self.visible = false
    self.anchor = anchor
    
func hold(throwable: Node2D) -> void:
    self.state = PlayerState.HOLDING
    self.throwable = throwable

func _on_InteractionTrigger_body_entered(body):
    self.interactables.append(body)

func _on_InteractionTrigger_body_exited(body):
    self.interactables.erase(body)
